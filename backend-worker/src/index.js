/**
 * ViraNav Marine Worker
 * Cloudflare Worker Proxy for Open-Meteo Marine & Weather APIs with KV 1-Hour Caching
 * and GPX Trip Uploading to Cloudflare R2
 */

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    const origin = request.headers.get("Origin") || "*";

    // CORS preflight response
    if (request.method === "OPTIONS") {
      return new Response(null, {
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
          "Access-Control-Allow-Headers": "Content-Type, Authorization",
        },
      });
    }

    const corsHeaders = {
      "Access-Control-Allow-Origin": "*",
      "Content-Type": "application/json",
    };

    // Route: GET /api/health
    if (url.pathname === "/api/health") {
      return new Response(
        JSON.stringify({ status: "healthy", service: "viranav-marine-worker", timestamp: new Date().toISOString() }),
        { headers: corsHeaders }
      );
    }

    // Route: GET /api/marine?lat=...&lon=...
    if (url.pathname === "/api/marine" || url.pathname === "/marine") {
      const lat = parseFloat(url.searchParams.get("lat") || "0");
      const lon = parseFloat(url.searchParams.get("lon") || "0");

      if (isNaN(lat) || isNaN(lon) || (lat === 0 && lon === 0)) {
        return new Response(
          JSON.stringify({ error: "Missing or invalid lat/lon parameters" }),
          { status: 400, headers: corsHeaders }
        );
      }

      // 1km grid tolerance cache key (rounded to 2 decimal places)
      const latGrid = lat.toFixed(2);
      const lonGrid = lon.toFixed(2);
      const cacheKey = `weather_${latGrid}_${lonGrid}`;

      // Check KV Cache
      if (env.WEATHER_CACHE) {
        try {
          const cached = await env.WEATHER_CACHE.get(cacheKey, "json");
          if (cached) {
            return new Response(
              JSON.stringify({ ...cached, _cached: true, _key: cacheKey }),
              { headers: corsHeaders }
            );
          }
        } catch (e) {
          console.error("KV Cache read error:", e);
        }
      }

      try {
        // Fetch Open-Meteo Marine & Forecast in parallel
        const marineUrl = `https://marine-api.open-meteo.com/v1/marine?latitude=${lat}&longitude=${lon}&current=wave_height,wave_period,wave_direction,ocean_current_velocity,ocean_current_direction&wind_speed_unit=kn`;
        const forecastUrl = `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&current=temperature_2m,relative_humidity_2m,wind_speed_10m,wind_direction_10m,surface_pressure&wind_speed_unit=kn`;

        const [marineRes, forecastRes] = await Promise.all([
          fetch(marineUrl),
          fetch(forecastUrl),
        ]);

        const marineData = marineRes.ok ? await marineRes.json() : null;
        const forecastData = forecastRes.ok ? await forecastRes.json() : null;

        const currentMarine = marineData?.current || {};
        const currentForecast = forecastData?.current || {};

        const windSpeedKn = currentForecast.wind_speed_10m ?? 0;
        const beaufort = calculateBeaufort(windSpeedKn);

        const payload = {
          coordinates: { lat, lon },
          timestamp: new Date().toISOString(),
          atmospheric: {
            temperature: currentForecast.temperature_2m ?? null, // °C
            relativeHumidity: currentForecast.relative_humidity_2m ?? null, // %
            surfacePressure: currentForecast.surface_pressure ?? null, // hPa
            pressureTrendWarning: (currentForecast.surface_pressure ?? 1013) < 1000,
          },
          wind: {
            speedKnots: windSpeedKn,
            directionDeg: currentForecast.wind_direction_10m ?? 0,
            beaufortScale: beaufort.scale,
            beaufortDescription: beaufort.description,
          },
          marine: {
            waveHeightMeters: currentMarine.wave_height ?? 0,
            wavePeriodSeconds: currentMarine.wave_period ?? 0,
            waveDirectionDeg: currentMarine.wave_direction ?? 0,
            currentVelocityKnots: (currentMarine.ocean_current_velocity ?? 0) * 0.539957, // km/h to knots
            currentDirectionDeg: currentMarine.ocean_current_direction ?? 0,
          },
          _cached: false,
        };

        // Cache in KV for 3600 seconds (1 hour)
        if (env.WEATHER_CACHE) {
          try {
            await env.WEATHER_CACHE.put(cacheKey, JSON.stringify(payload), {
              expirationTtl: 3600,
            });
          } catch (e) {
            console.error("KV Cache write error:", e);
          }
        }

        return new Response(JSON.stringify(payload), { headers: corsHeaders });
      } catch (err) {
        return new Response(
          JSON.stringify({ error: "Failed to fetch marine weather", details: err.message }),
          { status: 502, headers: corsHeaders }
        );
      }
    }

    // Route: POST /api/trips/upload
    if (url.pathname === "/api/trips/upload" && request.method === "POST") {
      try {
        const body = await request.json();
        const tripId = body.tripId || `trip_${Date.now()}`;
        const gpxContent = body.gpx;

        if (!gpxContent) {
          return new Response(
            JSON.stringify({ error: "gpx payload is required" }),
            { status: 400, headers: corsHeaders }
          );
        }

        const objectKey = `trips/${tripId}.gpx`;

        if (env.TRIP_BUCKET) {
          await env.TRIP_BUCKET.put(objectKey, gpxContent, {
            httpMetadata: {
              contentType: "application/gpx+xml",
            },
          });
        }

        return new Response(
          JSON.stringify({
            success: true,
            tripId,
            key: objectKey,
            storage: env.TRIP_BUCKET ? "r2" : "mock",
            uploadedAt: new Date().toISOString(),
          }),
          { headers: corsHeaders }
        );
      } catch (err) {
        return new Response(
          JSON.stringify({ error: "Failed to upload trip GPX", details: err.message }),
          { status: 500, headers: corsHeaders }
        );
      }
    }

    return new Response(JSON.stringify({ error: "Not Found" }), { status: 404, headers: corsHeaders });
  },
};

function calculateBeaufort(knots) {
  if (knots < 1) return { scale: 0, description: "Sakin (Calm)" };
  if (knots <= 3) return { scale: 1, description: "Esinti (Light Air)" };
  if (knots <= 6) return { scale: 2, description: "Hafif Rüzgar (Light Breeze)" };
  if (knots <= 10) return { scale: 3, description: "Tatlı Rüzgar (Gentle Breeze)" };
  if (knots <= 16) return { scale: 4, description: "Orta Rüzgar (Moderate Breeze)" };
  if (knots <= 21) return { scale: 5, description: "Sert Rüzgar (Fresh Breeze)" };
  if (knots <= 27) return { scale: 6, description: "Kuvvetli Rüzgar (Strong Breeze)" };
  if (knots <= 33) return { scale: 7, description: "Fırtınamsı Rüzgar (Near Gale)" };
  if (knots <= 40) return { scale: 8, description: "Fırtına (Gale)" };
  if (knots <= 47) return { scale: 9, description: "Kuvvetli Fırtına (Severe Gale)" };
  if (knots <= 55) return { scale: 10, description: "Tam Fırtına (Storm)" };
  if (knots <= 63) return { scale: 11, description: "Çok Şiddetli Fırtına (Violent Storm)" };
  return { scale: 12, description: "Kasırga (Hurricane)" };
}

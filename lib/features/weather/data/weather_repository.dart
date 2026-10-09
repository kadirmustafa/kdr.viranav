import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:viranav/core/models/marine_weather.dart';

class WeatherRepository {
  final http.Client _client;

  WeatherRepository({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches marine & atmospheric weather. First checks Cloudflare Worker proxy (with KV cache),
  /// falling back directly to Open-Meteo if worker is unavailable.
  Future<MarineWeather> getMarineWeather({
    required double lat,
    required double lon,
  }) async {
    final workerBaseUrl = dotenv.env['CLOUDFLARE_WORKER_URL'] ??
        'https://marine-api.viranav.workers.dev';

    try {
      final workerUri = Uri.parse('$workerBaseUrl/api/marine?lat=$lat&lon=$lon');
      final response = await _client.get(workerUri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MarineWeather.fromJson(data);
      }
    } catch (_) {
      // Fallback: query Open-Meteo directly if worker is not yet deployed or unreachable
      try {
        return await _fetchDirectOpenMeteo(lat, lon);
      } catch (e) {
        // Safe offline maritime fallback
        return MarineWeather.defaultDummy(lat, lon);
      }
    }

    return await _fetchDirectOpenMeteo(lat, lon);
  }

  Future<MarineWeather> _fetchDirectOpenMeteo(double lat, double lon) async {
    final marineUrl =
        'https://marine-api.open-meteo.com/v1/marine?latitude=$lat&longitude=$lon&current=wave_height,wave_period,wave_direction,ocean_current_velocity,ocean_current_direction&wind_speed_unit=kn';
    final forecastUrl =
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,wind_speed_10m,wind_direction_10m,surface_pressure&wind_speed_unit=kn';

    final marineRes = await _client.get(Uri.parse(marineUrl)).timeout(const Duration(seconds: 6));
    final forecastRes = await _client.get(Uri.parse(forecastUrl)).timeout(const Duration(seconds: 6));

    final marineJson = marineRes.statusCode == 200 ? jsonDecode(marineRes.body) : {};
    final forecastJson = forecastRes.statusCode == 200 ? jsonDecode(forecastRes.body) : {};

    final curMarine = (marineJson['current'] as Map<String, dynamic>?) ?? {};
    final curForecast = (forecastJson['current'] as Map<String, dynamic>?) ?? {};

    final windSpeedKn = (curForecast['wind_speed_10m'] as num?)?.toDouble() ?? 10.0;
    final beaufort = _calcBeaufort(windSpeedKn);

    return MarineWeather(
      lat: lat,
      lon: lon,
      timestamp: DateTime.now(),
      temperature: (curForecast['temperature_2m'] as num?)?.toDouble() ?? 20.0,
      relativeHumidity: (curForecast['relative_humidity_2m'] as num?)?.toInt() ?? 70,
      surfacePressure: (curForecast['surface_pressure'] as num?)?.toDouble() ?? 1013.0,
      pressureTrendWarning: ((curForecast['surface_pressure'] as num?)?.toDouble() ?? 1013.0) < 1000.0,
      windSpeedKnots: windSpeedKn,
      windDirectionDeg: (curForecast['wind_direction_10m'] as num?)?.toDouble() ?? 0.0,
      beaufortScale: beaufort['scale'] as int,
      beaufortDescription: beaufort['desc'] as String,
      waveHeightMeters: (curMarine['wave_height'] as num?)?.toDouble() ?? 0.5,
      wavePeriodSeconds: (curMarine['wave_period'] as num?)?.toDouble() ?? 4.5,
      waveDirectionDeg: (curMarine['wave_direction'] as num?)?.toDouble() ?? 0.0,
      currentVelocityKnots: ((curMarine['ocean_current_velocity'] as num?)?.toDouble() ?? 0.0) * 0.539957,
      currentDirectionDeg: (curMarine['ocean_current_direction'] as num?)?.toDouble() ?? 0.0,
      isCached: false,
    );
  }

  Map<String, dynamic> _calcBeaufort(double knots) {
    if (knots < 1) return {'scale': 0, 'desc': 'Sakin (Calm)'};
    if (knots <= 3) return {'scale': 1, 'desc': 'Esinti (Light Air)'};
    if (knots <= 6) return {'scale': 2, 'desc': 'Hafif Rüzgar (Light Breeze)'};
    if (knots <= 10) return {'scale': 3, 'desc': 'Tatlı Rüzgar (Gentle Breeze)'};
    if (knots <= 16) return {'scale': 4, 'desc': 'Orta Rüzgar (Moderate Breeze)'};
    if (knots <= 21) return {'scale': 5, 'desc': 'Sert Rüzgar (Fresh Breeze)'};
    if (knots <= 27) return {'scale': 6, 'desc': 'Kuvvetli Rüzgar (Strong Breeze)'};
    if (knots <= 33) return {'scale': 7, 'desc': 'Fırtınamsı (Near Gale)'};
    if (knots <= 40) return {'scale': 8, 'desc': 'Fırtına (Gale)'};
    if (knots <= 47) return {'scale': 9, 'desc': 'Kuvvetli Fırtına (Severe Gale)'};
    return {'scale': 10, 'desc': 'Tam Fırtına (Storm)'};
  }
}

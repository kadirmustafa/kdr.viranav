import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:viranav/core/theme/theme_provider.dart';
import 'package:viranav/core/theme/app_theme.dart';
import 'package:viranav/core/providers/navigation_providers.dart';
import 'widgets/wind_rose_widget.dart';
import 'widgets/hud_data_tile.dart';
import 'widgets/barometer_card.dart';

class CockpitScreen extends ConsumerStatefulWidget {
  const CockpitScreen({super.key});

  @override
  ConsumerState<CockpitScreen> createState() => _CockpitScreenState();
}

class _CockpitScreenState extends ConsumerState<CockpitScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final isNightVision = themeMode == NavThemeMode.nightVisionRed;

    final vessel = ref.watch(vesselProvider);
    final trackingState = ref.watch(trackingStateStreamProvider).value ??
        ref.read(trackingServiceProvider).currentState;
    final headingDeg = ref.watch(compassHeadingStreamProvider).value ?? 0.0;

    // Use current GPS or fallback to Mediterranean Aegean sea coordinates (Bodrum / Gökova Gulf)
    final lat = trackingState.lastPosition?.latitude ?? 37.0344;
    final lon = trackingState.lastPosition?.longitude ?? 27.4305;

    final weatherAsync = ref.watch(marineWeatherProvider(WeatherCoords(lat, lon)));
    final weather = weatherAsync.value;

    final sog = trackingState.currentSogKnots;
    final cog = trackingState.currentCogDeg;
    final twd = weather?.windDirectionDeg ?? 65.0;
    final tws = weather?.windSpeedKnots ?? 14.0;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.directions_boat_filled,
              color: isNightVision ? AppTheme.nightRedPrimary : AppTheme.neonCyan,
              size: 22,
            ),
            const SizedBox(width: 8),
            const Text('VIRANAV KOKPİT'),
          ],
        ),
        actions: [
          // Night Vision Toggle Button
          IconButton(
            tooltip: 'Gece Modu (Night Vision)',
            icon: Icon(
              Icons.remove_red_eye,
              color: isNightVision ? AppTheme.nightRedPrimary : Colors.white70,
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleNightVision();
            },
          ),
          IconButton(
            tooltip: 'Tekne Türü',
            icon: Icon(
              vessel.isSailboat ? Icons.sailing : Icons.directions_boat,
              color: isNightVision ? AppTheme.nightRedPrimary : AppTheme.neonCyan,
            ),
            onPressed: () {
              ref.read(vesselProvider.notifier).toggleType();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Aktif Tekne: ${vessel.isSailboat ? "Motor Yat Modu" : "Yelkenli Modu"}',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          children: [
            // Active Trip Status Ribbon
            if (trackingState.isTracking)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: (isNightVision ? AppTheme.nightRedPrimary : AppTheme.successGreen)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isNightVision ? AppTheme.nightRedPrimary : AppTheme.successGreen,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isNightVision ? AppTheme.nightRedPrimary : AppTheme.successGreen,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'SEYİR KAYDI AKTİF: ${trackingState.currentTrip?.title ?? "Seyir"} (${trackingState.pointsLogged} GPS noktası)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isNightVision ? AppTheme.nightRedPrimary : AppTheme.successGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // PRIMARY NAVIGATION HUD (SOG, HDG, COG, TWS)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.6,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                HudDataTile(
                  label: 'Yer Hızı (SOG)',
                  value: sog.toStringAsFixed(1),
                  unit: 'KTS',
                  icon: Icons.speed,
                  subtitle: sog > 0.5 ? 'Seyir Hali' : 'Demirde / Rıhtımda',
                ),
                HudDataTile(
                  label: 'Pusula Açısı (HDG)',
                  value: '${headingDeg.round()}°',
                  unit: 'MAG',
                  icon: Icons.explore,
                  subtitle: _headingCardinal(headingDeg),
                ),
                HudDataTile(
                  label: 'Rota Açısı (COG)',
                  value: '${cog.round()}°',
                  unit: 'TRUE',
                  icon: Icons.navigation_outlined,
                  subtitle: 'GPS İz Rotası',
                ),
                HudDataTile(
                  label: 'Gerçek Rüzgar (TWS)',
                  value: tws.toStringAsFixed(1),
                  unit: 'KTS',
                  icon: Icons.air,
                  subtitle: 'Bft: ${weather?.beaufortScale ?? 4} - ${weather?.beaufortDescription ?? "Orta Rüzgar"}',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // WIND ROSE (RÜZGAR GÜLÜ & TACK GÖSTERGESİ)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'RÜZGAR GÜLÜ & TRAMOLA (TACK) GÖSTERGESİ',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: isNightVision ? AppTheme.nightRedPrimary : AppTheme.neonCyan,
                          ),
                        ),
                        Text(
                          vessel.isSailboat ? '±${vessel.noGoZoneAngle.round()}° Kör Açı' : 'Motor Yat',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 250,
                      child: WindRoseWidget(
                        headingDeg: headingDeg,
                        windDirectionDeg: twwdCorrected(twd),
                        windSpeedKnots: tws,
                        noGoZoneAngle: vessel.isSailboat ? vessel.noGoZoneAngle : 0.0,
                        isNightVision: isNightVision,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _legendDot(const Color(0xFFFF3B30), 'No-Go Zone (Kör Nokta)'),
                        const SizedBox(width: 16),
                        _legendDot(
                          isNightVision ? AppTheme.nightRedPrimary : AppTheme.neonCyan,
                          'En İyi Tramola Açısı',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // OCEANOGRAPHY & WAVES HUD (Hs, Tp, Akıntı)
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.15,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                HudDataTile(
                  label: 'Dalga Boyu',
                  value: (weather?.waveHeightMeters ?? 0.8).toStringAsFixed(1),
                  unit: 'M',
                  icon: Icons.waves,
                  subtitle: 'Hs Belirgin',
                ),
                HudDataTile(
                  label: 'Dalga Periyodu',
                  value: (weather?.wavePeriodSeconds ?? 5.5).toStringAsFixed(1),
                  unit: 'SN',
                  icon: Icons.timer_outlined,
                  subtitle: 'Tp Periyot',
                ),
                HudDataTile(
                  label: 'Yüzey Akıntısı',
                  value: (weather?.currentVelocityKnots ?? 0.4).toStringAsFixed(1),
                  unit: 'KTS',
                  icon: Icons.water,
                  subtitle: '${(weather?.currentDirectionDeg ?? 180).round()}° Yön',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // BAROMETRIC PRESSURE & STORM PREDICTION
            BarometerCard(
              pressureHpa: weather?.surfacePressure ?? 1013.2,
              temperatureC: weather?.temperature ?? 22.4,
              humidityPercent: weather?.relativeHumidity ?? 68,
              hasStormWarning: weather?.pressureTrendWarning ?? false,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  double twwdCorrected(double deg) => (deg % 360.0);

  Widget _legendDot(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  String _headingCardinal(double deg) {
    final d = (deg % 360 + 360) % 360;
    if (d >= 337.5 || d < 22.5) return 'Kuzey (N)';
    if (d >= 22.5 && d < 67.5) return 'Kuzeydoğu (NE)';
    if (d >= 67.5 && d < 112.5) return 'Doğu (E)';
    if (d >= 112.5 && d < 157.5) return 'Güneydoğu (SE)';
    if (d >= 157.5 && d < 202.5) return 'Güney (S)';
    if (d >= 202.5 && d < 247.5) return 'Güneybatı (SW)';
    if (d >= 247.5 && d < 292.5) return 'Batı (W)';
    return 'Kuzeybatı (NW)';
  }
}

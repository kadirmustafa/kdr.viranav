import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:viranav/core/theme/theme_provider.dart';
import 'package:viranav/core/theme/app_theme.dart';
import 'package:viranav/core/localization/app_localizations.dart';
import 'package:viranav/core/providers/navigation_providers.dart';
import 'widgets/wind_rose_widget.dart';
import 'widgets/hud_data_tile.dart';
import 'widgets/barometer_card.dart';
import 'widgets/metric_detail_sheet.dart';

class CockpitScreen extends ConsumerStatefulWidget {
  const CockpitScreen({super.key});

  @override
  ConsumerState<CockpitScreen> createState() => _CockpitScreenState();
}

class _CockpitScreenState extends ConsumerState<CockpitScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = ref.watch(stringsProvider);
    final isNightVision = ref.watch(isNightVisionProvider);

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
    final waveHs = weather?.waveHeightMeters ?? 0.8;
    final waveTp = weather?.wavePeriodSeconds ?? 5.5;
    final currentKnots = weather?.currentVelocityKnots ?? 0.4;
    final currentDeg = weather?.currentDirectionDeg ?? 180.0;
    final pressureHpa = weather?.surfacePressure ?? 1013.2;
    final tempC = weather?.temperature ?? 22.4;
    final humidityPct = weather?.relativeHumidity ?? 68;

    final primaryAccent = isNightVision ? AppTheme.nightRedPrimary : AppTheme.neonCyan;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.directions_boat_filled,
              color: primaryAccent,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(s.cockpitTitle),
          ],
        ),
        actions: [
          // Night Vision Toggle Button
          IconButton(
            tooltip: 'Night Vision',
            icon: Icon(
              Icons.remove_red_eye,
              color: isNightVision ? AppTheme.nightRedPrimary : Colors.white70,
            ),
            onPressed: () {
              ref.read(themeSelectionProvider.notifier).toggleNightVision();
            },
          ),
          IconButton(
            tooltip: s.vesselType,
            icon: Icon(
              vessel.isSailboat ? Icons.sailing : Icons.directions_boat,
              color: primaryAccent,
            ),
            onPressed: () {
              ref.read(vesselProvider.notifier).toggleType();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${s.vesselType}: ${vessel.isSailboat ? s.motorYachtMode : s.sailboatMode}',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            // LOCATION & MARINE WEATHER HEADER BANNER
            _buildLocationWeatherBanner(
              context: context,
              lat: lat,
              lon: lon,
              tempC: tempC,
              humidityPct: humidityPct,
              tws: tws,
              isNightVision: isNightVision,
              strings: s,
            ),

            const SizedBox(height: 10),

            // Active Trip Status Ribbon
            if (trackingState.isTracking)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        '${s.activeTripRibbon}: ${trackingState.currentTrip?.title ?? "Voyage"} (${trackingState.pointsLogged} ${s.pointsCountLabel})',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isNightVision ? AppTheme.nightRedPrimary : AppTheme.successGreen,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
              childAspectRatio: 1.65,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                HudDataTile(
                  label: s.sogLabel,
                  value: sog.toStringAsFixed(1),
                  unit: s.knotsUnit,
                  icon: Icons.speed,
                  subtitle: sog > 0.5 ? s.underWay : s.anchoredMoored,
                  onTap: () => MetricDetailSheet.show(
                    context,
                    type: MetricType.sog,
                    value: sog,
                    strings: s,
                    isNightVision: isNightVision,
                  ),
                ),
                HudDataTile(
                  label: s.hdgLabel,
                  value: '${headingDeg.round()}°',
                  unit: 'MAG',
                  icon: Icons.explore,
                  subtitle: '${_headingCardinal(headingDeg)} • Pusula',
                  onTap: () => MetricDetailSheet.show(
                    context,
                    type: MetricType.hdg,
                    value: headingDeg,
                    strings: s,
                    isNightVision: isNightVision,
                  ),
                ),
                HudDataTile(
                  label: s.cogLabel,
                  value: '${cog.round()}°',
                  unit: 'TRUE',
                  icon: Icons.navigation_outlined,
                  subtitle: s.trueCourse,
                  onTap: () => MetricDetailSheet.show(
                    context,
                    type: MetricType.cog,
                    value: cog,
                    strings: s,
                    isNightVision: isNightVision,
                  ),
                ),
                HudDataTile(
                  label: s.twsLabel,
                  value: tws.toStringAsFixed(1),
                  unit: s.knotsUnit,
                  icon: Icons.air,
                  subtitle: 'Bft: ${weather?.beaufortScale ?? 4} - ${weather?.beaufortDescription ?? "Rüzgar"}',
                  onTap: () => MetricDetailSheet.show(
                    context,
                    type: MetricType.wind,
                    value: tws,
                    secondaryValue: twd,
                    strings: s,
                    isNightVision: isNightVision,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // WIND ROSE (RÜZGAR GÜLÜ & TACK GÖSTERGESİ & PUSULA)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          s.windRoseTitle,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: primaryAccent,
                          ),
                        ),
                        Text(
                          vessel.isSailboat ? '±${vessel.noGoZoneAngle.round()}° Kör Açı' : s.motorYachtMode,
                          style: TextStyle(
                            fontSize: 10.5,
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
                        _legendDot(const Color(0xFFFF3B30), s.noGoZone),
                        const SizedBox(width: 14),
                        _legendDot(
                          primaryAccent,
                          s.optimumTack,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // OCEANOGRAPHY & WAVES HUD (Hs, Tp, Akıntı)
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.15,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                HudDataTile(
                  label: s.waveHeight,
                  value: waveHs.toStringAsFixed(1),
                  unit: 'M',
                  icon: Icons.waves,
                  subtitle: s.significantHs,
                  onTap: () => MetricDetailSheet.show(
                    context,
                    type: MetricType.waveHeight,
                    value: waveHs,
                    strings: s,
                    isNightVision: isNightVision,
                  ),
                ),
                HudDataTile(
                  label: s.wavePeriod,
                  value: waveTp.toStringAsFixed(1),
                  unit: 'SN',
                  icon: Icons.timer_outlined,
                  subtitle: s.waveSec,
                  onTap: () => MetricDetailSheet.show(
                    context,
                    type: MetricType.wavePeriod,
                    value: waveTp,
                    strings: s,
                    isNightVision: isNightVision,
                  ),
                ),
                HudDataTile(
                  label: s.surfaceCurrent,
                  value: currentKnots.toStringAsFixed(1),
                  unit: s.knotsUnit,
                  icon: Icons.water,
                  subtitle: '${currentDeg.round()}° Yön',
                  onTap: () => MetricDetailSheet.show(
                    context,
                    type: MetricType.current,
                    value: currentKnots,
                    secondaryValue: currentDeg,
                    strings: s,
                    isNightVision: isNightVision,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // BAROMETRIC PRESSURE & STORM PREDICTION
            BarometerCard(
              pressureHpa: pressureHpa,
              temperatureC: tempC,
              humidityPercent: humidityPct,
              hasStormWarning: weather?.pressureTrendWarning ?? false,
              strings: s,
              isNightVision: isNightVision,
              onTapMetric: (metricKey) {
                if (metricKey == 'pressure') {
                  MetricDetailSheet.show(
                    context,
                    type: MetricType.pressure,
                    value: pressureHpa,
                    strings: s,
                    isNightVision: isNightVision,
                  );
                } else if (metricKey == 'temperature') {
                  MetricDetailSheet.show(
                    context,
                    type: MetricType.temperature,
                    value: tempC,
                    strings: s,
                    isNightVision: isNightVision,
                  );
                } else if (metricKey == 'humidity') {
                  MetricDetailSheet.show(
                    context,
                    type: MetricType.humidity,
                    value: humidityPct.toDouble(),
                    strings: s,
                    isNightVision: isNightVision,
                  );
                }
              },
            ),

            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationWeatherBanner({
    required BuildContext context,
    required double lat,
    required double lon,
    required double tempC,
    required int humidityPct,
    required double tws,
    required bool isNightVision,
    required AppStrings strings,
  }) {
    final theme = Theme.of(context);
    final coordStr = '${lat.toStringAsFixed(4)}°N, ${lon.toStringAsFixed(4)}°E';

    return InkWell(
      onTap: () => MetricDetailSheet.show(
        context,
        type: MetricType.location,
        value: lat,
        secondaryValue: lon,
        stringValue: coordStr,
        strings: strings,
        isNightVision: isNightVision,
      ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: theme.cardTheme.color ?? theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: (isNightVision ? AppTheme.nightRedPrimary : AppTheme.neonCyan).withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: isNightVision ? AppTheme.nightRedPrimary : AppTheme.neonCyan,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.locationGps,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isNightVision ? AppTheme.nightRedPrimary : AppTheme.neonCyan,
                      ),
                    ),
                    Text(
                      coordStr,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Icon(
                  Icons.wb_sunny_outlined,
                  size: 18,
                  color: Colors.amber.shade400,
                ),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${tempC.toStringAsFixed(1)}°C',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Nem: $humidityPct%  •  ${tws.toStringAsFixed(0)} kn',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
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
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 9.5)),
      ],
    );
  }

  String _headingCardinal(double deg) {
    final d = (deg % 360 + 360) % 360;
    if (d >= 337.5 || d < 22.5) return 'N (Kuzey)';
    if (d >= 22.5 && d < 67.5) return 'NE (Kuzeydoğu)';
    if (d >= 67.5 && d < 112.5) return 'E (Doğu)';
    if (d >= 112.5 && d < 157.5) return 'SE (Güneydoğu)';
    if (d >= 157.5 && d < 202.5) return 'S (Güney)';
    if (d >= 202.5 && d < 247.5) return 'SW (Güneybatı)';
    if (d >= 247.5 && d < 292.5) return 'W (Batı)';
    return 'NW (Kuzeybatı)';
  }
}

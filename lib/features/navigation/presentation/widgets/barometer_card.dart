import 'package:flutter/material.dart';
import 'package:viranav/core/localization/app_localizations.dart';

class BarometerCard extends StatelessWidget {
  final double pressureHpa;
  final double temperatureC;
  final int humidityPercent;
  final bool hasStormWarning;
  final AppStrings strings;
  final bool isNightVision;
  final void Function(String metricKey)? onTapMetric;

  const BarometerCard({
    super.key,
    required this.pressureHpa,
    required this.temperatureC,
    required this.humidityPercent,
    required this.hasStormWarning,
    required this.strings,
    this.isNightVision = false,
    this.onTapMetric,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAlert = hasStormWarning || pressureHpa < 1000.0;
    final primaryColor = isNightVision
        ? const Color(0xFFFF3B30)
        : (isAlert ? theme.colorScheme.error : theme.colorScheme.primary);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAlert ? theme.colorScheme.error : primaryColor.withValues(alpha: 0.25),
          width: isAlert ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.speed,
                    size: 18,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    strings.barometerTitle,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isAlert ? theme.colorScheme.error : primaryColor).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  pressureHpa > 1013 ? '1013+ hPa' : (pressureHpa < 1005 ? '<1005 hPa' : 'Kararlı'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                onTap: () => onTapMetric?.call('pressure'),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: _buildAtmosphereMetric(
                    context,
                    title: strings.pressureLabel,
                    value: pressureHpa.toStringAsFixed(1),
                    unit: 'hPa',
                    icon: Icons.compress,
                    primaryColor: primaryColor,
                  ),
                ),
              ),
              Container(
                height: 36,
                width: 1,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
              ),
              InkWell(
                onTap: () => onTapMetric?.call('temperature'),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: _buildAtmosphereMetric(
                    context,
                    title: strings.tempLabel,
                    value: temperatureC.toStringAsFixed(1),
                    unit: '°C',
                    icon: Icons.thermostat,
                    primaryColor: primaryColor,
                  ),
                ),
              ),
              Container(
                height: 36,
                width: 1,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
              ),
              InkWell(
                onTap: () => onTapMetric?.call('humidity'),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: _buildAtmosphereMetric(
                    context,
                    title: strings.humidityLabel,
                    value: '$humidityPercent',
                    unit: '%',
                    icon: Icons.water_drop_outlined,
                    primaryColor: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          if (isAlert) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 16, color: theme.colorScheme.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      strings.stormWarningDesc,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAtmosphereMetric(
    BuildContext context, {
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color primaryColor,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: TextStyle(
                fontSize: 10,
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

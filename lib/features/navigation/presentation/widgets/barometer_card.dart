import 'package:flutter/material.dart';

class BarometerCard extends StatelessWidget {
  final double pressureHpa;
  final double temperatureC;
  final int humidityPercent;
  final bool hasStormWarning;

  const BarometerCard({
    super.key,
    required this.pressureHpa,
    required this.temperatureC,
    required this.humidityPercent,
    required this.hasStormWarning,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAlert = hasStormWarning || pressureHpa < 1000.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAlert ? theme.colorScheme.error : theme.colorScheme.primary.withValues(alpha: 0.2),
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
                    color: isAlert ? theme.colorScheme.error : theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'BAROMETRİK BASINÇ & ATMOSFER',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: isAlert ? theme.colorScheme.error : theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isAlert ? theme.colorScheme.error : theme.colorScheme.primary)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  pressureHpa > 1013 ? 'Yüksek Basınç' : (pressureHpa < 1005 ? 'Alçak Basınç' : 'Normal'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isAlert ? theme.colorScheme.error : theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAtmosphereMetric(
                context,
                title: 'Basınç',
                value: pressureHpa.toStringAsFixed(1),
                unit: 'hPa',
                icon: Icons.compress,
              ),
              Container(
                height: 36,
                width: 1,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
              _buildAtmosphereMetric(
                context,
                title: 'Sıcaklık',
                value: temperatureC.toStringAsFixed(1),
                unit: '°C',
                icon: Icons.thermostat,
              ),
              Container(
                height: 36,
                width: 1,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
              _buildAtmosphereMetric(
                context,
                title: 'Nem',
                value: '$humidityPercent',
                unit: '%',
                icon: Icons.water_drop_outlined,
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
                      'Fırtına Habercisi: Kritik barometrik basınç düşüşü algılandı!',
                      style: TextStyle(
                        fontSize: 11,
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
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

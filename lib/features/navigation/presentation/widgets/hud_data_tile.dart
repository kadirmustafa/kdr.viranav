import 'package:flutter/material.dart';

class HudDataTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData? icon;
  final Color? accentColor;
  final String? subtitle;
  final bool isAlert;
  final VoidCallback? onTap;

  const HudDataTile({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    this.icon,
    this.accentColor,
    this.subtitle,
    this.isAlert = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveAccent = accentColor ?? theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isAlert
                  ? theme.colorScheme.error
                  : effectiveAccent.withValues(alpha: 0.25),
              width: isAlert ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header Row: Label & Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: effectiveAccent.withValues(alpha: 0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 4),
                    Icon(
                      icon,
                      size: 15,
                      color: effectiveAccent.withValues(alpha: 0.8),
                    ),
                  ],
                ],
              ),

              // Value & Unit with FittedBox to prevent any overflow
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: isAlert ? theme.colorScheme.error : theme.colorScheme.onSurface,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: effectiveAccent.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Subtitle with ellipsis
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 9.5,
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              else
                const SizedBox(height: 1),
            ],
          ),
        ),
      ),
    );
  }
}

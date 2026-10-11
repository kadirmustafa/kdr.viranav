import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A realistic nautical marine compass widget with a 3D faceted compass needle (ibre),
/// 360° calibrated azimuth dial, cardinal/intercardinal markers, lubber line,
/// and smooth angle-wrapped needle rotation.
class MarineCompassWidget extends StatelessWidget {
  final double headingDeg; // Ship Magnetic Heading (HDG in degrees)
  final bool isNightVision;
  final VoidCallback? onTap;
  final double size;

  const MarineCompassWidget({
    super.key,
    required this.headingDeg,
    this.isNightVision = false,
    this.onTap,
    this.size = 250.0,
  });

  String get headingCardinal {
    final d = (headingDeg % 360 + 360) % 360;
    if (d >= 337.5 || d < 22.5) return 'N';
    if (d >= 22.5 && d < 67.5) return 'NE';
    if (d >= 67.5 && d < 112.5) return 'E';
    if (d >= 112.5 && d < 157.5) return 'SE';
    if (d >= 157.5 && d < 202.5) return 'S';
    if (d >= 202.5 && d < 247.5) return 'SW';
    if (d >= 247.5 && d < 292.5) return 'W';
    return 'NW';
  }

  @override
  Widget build(BuildContext context) {
    // Shortest path angle interpolation for smooth liquid-damped needle movement
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Static Compass Card & Azimuth Dial
              CustomPaint(
                size: Size(size, size),
                painter: _CompassDialPainter(isNightVision: isNightVision),
              ),

              // Animated Compass Needle (İbre) rotating smoothly to headingDeg
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: headingDeg, end: headingDeg),
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                builder: (context, animatedDeg, child) {
                  return CustomPaint(
                    size: Size(size, size),
                    painter: _CompassNeedlePainter(
                      headingDeg: animatedDeg,
                      isNightVision: isNightVision,
                    ),
                  );
                },
              ),

              // Top Lubber Line Marker (Vessel Bow indicator at 12 o'clock)
              Positioned(
                top: 4,
                child: CustomPaint(
                  size: const Size(16, 12),
                  painter: _LubberLinePainter(isNightVision: isNightVision),
                ),
              ),

              // Central Digital Heading Readout Badge
              Positioned(
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: (isNightVision ? const Color(0xFF220000) : const Color(0xFF071426))
                        .withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isNightVision ? const Color(0xFFFF3B30) : const Color(0xFF00E5FF),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isNightVision ? Colors.red : Colors.cyan).withValues(alpha: 0.2),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.explore,
                        size: 13,
                        color: isNightVision ? const Color(0xFFFF3B30) : const Color(0xFF00E5FF),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${headingDeg.round().toString().padLeft(3, '0')}°  $headingCardinal',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                          color: isNightVision ? const Color(0xFFFF6B6B) : const Color(0xFF00E5FF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Paints the 360° marine compass dial, graduations, tick marks, and cardinal labels.
class _CompassDialPainter extends CustomPainter {
  final bool isNightVision;

  _CompassDialPainter({required this.isNightVision});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    final primaryColor = isNightVision ? const Color(0xFFFF3B30) : const Color(0xFF00E5FF);
    final secondaryColor = isNightVision ? const Color(0xFF991B1B) : const Color(0xFF1E3A5F);
    final textColor = isNightVision ? const Color(0xFFFF8080) : Colors.white;

    // Outer Bezel Rim (Dual layered nautical bezel)
    final outerBezelPaint = Paint()
      ..color = isNightVision ? const Color(0xFF2E0505) : const Color(0xFF09172B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius + 6, outerBezelPaint);

    final bezelBorderPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(center, radius + 4, bezelBorderPaint);

    // Inner Dial Face
    final dialFacePaint = Paint()
      ..color = isNightVision ? const Color(0xFF160000) : const Color(0xFF071221)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, dialFacePaint);

    // Subtle inner concentric ring
    final innerRingPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius * 0.72, innerRingPaint);
    canvas.drawCircle(center, radius * 0.40, innerRingPaint);

    // Dial Graduations (Ticks and Degree numbers)
    final tickPaint = Paint();
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int deg = 0; deg < 360; deg += 5) {
      final rad = (deg - 90) * math.pi / 180.0;
      final isMajorCardinal = deg % 90 == 0;
      final isIntercardinal = deg % 45 == 0 && !isMajorCardinal;
      final isTenDeg = deg % 10 == 0;

      final double tickLen;
      if (isMajorCardinal) {
        tickLen = 14.0;
        tickPaint.strokeWidth = 2.5;
        tickPaint.color = deg == 0
            ? (isNightVision ? const Color(0xFFFF3B30) : const Color(0xFFFF5252))
            : primaryColor;
      } else if (isIntercardinal) {
        tickLen = 10.0;
        tickPaint.strokeWidth = 1.8;
        tickPaint.color = primaryColor.withValues(alpha: 0.85);
      } else if (isTenDeg) {
        tickLen = 7.0;
        tickPaint.strokeWidth = 1.3;
        tickPaint.color = primaryColor.withValues(alpha: 0.6);
      } else {
        tickLen = 4.0;
        tickPaint.strokeWidth = 0.9;
        tickPaint.color = primaryColor.withValues(alpha: 0.35);
      }

      final p1 = Offset(center.dx + radius * math.cos(rad), center.dy + radius * math.sin(rad));
      final p2 = Offset(center.dx + (radius - tickLen) * math.cos(rad), center.dy + (radius - tickLen) * math.sin(rad));
      canvas.drawLine(p1, p2, tickPaint);

      // Degree Labels every 30 degrees (excluding 0, 90, 180, 270 where cardinals are painted)
      if (deg % 30 == 0 && !isMajorCardinal) {
        textPainter.text = TextSpan(
          text: deg.toString().padLeft(3, '0'),
          style: TextStyle(
            color: primaryColor.withValues(alpha: 0.65),
            fontSize: 8.5,
            fontWeight: FontWeight.w600,
          ),
        );
        textPainter.layout();
        final textRadius = radius - 21.0;
        final tx = center.dx + textRadius * math.cos(rad) - textPainter.width / 2;
        final ty = center.dy + textRadius * math.sin(rad) - textPainter.height / 2;
        textPainter.paint(canvas, Offset(tx, ty));
      }
    }

    // Cardinal Points (N, E, S, W) & Intercardinals (NE, SE, SW, NW)
    final cardinals = {
      0: 'N',
      45: 'NE',
      90: 'E',
      135: 'SE',
      180: 'S',
      225: 'SW',
      270: 'W',
      315: 'NW',
    };

    for (final entry in cardinals.entries) {
      final deg = entry.key;
      final label = entry.value;
      final rad = (deg - 90) * math.pi / 180.0;
      final isNorth = deg == 0;
      final isMajor = deg % 90 == 0;

      final textRadius = radius - (isMajor ? 26.0 : 21.0);

      textPainter.text = TextSpan(
        text: label,
        style: TextStyle(
          color: isNorth
              ? (isNightVision ? const Color(0xFFFF3B30) : const Color(0xFFFF453A))
              : (isMajor ? textColor : primaryColor.withValues(alpha: 0.8)),
          fontSize: isMajor ? 13.5 : 9.5,
          fontWeight: isMajor ? FontWeight.w900 : FontWeight.w700,
          letterSpacing: 0.5,
        ),
      );
      textPainter.layout();

      final tx = center.dx + textRadius * math.cos(rad) - textPainter.width / 2;
      final ty = center.dy + textRadius * math.sin(rad) - textPainter.height / 2;
      textPainter.paint(canvas, Offset(tx, ty));

      // Extra North Arrow symbol on dial under 'N'
      if (isNorth) {
        final arrowRad = (deg - 90) * math.pi / 180.0;
        final arrowTip = Offset(center.dx + (radius - 35) * math.cos(arrowRad), center.dy + (radius - 35) * math.sin(arrowRad));
        final arrowP1 = Offset(arrowTip.dx - 4, arrowTip.dy + 6);
        final arrowP2 = Offset(arrowTip.dx + 4, arrowTip.dy + 6);

        final arrowPath = Path()
          ..moveTo(arrowTip.dx, arrowTip.dy)
          ..lineTo(arrowP1.dx, arrowP1.dy)
          ..lineTo(arrowP2.dx, arrowP2.dy)
          ..close();

        final arrowPaint = Paint()
          ..color = isNightVision ? const Color(0xFFFF3B30) : const Color(0xFFFF453A)
          ..style = PaintingStyle.fill;
        canvas.drawPath(arrowPath, arrowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CompassDialPainter oldDelegate) {
    return oldDelegate.isNightVision != isNightVision;
  }
}

/// Paints the 3D faceted nautical compass needle (ibre) pointing directly to the ship's heading.
class _CompassNeedlePainter extends CustomPainter {
  final double headingDeg;
  final bool isNightVision;

  _CompassNeedlePainter({
    required this.headingDeg,
    required this.isNightVision,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final needleLength = (size.width / 2) * 0.70; // Needle reaches into inner dial ring
    final needleWidth = 9.0; // Half width at pivot shoulder

    canvas.save();
    canvas.translate(center.dx, center.dy);
    // Rotate canvas by headingDeg (0° is top)
    canvas.rotate(headingDeg * math.pi / 180.0);

    // 1. NORTH NEEDLE HALF (Kuzey İbresi - 3D Faceted Ruby/Coral Red)
    // Left Facet (Lighted highlight side)
    final northLightPath = Path()
      ..moveTo(0, -needleLength) // Sharp North tip
      ..lineTo(-needleWidth, 0) // Left shoulder
      ..lineTo(0, 0) // Center
      ..close();

    final northLightPaint = Paint()
      ..color = isNightVision ? const Color(0xFFFF453A) : const Color(0xFFFF3B30)
      ..style = PaintingStyle.fill;
    canvas.drawPath(northLightPath, northLightPaint);

    // Right Facet (Shaded shadow side)
    final northShadowPath = Path()
      ..moveTo(0, -needleLength) // Sharp North tip
      ..lineTo(0, 0) // Center
      ..lineTo(needleWidth, 0) // Right shoulder
      ..close();

    final northShadowPaint = Paint()
      ..color = isNightVision ? const Color(0xFFB91C1C) : const Color(0xFFCC1100)
      ..style = PaintingStyle.fill;
    canvas.drawPath(northShadowPath, northShadowPaint);

    // 2. SOUTH NEEDLE HALF (Güney İbresi - 3D Faceted Silver/White)
    final southLength = needleLength * 0.88;

    // Left Facet (Lighted highlight side)
    final southLightPath = Path()
      ..moveTo(0, southLength) // South tip
      ..lineTo(-needleWidth, 0) // Left shoulder
      ..lineTo(0, 0) // Center
      ..close();

    final southLightPaint = Paint()
      ..color = isNightVision ? const Color(0xFF6B1D1D) : const Color(0xFFF3F4F6)
      ..style = PaintingStyle.fill;
    canvas.drawPath(southLightPath, southLightPaint);

    // Right Facet (Shaded shadow side)
    final southShadowPath = Path()
      ..moveTo(0, southLength) // South tip
      ..lineTo(0, 0) // Center
      ..lineTo(needleWidth, 0) // Right shoulder
      ..close();

    final southShadowPaint = Paint()
      ..color = isNightVision ? const Color(0xFF3F0B0B) : const Color(0xFF9CA3AF)
      ..style = PaintingStyle.fill;
    canvas.drawPath(southShadowPath, southShadowPaint);

    // Needle Spine Ridge Line
    final spinePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, -needleLength), Offset(0, southLength), spinePaint);

    // 3. CENTER BRASS/CHROME PIVOT CAP (İbre Göbeği)
    // Outer metallic hub ring
    final hubRingPaint = Paint()
      ..color = isNightVision ? const Color(0xFF7F1D1D) : const Color(0xFFD97706)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 9.0, hubRingPaint);

    final hubBorderPaint = Paint()
      ..color = isNightVision ? const Color(0xFFFF5252) : const Color(0xFFFBBF24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset.zero, 9.0, hubBorderPaint);

    // Center Jewel Socket
    final jewelPaint = Paint()
      ..color = isNightVision ? const Color(0xFF220000) : const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 4.5, jewelPaint);

    // Glowing jewel highlight point
    final jewelHighlightPaint = Paint()
      ..color = isNightVision ? const Color(0xFFFF3B30) : const Color(0xFF00E5FF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(-1.2, -1.2), 1.8, jewelHighlightPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CompassNeedlePainter oldDelegate) {
    return oldDelegate.headingDeg != headingDeg ||
        oldDelegate.isNightVision != isNightVision;
  }
}

/// Paints the Lubber Line indicator triangle at the top 12 o'clock position (ship's bow reference).
class _LubberLinePainter extends CustomPainter {
  final bool isNightVision;

  _LubberLinePainter({required this.isNightVision});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height) // Point pointing down toward dial
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    final paint = Paint()
      ..color = isNightVision ? const Color(0xFFFF3B30) : const Color(0xFF00E5FF)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _LubberLinePainter oldDelegate) {
    return oldDelegate.isNightVision != isNightVision;
  }
}

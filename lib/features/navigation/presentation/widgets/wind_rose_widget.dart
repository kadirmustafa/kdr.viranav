import 'dart:math' as math;
import 'package:flutter/material.dart';

class WindRoseWidget extends StatelessWidget {
  final double headingDeg; // Ship Heading (HDG)
  final double windDirectionDeg; // True Wind Direction (TWD)
  final double windSpeedKnots;
  final double noGoZoneAngle;
  final bool isNightVision;

  const WindRoseWidget({
    super.key,
    required this.headingDeg,
    required this.windDirectionDeg,
    required this.windSpeedKnots,
    this.noGoZoneAngle = 45.0,
    this.isNightVision = false,
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
    return AspectRatio(
      aspectRatio: 1.0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: _WindRosePainter(
              headingDeg: headingDeg,
              windDirectionDeg: windDirectionDeg,
              windSpeedKnots: windSpeedKnots,
              noGoZoneAngle: noGoZoneAngle,
              isNightVision: isNightVision,
            ),
          ),
          // Top Digital Heading Readout Badge (HDG & Direction e.g. "042° NE")
          Positioned(
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: (isNightVision ? const Color(0xFF2A0000) : const Color(0xFF071426))
                    .withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isNightVision ? const Color(0xFFFF3B30) : const Color(0xFF00E5FF),
                  width: 1.2,
                ),
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
    );
  }
}

class _WindRosePainter extends CustomPainter {
  final double headingDeg;
  final double windDirectionDeg;
  final double windSpeedKnots;
  final double noGoZoneAngle;
  final bool isNightVision;

  _WindRosePainter({
    required this.headingDeg,
    required this.windDirectionDeg,
    required this.windSpeedKnots,
    required this.noGoZoneAngle,
    required this.isNightVision,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 6);
    final radius = math.min(size.width, size.height) / 2 - 20;

    final primaryColor = isNightVision ? const Color(0xFFFF3B30) : const Color(0xFF00E5FF);
    final secondaryColor = isNightVision ? const Color(0xFF991B1B) : const Color(0xFF1E3A5F);
    final textColor = isNightVision ? const Color(0xFFFF6B6B) : Colors.white;

    // Outer Bezel Ring
    final ringPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, ringPaint);

    // Inner dial
    final dialPaint = Paint()
      ..color = isNightVision ? const Color(0xFF1A0000) : const Color(0xFF0F213D)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 2, dialPaint);

    // Compass ticks and degree labels
    final tickPaint = Paint()..color = primaryColor.withValues(alpha: 0.7);

    final cardinalTextPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int deg = 0; deg < 360; deg += 15) {
      final rad = (deg - 90) * math.pi / 180.0;
      final isCardinal = deg % 90 == 0;
      final isIntercardinal = deg % 45 == 0 && !isCardinal;
      final len = isCardinal ? 13.0 : (isIntercardinal ? 8.0 : 4.0);

      final p1 = Offset(center.dx + radius * math.cos(rad), center.dy + radius * math.sin(rad));
      final p2 = Offset(center.dx + (radius - len) * math.cos(rad), center.dy + (radius - len) * math.sin(rad));

      tickPaint.strokeWidth = isCardinal ? 2.5 : (isIntercardinal ? 1.5 : 1.0);
      tickPaint.color = isCardinal
          ? primaryColor
          : (isIntercardinal ? primaryColor.withValues(alpha: 0.7) : primaryColor.withValues(alpha: 0.35));
      canvas.drawLine(p1, p2, tickPaint);

      // Cardinal Labels (N, E, S, W)
      if (isCardinal) {
        String label = '';
        if (deg == 0) label = 'N';
        if (deg == 90) label = 'E';
        if (deg == 180) label = 'S';
        if (deg == 270) label = 'W';

        cardinalTextPainter.text = TextSpan(
          text: label,
          style: TextStyle(
            color: deg == 0 ? (isNightVision ? const Color(0xFFFF3B30) : const Color(0xFFFF5252)) : textColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        );
        cardinalTextPainter.layout();
        final labelRadius = radius - 22;
        final tx = center.dx + labelRadius * math.cos(rad) - cardinalTextPainter.width / 2;
        final ty = center.dy + labelRadius * math.sin(rad) - cardinalTextPainter.height / 2;
        cardinalTextPainter.paint(canvas, Offset(tx, ty));
      }
    }

    // NO-GO ZONE (±45° relative to True Wind Direction)
    if (noGoZoneAngle > 0) {
      final noGoRadStart = (windDirectionDeg - noGoZoneAngle - 90) * math.pi / 180.0;
      final sweepAngle = (noGoZoneAngle * 2) * math.pi / 180.0;

      final noGoPaint = Paint()
        ..color = const Color(0xFFFF3B30).withValues(alpha: isNightVision ? 0.35 : 0.22)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 30),
        noGoRadStart,
        sweepAngle,
        true,
        noGoPaint,
      );

      // TACKING SWEET SPOT ARROWS
      final tackPaint = Paint()
        ..color = primaryColor
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      for (final offset in [-noGoZoneAngle, noGoZoneAngle]) {
        final tRad = (windDirectionDeg + offset - 90) * math.pi / 180.0;
        final arrowPt = Offset(
          center.dx + (radius - 32) * math.cos(tRad),
          center.dy + (radius - 32) * math.sin(tRad),
        );
        canvas.drawLine(center, arrowPt, tackPaint);
      }
    }

    // TRUE WIND VECTOR (Arrow pointing into center)
    final windRad = (windDirectionDeg - 90) * math.pi / 180.0;
    final windArrowStart = Offset(
      center.dx + (radius - 4) * math.cos(windRad),
      center.dy + (radius - 4) * math.sin(windRad),
    );
    final windArrowEnd = Offset(
      center.dx + (radius - 36) * math.cos(windRad),
      center.dy + (radius - 36) * math.sin(windRad),
    );

    final windPaint = Paint()
      ..color = isNightVision ? const Color(0xFFFF3B30) : const Color(0xFF38BDF8)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(windArrowStart, windArrowEnd, windPaint);

    // Arrow Head
    final headAngle = 0.45;
    final headLen = 9.0;
    final h1 = Offset(
      windArrowEnd.dx + headLen * math.cos(windRad + math.pi - headAngle),
      windArrowEnd.dy + headLen * math.sin(windRad + math.pi - headAngle),
    );
    final h2 = Offset(
      windArrowEnd.dx + headLen * math.cos(windRad + math.pi + headAngle),
      windArrowEnd.dy + headLen * math.sin(windRad + math.pi + headAngle),
    );
    canvas.drawLine(windArrowEnd, h1, windPaint);
    canvas.drawLine(windArrowEnd, h2, windPaint);

    // BOAT SYMBOL at center rotated by headingDeg
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate((headingDeg) * math.pi / 180.0);

    // Heading guideline extending out from bow
    final guidePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(0, -22), Offset(0, -radius + 28), guidePaint);

    final boatPath = Path();
    boatPath.moveTo(0, -22); // Bow
    boatPath.lineTo(8, 14); // Starboard Stern
    boatPath.lineTo(-8, 14); // Port Stern
    boatPath.close();

    final boatPaint = Paint()
      ..color = textColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(boatPath, boatPaint);

    final keelPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(boatPath, keelPaint);

    canvas.restore();

    // Wind Speed text in center bottom
    final speedPainter = TextPainter(
      text: TextSpan(
        text: 'WIND ${windSpeedKnots.toStringAsFixed(1)} KTS',
        style: TextStyle(
          color: primaryColor,
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    speedPainter.paint(
      canvas,
      Offset(center.dx - speedPainter.width / 2, center.dy + radius * 0.53),
    );
  }

  @override
  bool shouldRepaint(covariant _WindRosePainter oldDelegate) {
    return oldDelegate.headingDeg != headingDeg ||
        oldDelegate.windDirectionDeg != windDirectionDeg ||
        oldDelegate.windSpeedKnots != windSpeedKnots ||
        oldDelegate.isNightVision != isNightVision ||
        oldDelegate.noGoZoneAngle != noGoZoneAngle;
  }
}

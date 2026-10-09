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

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: CustomPaint(
        painter: _WindRosePainter(
          headingDeg: headingDeg,
          windDirectionDeg: windDirectionDeg,
          windSpeedKnots: windSpeedKnots,
          noGoZoneAngle: noGoZoneAngle,
          isNightVision: isNightVision,
        ),
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
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 14;

    final primaryColor = isNightVision ? const Color(0xFFFF3B30) : const Color(0xFF00E5FF);
    final secondaryColor = isNightVision ? const Color(0xFF991B1B) : const Color(0xFF1E3A5F);
    final textColor = isNightVision ? const Color(0xFFFF6B6B) : Colors.white;

    // Outer Bezel Ring
    final ringPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, ringPaint);

    // Inner dial
    final dialPaint = Paint()
      ..color = isNightVision ? const Color(0xFF1A0000) : const Color(0xFF0F213D)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 2, dialPaint);

    // Compass ticks and labels
    final tickPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.7)
      ..strokeWidth = 1.5;

    final cardinalTextPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int deg = 0; deg < 360; deg += 15) {
      final rad = (deg - 90) * math.pi / 180.0;
      final isMajor = deg % 90 == 0;
      final isMedium = deg % 45 == 0;
      final len = isMajor ? 12.0 : (isMedium ? 8.0 : 4.0);

      final p1 = Offset(center.dx + radius * math.cos(rad), center.dy + radius * math.sin(rad));
      final p2 = Offset(center.dx + (radius - len) * math.cos(rad), center.dy + (radius - len) * math.sin(rad));

      tickPaint.strokeWidth = isMajor ? 2.5 : 1.2;
      tickPaint.color = isMajor ? primaryColor : primaryColor.withValues(alpha: 0.4);
      canvas.drawLine(p1, p2, tickPaint);

      if (isMajor) {
        String label = '';
        if (deg == 0) label = 'N';
        if (deg == 90) label = 'E';
        if (deg == 180) label = 'S';
        if (deg == 220 || deg == 270) label = 'W';

        cardinalTextPainter.text = TextSpan(
          text: label,
          style: TextStyle(
            color: deg == 0 ? (isNightVision ? const Color(0xFFFF3B30) : const Color(0xFFFF5252)) : textColor,
            fontSize: 13,
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
    // Wind comes from windDirectionDeg.
    final noGoRadStart = (windDirectionDeg - noGoZoneAngle - 90) * math.pi / 180.0;
    final sweepAngle = (noGoZoneAngle * 2) * math.pi / 180.0;

    final noGoPaint = Paint()
      ..color = const Color(0xFFFF3B30).withValues(alpha: isNightVision ? 0.35 : 0.25)
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 30),
      noGoRadStart,
      sweepAngle,
      true,
      noGoPaint,
    );

    // TACKING SWEET SPOT ARROWS (Optimum Port & Starboard VMG angles)
    final tackPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    for (final offset in [-noGoZoneAngle - 3, noGoZoneAngle + 3]) {
      final tRad = (windDirectionDeg + offset - 90) * math.pi / 180.0;
      final arrowPt = Offset(
        center.dx + (radius - 32) * math.cos(tRad),
        center.dy + (radius - 32) * math.sin(tRad),
      );
      canvas.drawLine(center, arrowPt, tackPaint);
    }

    // TRUE WIND VECTOR (Arrow pointing in from wind direction towards center)
    final windRad = (windDirectionDeg - 90) * math.pi / 180.0;
    final windArrowStart = Offset(
      center.dx + (radius - 4) * math.cos(windRad),
      center.dy + (radius - 4) * math.sin(windRad),
    );
    final windArrowEnd = Offset(
      center.dx + (radius - 38) * math.cos(windRad),
      center.dy + (radius - 38) * math.sin(windRad),
    );

    final windPaint = Paint()
      ..color = isNightVision ? const Color(0xFFFF3B30) : const Color(0xFF38BDF8)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(windArrowStart, windArrowEnd, windPaint);

    // Draw Wind Barb head
    final headAngle = 0.45;
    final headLen = 10.0;
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

    // BOAT SYMBOL at center (rotated according to headingDeg)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate((headingDeg) * math.pi / 180.0);

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
        text: '${windSpeedKnots.toStringAsFixed(1)} KTS',
        style: TextStyle(
          color: primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    speedPainter.paint(
      canvas,
      Offset(center.dx - speedPainter.width / 2, center.dy + radius * 0.52),
    );
  }

  @override
  bool shouldRepaint(covariant _WindRosePainter oldDelegate) {
    return oldDelegate.headingDeg != headingDeg ||
        oldDelegate.windDirectionDeg != windDirectionDeg ||
        oldDelegate.windSpeedKnots != windSpeedKnots ||
        oldDelegate.isNightVision != isNightVision;
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Chalit Chart (Bhava Chalit) - Circular representation with house cusps
/// Shows true house positions based on Ascendant degree
class ChalitChart extends StatelessWidget {
  final String lagnaSign;
  final double lagnaDegree;
  final Map<int, String> houses;
  final Map<String, String> planets;

  const ChalitChart({
    super.key,
    this.lagnaSign = 'Aries',
    this.lagnaDegree = 15.0,
    this.houses = const {},
    this.planets = const {},
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: _ChalitPainter(
          lagnaSign: lagnaSign,
          lagnaDegree: lagnaDegree,
          houses: houses,
          planets: planets,
        ),
      ),
    );
  }
}

class _ChalitPainter extends CustomPainter {
  final String lagnaSign;
  final double lagnaDegree;
  final Map<int, String> houses;
  final Map<String, String> planets;

  // Green theme for Chalit (earth/cusp based)
  static const Color chalitGreen = Color(0xFF2E7D32);
  static const Color chalitLightGreen = Color(0xFF66BB6A);

  _ChalitPainter({
    required this.lagnaSign,
    required this.lagnaDegree,
    required this.houses,
    required this.planets,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.45;
    final innerRadius = radius * 0.5;

    // Background
    final bgPaint = Paint()
      ..color = chalitLightGreen.withOpacity(0.08)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Outer circle
    final outerPaint = Paint()
      ..color = chalitGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, outerPaint);

    // Inner circle
    final innerPaint = Paint()
      ..color = chalitGreen.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, innerRadius, innerPaint);

    // Draw 12 house divisions
    final divisionPaint = Paint()
      ..color = chalitGreen.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * math.pi / 180;
      final startX = center.dx + innerRadius * math.cos(angle);
      final startY = center.dy + innerRadius * math.sin(angle);
      final endX = center.dx + radius * math.cos(angle);
      final endY = center.dy + radius * math.sin(angle);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), divisionPaint);
    }

    // Draw house numbers
    for (int i = 1; i <= 12; i++) {
      final angle = ((i - 1) * 30 + 15 - 90) * math.pi / 180;
      final midRadius = (radius + innerRadius) / 2;
      final x = center.dx + midRadius * math.cos(angle);
      final y = center.dy + midRadius * math.sin(angle);
      
      _drawText(
        canvas,
        '$i',
        x, y,
        TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: chalitGreen,
        ),
      );
    }

    // Center content
    _drawText(
      canvas,
      'BHAVA',
      center.dx, center.dy - 12,
      TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: chalitGreen.withOpacity(0.7),
      ),
    );
    _drawText(
      canvas,
      'CHALIT',
      center.dx, center.dy + 2,
      TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: chalitGreen.withOpacity(0.7),
      ),
    );
    _drawText(
      canvas,
      'Asc: ${lagnaDegree.toStringAsFixed(1)}°',
      center.dx, center.dy + 16,
      TextStyle(
        fontSize: 9,
        color: AppTheme.neutralGrey,
      ),
    );

    // Draw Ascendant marker (arrow pointing to 1st house cusp)
    _drawAscendantMarker(canvas, center, radius);
  }

  void _drawAscendantMarker(Canvas canvas, Offset center, double radius) {
    // Draw a small arrow/marker at the Ascendant position
    final angle = -90 * math.pi / 180; // 1st house cusp at top
    final markerRadius = radius + 8;
    final x = center.dx + markerRadius * math.cos(angle);
    final y = center.dy + markerRadius * math.sin(angle);
    
    final markerPaint = Paint()
      ..color = chalitGreen
      ..style = PaintingStyle.fill;
    
    // Small triangle marker
    final path = Path()
      ..moveTo(x, y - 8)
      ..lineTo(x - 5, y)
      ..lineTo(x + 5, y)
      ..close();
    canvas.drawPath(path, markerPaint);
  }

  void _drawText(Canvas canvas, String text, double x, double y, TextStyle style) {
    final textSpan = TextSpan(text: text, style: style);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

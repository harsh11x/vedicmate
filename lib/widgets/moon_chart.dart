import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Moon Chart (Chandra Kundli) - North Indian style with Moon emphasis
/// The Moon sign becomes the 1st house
class MoonChart extends StatelessWidget {
  final String moonSign;
  final Map<int, String> houses;
  final Map<String, String> planets;

  const MoonChart({
    super.key,
    this.moonSign = 'Cancer',
    this.houses = const {},
    this.planets = const {},
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: _MoonChartPainter(
          moonSign: moonSign,
          houses: houses,
          planets: planets,
        ),
      ),
    );
  }
}

class _MoonChartPainter extends CustomPainter {
  final String moonSign;
  final Map<int, String> houses;
  final Map<String, String> planets;

  // Blue color theme for Moon
  static const Color moonBlue = Color(0xFF1565C0);
  static const Color moonLightBlue = Color(0xFF42A5F5);

  _MoonChartPainter({
    required this.moonSign,
    required this.houses,
    required this.planets,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final width = size.width;
    final height = size.height;

    // Background with moon tint
    final paintBg = Paint()
      ..color = moonLightBlue.withOpacity(0.08)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paintBg);

    // Border Paint
    final borderPaint = Paint()
      ..color = moonBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Inner Lines Paint
    final linePaint = Paint()
      ..color = moonBlue.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw Outer Box
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), borderPaint);

    // Draw Diagonals (X shape)
    canvas.drawLine(const Offset(0, 0), Offset(width, height), linePaint);
    canvas.drawLine(Offset(width, 0), Offset(0, height), linePaint);

    // Draw Diamond (Midpoints connection)
    final path = Path()
      ..moveTo(width / 2, 0)
      ..lineTo(width, height / 2)
      ..lineTo(width / 2, height)
      ..lineTo(0, height / 2)
      ..close();
    canvas.drawPath(path, linePaint);

    // Draw Moon symbol in center
    _drawMoonSymbol(canvas, center, size);

    // Draw house content
    _drawHouseContent(canvas, size);
  }

  void _drawMoonSymbol(Canvas canvas, Offset center, Size size) {
    final moonPaint = Paint()
      ..color = moonBlue.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    
    // Crescent moon shape
    final path = Path();
    path.addArc(
      Rect.fromCircle(center: center, radius: size.width * 0.12),
      -1.5,
      3.14,
    );
    path.arcTo(
      Rect.fromCircle(center: Offset(center.dx + 8, center.dy), radius: size.width * 0.09),
      1.6,
      -3.14,
      false,
    );
    canvas.drawPath(path, moonPaint);

    // Label
    _drawText(
      canvas,
      'CHANDRA',
      center.dx, center.dy - 5,
      TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: moonBlue.withOpacity(0.6)),
    );
    _drawText(
      canvas,
      'Moon: $moonSign',
      center.dx, center.dy + 10,
      TextStyle(fontSize: 9, color: AppTheme.neutralGrey),
    );
  }

  void _drawHouseContent(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    final Map<int, Offset> centers = {
      1: Offset(cx, h * 0.18),
      2: Offset(w * 0.18, h * 0.1),
      3: Offset(w * 0.08, h * 0.18),
      4: Offset(w * 0.18, h * 0.5),
      5: Offset(w * 0.08, h * 0.82),
      6: Offset(w * 0.18, h * 0.9),
      7: Offset(cx, h * 0.82),
      8: Offset(w * 0.82, h * 0.9),
      9: Offset(w * 0.92, h * 0.82),
      10: Offset(w * 0.82, h * 0.5),
      11: Offset(w * 0.92, h * 0.18),
      12: Offset(w * 0.82, h * 0.1),
    };

    final signStyle = TextStyle(fontSize: 9, color: AppTheme.neutralDark, fontWeight: FontWeight.w600);

    for (int i = 1; i <= 12; i++) {
      final center = centers[i]!;
      final signName = houses.isNotEmpty ? (houses[i] ?? '') : _getDefaultSign(i);
      _drawText(canvas, signName, center.dx, center.dy, signStyle);
    }
  }

  String _getDefaultSign(int house) {
    const signs = ['Can', 'Leo', 'Vir', 'Lib', 'Sco', 'Sag', 'Cap', 'Aqu', 'Pis', 'Ari', 'Tau', 'Gem'];
    return signs[(house - 1) % 12];
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

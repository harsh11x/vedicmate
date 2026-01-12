import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class LagnaChart extends StatelessWidget {
  final String lagnaSign;
  final Map<int, String> houses;
  final Map<String, String> planets;
  
  LagnaChart({
    super.key,
    this.lagnaSign = 'Aries',
    Map<int, String>? houses,
    Map<String, String>? planets,
  }) : houses = houses ?? _defaultHouses(),
       planets = planets ?? _defaultPlanets();
  
  static Map<int, String> _defaultHouses() {
    return {
      1: 'Aries', 2: 'Taurus', 3: 'Gemini', 4: 'Cancer',
      5: 'Leo', 6: 'Virgo', 7: 'Libra', 8: 'Scorpio',
      9: 'Sagittarius', 10: 'Capricorn', 11: 'Aquarius', 12: 'Pisces',
    };
  }
  
  static Map<String, String> _defaultPlanets() {
    return {
      'Sun': 'Leo 15°', 'Moon': 'Cancer 22°', 'Mars': 'Aries 8°',
      'Mercury': 'Virgo 12°', 'Jupiter': 'Sagittarius 18°', 'Venus': 'Libra 25°',
      'Saturn': 'Capricorn 10°', 'Rahu': 'Pisces 5°', 'Ketu': 'Virgo 5°',
    };
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: LagnaChartPainter(
          lagnaSign: lagnaSign,
          houses: houses,
          planets: planets,
        ),
      ),
    );
  }
}

class LagnaChartPainter extends CustomPainter {
  final String lagnaSign;
  final Map<int, String> houses;
  final Map<String, String> planets;

  LagnaChartPainter({
    required this.lagnaSign,
    required this.houses,
    required this.planets,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final width = size.width;
    final height = size.height;

    // Background
    final paintBg = Paint()
      ..color = AppTheme.primaryOrange.withOpacity(0.05)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paintBg);

    // Border Paint
    final borderPaint = Paint()
      ..color = AppTheme.primaryOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Inner Lines Paint
    final linePaint = Paint()
      ..color = AppTheme.primaryOrange.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw Outer Box
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), borderPaint);

    // Draw Diagonals (X shape)
    canvas.drawLine(Offset(0, 0), Offset(width, height), linePaint);
    canvas.drawLine(Offset(width, 0), Offset(0, height), linePaint);

    // Draw Diamond (Midpoints connection)
    final path = Path()
      ..moveTo(width / 2, 0) // Top mid
      ..lineTo(width, height / 2) // Right mid
      ..lineTo(width / 2, height) // Bottom mid
      ..lineTo(0, height / 2) // Left mid
      ..close();
    canvas.drawPath(path, linePaint);

    // Draw House Numbers and Signs
    _drawHouseContent(canvas, size);
  }

  void _drawHouseContent(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    // Define center points for each of the 12 houses in North Indian Chart
    // 1: Top Diamond (Lagna)
    // 2: Top-Left Triangle
    // 3: Top-Left Corner Triangle
    // ...
    final houseCenters = [
      Offset(cx, h * 0.25), // 1
      Offset(w * 0.25, h * 0.15), // 2
      Offset(w * 0.15, h * 0.25), // 3
      Offset(cx, h * 0.45), // 4 (Center Top) -> Actually House 4 is usually bottom diamond in some variations, but let's stick to standard North Indian
      // Correction for Standard North Indian Layout:
      // 1: Top Center Diamond
      // 2: Top Left Triangle
      // 3: Left Triangle (Upper part of left box)
      // 4: Center Diamond (Wait, North Indian chart is fixed. 1st house is always Top Center Diamond)
    ];

    // Standard North Indian House Centers (Approximate visual centers)
    final Map<int, Offset> centers = {
      1: Offset(cx, h * 0.2),       // Top Diamond
      2: Offset(w * 0.2, h * 0.1),  // Top Left
      3: Offset(w * 0.1, h * 0.2),  // Left Top
      4: Offset(w * 0.2, cy),       // Left Diamond
      5: Offset(w * 0.1, h * 0.8),  // Left Bottom
      6: Offset(w * 0.2, h * 0.9),  // Bottom Left
      7: Offset(cx, h * 0.8),       // Bottom Diamond
      8: Offset(w * 0.8, h * 0.9),  // Bottom Right
      9: Offset(w * 0.9, h * 0.8),  // Right Bottom
      10: Offset(w * 0.8, cy),      // Right Diamond
      11: Offset(w * 0.9, h * 0.2), // Right Top
      12: Offset(w * 0.8, h * 0.1), // Top Right
    };

    // Text Styles
    final houseNumStyle = TextStyle(
      fontSize: 10, 
      color: AppTheme.forestDark.withOpacity(0.5), 
      fontWeight: FontWeight.bold
    );
    final signStyle = TextStyle(
      fontSize: 10, 
      color: AppTheme.neutralDark, 
      fontWeight: FontWeight.w600
    );

    for (int i = 1; i <= 12; i++) {
        final center = centers[i]!;
        final signName = houses[i] ?? '';
        
        // Draw House Number (Static 1-12 usually, but here we draw the Sign Number actually in real charts)
        // For simplicity, let's draw the Sign Name
        _drawText(canvas, center.dx, center.dy, signName, signStyle);
        
        // Slightly above or below, draw planets in this house
        _drawPlanetsInHouse(canvas, i, center, size);
    }
  }

  void _drawPlanetsInHouse(Canvas canvas, int houseNum, Offset center, Size size) {
    // Filter planets in this house (Simulated matching)
    // In a real app, we check if planet longitude falls in this house
    // Here we just map randomly mostly or use the mock 'planets' map if it had house data. 
    // Since 'planets' map is Name->Degree, we don't know the house easily without calculation.
    // I will simulate placing a few planets for visual demo.
    
    // Mock simulation:
    List<String> planetsHere = [];
    if (houseNum == 1) planetsHere = ['Sun'];
    if (houseNum == 4) planetsHere = ['Moon', 'Merc'];
    if (houseNum == 7) planetsHere = ['Jup'];
    if (houseNum == 10) planetsHere = ['Sat', 'Rahu'];

    double offsetY = 15;
    final planetStyle = TextStyle(
      fontSize: 9, 
      color: AppTheme.forestDark, 
      fontWeight: FontWeight.bold
    );

    for (var p in planetsHere) {
        _drawText(canvas, center.dx, center.dy + offsetY, p, planetStyle);
        offsetY += 10;
    }
  }

  void _drawText(Canvas canvas, double x, double y, String text, TextStyle style) {
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

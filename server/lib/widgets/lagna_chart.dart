import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class LagnaChart extends StatelessWidget {
  final String lagnaSign; // Ascendant sign
  final Map<int, String> houses; // House number -> Sign
  final Map<String, String> planets; // Planet -> Sign and degree
  
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
      'Sun': 'Leo 15°',
      'Moon': 'Cancer 22°',
      'Mars': 'Aries 8°',
      'Mercury': 'Virgo 12°',
      'Jupiter': 'Sagittarius 18°',
      'Venus': 'Libra 25°',
      'Saturn': 'Capricorn 10°',
      'Rahu': 'Pisces 5°',
      'Ketu': 'Virgo 5°',
    };
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(400, 400),
      painter: LagnaChartPainter(
        lagnaSign: lagnaSign,
        houses: houses,
        planets: planets,
      ),
    );
  }
}

class LagnaChartPainter extends CustomPainter {
  final String lagnaSign;
  final Map<int, String> houses;
  final Map<String, String> planets;
  
  final List<String> _signs = [
    'Aries', 'Taurus', 'Gemini', 'Cancer',
    'Leo', 'Virgo', 'Libra', 'Scorpio',
    'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces',
  ];
  
  final Map<String, Color> _planetColors = {
    'Sun': Colors.orange,
    'Moon': Colors.lightBlue,
    'Mars': Colors.red,
    'Mercury': Colors.grey,
    'Jupiter': Colors.amber,
    'Venus': Colors.pink,
    'Saturn': Colors.blueGrey,
    'Rahu': Colors.purple,
    'Ketu': Colors.brown,
  };

  LagnaChartPainter({
    required this.lagnaSign,
    required this.houses,
    required this.planets,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 40;
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = AppTheme.neutralDark;
    
    // Draw outer square
    final squareSize = radius * 1.6;
    final squareRect = Rect.fromCenter(
      center: center,
      width: squareSize,
      height: squareSize,
    );
    canvas.drawRect(squareRect, paint);
    
    // Draw inner square (rotated 45 degrees)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(math.pi / 4);
    final innerSquareRect = Rect.fromCenter(
      center: Offset.zero,
      width: squareSize * 0.7,
      height: squareSize * 0.7,
    );
    canvas.drawRect(innerSquareRect, paint);
    canvas.restore();
    
    // Draw diagonal lines
    paint.strokeWidth = 1.5;
    canvas.drawLine(
      Offset(center.dx - squareSize / 2, center.dy - squareSize / 2),
      Offset(center.dx + squareSize / 2, center.dy + squareSize / 2),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - squareSize / 2, center.dy + squareSize / 2),
      Offset(center.dx + squareSize / 2, center.dy - squareSize / 2),
      paint,
    );
    
    // Draw horizontal and vertical lines
    canvas.drawLine(
      Offset(center.dx - squareSize / 2, center.dy),
      Offset(center.dx + squareSize / 2, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - squareSize / 2),
      Offset(center.dx, center.dy + squareSize / 2),
      paint,
    );
    
    // Draw 12 houses
    _drawHouses(canvas, center, squareSize);
    
    // Draw planets
    _drawPlanets(canvas, center, squareSize);
  }
  
  void _drawHouses(Canvas canvas, Offset center, double squareSize) {
    final textStyle = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
      color: AppTheme.neutralDark,
    );
    
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    // House positions (12 houses around the square)
    final housePositions = [
      Offset(center.dx, center.dy - squareSize / 2 - 15), // House 1 (Top)
      Offset(center.dx + squareSize / 2 + 15, center.dy - squareSize / 4), // House 2
      Offset(center.dx + squareSize / 2 + 15, center.dy), // House 3
      Offset(center.dx + squareSize / 2 + 15, center.dy + squareSize / 4), // House 4
      Offset(center.dx, center.dy + squareSize / 2 + 15), // House 5 (Bottom)
      Offset(center.dx - squareSize / 2 - 15, center.dy + squareSize / 4), // House 6
      Offset(center.dx - squareSize / 2 - 15, center.dy), // House 7
      Offset(center.dx - squareSize / 2 - 15, center.dy - squareSize / 4), // House 8
      Offset(center.dx - squareSize / 4, center.dy - squareSize / 2 - 15), // House 9
      Offset(center.dx + squareSize / 4, center.dy - squareSize / 2 - 15), // House 10
      Offset(center.dx + squareSize / 4, center.dy + squareSize / 2 + 15), // House 11
      Offset(center.dx - squareSize / 4, center.dy + squareSize / 2 + 15), // House 12
    ];
    
    for (int i = 0; i < 12; i++) {
      final houseNum = i + 1;
      final sign = houses[houseNum] ?? _signs[i];
      
      // Draw house number
      textPainter.text = TextSpan(
        text: '$houseNum',
        style: textStyle.copyWith(fontSize: 12, color: AppTheme.yellowPrimary),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          housePositions[i].dx - textPainter.width / 2,
          housePositions[i].dy - textPainter.height / 2,
        ),
      );
      
      // Draw sign name
      textPainter.text = TextSpan(
        text: sign,
        style: textStyle.copyWith(fontSize: 9),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          housePositions[i].dx - textPainter.width / 2,
          housePositions[i].dy + 8,
        ),
      );
    }
  }
  
  void _drawPlanets(Canvas canvas, Offset center, double squareSize) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Place planets in houses (simplified - in real implementation, calculate based on degrees)
    final planetPositions = [
      Offset(center.dx - squareSize / 4, center.dy - squareSize / 4), // Sun
      Offset(center.dx + squareSize / 4, center.dy - squareSize / 4), // Moon
      Offset(center.dx, center.dy - squareSize / 3), // Mars
      Offset(center.dx - squareSize / 4, center.dy + squareSize / 4), // Mercury
      Offset(center.dx + squareSize / 4, center.dy + squareSize / 4), // Jupiter
      Offset(center.dx + squareSize / 3, center.dy), // Venus
      Offset(center.dx - squareSize / 3, center.dy), // Saturn
      Offset(center.dx, center.dy + squareSize / 3), // Rahu
      Offset(center.dx, center.dy), // Ketu
    ];
    
    final planetNames = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu'];
    
    for (int i = 0; i < planetNames.length; i++) {
      final planetName = planetNames[i];
      final color = _planetColors[planetName] ?? Colors.grey;
      
      // Draw planet circle
      paint.color = color;
      canvas.drawCircle(planetPositions[i], 8, paint);
      
      // Draw planet label
      final textPainter = TextPainter(
        text: TextSpan(
          text: planetName[0], // First letter
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          planetPositions[i].dx - textPainter.width / 2,
          planetPositions[i].dy - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


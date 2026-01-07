import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Navamsha Chart (D9) - South Indian Square Grid Style
/// Each zodiac sign divided into 9 parts (navamshas)
class NavamshaChart extends StatelessWidget {
  final String lagnaSign;
  final Map<int, String> houses;
  final Map<String, String> planets;

  const NavamshaChart({
    super.key,
    this.lagnaSign = 'Libra',
    this.houses = const {},
    this.planets = const {},
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppTheme.mysticalPurple, width: 2),
        ),
        child: CustomPaint(
          painter: _NavamshaPainter(
            lagnaSign: lagnaSign,
            houses: houses,
            planets: planets,
          ),
        ),
      ),
    );
  }
}

class _NavamshaPainter extends CustomPainter {
  final String lagnaSign;
  final Map<int, String> houses;
  final Map<String, String> planets;

  // South Indian chart: Signs are fixed, houses rotate
  static const List<String> signs = [
    'Ari', 'Tau', 'Gem', 'Can', 'Leo', 'Vir',
    'Lib', 'Sco', 'Sag', 'Cap', 'Aqu', 'Pis'
  ];

  // South Indian grid positions (row, col) for each sign
  static const Map<int, List<int>> signPositions = {
    1: [0, 1],  // Aries
    2: [0, 2],  // Taurus
    3: [0, 3],  // Gemini
    4: [1, 3],  // Cancer
    5: [2, 3],  // Leo
    6: [3, 3],  // Virgo
    7: [3, 2],  // Libra
    8: [3, 1],  // Scorpio
    9: [3, 0],  // Sagittarius
    10: [2, 0], // Capricorn
    11: [1, 0], // Aquarius
    12: [0, 0], // Pisces
  };

  _NavamshaPainter({
    required this.lagnaSign,
    required this.houses,
    required this.planets,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / 4;
    final cellHeight = size.height / 4;

    final gridPaint = Paint()
      ..color = AppTheme.mysticalPurple.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw 4x4 grid
    for (int i = 0; i <= 4; i++) {
      canvas.drawLine(
        Offset(i * cellWidth, 0),
        Offset(i * cellWidth, size.height),
        gridPaint,
      );
      canvas.drawLine(
        Offset(0, i * cellHeight),
        Offset(size.width, i * cellHeight),
        gridPaint,
      );
    }

    // Fill center (empty in South Indian)
    final centerPaint = Paint()
      ..color = AppTheme.mysticalPurple.withOpacity(0.05)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(cellWidth, cellHeight, cellWidth * 2, cellHeight * 2),
      centerPaint,
    );

    // Draw sign names in their fixed positions
    for (int signNum = 1; signNum <= 12; signNum++) {
      final pos = signPositions[signNum]!;
      final x = pos[1] * cellWidth + cellWidth / 2;
      final y = pos[0] * cellHeight + cellHeight / 2;
      
      _drawText(
        canvas,
        signs[signNum - 1],
        x, y - 10,
        TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppTheme.mysticalPurple,
        ),
      );
      
      // Draw sign number
      _drawText(
        canvas,
        '$signNum',
        x, y + 8,
        TextStyle(
          fontSize: 9,
          color: AppTheme.neutralGrey,
        ),
      );
    }

    // Center text
    _drawText(
      canvas,
      'NAVAMSHA',
      size.width / 2, size.height / 2 - 10,
      TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppTheme.mysticalPurple.withOpacity(0.7),
      ),
    );
    _drawText(
      canvas,
      'D-9',
      size.width / 2, size.height / 2 + 8,
      TextStyle(
        fontSize: 10,
        color: AppTheme.neutralGrey,
      ),
    );
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

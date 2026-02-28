import 'package:flutter/material.dart';

class NorthIndianChartPainter extends CustomPainter {
  final List<String> interactions; // Which houses to highlight
  final Map<int, List<String>> planets; // House number -> List of planets

  NorthIndianChartPainter({
    this.interactions = const [],
    this.planets = const {},
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final width = size.width;
    final height = size.height;

    // Draw the main diamond structure (North Indian style)
    final path = Path();
    
    // Outer Box
    path.addRect(Rect.fromLTWH(0, 0, width, height));

    // Diagonals (X shape)
    path.moveTo(0, 0);
    path.lineTo(width, height);
    path.moveTo(width, 0);
    path.lineTo(0, height);

    // Inner Diamond
    path.moveTo(width / 2, 0);
    path.lineTo(width, height / 2);
    path.lineTo(width / 2, height);
    path.lineTo(0, height / 2);
    path.close();

    canvas.drawPath(path, paint);

    // Draw Planets (Simplified placement for now)
    _drawPlanets(canvas, size);
  }

  void _drawPlanets(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // House 1 (Top Center Diamond)
    _drawHouseContent(canvas, size, 1, size.width / 2, size.height / 4);

    // House 4 (Right Center Diamond) - Note: Direction depends on specific tradition variant
    // Standard North Indian:
    // 1st: Top Middle
    // 2nd: Top Left
    // 3rd: Left Middle
    // 4th: Bottom Left
    // 7th: Bottom Middle
    // 10th: Right Middle
    
    // Placeholder positions for visualization
  }

  void _drawHouseContent(Canvas canvas, Size size, int houseNum, double x, double y) {
      if (planets.containsKey(houseNum)) {
          final planetList = planets[houseNum]!;
          final textSpan = TextSpan(
            text: planetList.join('\n'),
            style: const TextStyle(color: Colors.black, fontSize: 10),
          );
          final textPainter = TextPainter(
            text: textSpan,
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
      }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ChartWidget extends StatelessWidget {
  final Map<int, List<String>> planets;

  const ChartWidget({super.key, required this.planets});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomPaint(
          painter: NorthIndianChartPainter(planets: planets),
        ),
      ),
    );
  }
}

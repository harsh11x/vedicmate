import 'dart:math';
import 'package:flutter/material.dart';

class SketchyPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double roughness;
  final double borderRadius;

  SketchyPainter({
    this.color = Colors.black,
    this.strokeWidth = 2.0,
    this.roughness = 2.0,
    this.borderRadius = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final random = Random(42); // Fixed seed for consistent "sketch" per widget instance

    Path createWobblyPath(Rect rect) {
      final path = Path();
      
      // Points for the rectangle with rounded corners
      final double left = rect.left;
      final double top = rect.top;
      final double right = rect.right;
      final double bottom = rect.bottom;
      final double r = borderRadius;

      // Start at top-left after the curve
      path.moveTo(left + r, top);
      
      // Top side
      _drawSketchyLine(path, Offset(left + r, top), Offset(right - r, top), random);
      
      // Top-right corner
      path.quadraticBezierTo(right, top, right, top + r);
      
      // Right side
      _drawSketchyLine(path, Offset(right, top + r), Offset(right, bottom - r), random);
      
      // Bottom-right corner
      path.quadraticBezierTo(right, bottom, right - r, bottom);
      
      // Bottom side
      _drawSketchyLine(path, Offset(right - r, bottom), Offset(left + r, bottom), random);
      
      // Bottom-left corner
      path.quadraticBezierTo(left, bottom, left, bottom - r);
      
      // Left side
      _drawSketchyLine(path, Offset(left, bottom - r), Offset(left, top + r), random);
      
      // Top-left corner
      path.quadraticBezierTo(left, top, left + r, top);

      return path;
    }

    // Draw twice for a slightly more "hand-sketched" overlapping look
    canvas.drawPath(createWobblyPath(Rect.fromLTWH(0, 0, size.width, size.height)), paint);
    
    // Second path slightly offset and different randomness if we didn't seed or used different seed
    // But for simplicity, let's just do one solid sketchy path first
  }

  void _drawSketchyLine(Path path, Offset start, Offset end, Random random) {
    final segments = 5;
    final dx = (end.dx - start.dx) / segments;
    final dy = (end.dy - start.dy) / segments;

    for (int i = 1; i <= segments; i++) {
      final targetX = start.dx + dx * i + (random.nextDouble() - 0.5) * roughness;
      final targetY = start.dy + dy * i + (random.nextDouble() - 0.5) * roughness;
      path.lineTo(targetX, targetY);
    }
    path.lineTo(end.dx, end.dy);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SketchyContainer extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final double padding;
  final double strokeWidth;
  final EdgeInsetsGeometry? margin;

  const SketchyContainer({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor = Colors.black87,
    this.borderRadius = 16.0,
    this.padding = 16.0,
    this.strokeWidth = 2.0,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = CustomPaint(
      painter: SketchyPainter(
        color: borderColor,
        borderRadius: borderRadius,
        strokeWidth: strokeWidth,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: EdgeInsets.all(padding),
        child: child,
      ),
    );

    if (margin != null) {
      return Padding(
        padding: margin!,
        child: content,
      );
    }

    return content;
  }
}

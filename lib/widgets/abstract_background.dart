import 'dart:math';
import 'package:flutter/material.dart';

class AbstractBackground extends StatefulWidget {
  final Widget child;

  const AbstractBackground({super.key, required this.child});

  @override
  State<AbstractBackground> createState() => _AbstractBackgroundState();
}

class _AbstractBackgroundState extends State<AbstractBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Background: Warm Parchment
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFF9E6), // AppTheme.divineBackground
          ),
        ),
        
        // Subtle Animated "Paper Texture" or Warm Glow Overlay
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _PaperTexturePainter(
                animationValue: _controller.value,
              ),
              size: Size.infinite,
            );
          },
        ),

        // Content
        widget.child,
      ],
    );
  }
}

class _PaperTexturePainter extends CustomPainter {
  final double animationValue;

  _PaperTexturePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    // Subtle Warm Orange glow at top-right
    final Paint glowPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(0.8 - (animationValue * 0.1), -0.6 + (animationValue * 0.15)),
        radius: 1.2,
        colors: [
           const Color(0xFFE67E22).withOpacity(0.04), // Saffron/Gold faint glow
           Colors.transparent,
        ],
      ).createShader(rect);
      
    canvas.drawRect(rect, glowPaint);
    
    // Subtle Darker Parchment accent at bottom left
     final Paint accentPaint = Paint()
      ..shader = RadialGradient(
         center: Alignment(-0.7 + (animationValue * 0.05), 0.6 - (animationValue * 0.1)),
        radius: 1.0,
        colors: [
           const Color(0xFFD4C4A8).withOpacity(0.05), // Paper shadow faint glow
           Colors.transparent,
        ],
      ).createShader(rect);
      
    canvas.drawRect(rect, accentPaint);
  }

  @override
  bool shouldRepaint(covariant _PaperTexturePainter oldDelegate) {
     return oldDelegate.animationValue != animationValue;
  }
}

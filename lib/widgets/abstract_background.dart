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
        // Base Background: Clean Warm Off-White
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF5F9F6), // Forest Background (very light green/white)
                Color(0xFFFAFAFA), // Clean neutral off-white
              ],
            ),
          ),
        ),
        
        // Subtle Animated Forest Gradient Overlay
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _LightAuroraPainter(
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

class _LightAuroraPainter extends CustomPainter {
  final double animationValue;

  _LightAuroraPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    // Subtle Forest Green glow at top-right
    final Paint glowPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(0.8 - (animationValue * 0.1), -0.6 + (animationValue * 0.15)),
        radius: 1.0,
        colors: [
           const Color(0xFF2E6F40).withOpacity(0.06), // Forest Primary faint glow
           Colors.transparent,
        ],
      ).createShader(rect);
      
    canvas.drawRect(rect, glowPaint);
    
    // Subtle Deep Green/Mint accent glow at bottom left
     final Paint accentPaint = Paint()
      ..shader = RadialGradient(
         center: Alignment(-0.7 + (animationValue * 0.05), 0.6 - (animationValue * 0.1)),
        radius: 0.8,
        colors: [
           const Color(0xFF253D2C).withOpacity(0.04), // Forest Dark faint glow
           Colors.transparent,
        ],
      ).createShader(rect);
      
    canvas.drawRect(rect, accentPaint);
  }

  @override
  bool shouldRepaint(covariant _LightAuroraPainter oldDelegate) {
     return oldDelegate.animationValue != animationValue;
  }
}

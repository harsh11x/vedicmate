import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animated cosmic background with twinkling stars and nebula effects
class CosmicBackground extends StatefulWidget {
  final Widget child;
  
  const CosmicBackground({
    super.key,
    required this.child,
  });

  @override
  State<CosmicBackground> createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<CosmicBackground>
    with TickerProviderStateMixin {
  late AnimationController _starsController;
  late AnimationController _nebulaController;
  final List<Star> _stars = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    
    // Initialize stars
    for (int i = 0; i < 100; i++) {
      _stars.add(Star(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 2 + 0.5,
        opacity: _random.nextDouble() * 0.5 + 0.3,
        twinkleSpeed: _random.nextDouble() * 2 + 1,
      ));
    }

    // Stars animation (twinkling)
    _starsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Nebula animation (slow drift)
    _nebulaController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _starsController.dispose();
    _nebulaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0A0E27), // Deep space
                Color(0xFF1A1F3A), // Dark space blue
                Color(0xFF0F1729), // Midnight
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        
        // Animated nebula layer
        AnimatedBuilder(
          animation: _nebulaController,
          builder: (context, child) {
            return CustomPaint(
              painter: NebulaPainter(
                animation: _nebulaController.value,
              ),
              size: Size.infinite,
            );
          },
        ),
        
        // Twinkling stars
        AnimatedBuilder(
          animation: _starsController,
          builder: (context, child) {
            return CustomPaint(
              painter: StarsPainter(
                stars: _stars,
                animation: _starsController.value,
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

class Star {
  final double x;
  final double y;
  final double size;
  final double opacity;
  final double twinkleSpeed;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.twinkleSpeed,
  });
}

class StarsPainter extends CustomPainter {
  final List<Star> stars;
  final double animation;

  StarsPainter({
    required this.stars,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var star in stars) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(
          star.opacity * (0.5 + 0.5 * math.sin(animation * math.pi * star.twinkleSpeed)),
        )
        ..style = PaintingStyle.fill;

      final position = Offset(
        star.x * size.width,
        star.y * size.height,
      );

      // Draw star
      canvas.drawCircle(position, star.size, paint);
      
      // Add glow for larger stars
      if (star.size > 1.5) {
        final glowPaint = Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(position, star.size * 2, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(StarsPainter oldDelegate) => true;
}

class NebulaPainter extends CustomPainter {
  final double animation;

  NebulaPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    // Purple nebula
    final purpleGradient = RadialGradient(
      center: Alignment(
        -0.5 + math.sin(animation * 2 * math.pi) * 0.2,
        -0.3 + math.cos(animation * 2 * math.pi) * 0.2,
      ),
      radius: 0.8,
      colors: [
        const Color(0xFF6366F1).withOpacity(0.15),
        const Color(0xFF6366F1).withOpacity(0.05),
        Colors.transparent,
      ],
    );

    final purplePaint = Paint()
      ..shader = purpleGradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      purplePaint,
    );

    // Blue nebula
    final blueGradient = RadialGradient(
      center: Alignment(
        0.5 + math.cos(animation * 2 * math.pi) * 0.3,
        0.5 + math.sin(animation * 2 * math.pi) * 0.3,
      ),
      radius: 0.6,
      colors: [
        const Color(0xFF3B82F6).withOpacity(0.12),
        const Color(0xFF3B82F6).withOpacity(0.04),
        Colors.transparent,
      ],
    );

    final bluePaint = Paint()
      ..shader = blueGradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      bluePaint,
    );

    // Pink galaxy accent
    final pinkGradient = RadialGradient(
      center: Alignment(
        0.0 + math.sin(animation * 2 * math.pi + 1) * 0.25,
        0.8 + math.cos(animation * 2 * math.pi + 1) * 0.15,
      ),
      radius: 0.5,
      colors: [
        const Color(0xFFEC4899).withOpacity(0.1),
        const Color(0xFFEC4899).withOpacity(0.03),
        Colors.transparent,
      ],
    );

    final pinkPaint = Paint()
      ..shader = pinkGradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      pinkPaint,
    );
  }

  @override
  bool shouldRepaint(NebulaPainter oldDelegate) => true;
}

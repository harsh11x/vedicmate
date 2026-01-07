import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import '../core/theme/app_theme.dart';

class MandirGateAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback? onCompleted;

  const MandirGateAnimation({
    super.key,
    required this.child,
    this.onCompleted,
  });

  @override
  State<MandirGateAnimation> createState() => _MandirGateAnimationState();
}

class _MandirGateAnimationState extends State<MandirGateAnimation>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _shakeController;
  
  late Animation<Offset> _leftDoorSlide;
  late Animation<Offset> _rightDoorSlide;
  late Animation<double> _fadeContent;
  late Animation<double> _glowOpacity;
  
  bool _animationCompleted = false;
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _initParticles();
    
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // 1. Shake Phase (0s - 0.8s)
    // 2. Open Phase (0.8s - 3.5s)

    // Doors start sliding after shake
    _leftDoorSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.25, 1.0, curve: Curves.easeInOutCubicEmphasized),
    ));

    _rightDoorSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.25, 1.0, curve: Curves.easeInOutCubicEmphasized),
    ));
    
    _fadeContent = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
    ));
    
    _glowOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.2, curve: Curves.easeIn),
    ));

    _startSequence();
  }

  void _initParticles() {
    final random = math.Random();
    for (int i = 0; i < 50; i++) {
      _particles.add(_Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        speed: 0.2 + random.nextDouble() * 0.5,
        theta: random.nextDouble() * 2 * math.pi,
        radius: 1.0 + random.nextDouble() * 2.0,
      ));
    }
  }

  void _startSequence() async {
    // Phase 1: Glow & Rumble
    _shakeController.repeat(reverse: true);
    await HapticFeedback.heavyImpact();
    
    // Play main animation
    await _mainController.forward();
    
    _shakeController.stop();
    if (mounted) {
      setState(() => _animationCompleted = true);
      widget.onCompleted?.call();
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_animationCompleted) {
      return widget.child;
    }

    return Stack(
      children: [
        // Content underlying
        FadeTransition(
          opacity: _fadeContent,
          child: widget.child,
        ),

        // The Gate Overlay
        AnimatedBuilder(
          animation: Listenable.merge([_mainController, _shakeController]),
          builder: (context, child) {
            // Calculate Shake Offset
            double shakeX = 0;
            if (_mainController.value < 0.25) {
               shakeX = math.sin(_shakeController.value * math.pi * 4) * 2.0; 
            }

            return Transform.translate(
              offset: Offset(shakeX, 0),
              child: Stack(
                children: [
                   // Background Particles (Visible through the crack/open doors)
                   if (_mainController.value > 0.1)
                     Positioned.fill(
                       child: CustomPaint(
                         painter: _ParticlePainter(_particles, _mainController.value),
                       ),
                     ),

                   // Left Door
                   SlideTransition(
                     position: _leftDoorSlide,
                     child: Align(
                       alignment: Alignment.centerLeft,
                       child: _buildDivineDoor(isLeft: true),
                     ),
                   ),

                   // Right Door
                   SlideTransition(
                     position: _rightDoorSlide,
                     child: Align(
                       alignment: Alignment.centerRight,
                       child: _buildDivineDoor(isLeft: false),
                     ),
                   ),

                   // Central Spiritual Energy (Glow)
                   Opacity(
                     opacity: _glowOpacity.value * (1.0 - _mainController.value * 2).clamp(0.0, 1.0),
                     child: Center(
                       child: Container(
                         width: 100,
                         height: 200,
                         decoration: BoxDecoration(
                           boxShadow: [
                             BoxShadow(
                               color: AppTheme.accentGold.withOpacity(0.8),
                               blurRadius: 50,
                               spreadRadius: 20,
                             ),
                             BoxShadow(
                               color: AppTheme.primaryOrange.withOpacity(0.5),
                               blurRadius: 80,
                               spreadRadius: 40,
                             )
                           ]
                         ),
                       ),
                     ),
                   ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDivineDoor({required bool isLeft}) {
    return Container(
      width: MediaQuery.of(context).size.width / 2 + 2, // Slight overlap
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A0B2E), // Deep Cosmic Wood
        border: Border(
           right: isLeft ? const BorderSide(color: Color(0xFFD4AF37), width: 3) : BorderSide.none,
           left: !isLeft ? const BorderSide(color: Color(0xFFD4AF37), width: 3) : BorderSide.none,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.9),
            blurRadius: 40,
            offset: isLeft ? const Offset(15, 0) : const Offset(-15, 0),
          )
        ]
      ),
      child: Stack(
        children: [
          // 1. Wood Grain Texture
          Positioned.fill(
             child: Opacity(
               opacity: 0.1,
               child: Image.asset(
                 'assets/images/wood_texture.png', // Fallback to procedural if this fails
                 fit: BoxFit.cover,
                 errorBuilder: (_,__,___) => CustomPaint(painter: _ProceduralWoodPainter()),
               ),
             ),
          ),

          // 2. Intricate Jaali (Lattice) Pattern
          Positioned.fill(
             child: CustomPaint(
               painter: _JaaliPatternPainter(isLeft: isLeft),
             ),
          ),

          // 3. Central Handle / Ornament
          Align(
            alignment: isLeft ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 60,
              height: 120,
              margin: EdgeInsets.only(
                right: isLeft ? 12 : 0, 
                left: !isLeft ? 12 : 0
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37), // Metallic Gold
                borderRadius: BorderRadius.only(
                  topLeft: isLeft ? const Radius.circular(30) : Radius.zero,
                  bottomLeft: isLeft ? const Radius.circular(30) : Radius.zero,
                  topRight: !isLeft ? const Radius.circular(30) : Radius.zero,
                  bottomRight: !isLeft ? const Radius.circular(30) : Radius.zero,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                     const Color(0xFFFFF8E1),
                     const Color(0xFFD4AF37),
                     const Color(0xFFA08020),
                  ]
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 10, offset: const Offset(0, 4))
                ]
              ),
              child: Center(
                child: Icon(Icons.wb_sunny_rounded, color: const Color(0xFF5D4037).withOpacity(0.8), size: 30),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// Procedural Wood Grain if image unavailable
class _ProceduralWoodPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
      
    final random = math.Random(12345);
    for(int i=0; i<80; i++) {
       final x = random.nextDouble() * size.width;
       final path = Path();
       path.moveTo(x, 0);
       path.cubicTo(
         x + random.nextDouble()*20 - 10, size.height * 0.3,
         x + random.nextDouble()*20 - 10, size.height * 0.7,
         x + random.nextDouble()*20 - 10, size.height
       );
       canvas.drawPath(path, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Complex Jaali Pattern
class _JaaliPatternPainter extends CustomPainter {
  final bool isLeft;
  _JaaliPatternPainter({required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.15) // Subtle Gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
      
    final fillPaint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.05)
      ..style = PaintingStyle.fill;
      
    const double cellSize = 60.0;
    
    // Draw repeating geometric pattern
    for (double y = 0; y < size.height; y += cellSize) {
      for (double x = 0; x < size.width; x += cellSize) {
         // Diamond 
         final path = Path();
         path.moveTo(x + cellSize/2, y);
         path.lineTo(x + cellSize, y + cellSize/2);
         path.lineTo(x + cellSize/2, y + cellSize);
         path.lineTo(x, y + cellSize/2);
         path.close();
         
         canvas.drawPath(path, paint);
         canvas.drawPath(path, fillPaint);
         
         // Inner circle
         canvas.drawCircle(Offset(x+cellSize/2, y+cellSize/2), cellSize/6, paint);
      }
    }
    
    // Borders
    final borderPaint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 10), borderPaint);
    canvas.drawRect(Rect.fromLTWH(0, size.height-10, size.width, 10), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Particle {
  double x, y, speed, theta, radius;
  _Particle({required this.x, required this.y, required this.speed, required this.theta, required this.radius});
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double animationValue;

  _ParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppTheme.accentGold.withOpacity(0.6);
    
    for (var p in particles) {
      double dx = p.x * size.width + math.cos(p.theta + animationValue * 5) * 20;
      double dy = p.y * size.height + math.sin(p.theta + animationValue * 5) * 20;
      
      canvas.drawCircle(Offset(dx, dy), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

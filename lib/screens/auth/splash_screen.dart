import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import '../../core/theme/app_theme.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  late AnimationController _graphicController;
  late AnimationController _textController;
  late AnimationController _ctaController;
  
  late Animation<double> _graphicScaleAnimation;
  late Animation<double> _graphicFadeAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _ctaScaleAnimation;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Get daily, weekly, and monthly Vedic horoscopes, detailed birth charts, numerology readings, and spiritual memes tailored to your zodiac sign.',
      subtitle: 'Stay connected with the cosmos',
      graphicType: GraphicType.cosmic,
    ),
    OnboardingPage(
      title: 'Connect with verified Vedic Pandits through HD video calls, voice calls, or encrypted chat. Get AI-powered recommendations based on your preferences.',
      subtitle: 'Expert consultations at your fingertips',
      graphicType: GraphicType.pandit,
    ),
    OnboardingPage(
      title: 'Watch live Pandit streams, send in-app gifts, order custom remedies, and shop spiritual products like bracelets and malas for your well-being.',
      subtitle: 'Live sessions & spiritual remedies',
      graphicType: GraphicType.remedies,
    ),
    OnboardingPage(
      title: 'Receive your free digital Kundli as a welcome gift! Download your personalized birth chart with Vedic Mate watermark and unlock your astrological destiny.',
      subtitle: 'Your personalized birth chart',
      graphicType: GraphicType.kundli,
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    _graphicController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _ctaController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _graphicScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _graphicController,
      curve: Curves.easeOut,
    ));

    _graphicFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _graphicController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
    ));

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));
    
    _ctaScaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _ctaController,
      curve: Curves.easeOut,
    ));

    _startPageAnimations();
  }

  void _startPageAnimations() {
    _graphicController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _textController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      _ctaController.forward();
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    _graphicController.reset();
    _textController.reset();
    _ctaController.reset();
    _startPageAnimations();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to login screen - use pushReplacement to ensure navigation
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          try {
            context.go('/login');
          } catch (e) {
            // If go_router fails, try Navigator
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            }
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _graphicController.dispose();
    _textController.dispose();
    _ctaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.white,
                AppTheme.yellowPrimary.withOpacity(0.1),
                AppTheme.primarySoft,
              ],
            ),
          ),
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: BoxConstraints(
                maxWidth: 400,
                minWidth: 300,
              ),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neutralDark.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              padding: EdgeInsets.all(
                (MediaQuery.of(context).size.width * 0.08).clamp(24.0, 32.0),
              ),
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // PageView for onboarding pages
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _buildPage(_pages[index]);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // Bottom area with pagination and CTA
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Pagination dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? AppTheme.yellowPrimary
                                : AppTheme.neutralLight.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    // CTA diamond button
                    AnimatedBuilder(
                      animation: _ctaController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _ctaScaleAnimation.value,
                          child: GestureDetector(
                            onTap: _nextPage,
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Transform.rotate(
                                angle: pi / 4, // Rotate square to make diamond
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  alignment: Alignment.center,
                                  child: Transform.rotate(
                                    angle: -pi / 4, // Rotate back for proper arrow orientation
                                    child: Icon(
                                      _currentPage == _pages.length - 1
                                          ? Icons.check
                                          : Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Geometric graphic
        AnimatedBuilder(
          animation: _graphicController,
          builder: (context, child) {
            return Opacity(
              opacity: _graphicFadeAnimation.value,
              child: Transform.scale(
                scale: _graphicScaleAnimation.value,
                child: _buildGraphic(page.graphicType),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        // Subtitle (if available)
        if (page.subtitle != null)
          SlideTransition(
            position: _textSlideAnimation,
            child: FadeTransition(
              opacity: _textFadeAnimation,
              child: Text(
                page.subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.yellowPrimary,
                  height: 1.3,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        if (page.subtitle != null) const SizedBox(height: 16),
        // Body text
        SlideTransition(
          position: _textSlideAnimation,
          child: FadeTransition(
            opacity: _textFadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                page.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2B2B2F),
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGraphic(GraphicType type) {
    switch (type) {
      case GraphicType.cosmic:
        return const EnhancedCosmicGraphic();
      case GraphicType.pandit:
        return const PanditConnectionGraphic();
      case GraphicType.remedies:
        return const RemediesGraphic();
      case GraphicType.kundli:
        return const KundliGraphic();
    }
  }
}

enum GraphicType {
  cosmic,
  pandit,
  remedies,
  kundli,
}

class OnboardingPage {
  final String title;
  final String? subtitle;
  final GraphicType graphicType;

  OnboardingPage({
    required this.title,
    this.subtitle,
    required this.graphicType,
  });
}

// Enhanced Cosmic Graphic (Original)
class EnhancedCosmicGraphic extends StatelessWidget {
  const EnhancedCosmicGraphic({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(200, 200),
      painter: EnhancedCosmicGraphicPainter(),
    );
  }
}

class EnhancedCosmicGraphicPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.7;
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    
    // Draw the main disk with gradient
    final gradient = RadialGradient(
      colors: [
        const Color(0xFF2B2B2F).withOpacity(0.9),
        const Color(0xFF2B2B2F).withOpacity(0.7),
        const Color(0xFF4A4A4A).withOpacity(0.5),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    
    final rect = Rect.fromCircle(center: center, radius: radius * 0.75);
    final shader = gradient.createShader(rect);
    
    final diskPaint = Paint()
      ..shader = shader;
    
    canvas.drawCircle(center, radius * 0.75, diskPaint);
    
    // Draw radial spokes with enhanced pattern
    paint.color = const Color(0xFF2B2B2F);
    final spokeCount = 72;
    
    for (int i = 0; i < spokeCount; i++) {
      final angle = (i / spokeCount) * 2 * pi;
      // Create mandala pattern
      final patternFactor = (sin(angle * 6) + 1) / 2;
      final innerRadius = radius * 0.3;
      final outerRadius = radius * 0.7 * (0.6 + 0.4 * patternFactor);
      
      final startX = center.dx + innerRadius * cos(angle);
      final startY = center.dy + innerRadius * sin(angle);
      final endX = center.dx + outerRadius * cos(angle);
      final endY = center.dy + outerRadius * sin(angle);
      
      paint.color = i % 3 == 0
          ? const Color(0xFFB38859) // Bronze/gold
          : const Color(0xFF2B2B2F); // Dark gray
      
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
    
    // Draw 3D geometric shape (octahedron/pyramid) in center
    paint.style = PaintingStyle.stroke;
    paint.color = Colors.white.withOpacity(0.9);
    paint.strokeWidth = 2.5;
    
    final shapeSize = radius * 0.4;
    final top = Offset(center.dx, center.dy - shapeSize * 0.6);
    final bottomLeft = Offset(center.dx - shapeSize * 0.5, center.dy + shapeSize * 0.4);
    final bottomRight = Offset(center.dx + shapeSize * 0.5, center.dy + shapeSize * 0.4);
    final backTop = Offset(center.dx, center.dy - shapeSize * 0.3);
    final backLeft = Offset(center.dx - shapeSize * 0.4, center.dy + shapeSize * 0.2);
    final backRight = Offset(center.dx + shapeSize * 0.4, center.dy + shapeSize * 0.2);
    
    // Front face
    canvas.drawLine(top, bottomLeft, paint);
    canvas.drawLine(top, bottomRight, paint);
    canvas.drawLine(bottomLeft, bottomRight, paint);
    
    // Back face
    canvas.drawLine(backTop, backLeft, paint);
    canvas.drawLine(backTop, backRight, paint);
    canvas.drawLine(backLeft, backRight, paint);
    
    // Connecting lines
    canvas.drawLine(top, backTop, paint);
    canvas.drawLine(bottomLeft, backLeft, paint);
    canvas.drawLine(bottomRight, backRight, paint);
    
    // Draw elliptical orbits
    paint.color = const Color(0xFFB38859).withOpacity(0.7);
    paint.strokeWidth = 1.5;
    
    // First ellipse (horizontal)
    final ellipseRect1 = Rect.fromCenter(
      center: center,
      width: radius * 1.8,
      height: radius * 1.3,
    );
    canvas.drawOval(ellipseRect1, paint);
    
    // Second ellipse (diagonal)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(pi / 5);
    final ellipseRect2 = Rect.fromCenter(
      center: Offset.zero,
      width: radius * 1.6,
      height: radius * 1.0,
    );
    canvas.drawOval(ellipseRect2, paint);
    canvas.restore();
    
    // Third ellipse (vertical)
    final ellipseRect3 = Rect.fromCenter(
      center: center,
      width: radius * 1.2,
      height: radius * 1.7,
    );
    canvas.drawOval(ellipseRect3, paint);
    
    // Draw planets on orbits with glow effect
    paint.style = PaintingStyle.fill;
    
    // Planet 1 (with glow)
    paint.color = const Color(0xFFB38859);
    final planet1Angle = pi / 4;
    final planet1X = center.dx + radius * 1.8 / 2 * cos(planet1Angle);
    final planet1Y = center.dy + radius * 1.3 / 2 * sin(planet1Angle);
    
    // Glow
    final glowPaint = Paint()
      ..color = const Color(0xFFB38859).withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(planet1X, planet1Y), 8, glowPaint);
    canvas.drawCircle(Offset(planet1X, planet1Y), 5, paint);
    
    // Planet 2
    final planet2Angle = pi;
    final planet2X = center.dx + radius * 1.8 / 2 * cos(planet2Angle);
    final planet2Y = center.dy + radius * 1.3 / 2 * sin(planet2Angle);
    canvas.drawCircle(Offset(planet2X, planet2Y), 4, paint);
    
    // Planet 3 (on diagonal orbit)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(pi / 5);
    final planet3Angle = pi / 3;
    final planet3X = radius * 1.6 / 2 * cos(planet3Angle);
    final planet3Y = radius * 1.0 / 2 * sin(planet3Angle);
    canvas.drawCircle(Offset(planet3X, planet3Y), 4.5, paint);
    canvas.restore();
    
    // Planet 4 (on vertical orbit)
    final planet4Angle = 3 * pi / 2;
    final planet4X = center.dx + radius * 1.2 / 2 * cos(planet4Angle);
    final planet4Y = center.dy + radius * 1.7 / 2 * sin(planet4Angle);
    canvas.drawCircle(Offset(planet4X, planet4Y), 3.5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Pandit Connection Graphic
class PanditConnectionGraphic extends StatelessWidget {
  const PanditConnectionGraphic({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(200, 200),
      painter: PanditConnectionGraphicPainter(),
    );
  }
}

class PanditConnectionGraphicPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.6;
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    
    // Draw central circle (user)
    paint.color = const Color(0xFF2B2B2F);
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.3, paint);
    
    // Draw connecting lines to Pandits (outer circles)
    paint.style = PaintingStyle.stroke;
    paint.color = const Color(0xFFB38859).withOpacity(0.6);
    
    final panditCount = 4;
    final callIcons = ['video', 'voice', 'chat', 'ai']; // Represent different connection types
    
    for (int i = 0; i < panditCount; i++) {
      final angle = (i / panditCount) * 2 * pi;
      final panditX = center.dx + radius * 1.2 * cos(angle);
      final panditY = center.dy + radius * 1.2 * sin(angle);
      
      // Draw connection line with pulse effect
      paint.strokeWidth = 2.0;
      canvas.drawLine(center, Offset(panditX, panditY), paint);
      
      // Draw Pandit circle
      paint.style = PaintingStyle.fill;
      paint.color = const Color(0xFFB38859);
      canvas.drawCircle(Offset(panditX, panditY), radius * 0.25, paint);
      
      // Draw verified badge (checkmark circle)
      paint.color = Colors.white;
      canvas.drawCircle(Offset(panditX, panditY), radius * 0.15, paint);
      
      // Draw small icon indicator (simplified)
      paint.color = const Color(0xFFB38859);
      paint.style = PaintingStyle.fill;
      // Draw small circle to represent call/chat icon
      canvas.drawCircle(
        Offset(panditX + radius * 0.15, panditY - radius * 0.15),
        radius * 0.08,
        paint,
      );
      
      paint.style = PaintingStyle.stroke;
    }
    
    // Draw outer ring
    paint.color = const Color(0xFF2B2B2F).withOpacity(0.3);
    paint.strokeWidth = 1.5;
    canvas.drawCircle(center, radius * 1.5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Remedies Graphic
class RemediesGraphic extends StatelessWidget {
  const RemediesGraphic({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(200, 200),
      painter: RemediesGraphicPainter(),
    );
  }
}

class RemediesGraphicPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.5;
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    
    // Draw lotus/flower pattern
    paint.color = const Color(0xFFB38859);
    final petalCount = 8;
    for (int i = 0; i < petalCount; i++) {
      final angle = (i / petalCount) * 2 * pi;
      final petalRect = Rect.fromCenter(
        center: Offset(
          center.dx + radius * 0.6 * cos(angle),
          center.dy + radius * 0.6 * sin(angle),
        ),
        width: radius * 0.4,
        height: radius * 0.6,
      );
      canvas.drawOval(petalRect, paint);
    }
    
    // Draw center circle
    paint.style = PaintingStyle.fill;
    paint.color = const Color(0xFF2B2B2F);
    canvas.drawCircle(center, radius * 0.2, paint);
    
    // Draw live stream indicator (top)
    paint.color = const Color(0xFFEF4444); // Red for live
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center.dx, center.dy - radius * 1.2),
      radius * 0.2,
      paint,
    );
    paint.color = Colors.white;
    canvas.drawCircle(
      Offset(center.dx, center.dy - radius * 1.2),
      radius * 0.12,
      paint,
    );
    
    // Draw gift icons (sides)
    paint.color = const Color(0xFFB38859);
    final giftPositions = [
      Offset(center.dx - radius * 0.9, center.dy),
      Offset(center.dx + radius * 0.9, center.dy),
    ];
    
    for (final pos in giftPositions) {
      // Draw gift box
      final giftRect = Rect.fromCenter(
        center: pos,
        width: radius * 0.3,
        height: radius * 0.3,
      );
      canvas.drawRect(giftRect, paint);
      // Draw ribbon
      paint.color = Colors.white;
      canvas.drawLine(
        Offset(pos.dx, pos.dy - radius * 0.15),
        Offset(pos.dx, pos.dy + radius * 0.15),
        paint,
      );
      canvas.drawLine(
        Offset(pos.dx - radius * 0.15, pos.dy),
        Offset(pos.dx + radius * 0.15, pos.dy),
        paint,
      );
      paint.color = const Color(0xFFB38859);
    }
    
    // Draw product icons (bracelets, malas - bottom)
    final productPositions = [
      Offset(center.dx - radius * 0.6, center.dy + radius * 0.5),
      Offset(center.dx + radius * 0.6, center.dy + radius * 0.5),
    ];
    
    for (final pos in productPositions) {
      canvas.drawCircle(pos, radius * 0.12, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Kundli Graphic
class KundliGraphic extends StatelessWidget {
  const KundliGraphic({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(200, 200),
      painter: KundliGraphicPainter(),
    );
  }
}

class KundliGraphicPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.7;
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    
    // Draw outer square (Kundli chart)
    paint.color = const Color(0xFF2B2B2F);
    final squareSize = radius * 1.2;
    final squareRect = Rect.fromCenter(
      center: center,
      width: squareSize,
      height: squareSize,
    );
    canvas.drawRect(squareRect, paint);
    
    // Draw diagonal lines
    canvas.drawLine(
      Offset(center.dx - squareSize / 2, center.dy - squareSize / 2),
      Offset(center.dx + squareSize / 2, center.dy + squareSize / 2),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + squareSize / 2, center.dy - squareSize / 2),
      Offset(center.dx - squareSize / 2, center.dy + squareSize / 2),
      paint,
    );
    
    // Draw inner circle
    paint.color = const Color(0xFFB38859);
    canvas.drawCircle(center, radius * 0.4, paint);
    
    // Draw zodiac signs (12 segments)
    paint.color = const Color(0xFF2B2B2F).withOpacity(0.5);
    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * pi;
      final startX = center.dx + radius * 0.4 * cos(angle);
      final startY = center.dy + radius * 0.4 * sin(angle);
      final endX = center.dx + radius * 0.6 * cos(angle);
      final endY = center.dy + radius * 0.6 * sin(angle);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
    
    // Draw center point
    paint.style = PaintingStyle.fill;
    paint.color = const Color(0xFFB38859);
    canvas.drawCircle(center, 4, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

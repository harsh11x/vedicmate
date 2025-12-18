import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import 'dart:ui';
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
  
  late AnimationController _mainController;
  late AnimationController _rotateController;
  
  // Animations
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;
  
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Vedic Wisdom',
      subtitle: 'Ancient knowledge for modern life',
      description: 'Discover the profound insights of Vedic astrology and how they influence your destiny.',
      icon: Icons.auto_awesome,
      color: const Color(0xFFFFD700), // Gold
    ),
    OnboardingPage(
      title: 'Expert Guidance',
      subtitle: 'Connect with learned Pandits',
      description: 'Get personalized consultations from verified astrologers through chat or call.',
      icon: Icons.psychology,
      color: const Color(0xFFE0AA3E), // Muted Gold
    ),
    OnboardingPage(
      title: 'Spiritual Harmony',
      subtitle: 'Balance your cosmic energy',
      description: 'Perform rituals and remedies to align your life with the universe.',
      icon: Icons.balance,
      color: const Color(0xFFD4AF37), // Metallic Gold
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _rotateController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    )..repeat();

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _mainController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _mainController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    context.pushReplacement('/login');
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 Building SplashScreen');
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A), // Deep mystical blue-black
      body: Stack(
        children: [
          // 1. Abstract Rotating Mandala/Constellation Background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _rotateController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotateController.value * 2 * pi,
                  child: CustomPaint(
                    painter: AbstractMandalaPainter(
                      color: _pages[_currentPage].color.withOpacity(0.05),
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. Content
          SafeArea(
            child: Column(
              children: [
                const Spacer(),

                // Main Content Area
                Expanded(
                  flex: 3,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                      _mainController.reset();
                      _mainController.forward();
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _buildPageContent(_pages[index]);
                    },
                  ),
                ),

                // Bottom Controls
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Page Indicators
                      Row(
                        children: List.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 8),
                            height: 4,
                            width: _currentPage == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? _pages[_currentPage].color
                                  : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),

                      // Next/Get Started Button
                      GestureDetector(
                        onTap: _nextPage,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _pages[_currentPage].color.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: _pages[_currentPage].color.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _currentPage == _pages.length - 1
                                    ? Icons.arrow_forward
                                    : Icons.arrow_forward,
                                color: _pages[_currentPage].color,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with subtle glow
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    page.color.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Icon(
                page.icon,
                size: 48,
                color: page.color,
              ),
            ),
          ),
          const SizedBox(height: 60),
          
          // Text Content with Animation
          FadeTransition(
            opacity: _contentFadeAnimation,
            child: SlideTransition(
              position: _contentSlideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    page.title.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1.2,
                      fontFamily: 'Serif', // Use a serif font if available for professional look
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    page.subtitle,
                    style: TextStyle(
                      color: page.color,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    page.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 16,
                      height: 1.8,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class AbstractMandalaPainter extends CustomPainter {
  final Color color;

  AbstractMandalaPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.8;

    // Draw concentric circles/arcs
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(center, radius * (0.2 + i * 0.2), paint);
    }

    // Draw geometric patterns
    final path = Path();
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * pi / 180;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant AbstractMandalaPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

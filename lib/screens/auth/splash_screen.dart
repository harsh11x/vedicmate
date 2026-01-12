import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import '../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Vedic Wisdom',
      subtitle: 'Ancient knowledge, Modern life',
      description: 'Discover the profound insights of Vedic astrology and how they influence your destiny.',
      icon: Icons.auto_awesome,
    ),
    OnboardingPage(
      title: 'Expert Guidance',
      subtitle: 'Connect with learned Pandits',
      description: 'Get personalized consultations from verified astrologers through chat or call.',
      icon: Icons.psychology,
    ),
    OnboardingPage(
      title: 'Spiritual Harmony',
      subtitle: 'Balance your cosmic energy',
      description: 'Perform rituals and remedies to align your life with the universe.',
      icon: Icons.balance,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: 600.ms,
        curve: Curves.easeOutCubic,
      );
    } else {
      context.pushReplacement('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.divineBackground,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            
            // PageView
            Expanded(
              flex: 3,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) => _buildPageContent(_pages[index]),
              ),
            ),

            // Controls
            Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicators
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: 300.ms,
                        margin: const EdgeInsets.only(right: 6),
                        height: 6,
                        width: _currentPage == index ? 24 : 6,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppTheme.divinePrimary
                              : AppTheme.divinePrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),

                  // Next Button (Minimal)
                  GestureDetector(
                    onTap: _nextPage,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.divinePrimary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.divinePrimary.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                      ),
                    ).animate(target: _currentPage == _pages.length - 1 ? 1 : 0)
                     .scale(begin: const Offset(1,1), end: const Offset(1.1, 1.1), duration: 200.ms),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image / Icon
          Expanded(
            child: Center(
              child: Container(
                width: 250,
                height: 250,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.divineSurface,
                  boxShadow: AppTheme.softShadow,
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ).animate(target: 1).scale(duration: 600.ms, curve: Curves.easeOutBack),
              ),
            ),
          ),
          
          const SizedBox(height: 48),

          Text(
            page.title,
            style: AppTheme.titleStyle.copyWith(fontSize: 32),
            textAlign: TextAlign.center,
          ).animate().fadeIn().slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 12),
          
          Text(
            page.subtitle.toUpperCase(),
            style: AppTheme.bodyStyle.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.divineGold,
              letterSpacing: 1.5,
            ),
             textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 24),
          
          Text(
            page.description,
            style: AppTheme.bodyStyle.copyWith(
              color: AppTheme.textGrey,
              height: 1.6,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms),
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

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
  });
}

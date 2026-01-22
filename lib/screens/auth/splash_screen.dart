import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  Future<void> _navigateToLogin() async {
    // Show splash for 2 seconds then go to login
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      context.pushReplacement('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.divineBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.divineSurface,
                boxShadow: AppTheme.softShadow,
              ),
              padding: const EdgeInsets.all(24),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
              ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: AppTheme.divinePrimary,
            ),
          ],
        ),
      ),
    );
  }
}

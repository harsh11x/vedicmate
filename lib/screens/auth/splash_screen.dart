import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Show splash for at least 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      final user = ref.read(authStateProvider).value;
      if (user != null) {
        context.go('/client/home');
      } else {
        context.pushReplacement('/login');
      }
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
              width: 220,
              height: 220,
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

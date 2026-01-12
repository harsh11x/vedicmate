import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Artificial delay to show logo
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

      debugPrint('SplashScreen: Manual Session Check -> $isLoggedIn');

      if (isLoggedIn) {
        context.go('/client/dashboard');
      } else {
        context.go('/login');
      }
    } catch (e) {
      debugPrint('SplashScreen error: $e');
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Hardcoded 'Divine Background' to avoid import circle if any
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 150, 
              height: 150,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.auto_awesome, size: 80, color: Color(0xFFC39130)),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Color(0xFF121212), // Divine Primary
                strokeWidth: 2,
              ),
            ), 
          ],
        ),
      ),
    );
  }
}

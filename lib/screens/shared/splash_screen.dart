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
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 200, 
              height: 200,
              errorBuilder: (_, __, ___) => const Icon(Icons.star, size: 80, color: Colors.orange),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: Colors.orange), 
          ],
        ),
      ),
    );
  }
}

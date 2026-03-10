import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // SplashScreen is just a passive loader. 
  // The AppRouter handles the navigation based on AuthState changes.
  @override
  void initState() {
    super.initState();
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
              width: 220,
              height: 220,
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

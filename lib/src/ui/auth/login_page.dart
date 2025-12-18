import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to VedicMate')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            const Text('Sign in with phone or social accounts', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () async {
                try {
                  await AuthService().signInWithGoogle();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to sign in: $e')),
                  );
                }
              },
              child: const Text('Sign in with Google'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: () {}, child: const Text('Sign in with Apple')),
          ],
        ),
      ),
    );
  }
}

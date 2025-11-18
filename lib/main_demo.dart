import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/registration_screen.dart';

void main() {
  runApp(const VedicMateDemo());
}

class VedicMateDemo extends StatelessWidget {
  const VedicMateDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Vedic Mate - Enhanced UI Demo',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegistrationScreen(),
    ),
    GoRoute(
      path: '/client/dashboard',
      builder: (context, state) => const DashboardDemo(userType: 'Client'),
    ),
    GoRoute(
      path: '/pandit/dashboard',
      builder: (context, state) => const DashboardDemo(userType: 'Pandit'),
    ),
    GoRoute(
      path: '/admin/dashboard',
      builder: (context, state) => const DashboardDemo(userType: 'Admin'),
    ),
  ],
);

class DashboardDemo extends StatelessWidget {
  final String userType;
  
  const DashboardDemo({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$userType Dashboard'),
        backgroundColor: AppTheme.yellowPrimary,
        foregroundColor: AppTheme.textDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.go('/login'),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF9E6),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.yellowPrimary, AppTheme.goldAccent],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.yellowPrimary.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  size: 60,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome to $userType Dashboard!',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Enhanced UI Demo - Login/Signup screens completed',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textLight,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppTheme.successGreen,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Enhanced Features Implemented:',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• Beautiful animated splash screen\n'
                      '• Enhanced login with role selection\n'
                      '• Improved registration with Kundli fields\n'
                      '• Gradient backgrounds and animations\n'
                      '• Better visual hierarchy and spacing\n'
                      '• Admin login functionality\n'
                      '• Pandit login support',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.yellowPrimary,
                  foregroundColor: AppTheme.textDark,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

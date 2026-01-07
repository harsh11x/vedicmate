import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/mandir_gate_animation.dart';
import '../../core/utils/validators.dart';
import '../../services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        User? user = await _authService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (mounted && user != null) {
          setState(() => _isLoading = false);
          context.go('/client/dashboard');
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(e.toString())),
                ],
              ),
              backgroundColor: AppTheme.errorRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }

  void _handleForgotPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address first'),
          backgroundColor: AppTheme.warningAmber,
        ),
      );
      return;
    }

    try {
      await _authService.sendPasswordResetEmail(_emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent! Check your inbox.'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    // Aggressively enforce dark visuals regardless of system theme
    
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B19), // Force Celestial Void
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Email Login',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: MandirGateAnimation(
        child: Stack(
          children: [
              // 1. Deep Space Background (Hardcoded)
               Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF0B0B19), // Deep Void
                          Color(0xFF150A26), // Deep Purple Haze
                          Color(0xFF000000), // Pure Black bottom
                        ],
                        stops: [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
              ),
              
              // 2. Starry Overlay (Subtle)
              Positioned.fill(
                child: CustomPaint(
                  painter: _StarFieldPainter(),
                ),
              ),
          
              // 3. Form Content
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo / Icon placeholder
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(colors: [AppTheme.primaryOrange, AppTheme.celestialPurple]),
                              boxShadow: [
                                BoxShadow(color: AppTheme.primaryOrange.withOpacity(0.4), blurRadius: 30, spreadRadius: 5),
                              ]
                            ),
                            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
                          ),
                          const SizedBox(height: 32),
                          
                          Text(
                            'Welcome Back',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(color: AppTheme.primaryOrange.withOpacity(0.5), blurRadius: 20),
                              ]
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to continue your cosmic journey',
                            style: GoogleFonts.outfit(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),
                          
                          // Email Field (Glass)
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.validateEmail,
                            style: GoogleFonts.outfit(color: Colors.white),
                            cursorColor: AppTheme.accentGold,
                            decoration: _buildGlassDecoration(
                              label: 'Email Address',
                              hint: 'Enter your email',
                              icon: Icons.email_outlined,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Password Field (Glass)
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            validator: Validators.validatePassword,
                            style: GoogleFonts.outfit(color: Colors.white),
                            cursorColor: AppTheme.accentGold,
                            decoration: _buildGlassDecoration(
                              label: 'Password',
                              hint: 'Enter your password',
                              icon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _handleForgotPassword,
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.accentGold,
                              ),
                              child: Text(
                                'Forgot Password?',
                                 style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Login Button (Gradient)
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [AppTheme.primaryOrange, Color(0xFFE11D48)],
                              ),
                               boxShadow: [
                                 BoxShadow(
                                   color: AppTheme.primaryOrange.withOpacity(0.4),
                                   blurRadius: 20,
                                   offset: const Offset(0, 8),
                                 )
                               ]
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text(
                                      'LOGIN',
                                      style: GoogleFonts.outfit(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ]
        ),
      ),
    );
  }

  InputDecoration _buildGlassDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.outfit(color: Colors.white.withOpacity(0.6)),
      hintText: hint,
      hintStyle: GoogleFonts.outfit(color: Colors.white.withOpacity(0.3)),
      prefixIcon: Icon(icon, color: Colors.white70),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFF1E1E2E).withOpacity(0.4), // Dark Glass
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.errorRed, width: 1.5),
      ),
    );
  }
}

// Simple star field painter for extra cosmic vibe
class _StarFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.2);
    // Random stars would ideally be cached, but for now we draw some fixed positions relative to size
    // to avoid flickering on rebuilds if we used Random().
    
    // Draw ~50 pseudo-random stars
    for (int i = 0; i < 50; i++) {
       final x = (i * 137.5) % size.width;
       final y = (i * 293.3) % size.height;
       final radius = (i % 3 == 0) ? 1.5 : 0.8;
       canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


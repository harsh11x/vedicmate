import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart' hide User;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../core/constants/app_constants.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/abstract_background.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  // Separate form keys
  final _emailFormKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final AuthService _authService;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _authService = ref.read(authServiceProvider);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Auth Handlers ---

  void _handleGoogleSignUp() async {
    setState(() => _isLoading = true);
    try {
      User? user = await _authService.signInWithGoogle(AppConstants.roleClient);
      if (mounted && user != null) {
        await _navigateAfterAuth(user);
      }
    } catch (e) {
      if (mounted) _showSnackBar(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleAppleSignUp() async {
    setState(() => _isLoading = true);
    try {
      User? user = await _authService.signInWithApple(AppConstants.roleClient);
      if (mounted && user != null) {
        await _navigateAfterAuth(user);
      }
    } catch (e) {
      if (mounted) _showSnackBar(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleEmailRegister() async {
    if (_emailFormKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        User? user = await _authService.register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          '',
          _passwordController.text,
          AppConstants.roleClient,
        );

        if (mounted && user != null) {
          _showSnackBar('Account created successfully!', isSuccess: true);
          await _navigateAfterAuth(user);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showSnackBar(e.toString(), isError: true);
        }
      }
    }
  }

  Future<void> _navigateAfterAuth(User user) async {
    await _authService.ensureUserProfile(user: user, name: _nameController.text.isNotEmpty ? _nameController.text : null);

    if (!user.isAnonymous) {
      try {
        await NotificationService.saveFCMTokenForUser(user.uid);
      } catch (_) {}
    }

    await _authService.saveUserSession();

    if (mounted) {
      setState(() => _isLoading = false);
      // Directly navigate to dashboard as per user request
      context.go('/client/dashboard'); 
    }
  }

  void _showSnackBar(String message, {bool isError = false, bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
             Icon(
              isError ? Icons.error_outline : (isSuccess ? Icons.check_circle : Icons.info_outline),
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? AppTheme.errorRed : (isSuccess ? AppTheme.successGreen : AppTheme.neutralDark),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // --- Responsive Helpers ---
  bool get _isIOS => Platform.isIOS;
  double get _spacingSmall => _isIOS ? 8.0 : 16.0;
  double get _spacingMedium => _isIOS ? 16.0 : 24.0;
  double get _spacingLarge => _isIOS ? 20.0 : 32.0; // was 20:32
  double get _logoHeight => _isIOS ? 130.0 : 160.0;
  double get _buttonHeight => _isIOS ? 48.0 : 56.0; // Standard Android touch target
  bool get _isDense => _isIOS;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: AbstractBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: _isIOS ? 8 : 24),
              child: Column(
                children: [
                  // Logo
                  SizedBox(
                    height: _logoHeight,
                    width: _logoHeight,
                    child: Image.asset('assets/images/ChatGPT Image Nov 3, 2025 at 09_33_25 PM-2.png', fit: BoxFit.contain),
                  ),
                  SizedBox(height: _spacingSmall), 
                  
                  Text(
                    'Create Account',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: _isIOS ? 24 : 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.neutralDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Join our spiritual community today',
                    style: GoogleFonts.outfit(
                      fontSize: _isIOS ? 14 : 16,
                      color: AppTheme.neutralMedium,
                    ),
                  ),
                  SizedBox(height: _spacingLarge),

                  // Form Container
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    alignment: Alignment.topCenter,
                    child: Container(
                      decoration: AppTheme.glassMorphism,
                      padding: EdgeInsets.all(_isIOS ? 16 : 24),
                      child: Column(
                        children: [
                          _buildEmailForm(),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: _spacingMedium),
                  
                  // Divider
                   Row(
                    children: [
                      Expanded(child: Divider(color: AppTheme.forestBackground.withOpacity(0.8))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: GoogleFonts.outfit(
                            color: AppTheme.neutralMedium,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: AppTheme.forestBackground.withOpacity(0.8))),
                    ],
                  ),
                  SizedBox(height: _spacingMedium),

                  // Sign up with Apple (required by App Store when offering Google)
                  if (Platform.isIOS)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SizedBox(
                        height: _buttonHeight,
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _handleAppleSignUp,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.neutralDark),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            backgroundColor: AppTheme.white,
                            foregroundColor: AppTheme.neutralDark,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.apple, size: 24, color: AppTheme.neutralDark),
                              const SizedBox(width: 12),
                              Text(
                                'Sign up with Apple',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Google Sign Up
                  SizedBox(
                    height: _buttonHeight,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _handleGoogleSignUp,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        side: const BorderSide(color: AppTheme.forestBackground),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: AppTheme.white,
                        foregroundColor: AppTheme.neutralDark,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            // Image.asset(
                            //   'assets/images/google_logo.png',
                            //   height: 24,
                            //   width: 24,
                            //   errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 28),
                            // ),
                            const Icon(Icons.g_mobiledata, size: 28, color: AppTheme.primaryOrange),
                          const SizedBox(width: 12),
                          Text(
                            'Sign up with Google',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: _spacingLarge),
                  
                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: GoogleFonts.outfit(color: AppTheme.neutralMedium, fontSize: _isIOS ? 12 : 14),
                      ),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        child: Text(
                          'Login', 
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.primaryOrange, fontSize: _isIOS ? 12 : 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, 
      {TextInputType? type, String? Function(String?)? validator, bool isPassword = false, Widget? suffix, String? prefixText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: _isIOS ? 13 : 15,
            color: AppTheme.neutralDark,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: type,
          validator: validator,
          obscureText: isPassword,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Enter your ${label.toLowerCase()}',
            prefixText: prefixText,
            prefixIcon: Icon(icon, color: AppTheme.neutralMedium, size: 18),
            suffixIcon: suffix,
            filled: true,
            fillColor: AppTheme.forestBackground.withOpacity(0.5),
            contentPadding: _isIOS 
              ? const EdgeInsets.symmetric(horizontal: 12, vertical: 12)
              : const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            isDense: _isDense, 
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailForm() {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildField(
            _nameController,
            'Full Name',
            Icons.person_outline_rounded,
            validator: Validators.validateName,
            type: TextInputType.name,
          ),
          const SizedBox(height: 12),
          _buildField(
            _emailController,
            'Email Address',
            Icons.email_outlined,
            validator: Validators.validateEmail,
            type: TextInputType.emailAddress,
          ),
          _buildField(
            _passwordController,
            'Password', 
            Icons.lock_outline_rounded,
            validator: Validators.validatePassword,
            isPassword: _obscurePassword,
            suffix: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleEmailRegister,
              child: _isLoading 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Create Account'),
            ),
          ),
        ],
      ),
    );
  }
}

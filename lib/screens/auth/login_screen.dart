import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../core/constants/app_constants.dart';
import '../../services/auth_service.dart';
import '../../services/user_preferences_service.dart';
import '../../widgets/abstract_background.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  late final AuthService _authService; // Use provider
  final _prefsService = UserPreferencesService();

  bool _isOTPSent = false;
  bool _isLoading = false;
  // Client-only app - no role selection needed
  static const String _userRole = AppConstants.roleClient;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _authService = ref.read(authServiceProvider); // Get shared instance
    try {
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      );
      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );
      _slideAnimation = Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
      _animationController.forward();
    } catch (e) {
      debugPrint('Animation error: $e');
    }
  }

  void _handleSendOTP() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      await _authService.sendOTP(
        _phoneController.text, 
        _userRole,
        onCodeSent: () {
          if (mounted) {
            setState(() {
              _isOTPSent = true;
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Text('OTP sent to +91 ${_phoneController.text}'),
                  ],
                ),
                backgroundColor: AppTheme.successGreen,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
        onVerificationCompleted: (User user) async {
          if (mounted) {
             setState(() => _isLoading = false);
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(child: Text('Phone verified automatically!')),
                  ],
                ),
                backgroundColor: AppTheme.successGreen,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
            await _navigateAfterLogin(user);
          }
        },
        onError: (message) {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppTheme.errorRed,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      );
    }
  }

  void _handleVerifyOTP() async {
    if (_otpController.text.isEmpty || _otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter valid 6-digit OTP'),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      User? user = await _authService.verifyOTP(
        _otpController.text,
        _phoneController.text,
        _userRole,
      );

      if (mounted && user != null) {
        await _navigateAfterLogin(user);
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleAuthError(Object error) {
    if (mounted) {
      setState(() => _isLoading = false);
      String message = error.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _navigateAfterLogin(User user) async {
    // Ensure user profile exists (Auto-migrate existing users)
    await _authService.ensureUserProfile(user: user);

    // MANUAL PERSISTENCE: Save session immediately
    await _authService.saveUserSession();

    if (mounted) {
      // Directly navigate to dashboard as per user request
      context.go('/client/dashboard');
    }
  }

  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      User? user = await _authService.signInWithGoogle(_userRole);
      
      if (mounted && user != null) {
        await _navigateAfterLogin(user);
        if (mounted) setState(() => _isLoading = false);
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      _handleAuthError(e);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Platform-specific sizing
    final isIOS = Platform.isIOS;
    final double logoHeight = isIOS ? 120 : 180;
    final double titleSize = isIOS ? 28 : 34; // Larger title for Android
    final double buttonHeight = isIOS ? 48 : 56; // Standard touch target
    final double spacingSmall = isIOS ? 8 : 16;
    final double spacingMedium = isIOS ? 16 : 24;
    final double spacingLarge = isIOS ? 24 : 40;
    final bool isDense = isIOS; // True for IOS (Compact), False for Android (Spacious)

    return Scaffold(
      backgroundColor: AppTheme.divineBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Stack(
        children: [
          // Background Pattern (subtle gradient/color only)
          Positioned.fill(
             child: Container(color: Colors.transparent), // Placeholder if needed, or just remove
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: isIOS ? 8 : 24),
                child: Column(
                  children: [
                    // 1. Logo
                    SizedBox(
                      height: logoHeight,
                      width: logoHeight,
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms),
                    
                    SizedBox(height: spacingMedium),
                    
                    // 2. Title (Playfair Display)
                    Text(
                      'VEDIC MATE',
                      style: AppTheme.titleStyle.copyWith(
                        fontSize: titleSize,
                        letterSpacing: 1.2,
                        color: AppTheme.divinePrimary,
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
                    
                    Text(
                      'Spiritual guidance for the modern age',
                      style: AppTheme.bodyStyle.copyWith(
                        color: AppTheme.textGrey,
                        fontSize: isIOS ? 14 : 16,
                      ),
                    ).animate().fadeIn(delay: 600.ms),
                    
                    SizedBox(height: spacingLarge * 1.5),

                    // 3. Form Section (Clean, no heavy glass box)
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!_isOTPSent) ...[
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              validator: Validators.validatePhone,
                              style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                hintText: '9876543210',
                                prefixText: '+91 ',
                                prefixIcon: const Icon(Icons.phone_outlined, color: AppTheme.textGrey),
                              ),
                            ).animate().fadeIn(delay: 800.ms).slideX(begin: -0.1, end: 0),
                            
                            SizedBox(height: spacingMedium),
                            
                            ElevatedButton(
                              onPressed: _isLoading ? null : _handleSendOTP,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: _isLoading
                                ? const SizedBox(
                                      height: 24, 
                                      width: 24, 
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                    )
                                  : Text('Send OTP', style: TextStyle(letterSpacing: 1.0)),
                            ).animate().fadeIn(delay: 1000.ms).slideX(begin: 0.1, end: 0),
                          ] else ...[
                            // OTP Input
                            TextFormField(
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              textAlign: TextAlign.center,
                              style: AppTheme.titleStyle.copyWith(
                                fontSize: 28,
                                letterSpacing: 12,
                                color: AppTheme.divinePrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: '••••••',
                                counterText: '',
                                fillColor: AppTheme.divineSurface,
                              ),
                            ).animate().fadeIn(),
                            
                            SizedBox(height: spacingMedium),
                            
                            ElevatedButton(
                              onPressed: _isLoading ? null : _handleVerifyOTP,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Verify & Login'),
                            ).animate().fadeIn(delay: 200.ms),
                            
                            TextButton(
                              onPressed: () => setState(() => _isOTPSent = false),
                              child: Text('Change Phone Number', style: TextStyle(color: AppTheme.textGrey)),
                            ).animate().fadeIn(delay: 400.ms),
                          ],
                        ],
                      ),
                    ),
                    
                    SizedBox(height: spacingLarge),
                    
                    // 4. Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.withOpacity(0.2))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR CONTINUE WITH',
                            style: AppTheme.bodyStyle.copyWith(
                              fontSize: 10, 
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textGrey,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.withOpacity(0.2))),
                      ],
                    ).animate().fadeIn(delay: 1200.ms),
                    
                    SizedBox(height: spacingMedium),

                    // 5. Social Buttons (Minimal Outline)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _handleGoogleSignIn,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Image.asset('assets/images/google_logo.png', height: 20),
                                const Icon(Icons.g_mobiledata, size: 32, color: AppTheme.primaryOrange),
                                const SizedBox(width: 8),
                                const Text('Google'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                         Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.push('/login/email'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.email_outlined, size: 20),
                                SizedBox(width: 8),
                                Text('Email'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 1400.ms).slideY(begin: 0.2, end: 0),
                    
                    SizedBox(height: spacingMedium),
                    
                    // 6. Guest Mode Button
                    TextButton(
                      onPressed: () async {
                         setState(() => _isLoading = true);
                         try {
                           final user = await _authService.signInAsGuest();
                           if (mounted && user != null) {
                             await _navigateAfterLogin(user);
                           }
                         } catch (e) {
                           _handleAuthError(e);
                         } finally {
                           if (mounted) setState(() => _isLoading = false);
                         }
                      },
                      child: Text(
                        'Continue as Guest', 
                        style: AppTheme.bodyStyle.copyWith(
                          color: AppTheme.divineGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ).animate().fadeIn(delay: 1600.ms),

                    SizedBox(height: spacingLarge * 2),

                    // 6. Registration Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "New to Vedic Mate? ",
                          style: AppTheme.bodyStyle.copyWith(color: AppTheme.textGrey),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/register'),
                          child: Text(
                            'Create Account',
                            style: AppTheme.bodyStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.divineGold,
                              decoration: TextDecoration.underline,
                              decorationColor: AppTheme.divineGold.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 1600.ms),
                    
                    SizedBox(height: spacingLarge),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _EnhancedRoleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _EnhancedRoleButton({
    required this.label,
    required this.icon,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppTheme.yellowPrimary, AppTheme.goldAccent],
                )
              : null,
          color: isSelected ? null : Colors.grey[50],
          border: Border.all(
            color: isSelected ? AppTheme.yellowPrimary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.yellowPrimary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppTheme.textDark : AppTheme.yellowPrimary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.textDark : AppTheme.textDark,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                color: isSelected ? AppTheme.textDark.withOpacity(0.8) : AppTheme.textLight,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AIBenefitItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _AIBenefitItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.yellowPrimary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.yellowPrimary.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            size: 22,
            color: AppTheme.yellowPrimary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.neutralDark,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.neutralMedium,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


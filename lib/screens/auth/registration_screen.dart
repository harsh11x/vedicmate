import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../core/constants/app_constants.dart';
import '../../services/auth_service.dart';
import '../../widgets/abstract_background.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // Separate form keys
  final _phoneFormKey = GlobalKey<FormState>();
  final _emailFormKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController(); // For Phone Tab
  final _emailPhoneController = TextEditingController(); // For Email Tab (optional phone)
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  final _authService = AuthService();
  bool _isLoading = false;
  bool _isOTPSent = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {}); // Rebuild to update slider UI
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailPhoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // --- Auth Handlers ---

  void _handleGoogleSignUp() async {
    setState(() => _isLoading = true);
    try {
      User? user = await _authService.signInWithGoogle(AppConstants.roleClient);
      if (mounted && user != null) {
        await _navigateAfterAuth(user);
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar(e.toString(), isError: true);
      }
    }
  }

  void _handleSendOTP() async {
    if (_phoneFormKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final phone = _phoneController.text.trim();

      // Check uniqueness
      final isTaken = await _authService.isMobileNumberTaken(phone); // Check raw or +91
      if (isTaken) {
        if (mounted) {
           setState(() => _isLoading = false);
           _showSnackBar('This mobile number is already registered. Please login.', isError: true);
        }
        return;
      }

      await _authService.sendOTP(
        phone, 
        AppConstants.roleClient,
        onCodeSent: () {
          if (mounted) {
            setState(() {
              _isOTPSent = true;
              _isLoading = false;
            });
            _showSnackBar('OTP sent to +91 $phone', isSuccess: true);
          }
        },
        onVerificationCompleted: (User user) async {
           if (mounted) {
             _showSnackBar('Phone verified verification complete!', isSuccess: true);
             await _navigateAfterAuth(user);
           }
        },
        onError: (message) {
          if (mounted) {
            setState(() => _isLoading = false);
            _showSnackBar(message, isError: true);
          }
        },
      );
    }
  }

  void _handleVerifyOTP() async {
    if (_otpController.text.length != 6) {
      _showSnackBar('Please enter valid 6-digit OTP', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      User? user = await _authService.verifyOTP(
        _otpController.text,
        _phoneController.text,
        AppConstants.roleClient,
      );

      if (mounted && user != null) {
        // Update display name for phone users since we collected it
        if (_nameController.text.isNotEmpty) {
           await user.updateDisplayName(_nameController.text.trim());
        }
        await _navigateAfterAuth(user);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar(e.toString(), isError: true);
      }
    }
  }

  void _handleEmailRegister() async {
    if (_emailFormKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final phoneInput = _emailPhoneController.text.trim();
      String phoneToSave = '';

      if (phoneInput.isNotEmpty) {
        // Enforce +91 prefix for saving
        phoneToSave = '+91$phoneInput'; 
        
        // Check uniqueness
        final isTaken = await _authService.isMobileNumberTaken(phoneInput);
        if (isTaken) {
          if (mounted) {
             setState(() => _isLoading = false);
             _showSnackBar('This mobile number is already registered.', isError: true);
          }
          return;
        }
      }

      try {
        User? user = await _authService.register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          phoneToSave, // Pass formatted phone
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
    
    // MANUAL PERSISTENCE: Save session immediately
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
  double get _logoHeight => _isIOS ? 90.0 : 120.0; // Bump for Android
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

                  // Premium Segmented Control
                  Container(
                    height: _buttonHeight,
                    decoration: BoxDecoration(
                      color: AppTheme.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.forestBackground),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        AnimatedAlign(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          alignment: _tabController.index == 0 ? Alignment.centerLeft : Alignment.centerRight,
                          child: FractionallySizedBox(
                            widthFactor: 0.5,
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryOrange.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _tabController.animateTo(0),
                                behavior: HitTestBehavior.opaque,
                                child: Center(
                                  child: Text(
                                    'Phone',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: _isIOS ? 14 : 16,
                                      color: _tabController.index == 0 ? Colors.white : AppTheme.neutralMedium,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _tabController.animateTo(1),
                                behavior: HitTestBehavior.opaque,
                                child: Center(
                                  child: Text(
                                    'Email',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: _isIOS ? 14 : 16,
                                      color: _tabController.index == 1 ? Colors.white : AppTheme.neutralMedium,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
                          [_buildPhoneForm(), _buildEmailForm()][_tabController.index],
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

  Widget _buildPhoneForm() {
    return Form(
      key: _phoneFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_isOTPSent) ...[
            _buildField(
              _nameController,
              'Full Name', 
              Icons.person_outline_rounded,
              validator: Validators.validateName,
              type: TextInputType.name,
            ),
            SizedBox(height: _spacingSmall),
            _buildField(
              _phoneController,
              'Phone Number',
              Icons.phone_android_rounded,
              type: TextInputType.phone,
              validator: Validators.validatePhone,
              prefixText: '+91 ',
            ),
            SizedBox(height: _spacingMedium),
            SizedBox(
              height: _buttonHeight,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSendOTP,
                child: _isLoading 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Send Verification Code'),
              ),
            ),
          ] else ...[
             Text(
              'Enter the code sent to +91 ${_phoneController.text}',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: AppTheme.neutralMedium, fontSize: 14),
            ),
            SizedBox(height: _spacingMedium),
             TextFormField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: GoogleFonts.outfit(fontSize: 20, letterSpacing: 8, fontWeight: FontWeight.bold, color: AppTheme.primaryOrange),
              decoration: InputDecoration(
                hintText: '••••••',
                counterText: '',
                fillColor: AppTheme.neutralSoft,
                isDense: _isDense,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            SizedBox(height: _spacingMedium),
            SizedBox(
              height: _buttonHeight,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleVerifyOTP,
                child: _isLoading 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Verify & Create Account'),
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => setState(() => _isOTPSent = false),
              child: const Text('Change Phone Number'),
            ),
          ]
        ],
      ),
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
          const SizedBox(height: 12),
           _buildField(
            _emailPhoneController,
            'Phone Number (Optional)',
            Icons.phone_outlined,
            type: TextInputType.phone,
            prefixText: '+91 ',
          ),
          const SizedBox(height: 12),
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

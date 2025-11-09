import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../core/constants/app_constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '1234567890');
  final _otpController = TextEditingController();
  bool _isOTPSent = false;
  bool _isLoading = false;
  String? _userRole; // 'client' or 'pandit'

  // Demo credentials
  static const String demoPhone = '1234567890';
  static const String demoOTP = '123456';

  void _handleSendOTP() {
    if (_phoneController.text == demoPhone) {
      setState(() {
        _isOTPSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent successfully! Use OTP: 123456'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please use demo number: 1234567890'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  void _handleVerifyOTP() {
    if (_otpController.text == demoOTP) {
      setState(() => _isLoading = true);
      // Determine role based on context or let user choose
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _isLoading = false);
          if (_userRole == AppConstants.rolePandit) {
            context.go('/pandit/dashboard');
          } else {
            context.go('/client/dashboard');
          }
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid OTP. Use: 123456'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  void _handleAdminLogin() {
    showDialog(
      context: context,
      builder: (context) => _AdminLoginDialog(),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Skip button (top right)
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => context.go('/client/dashboard'),
                  child: const Text('Skip'),
                ),
              ),
              const SizedBox(height: 20),
              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.yellowPrimary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  size: 70,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 24),
              // App Name
              Text(
                'Vedic Mate',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 32),
              // Free Chat Banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  border: Border.all(color: AppTheme.yellowPrimary, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.celebration, color: AppTheme.yellowPrimary, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'First Chat with Pandit is FREE!',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Login Form
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!_isOTPSent) ...[
                        // Phone Input
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            hintText: 'Enter phone number',
                            prefixText: 'IN +91 ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppTheme.yellowPrimary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Role Selection
                        Row(
                          children: [
                            Expanded(
                              child: _RoleButton(
                                label: 'Client',
                                isSelected: _userRole != AppConstants.rolePandit,
                                onTap: () => setState(() => _userRole = AppConstants.roleClient),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _RoleButton(
                                label: 'Pandit',
                                isSelected: _userRole == AppConstants.rolePandit,
                                onTap: () => setState(() => _userRole = AppConstants.rolePandit),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Send OTP Button
                        ElevatedButton(
                          onPressed: _handleSendOTP,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.yellowPrimary,
                            foregroundColor: AppTheme.textDark,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('SEND OTP'),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward),
                            ],
                          ),
                        ),
                      ] else ...[
                        // OTP Input
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: InputDecoration(
                            labelText: 'Enter OTP',
                            hintText: '123456',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppTheme.yellowPrimary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => setState(() => _isOTPSent = false),
                          child: const Text('Change Phone Number'),
                        ),
                        const SizedBox(height: 24),
                        // Verify OTP Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleVerifyOTP,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.yellowPrimary,
                            foregroundColor: AppTheme.textDark,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('VERIFY OTP'),
                        ),
                      ],
                      const SizedBox(height: 16),
                      // Terms
                      Text(
                        'By signing up, you agree to our Terms of Use and Privacy Policy',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[300])),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Or',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey[300])),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Social Login
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.g_mobiledata),
                        label: const Text('Login with Google'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppTheme.yellowPrimary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Admin Login
                      TextButton(
                        onPressed: _handleAdminLogin,
                        child: const Text('Admin Login'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // App Stats
              Container(
                padding: const EdgeInsets.all(16),
                color: AppTheme.creamPrimary,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(icon: Icons.lock, text: '100% Privacy'),
                    _StatItem(icon: Icons.people, text: '10000+ Top Pandits'),
                    _StatItem(icon: Icons.favorite, text: '3Cr+ Happy Customers'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.yellowPrimary : AppTheme.white,
          border: Border.all(
            color: isSelected ? AppTheme.yellowPrimary : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppTheme.textDark : AppTheme.textLight,
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _StatItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.yellowPrimary),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _AdminLoginDialog extends StatefulWidget {
  @override
  State<_AdminLoginDialog> createState() => _AdminLoginDialogState();
}

class _AdminLoginDialogState extends State<_AdminLoginDialog> {
  final _emailController = TextEditingController(text: 'vedicmate2025@gmail.com');
  final _passwordController = TextEditingController(text: 'admin123');
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _handleAdminLogin() {
    if (_formKey.currentState!.validate()) {
      if (_emailController.text == 'vedicmate2025@gmail.com' &&
          _passwordController.text == 'admin123') {
        setState(() => _isLoading = true);
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pop(context);
            context.go('/admin/dashboard');
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid admin credentials'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Admin Login',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleAdminLogin,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

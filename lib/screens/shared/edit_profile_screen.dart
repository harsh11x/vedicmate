import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/country_codes.dart';
import '../../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isOTPSent = false;
  bool _isVerifying = false;
  CountryCode _selectedCountry = countryCodes.first;
  String? _verifiedPhone; // Phone that passed OTP (to save to Supabase)

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _parseAndSetPhone(String? fullPhone) {
    if (fullPhone == null || fullPhone.isEmpty) return;
    for (final cc in countryCodes) {
      if (cc.dialCode != '+' && fullPhone.startsWith(cc.dialCode)) {
        final number = fullPhone.substring(cc.dialCode.length).replaceAll(RegExp(r'\D'), '');
        _selectedCountry = cc;
        _phoneController.text = number;
        return;
      }
    }
    _phoneController.text = fullPhone.replaceAll(RegExp(r'\D'), '');
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _nameController.text = user.displayName ?? '';
        _emailController.text = user.email ?? '';
      });

      try {
        final data = await Supabase.instance.client
            .from('users')
            .select()
            .eq('id', user.uid)
            .maybeSingle();

        if (data != null && mounted) {
          _nameController.text = data['name'] ?? user.displayName ?? '';
          _parseAndSetPhone(data['phone'] ?? user.phoneNumber ?? '');
          _verifiedPhone = data['phone'] as String?;
          setState(() {});
        } else {
          _parseAndSetPhone(user.phoneNumber);
          _verifiedPhone = user.phoneNumber;
          if (mounted) setState(() {});
        }
      } catch (e) {
        debugPrint('Error loading user data: $e');
        _parseAndSetPhone(user.phoneNumber);
        _verifiedPhone = user.phoneNumber;
        if (mounted) setState(() {});
      }
    }
  }

  String get _fullPhone {
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    return '${_selectedCountry.dialCode}$digits';
  }

  Future<void> _saveNameOnly() async {
    if (_nameController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await user.updateDisplayName(_nameController.text);
      await user.reload();
      await Supabase.instance.client.from('users').update({'name': _nameController.text}).eq('id', user.uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Name updated'), backgroundColor: AppTheme.successGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendOTP() async {
    final phone = _fullPhone;
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid phone number'), backgroundColor: AppTheme.errorRed));
      return;
    }
    if (_validatePhone(_phoneController.text) != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid phone number'), backgroundColor: AppTheme.errorRed));
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _isLoading = true);
    final isTaken = await _authService.isPhoneTakenByOtherUser(phone, user.uid);
    if (mounted && isTaken) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This number is already registered with another account'), backgroundColor: AppTheme.errorRed),
      );
      return;
    }
    if (!mounted) return;
    _authService.sendOTPForPhoneUpdate(
      phone,
      onCodeSent: () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isOTPSent = true;
            _otpController.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('OTP sent to $phone'), backgroundColor: AppTheme.successGreen),
          );
        }
      },
      onError: (msg) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppTheme.errorRed));
        }
      },
    );
  }

  Future<void> _verifyAndSavePhone() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter 6-digit OTP'), backgroundColor: AppTheme.errorRed));
      return;
    }
    final phone = _fullPhone;
    setState(() => _isVerifying = true);
    try {
      await _authService.verifyOTPAndUpdatePhone(otp, phone);
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('users').update({'phone': phone}).eq('id', user.uid);
      }
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _isOTPSent = false;
          _verifiedPhone = phone;
          _otpController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phone number verified and saved!'), backgroundColor: AppTheme.successGreen),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _isVerifying = false);
        String msg = 'Verification failed';
        if (e.code == 'invalid-verification-code') msg = 'Invalid OTP. Please try again.';
        else if (e.code == 'credential-already-in-use') msg = 'This number is already linked to another account.';
        else if (e.code == 'requires-recent-login') msg = 'Please sign out and sign in again, then try verifying.';
        else if (e.message != null) msg = e.message!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppTheme.errorRed));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isVerifying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: $e'), backgroundColor: AppTheme.errorRed),
        );
      }
    }
  }

  void _cancelOTP() {
    setState(() {
      _isOTPSent = false;
      _otpController.clear();
    });
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await user.updateDisplayName(_nameController.text);
      await user.reload();
      final updateData = <String, dynamic>{'name': _nameController.text};
      if (_verifiedPhone != null && _verifiedPhone!.isNotEmpty) {
        updateData['phone'] = _verifiedPhone;
      }
      await Supabase.instance.client.from('users').update(updateData).eq('id', user.uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: AppTheme.successGreen),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your phone number';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (_selectedCountry.code == 'IN') {
      if (digits.length != 10) return 'Indian number must be exactly 10 digits';
      if (!RegExp(r'^[6-9]\d{9}$').hasMatch(digits)) return 'Enter a valid 10-digit Indian mobile number';
    } else if (digits.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.neutralSoft,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppTheme.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save', style: TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.white, width: 4),
                    ),
                    child: user?.photoURL != null
                        ? ClipOval(
                            child: Image.network(user!.photoURL!, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 60, color: Colors.white)),
                          )
                        : const Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppTheme.primaryOrange, shape: BoxShape.circle, border: Border.all(color: AppTheme.white, width: 2)),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppTheme.neutralSoft,
                ),
                readOnly: true,
                enabled: false,
              ),
              const SizedBox(height: 24),

              // Phone section with OTP verification
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.forestBackground.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.phone, color: AppTheme.primaryOrange),
                        const SizedBox(width: 8),
                        Text('Phone Number', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                        if (_verifiedPhone != null && _verifiedPhone!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Chip(
                              label: const Text('Verified', style: TextStyle(fontSize: 11)),
                              backgroundColor: AppTheme.successGreen.withOpacity(0.2),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 110,
                          child: DropdownButtonFormField<CountryCode>(
                            value: _selectedCountry,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                            ),
                            isExpanded: true,
                            items: countryCodes.map((cc) => DropdownMenuItem(value: cc, child: Text('${cc.code} ${cc.dialCode}', style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis))).toList(),
                            onChanged: _isOTPSent ? null : (cc) { if (cc != null) setState(() => _selectedCountry = cc); },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              hintText: _selectedCountry.code == 'IN' ? '9876543210' : 'Phone',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            keyboardType: TextInputType.number,
                            enabled: !_isOTPSent,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(_selectedCountry.code == 'IN' ? 10 : 15),
                            ],
                            validator: _validatePhone,
                          ),
                        ),
                      ],
                    ),
                    if (!_isOTPSent) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _sendOTP,
                          icon: _isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send, size: 18),
                          label: Text(_isLoading ? 'Sending OTP...' : 'Send OTP to Verify'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryOrange,
                            side: const BorderSide(color: AppTheme.primaryOrange),
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 16),
                      Text('Enter 6-digit OTP sent to ${_fullPhone}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _otpController,
                        decoration: InputDecoration(
                          hintText: '000000',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          counterText: '',
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isVerifying ? null : _cancelOTP,
                              child: const Text('Change Number'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isVerifying ? null : _verifyAndSavePhone,
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange),
                              child: _isVerifying ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Verify & Save'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

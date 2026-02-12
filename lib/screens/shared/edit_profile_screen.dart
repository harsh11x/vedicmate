import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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
  final _authService = AuthService();
  bool _isLoading = false;
  CountryCode _selectedCountry = countryCodes.first;
  bool _hasExistingEmail = false; // True if user already has email (Firebase or Supabase)
  File? _selectedImage; // Selected image for profile picture
  bool _isUploadingImage = false; // Loading state for image upload

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
      // For guest accounts, hardcode email and phone
      if (user.isAnonymous) {
        setState(() {
          _nameController.text = user.displayName ?? 'Guest User';
          _emailController.text = 'vedicmate@gmail.com';
          _hasExistingEmail = true; // Make email read-only for guests
        });
        _parseAndSetPhone('+919898989898');
        return;
      }

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
          final dbEmail = data['email'] as String?;
          final firebaseEmail = user.email;
          _hasExistingEmail = (dbEmail != null && dbEmail.isNotEmpty) || (firebaseEmail != null && firebaseEmail.isNotEmpty);
          if (dbEmail != null && dbEmail.isNotEmpty) {
            _emailController.text = dbEmail;
          } else if (firebaseEmail != null && firebaseEmail.isNotEmpty) {
            _emailController.text = firebaseEmail;
          }
          setState(() {});
        } else {
          _parseAndSetPhone(user.phoneNumber);
          _hasExistingEmail = (user.email != null && user.email!.isNotEmpty);
          if (mounted) setState(() {});
        }
      } catch (e) {
        debugPrint('Error loading user data: $e');
        _parseAndSetPhone(user.phoneNumber);
        _hasExistingEmail = (user.email != null && user.email!.isNotEmpty);
        if (mounted) setState(() {});
      }
    }
  }

  String get _fullPhone {
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    return '${_selectedCountry.dialCode}$digits';
  }

  Future<void> _savePhone() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Prevent guest users from changing phone
    if (user.isAnonymous) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Guest accounts cannot modify phone number'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    final phone = _fullPhone;
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid phone number'), backgroundColor: AppTheme.errorRed),
      );
      return;
    }
    final validation = _validatePhone(_phoneController.text);
    if (validation != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validation), backgroundColor: AppTheme.errorRed),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final isTaken = await _authService.isPhoneTakenByOtherUser(phone, user.uid);
      if (mounted && isTaken) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This number is already in use with another account. Please use another number.'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
        return;
      }
      if (!mounted) return;

      await Supabase.instance.client.from('users').update({'phone': phone}).eq('id', user.uid);
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phone number saved successfully!'), backgroundColor: AppTheme.successGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed),
        );
      }
    }
  }

  Future<void> _saveEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Prevent guest users from changing email
    if (user.isAnonymous) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Guest accounts cannot modify email'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email address'), backgroundColor: AppTheme.errorRed),
      );
      return;
    }
    final validation = _validateEmail(email);
    if (validation != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validation), backgroundColor: AppTheme.errorRed),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final isTaken = await _authService.isEmailTakenByOtherUser(email, user.uid);
      if (mounted && isTaken) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This email is already in use with another account. Please use another email.'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
        return;
      }
      if (!mounted) return;

      await Supabase.instance.client.from('users').update({'email': email}).eq('id', user.uid);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasExistingEmail = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email saved successfully!'), backgroundColor: AppTheme.successGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed),
        );
      }
    }
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name'), backgroundColor: AppTheme.errorRed),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      await user.updateDisplayName(name);
      await user.reload();
      await Supabase.instance.client.from('users').update({'name': name}).eq('id', user.uid);
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Name updated successfully!'), backgroundColor: AppTheme.successGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed),
        );
      }
    }
  }

  Future<void> _saveAll() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // For guest users, only allow name changes
    if (user.isAnonymous) {
      setState(() => _isLoading = true);
      try {
        final name = _nameController.text.trim();
        if (name.isNotEmpty) {
          await user.updateDisplayName(name);
          await user.reload();
          await Supabase.instance.client.from('users').update({'name': name}).eq('id', user.uid);
        }
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Name updated successfully! Email and phone cannot be changed for guest accounts.'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed),
          );
        }
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Save name
      final name = _nameController.text.trim();
      if (name.isNotEmpty) {
        await user.updateDisplayName(name);
        await user.reload();
      }

      final updateData = <String, dynamic>{'name': name.isNotEmpty ? name : user.displayName ?? ''};

      // Phone: validate and check duplicate before saving
      final phone = _fullPhone;
      if (phone.isNotEmpty && _validatePhone(_phoneController.text) == null) {
        final isPhoneTaken = await _authService.isPhoneTakenByOtherUser(phone, user.uid);
        if (isPhoneTaken) {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('This number is already in use with another account. Please use another number.'),
                backgroundColor: AppTheme.errorRed,
              ),
            );
          }
          return;
        }
        updateData['phone'] = phone;
      }

      // Email: only if user has no existing email and entered one
      if (!_hasExistingEmail) {
        final email = _emailController.text.trim();
        if (email.isNotEmpty && _validateEmail(email) == null) {
          final isEmailTaken = await _authService.isEmailTakenByOtherUser(email, user.uid);
          if (isEmailTaken) {
            if (mounted) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('This email is already in use with another account. Please use another email.'),
                  backgroundColor: AppTheme.errorRed,
                ),
              );
            }
            return;
          }
          updateData['email'] = email;
        }
      }

      await Supabase.instance.client.from('users').update(updateData).eq('id', user.uid);

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (updateData.containsKey('email')) _hasExistingEmail = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: AppTheme.successGreen),
        );
        // Stay on page and refresh data
        _loadUserData();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed),
        );
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        // Automatically upload after selection
        await _uploadProfilePicture();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.primaryOrange),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.primaryOrange),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadProfilePicture() async {
    debugPrint('🖼️ _uploadProfilePicture called');
    if (_selectedImage == null) {
      debugPrint('❌ No image selected');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('❌ No user logged in');
      return;
    }

    debugPrint('✓ Starting upload for user: ${user.uid}');
    setState(() => _isUploadingImage = true);

    try {
      // Upload to Firebase Storage
      debugPrint('📤 Uploading to Firebase Storage...');
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${user.uid}.jpg');

      await storageRef.putFile(_selectedImage!);
      debugPrint('✓ File uploaded to Storage');
      
      final photoURL = await storageRef.getDownloadURL();
      debugPrint('✓ Got download URL: $photoURL');

      // Update Firebase Auth
      debugPrint('📝 Updating Firebase Auth...');
      await user.updatePhotoURL(photoURL);
      await user.reload();
      debugPrint('✓ Firebase Auth updated');

      // Update Supabase
      try {
        debugPrint('📝 Updating Supabase...');
        await Supabase.instance.client
            .from('users')
            .update({'photo_url': photoURL})
            .eq('id', user.uid);
        debugPrint('✓ Supabase updated');
      } catch (e) {
        debugPrint('⚠️ Could not update Supabase photo_url: $e');
        // Continue anyway, Firebase Auth is updated
      }

      if (mounted) {
        debugPrint('✓ Upload complete, updating UI');
        setState(() {
          _isUploadingImage = false;
          _selectedImage = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully!'),
            backgroundColor: AppTheme.successGreen,
            duration: Duration(seconds: 2),
          ),
        );
        // Reload user data to show new picture
        await user.reload();
        setState(() {}); // Trigger rebuild to show new photo
        debugPrint('✅ Profile picture upload complete!');
      }
    } catch (e) {
      debugPrint('❌ Error uploading image: $e');
      if (mounted) {
        setState(() => _isUploadingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _showDeleteAccountDialog() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This will permanently delete your account and all associated data including:\n\n'
          '• Profile information\n'
          '• Booking history\n'
          '• Wallet balance\n'
          '• Uploaded images\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorRed),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final userId = user.uid;
      
      // 1. Delete profile picture from Firebase Storage (if exists)
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures')
            .child('$userId.jpg');
        await storageRef.delete();
        debugPrint('✓ Deleted profile picture from Storage');
      } catch (e) {
        debugPrint('Note: Could not delete profile picture: $e');
        // Continue anyway
      }

      // 2. Delete all user data from Supabase database
      // Order matters: delete child tables first, then parent tables
      try {
        final supabase = Supabase.instance.client;
        
        // Delete chat messages (references chat_sessions)
        await supabase.from('chat_messages').delete().eq('sender_id', userId);
        debugPrint('✓ Deleted chat messages');
        
        // Delete chat sessions (as client or pandit)
        await supabase.from('chat_sessions').delete().eq('client_id', userId);
        await supabase.from('chat_sessions').delete().eq('pandit_id', userId);
        debugPrint('✓ Deleted chat sessions');
        
        // Delete bookings (as client or pandit)
        await supabase.from('bookings').delete().eq('client_id', userId);
        await supabase.from('bookings').delete().eq('pandit_id', userId);
        debugPrint('✓ Deleted bookings');
        
        // Delete transactions (references wallet)
        await supabase.from('transactions').delete().eq('wallet_id', userId);
        debugPrint('✓ Deleted transactions');
        
        // Delete wallet
        await supabase.from('wallets').delete().eq('user_id', userId);
        debugPrint('✓ Deleted wallet');
        
        // Delete profile data
        await supabase.from('client_profiles').delete().eq('user_id', userId);
        debugPrint('✓ Deleted client profile');
        
        await supabase.from('pandit_profiles').delete().eq('user_id', userId);
        debugPrint('✓ Deleted pandit profile');
        
        // Finally, delete user record
        await supabase.from('users').delete().eq('id', userId);
        debugPrint('✓ Deleted user record');
        
      } catch (e) {
        debugPrint('Error deleting from Supabase: $e');
        // Continue to delete Firebase Auth account anyway
      }

      // 3. Delete Firebase Auth account
      await user.delete();
      debugPrint('✓ Deleted Firebase Auth account');

      // 4. Sign out and navigate to login
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account and all data deleted successfully'),
            backgroundColor: AppTheme.successGreen,
            duration: Duration(seconds: 3),
          ),
        );
        // Navigate to login screen
        context.go('/login');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        
        // If recent login required, show re-authentication dialog
        if (e.code == 'requires-recent-login') {
          _showReauthenticationDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting account: ${e.message}'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _showReauthenticationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Re-authentication Required'),
        content: const Text(
          'For security reasons, please sign out and sign in again before deleting your account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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
            onPressed: _isLoading ? null : _saveAll,
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
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _showImageSourceDialog,
                      borderRadius: BorderRadius.circular(60),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.white, width: 4),
                        ),
                        child: _isUploadingImage
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : _selectedImage != null
                                ? ClipOval(
                                    child: Image.file(_selectedImage!, fit: BoxFit.cover),
                                  )
                                : user?.photoURL != null
                                    ? ClipOval(
                                        child: Image.network(
                                          user!.photoURL!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 60, color: Colors.white),
                                        ),
                                      )
                                    : const Icon(Icons.person, size: 60, color: Colors.white),
                      ),
                    ),
                  ),
                  if (!_isUploadingImage)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _showImageSourceDialog,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryOrange,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.check_circle_outline, color: AppTheme.primaryOrange),
                    onPressed: _isLoading ? null : _saveName,
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 16),

              // Email: read-only if existing, editable if not
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: _hasExistingEmail,
                  fillColor: _hasExistingEmail ? AppTheme.neutralSoft : null,
                  suffixIcon: _hasExistingEmail
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.check_circle_outline, color: AppTheme.primaryOrange),
                          onPressed: _isLoading ? null : _saveEmail,
                        ),
                ),
                readOnly: _hasExistingEmail,
                enabled: !_hasExistingEmail,
                validator: (v) {
                  if (_hasExistingEmail) return null;
                  return _validateEmail(v);
                },
              ),
              if (_hasExistingEmail)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Email cannot be changed once set.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              const SizedBox(height: 16),

              // Phone (no OTP - direct save)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: user?.isAnonymous == true ? AppTheme.neutralSoft : AppTheme.white,
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
                        Text(
                          'Phone Number',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
                              filled: user?.isAnonymous == true,
                              fillColor: user?.isAnonymous == true ? AppTheme.neutralSoft : null,
                            ),
                            isExpanded: true,
                            items: countryCodes
                                .map((cc) => DropdownMenuItem(
                                      value: cc,
                                      child: Text(
                                        '${cc.code} ${cc.dialCode}',
                                        style: const TextStyle(fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ))
                                .toList(),
                            onChanged: user?.isAnonymous == true ? null : (cc) {
                              if (cc != null) setState(() => _selectedCountry = cc);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              hintText: _selectedCountry.code == 'IN' ? '9876543210' : 'Phone',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: user?.isAnonymous == true,
                              fillColor: user?.isAnonymous == true ? AppTheme.neutralSoft : null,
                              suffixIcon: user?.isAnonymous == true ? null : IconButton(
                                icon: const Icon(Icons.check_circle_outline, color: AppTheme.primaryOrange),
                                onPressed: _isLoading ? null : _savePhone,
                              ),
                            ),
                            readOnly: user?.isAnonymous == true,
                            enabled: user?.isAnonymous != true,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(_selectedCountry.code == 'IN' ? 10 : 15),
                            ],
                            validator: _validatePhone,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        user?.isAnonymous == true 
                            ? 'Phone number cannot be changed for guest accounts.'
                            : 'Enter number and tap ✓ to save. Duplicate numbers will be rejected.',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveAll,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),

              // Delete Account Button
              if (user?.isAnonymous != true)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _showDeleteAccountDialog,
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Delete Account'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorRed,
                      side: const BorderSide(color: AppTheme.errorRed),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

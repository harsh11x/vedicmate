import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/theme/app_theme.dart';
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
  final _authService = AuthService();
  bool _isLoading = false;
  bool _hasExistingEmail = false; // True if user already has email (Firebase or Supabase)
  File? _selectedImage; // Selected image for profile picture
  String? _photoUrl;
  bool _isUploadingImage = false; // Loading state for image upload

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // For guest accounts, hardcode email
      if (user.isAnonymous) {
        setState(() {
          _nameController.text = user.displayName ?? 'Guest User';
          _emailController.text = 'vedicmate@gmail.com';
          _photoUrl = user.photoURL;
          _hasExistingEmail = true; // Make email read-only for guests
        });
        return;
      }

      setState(() {
        _nameController.text = user.displayName ?? '';
        _emailController.text = user.email ?? '';
        _photoUrl = user.photoURL;
      });

      try {
        final data = await Supabase.instance.client
            .from('users')
            .select()
            .eq('id', user.uid)
            .maybeSingle();

        if (data != null && mounted) {
          _nameController.text = data['name'] ?? user.displayName ?? '';
          _photoUrl = (data['avatar_url'] as String?) ?? user.photoURL;
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
          _hasExistingEmail = (user.email != null && user.email!.isNotEmpty);
          if (mounted) setState(() {});
        }
      } catch (e) {
        debugPrint('Error loading user data: $e');
        _hasExistingEmail = (user.email != null && user.email!.isNotEmpty);
        if (mounted) setState(() {});
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

    // For guest users, only allow name changes (+ optional profile photo on Save)
    if (user.isAnonymous) {
      setState(() => _isLoading = true);
      try {
        if (_selectedImage != null) {
          final uploaded = await _uploadProfilePicture();
          if (!uploaded) {
            if (mounted) setState(() => _isLoading = false);
            return;
          }
        }

        final name = _nameController.text.trim();
        if (name.isNotEmpty) {
          await user.updateDisplayName(name);
          await Supabase.instance.client.from('users').update({'name': name}).eq('id', user.uid);
        }
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile saved successfully!'),
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
      if (_selectedImage != null) {
        final uploaded = await _uploadProfilePicture();
        if (!uploaded) {
          if (mounted) setState(() => _isLoading = false);
          return;
        }
      }

      // Save name
      final name = _nameController.text.trim();
      if (name.isNotEmpty) {
        await user.updateDisplayName(name);
      }

      final updateData = <String, dynamic>{'name': name.isNotEmpty ? name : user.displayName ?? ''};

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
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().toLowerCase().contains('permission')
            ? 'Access was denied. Please allow permission if you want to upload a profile photo.'
            : 'Could not open image picker. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppTheme.primaryOrange),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(ctx);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _pickImage(ImageSource.camera);
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppTheme.primaryOrange),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _pickImage(ImageSource.gallery);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns true if upload and profile persistence succeeded.
  Future<bool> _uploadProfilePicture({bool showSuccessSnackBar = false}) async {
    debugPrint('🖼️ _uploadProfilePicture called');
    if (_selectedImage == null) {
      debugPrint('❌ No image selected');
      return false;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('❌ No user logged in');
      return false;
    }

    debugPrint('✓ Starting upload for user: ${user.uid}');
    if (mounted) setState(() => _isUploadingImage = true);

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putFile(
        _selectedImage!,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final photoURL = await storageRef.getDownloadURL();
      debugPrint('✓ Got download URL: $photoURL');

      try {
        await user.updatePhotoURL(photoURL);
      } catch (e) {
        debugPrint('⚠️ Firebase Auth photoURL update failed (continuing): $e');
      }

      await Supabase.instance.client.from('users').update({
        'avatar_url': photoURL,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.uid);

      if (mounted) {
        setState(() {
          _isUploadingImage = false;
          _selectedImage = null;
          _photoUrl = photoURL;
        });
        if (showSuccessSnackBar) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: AppTheme.successGreen,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
      return true;
    } catch (e) {
      debugPrint('❌ Error uploading image: $e');
      if (mounted) {
        setState(() => _isUploadingImage = false);
        final errorText = e.toString().toLowerCase();
        final msg = errorText.contains('permission') || errorText.contains('denied')
            ? 'Photo access was denied. Allow camera or photos access to upload a profile picture.'
            : errorText.contains('unauthorized') || errorText.contains('permission-denied')
                ? 'Upload blocked by server rules. Deploy Firebase Storage rules, then try again.'
                : 'Could not upload image. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppTheme.errorRed,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return false;
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
                                : (_photoUrl != null && _photoUrl!.isNotEmpty) || user?.photoURL != null
                                    ? ClipOval(
                                        child: Image.network(
                                          (_photoUrl != null && _photoUrl!.isNotEmpty) ? _photoUrl! : user!.photoURL!,
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

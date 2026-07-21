import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    hide User, OAuthProvider;
import 'package:shared_preferences/shared_preferences.dart';
import 'email_service.dart';

class AuthService {
  firebase_auth.FirebaseAuth get _auth => firebase_auth.FirebaseAuth.instance;
  GoogleSignIn get _googleSignIn => GoogleSignIn();
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // Safe Supabase client access
  SupabaseClient get _supabase {
    try {
      return Supabase.instance.client;
    } catch (e) {
      debugPrint('AuthService: Supabase not initialized.');
      // Return a dummy or throw a clear error, but for now rethrow safely to prevent field init crash
      throw Exception('Supabase not initialized');
    }
  }

  // Auth state changes stream
  Stream<firebase_auth.User?> authStateChanges() => _auth.authStateChanges();

  // User changes stream (includes profile changes like displayName)
  Stream<firebase_auth.User?> userChanges() => _auth.userChanges();

  // Get current user
  firebase_auth.User? get currentUser => _auth.currentUser;

  // Ensure user profile exists (Auto-register if missing)
  Future<void> ensureUserProfile(
      {firebase_auth.User? user, String? name}) async {
    user ??= currentUser;
    if (user == null) return;
    if (user.isAnonymous) {
      await _auth.signOut();
      throw Exception('Guest mode is disabled. Please sign in to continue.');
    }

    final isRegistered = await isUserRegistered(user.uid);
    if (!isRegistered) {
      final displayName = name ?? user.displayName ?? 'User';
      final email = user.email ?? '';
      final phone = user.phoneNumber ?? '';

      await _supabase.from('users').insert({
        'id': user.uid,
        'name': displayName,
        'email': email,
        'phone': phone,
        'role': 'client',
        'created_at': DateTime.now().toIso8601String(),
      });

      await _ensureSignupWallet(user.uid);

      try {
        if (email.isNotEmpty) {
          await EmailService.sendOnboardingEmail(
              name: displayName, email: email);
        }
      } catch (e) {
        debugPrint('Failed email: $e');
      }
    }
  }

  Future<void> _ensureSignupWallet(String uid) async {
    try {
      final existingWallet = await _supabase
          .from('wallets')
          .select('user_id')
          .eq('user_id', uid)
          .maybeSingle();

      if (existingWallet != null) return;

      const initialBalance = 50.0;
      await _supabase.from('wallets').insert({
        'user_id': uid,
        'balance': initialBalance,
        'currency': 'INR',
      });

      await _supabase.from('transactions').insert({
        'wallet_id': uid,
        'amount': initialBalance,
        'type': 'credit',
        'category': 'recharge',
        'description': 'Signup Bonus',
        'reference_id': 'SIGNUP_BONUS_${DateTime.now().millisecondsSinceEpoch}',
        'status': 'completed',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Failed to create signup wallet bonus: $e');
    }
  }

  // Sign in with Google - returning User?
  Future<firebase_auth.User?> signInWithGoogle([String? role]) async {
    // Let errors propagate to be handled by the UI
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // User canceled

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = firebase_auth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    // Auto-create profile if needed
    if (userCredential.user != null) {
      await ensureUserProfile(user: userCredential.user);
    }
    return userCredential.user;
  }

  static String _generateNonce([int length = 32]) {
    final random = Random.secure();
    final values = List<int>.generate(length, (_) => random.nextInt(256));
    return base64Url
        .encode(values)
        .replaceAll('=', '')
        .replaceAll('+', '-')
        .replaceAll('/', '_');
  }

  static String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<firebase_auth.User?> signInWithApple([String? role]) async {
    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final oauthCredential = firebase_auth.OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
      accessToken: appleCredential.authorizationCode,
    );

    final userCredential = await _auth.signInWithCredential(oauthCredential);
    if (userCredential.user != null) {
      final name = appleCredential.givenName != null ||
              appleCredential.familyName != null
          ? '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
              .trim()
          : null;
      await ensureUserProfile(user: userCredential.user, name: name);
    }
    return userCredential.user;
  }

  // Sign out
  Future<void> signOut() async {
    final uid = _auth.currentUser?.uid;
    await _googleSignIn.signOut();
    await _auth.signOut();
    if (uid != null) {
      try {
        await Supabase.instance.client.from('users').update({
          'fcm_token': null,
          'updated_at': DateTime.now().toIso8601String()
        }).eq('id', uid);
      } catch (_) {}
    }
    await clearUserSession();
  }

  // --- Manual Persistence Logic ---
  static const String _sessionKey = 'is_logged_in';

  Future<void> saveUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sessionKey, true);
    debugPrint('AuthService: Session saved manually.');
  }

  Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sessionKey, false);
    debugPrint('AuthService: Session cleared manually.');
  }

  Future<bool> isSessionActive() async {
    final prefs = await SharedPreferences.getInstance();
    final isActive = prefs.getBool(_sessionKey) ?? false;
    debugPrint('AuthService: Manual session check -> $isActive');
    return isActive;
  }

  String? _verificationId;
  int? _resendToken;
  static const String _pendingOtpPhoneKey = 'pending_otp_phone';

  /// Persist phone when starting OTP flow so we can restore OTP screen after captcha.
  Future<void> _savePendingOtpPhone(String e164) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingOtpPhoneKey, e164);
  }

  /// Clear persisted pending OTP state.
  Future<void> clearPendingOtpState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingOtpPhoneKey);
  }

  /// Get persisted phone if we're in a pending OTP flow (e.g. returned from captcha).
  Future<String?> getPendingOtpPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pendingOtpPhoneKey);
  }

  bool get hasPendingOtpVerification => _verificationId != null;

  // Separate verification state for profile phone update (avoid conflict with login OTP)
  String? _phoneUpdateVerificationId;
  int? _phoneUpdateResendToken;

  /// Send OTP for phone number update (profile). [fullPhone] must be E.164 e.g. +919876543210
  Future<void> sendOTPForPhoneUpdate(
    String fullPhone, {
    required Function() onCodeSent,
    required Function(String) onError,
  }) async {
    final normalized = fullPhone.startsWith('+') ? fullPhone : '+$fullPhone';
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: normalized,
        timeout: const Duration(seconds: 60),
        verificationCompleted:
            (firebase_auth.PhoneAuthCredential credential) async {
          // Auto-verification (Android) - handled via codeSent flow, user will verify manually
          debugPrint('Phone verification auto-completed');
        },
        verificationFailed: (firebase_auth.FirebaseAuthException e) {
          onError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          _phoneUpdateVerificationId = verificationId;
          _phoneUpdateResendToken = resendToken;
          onCodeSent();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _phoneUpdateVerificationId = verificationId;
        },
        forceResendingToken: _phoneUpdateResendToken,
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  /// Verify OTP and update phone on current user. Returns true on success.
  /// For email/Google/Apple users, Firebase updatePhoneNumber may fail (e.g. requires-recent-login);
  /// caller can still update Supabase after OTP verification.
  Future<bool> verifyOTPAndUpdatePhone(String otp, String fullPhone) async {
    if (_phoneUpdateVerificationId == null) {
      throw Exception('Verification ID missing. Please request OTP again.');
    }
    final credential = firebase_auth.PhoneAuthProvider.credential(
      verificationId: _phoneUpdateVerificationId!,
      smsCode: otp.trim(),
    );
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not signed in');

    _phoneUpdateVerificationId = null;
    _phoneUpdateResendToken = null;

    try {
      await user.updatePhoneNumber(credential);
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception(
            'For security, please sign out and sign in again, then try updating your phone.');
      }
      rethrow;
    }
  }

  /// Check if email is taken by another user (exclude current user id)
  Future<bool> isEmailTakenByOtherUser(
      String email, String excludeUserId) async {
    if (email.isEmpty) return false;
    try {
      final normalized = email.trim().toLowerCase();
      final res = await _supabase
          .from('users')
          .select('id')
          .ilike('email', normalized)
          .neq('id', excludeUserId)
          .maybeSingle();
      return res != null;
    } catch (e) {
      debugPrint('Error checking email: $e');
      return true;
    }
  }

  /// Check if phone is taken by another user (exclude current user id)
  Future<bool> isPhoneTakenByOtherUser(
      String fullPhone, String excludeUserId) async {
    try {
      final normalized = fullPhone.startsWith('+') ? fullPhone : '+$fullPhone';
      final raw = fullPhone.replaceAll(RegExp(r'\D'), '');
      // Check E.164 and raw formats - any user other than current
      final res1 = await _supabase
          .from('users')
          .select('id')
          .eq('phone', normalized)
          .neq('id', excludeUserId)
          .maybeSingle();
      if (res1 != null) return true;
      final res2 = await _supabase
          .from('users')
          .select('id')
          .eq('phone', raw)
          .neq('id', excludeUserId)
          .maybeSingle();
      return res2 != null;
    } catch (e) {
      debugPrint('Error checking phone: $e');
      return true; // Fail safe - assume taken
    }
  }

  // Send OTP - phone: digits only, assumed India (+91) unless starts with +
  String _normalizeToE164India(String phone) {
    final raw = phone.trim();
    if (raw.isEmpty) return '';
    if (raw.startsWith('+')) return raw;
    String digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('91') && digits.length > 10) {
      digits = digits.substring(2);
    }
    if (digits.startsWith('0')) digits = digits.substring(1);
    if (digits.length == 10) return '+91$digits';
    // Fallback: if user pasted country code without plus
    if (digits.startsWith('91') && digits.length >= 12) return '+$digits';
    return '+$digits';
  }

  /// Find a user profile by phone (checks raw and E.164 formats). Returns row or null.
  Future<Map<String, dynamic>?> findUserProfileByPhone(String phone) async {
    try {
      final e164 = _normalizeToE164India(phone);
      final raw = phone.replaceAll(RegExp(r'\D'), '');
      final res = await _supabase
          .from('users')
          .select()
          .or('phone.eq.$e164,phone.eq.$raw,phone.eq.$phone')
          .maybeSingle();
      return res;
    } catch (e) {
      debugPrint('Error finding user by phone: $e');
      return null;
    }
  }

  /// Check if email exists in `users` table (case-insensitive).
  Future<bool> isEmailAlreadyUsed(String email) async {
    if (email.trim().isEmpty) return false;
    try {
      final normalized = email.trim().toLowerCase();
      final res = await _supabase
          .from('users')
          .select('id')
          .ilike('email', normalized)
          .maybeSingle();
      return res != null;
    } catch (e) {
      debugPrint('Error checking email exists: $e');
      // Fail safe: assume used to prevent duplicates
      return true;
    }
  }

  Future<void> sendOTP(
    String phone,
    String role, {
    required Function() onCodeSent,
    required Function(String) onError,
    required Function(firebase_auth.User) onVerificationCompleted,
  }) async {
    try {
      final e164 = _normalizeToE164India(phone);
      final onlyDigits = e164.replaceAll(RegExp(r'\D'), '');
      if (onlyDigits.length < 10) {
        onError('Please enter a valid phone number');
        return;
      }

      // Persist phone so we can restore OTP screen if user returns after captcha
      await _savePendingOtpPhone(e164);

      await _auth.verifyPhoneNumber(
        phoneNumber: e164,
        timeout: const Duration(seconds: 60),
        verificationCompleted:
            (firebase_auth.PhoneAuthCredential credential) async {
          // Auto-verification (Android)
          try {
            final userCredential = await _auth.signInWithCredential(credential);
            if (userCredential.user != null) {
              onVerificationCompleted(userCredential.user!);
            }
          } catch (e) {
            onError(e.toString());
          }
        },
        verificationFailed: (firebase_auth.FirebaseAuthException e) async {
          await clearPendingOtpState();
          if (e.code == 'invalid-phone-number') {
            onError('The provided phone number is not valid.');
          } else if (e.code == 'too-many-requests') {
            onError('Too many OTP attempts. Please wait a bit and try again.');
          } else {
            onError('${e.message ?? 'Verification failed'} (code: ${e.code})');
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      await clearPendingOtpState();
      onError(e.toString());
    }
  }

  // Verify OTP - phone param is only for reference, credential comes from verificationId
  Future<firebase_auth.User?> verifyOTP(
      String otp, String phone, String role) async {
    if (_verificationId == null)
      throw Exception('Verification ID is missing. Request OTP again.');

    final credential = firebase_auth.PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp.trim(),
    );

    final userCredential = await _auth.signInWithCredential(credential);
    _verificationId = null;
    _resendToken = null;
    await clearPendingOtpState();
    return userCredential.user;
  }

  Future<firebase_auth.User?> signInAsGuest() async {
    throw Exception('Guest mode is disabled. Please sign in to continue.');
  }

  // Supabase client is now a getter
  // final SupabaseClient _supabase = Supabase.instance.client;

  // Check if user is registered in Supabase
  Future<bool> isUserRegistered(String uid) async {
    try {
      final response =
          await _supabase.from('users').select().eq('id', uid).maybeSingle();
      return response != null;
    } catch (e) {
      // If table doesn't exist or other error, assume not registered
      return false;
    }
  }

  // Check if mobile number is already taken
  Future<bool> isMobileNumberTaken(String phone) async {
    try {
      // Normalize: check both raw (98...) and formatted (+9198...)
      final String rawPhone =
          phone.replaceAll(RegExp(r'\D'), ''); // Strip non-digits
      final String formattedPhone = phone.startsWith('+') ? phone : '+91$phone';

      final response = await _supabase
          .from('users')
          .select('id')
          .or('phone.eq.$rawPhone,phone.eq.$formattedPhone,phone.eq.$phone')
          .maybeSingle(); // Returns null if no match found

      return response != null;
    } catch (e) {
      debugPrint('Error checking mobile number: $e');
      return false; // Fail safe
    }
  }

  Future<firebase_auth.User?> register(
    String name,
    String email,
    String phone,
    String password,
    String role,
  ) async {
    try {
      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        // Update display name in Firebase
        await user.updateDisplayName(name);

        // Save user details to Supabase (instead of Firestore)
        await _supabase.from('users').insert({
          'id': user.uid,
          'name': name,
          'email': email,
          'phone': phone,
          'role': role,
          'created_at': DateTime.now().toIso8601String(),
        });

        await _ensureSignupWallet(user.uid);

        // Send E-mail verification
        try {
          await user.sendEmailVerification();
        } catch (e) {
          debugPrint('Failed to send verification email: $e');
        }

        // Try to trigger onboarding email (best effort)
        try {
          await EmailService.sendOnboardingEmail(
            name: name,
            email: email,
          );
        } catch (e) {
          debugPrint('Failed to trigger email: $e');
        }
      }

      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<firebase_auth.User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }
}

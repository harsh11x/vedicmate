import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Phone verification ID for OTP
  String? _verificationId;

  // Send OTP to phone number
  Future<bool> sendOTP(String phoneNumber, String role) async {
    try {
      // Format phone number with country code
      String formattedPhone = phoneNumber.startsWith('+91') 
          ? phoneNumber 
          : '+91$phoneNumber';

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-retrieve or instant verification
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          throw e.message ?? 'Verification failed';
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
      return true;
    } catch (e) {
      throw e.toString();
    }
  }

  // Verify OTP and sign in
  Future<User?> verifyOTP(String otp, String phoneNumber, String role) async {
    try {
      if (_verificationId == null) {
        throw 'Please send OTP first';
      }

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Create or update user document in Firestore
        await _createOrUpdateUser(user, role, phoneNumber);
      }

      return user;
    } catch (e) {
      throw e.toString();
    }
  }

  // Google Sign-In
  Future<User?> signInWithGoogle(String role) async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Create or update user document in Firestore
        await _createOrUpdateUser(
          user, 
          role, 
          user.phoneNumber ?? '',
          email: user.email,
          displayName: user.displayName,
          photoURL: user.photoURL,
        );
      }

      return user;
    } catch (e) {
      throw e.toString();
    }
  }

  // Create or update user in Firestore
  Future<void> _createOrUpdateUser(
    User user,
    String role,
    String phoneNumber, {
    String? email,
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        // Create new user
        await userDoc.set({
          'uid': user.uid,
          'role': role,
          'phoneNumber': phoneNumber,
          'email': email ?? user.email ?? '',
          'displayName': displayName ?? user.displayName ?? '',
          'photoURL': photoURL ?? user.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'isActive': true,
          'isVerified': role == AppConstants.roleClient ? true : false,
        });
      } else {
        // Update existing user
        await userDoc.update({
          'updatedAt': FieldValue.serverTimestamp(),
          'email': email ?? user.email ?? docSnapshot.data()?['email'] ?? '',
          'displayName': displayName ?? user.displayName ?? docSnapshot.data()?['displayName'] ?? '',
          'photoURL': photoURL ?? user.photoURL ?? docSnapshot.data()?['photoURL'] ?? '',
        });
      }
    } catch (e) {
      throw e.toString();
    }
  }

  // Register new user
  Future<User?> register(
    String name,
    String email,
    String phone,
    String role, {
    DateTime? dateOfBirth,
    String? placeOfBirth,
    String? timeOfBirth,
  }) async {
    try {
      // For registration, we'll use phone auth
      // The OTP should have already been verified by this point
      User? user = _auth.currentUser;

      if (user != null) {
        // Update user profile
        await user.updateDisplayName(name);
        if (email.isNotEmpty) {
          await user.updateEmail(email);
        }

        // Update Firestore document with additional details
        await _firestore.collection('users').doc(user.uid).update({
          'displayName': name,
          'email': email,
          'phoneNumber': phone,
          'role': role,
          'dateOfBirth': dateOfBirth,
          'placeOfBirth': placeOfBirth,
          'timeOfBirth': timeOfBirth,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } catch (e) {
      throw e.toString();
    }
  }

  // Get user role from Firestore
  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data()?['role'] as String?;
    } catch (e) {
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}


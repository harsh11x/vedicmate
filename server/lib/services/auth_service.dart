import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'supabase_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Auth state changes stream
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with Google - returning User?
  Future<User?> signInWithGoogle([String? role]) async {
    // Let errors propagate to be handled by the UI
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // User canceled

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;
    
    if (user != null) {
      // Save/Update profile in Supabase
      // Google provides email and displayName. Phone might be null.
      await SupabaseService().saveUserProfile(
        userId: user.uid,
        email: user.email ?? '',
        name: user.displayName,
        phone: user.phoneNumber, 
      );
    }
    
    return user;
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Placeholder for OTP
  Future<void> sendOTP(String phone, String role) async {
    // Implement Phone Auth here or use a service
  }
  
  Future<User?> verifyOTP(String otp, String phone, String role) async { 
    return null; 
  }

  Future<User?> signInAsGuest() async {
    await _auth.signInAnonymously();
    return _auth.currentUser;
  }

  Future<User?> register(
    String name,
    String email, 
    String phone, 
    String password, 
    String role, 
    {DateTime? dateOfBirth, String? placeOfBirth, String? timeOfBirth}
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(name);
        
        // Save profile to Supabase
        await SupabaseService().saveUserProfile(
          userId: user.uid,
          name: name,
          email: email,
          phone: phone,
        );
      }
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}

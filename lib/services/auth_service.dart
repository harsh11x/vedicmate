import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
    return userCredential.user;
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Placeholder for OTP
  Future<void> sendOTP(String phone, String role) async {}
  Future<User?> verifyOTP(String otp, String phone, String role) async { return null; }

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
    return null;
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    return null;
  }

  Future<void> sendPasswordResetEmail(String email) async {}
}

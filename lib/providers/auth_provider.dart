import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<User?>((ref) async* {
  final authService = ref.watch(authServiceProvider);
  // Yield current user immediately to prevent "Loading" state from blocking routes
  // This ensures we start with AsyncData(user) or AsyncData(null), not AsyncLoading
  yield authService.currentUser;
  yield* authService.userChanges();
});

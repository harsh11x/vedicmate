import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'auth_provider.dart';

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, AsyncValue<UserModel?>>((ref) {
  final authState = ref.watch(authStateProvider);
  return UserProfileNotifier(ref, authState);
});

class UserProfileNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final Ref _ref;
  final AsyncValue<firebase_auth.User?> _authState;
  final _supabase = Supabase.instance.client;

  UserProfileNotifier(this._ref, this._authState) : super(const AsyncValue.loading()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _authState.value;
    if (user == null) {
      state = const AsyncValue.data(null);
      return;
    }

    try {
      state = const AsyncValue.loading();
      
      // Fetch core profile
      // Note: Adjust table name if strictly using 'profiles' or 'users' based on current schema
      // For now assuming we are joining or fetching directly.
      // If we made a separate 'user_astrology_profiles' table, we might need to join/fetch both.
      
      final response = await _supabase
          .from('users') // or 'profiles'
          .select()
          .eq('id', user.uid)
          .single();

      state = AsyncValue.data(UserModel.fromJson(response));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateBirthDetails({
    required DateTime birthDate,
    required String birthTime,
    required String birthPlace,
    required double latitude,
    required double longitude,
    required String timezone,
  }) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    try {
      final updates = {
        'birth_date': birthDate.toIso8601String(),
        'birth_time': birthTime,
        'birth_place_name': birthPlace,
        'birth_latitude': latitude,
        'birth_longitude': longitude,
        'birth_timezone': timezone,
      };

      // Update in Supabase
      // If using separate table, update 'user_astrology_profiles'
      await _supabase.from('users').update(updates).eq('id', currentUser.id);

      // Refresh local state
      await _loadProfile();
    } catch (e) {
      // Handle error (e.g., show snackbar via listener)
      rethrow;
    }
  }

  Future<void> updatePreferences({
    String? ayanamsa,
    String? chartStyle,
  }) async {
    final currentUser = state.value;
    if (currentUser == null) return;

     try {
      final updates = <String, dynamic>{};
      if (ayanamsa != null) updates['preferred_ayanamsa'] = ayanamsa;
      if (chartStyle != null) updates['preferred_chart_style'] = chartStyle;

      if (updates.isEmpty) return;

      await _supabase.from('users').update(updates).eq('id', currentUser.id);
      await _loadProfile();
    } catch (e) {
      rethrow;
    }
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Singleton
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  /// Save or update user birth details
  Future<void> saveBirthDetails({
    required String userId,
    required String astrologyType, // e.g., 'Vedic', 'Lal Kitab'
    required DateTime dateOfBirth,
    String? placeOfBirth,
    String? timeOfBirth,
  }) async {
    try {
      final data = {
        'user_id': userId,
        'astrology_type': astrologyType,
        'date_of_birth': dateOfBirth.toIso8601String(),
        'place_of_birth': placeOfBirth,
        'time_of_birth': timeOfBirth,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Upsert into 'user_birth_details' table (assuming this table exists or will be created)
      // We use upsert to handle both insert and update
      await _client.from('user_birth_details').upsert(
        data,
        onConflict: 'user_id', // Assuming user_id is unique or primary key for 1:1 mapping
      );
    } catch (e) {
      // Allow error to propagate or log it
      print('Error saving birth details: $e');
      rethrow;
    }
  }

  /// Save basic user profile
  Future<void> saveUserProfile({
    required String userId,
    required String email,
    String? name,
    String? phone,
  }) async {
    try {
      final data = {
        'user_id': userId,
        'email': email,
        if (name != null) 'full_name': name,
        if (phone != null) 'phone_number': phone,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _client.from('profiles').upsert(
        data,
        onConflict: 'user_id',
      );
    } catch (e) {
      print('Error saving profile: $e');
      // Non-blocking for profile updates usually
    }
  }
}

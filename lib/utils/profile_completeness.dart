import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

/// Utility class for checking and managing user profile completeness
class ProfileCompleteness {
  // Use Supabase client directly
  static final SupabaseClient _supabase = Supabase.instance.client;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Check if user profile is complete for AI chat
  static Future<ProfileCheckResult> checkProfile({
    bool checkIdentity = true,
    bool checkBirthDetails = true,
    bool checkNumerology = true,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      return ProfileCheckResult(
        isComplete: false,
        missingFields: ['User not logged in'],
      );
    }

    try {
      // Query Supabase instead of Firestore
      final data = await _supabase
          .from('users')
          .select()
          .eq('id', user.uid)
          .maybeSingle();

      if (data == null) {
        return ProfileCheckResult(
          isComplete: false,
          missingFields: ['Profile not found'],
        );
      }

      final missingFields = <String>[];

      // Check birth details - Supabase structure might be flat or JSONB
      // Assuming JSONB column 'birth_details' or flat fields. 
      // Based on typical Supabase usage in this app, let's check for specific columns or a json column.
      // If the schema isn't strictly defined, we fallback to checking keys in the returned map.

      // Strategy: Check if data contains 'birthDetails' (JSON) or individual fields.
      // Adjusting to common Supabase patterns. Let's assume 'birth_details' column for JSON data 
      // OR direct columns. given the previous code used a map 'birthDetails', 
      // let's try to find that key or similar.
      
      // Check Identity (Name & Phone)
      if (checkIdentity) {
        if (data['name'] == null || data['name'].toString().isEmpty) missingFields.add('Name');
        if (data['phone'] == null || data['phone'].toString().isEmpty) missingFields.add('Phone Number');
      }

      // Check birth details
      if (checkBirthDetails) {
        final birthDetails = data['birth_details'] ?? data['birthDetails']; // Handle camelCase or snake_case
        
        if (birthDetails == null) {
           // If no JSON block, check for individual columns if they exist
           bool hasDate = data['date_of_birth'] != null || data['dateOfBirth'] != null;
           bool hasTime = data['time_of_birth'] != null || data['timeOfBirth'] != null;
           bool hasPlace = data['place_of_birth'] != null || data['placeOfBirth'] != null;
           
           if (!hasDate) missingFields.add('Date of Birth');
           if (!hasTime) missingFields.add('Time of Birth');
           if (!hasPlace) missingFields.add('Place of Birth');
        } else {
          // It's a map/json
          final bd = birthDetails as Map<String, dynamic>;
          if (bd['date_of_birth'] == null && bd['dateOfBirth'] == null) missingFields.add('Date of Birth');
          if (bd['time_of_birth'] == null && bd['timeOfBirth'] == null) missingFields.add('Time of Birth');
          if (bd['place_of_birth'] == null && bd['placeOfBirth'] == null) missingFields.add('Place of Birth');
        }
      }

      // Check numerology
      if (checkNumerology) {
        final numerology = data['numerology'] ?? data['numerologyProperties'];
        if (numerology == null) {
          missingFields.add('Numerology Preference');
        }
      }

      return ProfileCheckResult(
        isComplete: missingFields.isEmpty,
        missingFields: missingFields,
        profileData: data,
      );
    } catch (e) {
      print('Error checking profile (Supabase): $e');
      return ProfileCheckResult(
        isComplete: false,
        missingFields: ['Error loading profile: ${e.toString()}'],
      );
    }
  }

  /// Save numerology preferences
  static Future<bool> saveNumerologyPreferences({
    required String inputType,
    int? dayOfBirth,
    DateTime? fullDateOfBirth,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final numerologyData = {
        'inputType': inputType,
        if (inputType == 'day_only' && dayOfBirth != null)
          'dayOfBirth': dayOfBirth,
        if (inputType == 'full_date' && fullDateOfBirth != null)
          'fullDateOfBirth': fullDateOfBirth?.toIso8601String(), // Supabase likes strings for dates
        'calculatedNumber': _calculateLifePathNumber(
          inputType == 'day_only' ? dayOfBirth! : fullDateOfBirth!.day,
        ),
        if (inputType == 'full_date' && fullDateOfBirth != null)
          'bhagyaank': _calculateDestinyNumber(fullDateOfBirth),
      };

      await _supabase.from('users').update({
        'numerology': numerologyData,
        'last_updated': DateTime.now().toIso8601String(),
      }).eq('id', user.uid);

      return true;
    } catch (e) {
      print('Error saving numerology (Supabase): $e');
      return false;
    }
  }

  /// Save birth details
  static Future<bool> saveBirthDetails({
    required DateTime dateOfBirth,
    required String timeOfBirth,
    required Map<String, dynamic> placeOfBirth,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      await _supabase.from('users').update({
        'birth_details': {
          'dateOfBirth': dateOfBirth.toIso8601String(),
          'timeOfBirth': timeOfBirth,
          'placeOfBirth': placeOfBirth,
        },
        'last_updated': DateTime.now().toIso8601String(),
      }).eq('id', user.uid);

      return true;
    } catch (e) {
      print('Error saving birth details (Supabase): $e');
      return false;
    }
  }

  /// Calculate Life Path Number (Mulank)
  static int _calculateLifePathNumber(int dayOfBirth) {
    return _reduceToSingleDigit(dayOfBirth);
  }

  /// Calculate Destiny Number (Bhagyaank)
  static int _calculateDestinyNumber(DateTime date) {
    final day = date.day;
    final month = date.month;
    final year = date.year;
    
    final sum = day + month + year;
    return _reduceToSingleDigit(sum);
  }

  /// Reduce number to single digit (except 11, 22, 33)
  static int _reduceToSingleDigit(int num) {
    while (num > 9 && num != 11 && num != 22 && num != 33) {
      num = num.toString().split('').fold(0, (sum, digit) => sum + int.parse(digit));
    }
    return num;
  }

  /// Get user profile data for AI context
  static Future<Map<String, dynamic>?> getUserProfileForAI() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('id', user.uid)
          .maybeSingle();
      return data;
    } catch (e) {
      print('Error getting profile for AI (Supabase): $e');
      return null;
    }
  }
}

/// Result of profile completeness check
class ProfileCheckResult {
  final bool isComplete;
  final List<String> missingFields;
  final Map<String, dynamic>? profileData;

  ProfileCheckResult({
    required this.isComplete,
    required this.missingFields,
    this.profileData,
  });

  String get missingFieldsMessage {
    if (missingFields.isEmpty) return '';
    if (missingFields.length == 1) return missingFields.first;
    return '${missingFields.take(missingFields.length - 1).join(', ')} and ${missingFields.last}';
  }
}

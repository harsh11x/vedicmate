import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Utility class for checking and managing user profile completeness
class ProfileCompleteness {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Check if user profile is complete for AI chat
  static Future<ProfileCheckResult> checkProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      return ProfileCheckResult(
        isComplete: false,
        missingFields: ['User not logged in'],
      );
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();

      if (data == null) {
        return ProfileCheckResult(
          isComplete: false,
          missingFields: ['Profile not found'],
        );
      }

      final missingFields = <String>[];

      // Check birth details
      final birthDetails = data['birthDetails'] as Map<String, dynamic>?;
      if (birthDetails == null) {
        missingFields.addAll(['Date of Birth', 'Time of Birth', 'Place of Birth']);
      } else {
        if (birthDetails['dateOfBirth'] == null) missingFields.add('Date of Birth');
        if (birthDetails['timeOfBirth'] == null) missingFields.add('Time of Birth');
        if (birthDetails['placeOfBirth'] == null) missingFields.add('Place of Birth');
      }

      // Check numerology
      final numerology = data['numerology'] as Map<String, dynamic>?;
      if (numerology == null) {
        missingFields.add('Numerology Preference');
      }

      return ProfileCheckResult(
        isComplete: missingFields.isEmpty,
        missingFields: missingFields,
        profileData: data,
      );
    } catch (e) {
      print('Error checking profile: $e');
      return ProfileCheckResult(
        isComplete: false,
        missingFields: ['Error loading profile'],
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
          'fullDateOfBirth': Timestamp.fromDate(fullDateOfBirth),
        'calculatedNumber': _calculateLifePathNumber(
          inputType == 'day_only' ? dayOfBirth! : fullDateOfBirth!.day,
        ),
        if (inputType == 'full_date' && fullDateOfBirth != null)
          'bhagyaank': _calculateDestinyNumber(fullDateOfBirth),
      };

      await _firestore.collection('users').doc(user.uid).set({
        'numerology': numerologyData,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      print('Error saving numerology: $e');
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
      await _firestore.collection('users').doc(user.uid).set({
        'birthDetails': {
          'dateOfBirth': Timestamp.fromDate(dateOfBirth),
          'timeOfBirth': timeOfBirth,
          'placeOfBirth': placeOfBirth,
        },
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      print('Error saving birth details: $e');
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
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data();
    } catch (e) {
      print('Error getting profile for AI: $e');
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

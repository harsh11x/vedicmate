import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesService {
  static const String _keySelectedCategory = 'selected_category';
  static const String _keyDateOfBirth = 'date_of_birth';
  static const String _keyPlaceOfBirth = 'place_of_birth';
  static const String _keyTimeOfBirth = 'time_of_birth';
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyPreferredPanditId = 'preferred_pandit_id';

  // Save selected category
  Future<void> saveSelectedCategory(String category) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedCategory, category);
  }

  // Get selected category
  Future<String?> getSelectedCategory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedCategory);
  }

  // Save birth details
  Future<void> saveBirthDetails({
    required DateTime dateOfBirth,
    String? placeOfBirth,
    String? timeOfBirth,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDateOfBirth, dateOfBirth.toIso8601String());
    if (placeOfBirth != null) {
      await prefs.setString(_keyPlaceOfBirth, placeOfBirth);
    }
    if (timeOfBirth != null) {
      await prefs.setString(_keyTimeOfBirth, timeOfBirth);
    }
  }

  // Get date of birth
  Future<DateTime?> getDateOfBirth() async {
    final prefs = await SharedPreferences.getInstance();
    final dobString = prefs.getString(_keyDateOfBirth);
    if (dobString != null) {
      return DateTime.parse(dobString);
    }
    return null;
  }

  // Get place of birth
  Future<String?> getPlaceOfBirth() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPlaceOfBirth);
  }

  // Get time of birth
  Future<String?> getTimeOfBirth() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyTimeOfBirth);
  }

  // Mark onboarding as complete
  Future<void> setOnboardingComplete(bool complete) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingComplete, complete);
  }

  // Check if onboarding is complete
  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  // Save preferred pandit
  Future<void> savePreferredPandit(String panditId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPreferredPanditId, panditId);
  }

  // Get preferred pandit
  Future<String?> getPreferredPandit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPreferredPanditId);
  }

  static const String _keyShippingName = 'shipping_name';
  static const String _keyShippingEmail = 'shipping_email';
  static const String _keyShippingPhone = 'shipping_phone';
  static const String _keyShippingAddressLine1 = 'shipping_address_line1';
  static const String _keyShippingCity = 'shipping_city';
  static const String _keyShippingState = 'shipping_state';
  static const String _keyShippingZip = 'shipping_zip';

  // Save shipping details
  Future<void> saveShippingDetails({
    required String name,
    required String email,
    required String phone,
    required String addressLine1,
    required String city,
    required String state,
    required String zip,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyShippingName, name);
    await prefs.setString(_keyShippingEmail, email);
    await prefs.setString(_keyShippingPhone, phone);
    await prefs.setString(_keyShippingAddressLine1, addressLine1);
    await prefs.setString(_keyShippingCity, city);
    await prefs.setString(_keyShippingState, state);
    await prefs.setString(_keyShippingZip, zip);
  }

  // Get shipping details
  Future<Map<String, String>?> getShippingDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_keyShippingName);
    if (name == null) return null;

    return {
      'name': name,
      'email': prefs.getString(_keyShippingEmail) ?? '',
      'phone': prefs.getString(_keyShippingPhone) ?? '',
      'addressLine1': prefs.getString(_keyShippingAddressLine1) ?? '',
      'city': prefs.getString(_keyShippingCity) ?? '',
      'state': prefs.getString(_keyShippingState) ?? '',
      'zip': prefs.getString(_keyShippingZip) ?? '',
    };
  }

  // Clear all preferences (for logout)
  Future<void> clearAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Clear only onboarding data (keep user preferences)
  Future<void> clearOnboardingData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySelectedCategory);
    await prefs.remove(_keyDateOfBirth);
    await prefs.remove(_keyPlaceOfBirth);
    await prefs.remove(_keyTimeOfBirth);
    await prefs.remove(_keyOnboardingComplete);
  }
}

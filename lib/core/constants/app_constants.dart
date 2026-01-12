class AppConstants {
  // App Info
  static const String appName = 'Vedic Mate';
  static const String appTagline = 'Connect with Trusted Vedic Experts';
  
  // API Endpoints (Placeholder - replace with actual endpoints)
  static const String baseUrl = 'https://15.207.36.26:3001';
  static const String apiVersion = '/v1';
  
  // Storage Keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  
  // User Roles
  static const String roleClient = 'client';
  static const String rolePandit = 'pandit';
  static const String roleAdmin = 'admin';
  
  // Booking Status
  static const String bookingPending = 'pending';
  static const String bookingConfirmed = 'confirmed';
  static const String bookingCompleted = 'completed';
  static const String bookingCancelled = 'cancelled';
  
  // Payment Status
  static const String paymentPending = 'pending';
  static const String paymentSuccess = 'success';
  static const String paymentFailed = 'failed';
  static const String paymentRefunded = 'refunded';
  
  // Call Types
  static const String callTypeVideo = 'video';
  static const String callTypeAudio = 'audio';
  
  // Platform Fee Percentage (65% to Pandit, 35% to Platform)
  static const double platformFeePercent = 35.0;
  static const double panditSharePercent = 65.0;
  
  // GST Rate
  static const double gstRate = 18.0;
  
  // Pagination
  static const int itemsPerPage = 20;
  
  // Timeouts
  static const int apiTimeout = 30; // seconds
  static const int otpTimeout = 300; // seconds
  
  // File Upload Limits
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
}


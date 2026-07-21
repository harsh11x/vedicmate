class EnvConfig {
  // AWS Server Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://13.60.233.237:3001',
  );
  
  // AI Service Configuration (local LM Studio by default)
  static const String aiServiceUrl = String.fromEnvironment(
    'AI_SERVICE_URL',
    defaultValue: 'http://localhost:1234',
  );
  
  // Supabase Configuration
  static const String supabaseUrl = 'https://huudzivjspjfljiqoquh.supabase.com';
  static const String supabaseAnonKey = 'sb_publishable_0fsJbek0e13wD0MWcFin5w_muQr2gKI';

  // Razorpay keys stay on the backend. The app requests checkout orders from API_BASE_URL.
}

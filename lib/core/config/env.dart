class EnvConfig {
  // AWS Server Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://15.207.36.26:3001',
  );
  
  // AI Service Configuration (ngrok)
  static const String aiServiceUrl = String.fromEnvironment(
    'AI_SERVICE_URL',
    defaultValue: 'https://eb1d2d0d4fc8.ngrok-free.app',
  );
  
  // Supabase Configuration
  static const String supabaseUrl = 'https://huudzivjspjfljiqoquh.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_0fsJbek0e13wD0MWcFin5w_muQr2gKI';
}

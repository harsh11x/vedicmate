class EnvConfig {
  // AWS Server Configuration
  // Set this to your AWS server IP/domain when deploying
  // Example: 'http://ec2-xx-xx-xx-xx.compute-1.amazonaws.com:4000'
  // Or use environment variable: flutter run --dart-define=API_BASE_URL=http://your-server-ip:4000
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:4000', // Change to AWS server IP when ready
  );
  
  // AI Service Configuration
  // Set this to your AWS AI service URL when deployed
  // Example: 'http://ec2-xx-xx-xx-xx.compute-1.amazonaws.com:5000'
  // Or use environment variable: flutter run --dart-define=AI_SERVICE_URL=http://your-ai-server-ip:5000
  static const String aiServiceUrl = String.fromEnvironment(
    'AI_SERVICE_URL',
    defaultValue: 'http://localhost:5000', // Change to AWS AI service URL when ready
  );
  
  // For production, uncomment and set your AWS server IP:
  // static const String apiBaseUrl = 'http://YOUR_AWS_SERVER_IP:4000';
  // Or use: 'https://your-domain.com'
  // Supabase Configuration
  static const String supabaseUrl = 'https://huudzivjspjfljiqoquh.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_0fsJbek0e13wD0MWcFin5w_muQr2gKI';
}

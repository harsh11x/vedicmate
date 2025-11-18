class EnvConfig {
  // AWS Server Configuration
  // Set this to your AWS server IP/domain when deploying
  // Example: 'http://ec2-xx-xx-xx-xx.compute-1.amazonaws.com:4000'
  // Or use environment variable: flutter run --dart-define=API_BASE_URL=http://your-server-ip:4000
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:4000', // Change to AWS server IP when ready
  );
  
  // For production, uncomment and set your AWS server IP:
  // static const String apiBaseUrl = 'http://YOUR_AWS_SERVER_IP:4000';
  // Or use: 'https://your-domain.com'
}

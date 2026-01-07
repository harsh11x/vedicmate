/// Gemini API Configuration
/// 
/// To use the AI personality features:
/// 1. Get your Gemini API key from: https://makersuite.google.com/app/apikey
/// 2. Replace 'YOUR_GEMINI_API_KEY_HERE' in gemini_service.dart with your actual API key
/// 3. For production, consider using environment variables or secure storage
class GeminiConfig {
  // Gemini API Key for Vedic Mate
  // Project: Vedic Mate (933572591660)
  // Note: In production, use environment variables or secure storage
  static const String apiKey = 'AIzaSyD5xwXaJbKIq_HzDSFhHY3ZaLQ_FvjS4Xw';
  
  // API endpoint (without key parameter - key is added in service)
  static const String baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=';
  
  // Model configuration
  static const double temperature = 0.7; // Controls randomness (0.0-1.0)
  static const int topK = 40; // Top K sampling
  static const double topP = 0.95; // Nucleus sampling
  static const int maxOutputTokens = 1024; // Maximum response length
}


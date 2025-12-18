class GeminiService {
  GeminiService();
  Future<String> getWelcomeMessage() async => "Welcome to AI Chat";
  Future<String> sendMessage(String message, List<dynamic> history, {String? panditId}) async => "I am an AI response";
}

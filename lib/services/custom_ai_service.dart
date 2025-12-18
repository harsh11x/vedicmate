class CustomAIService {
  CustomAIService();
  Future<String> getWelcomeMessage() async => "Welcome to Custom AI";
  Future<String> sendMessage(String message, List<dynamic> history) async => "AI response";
}

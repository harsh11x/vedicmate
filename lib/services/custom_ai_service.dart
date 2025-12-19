import '../models/ai_pandit_model.dart';
import 'dart:math';

/// Custom AI Service that provides personality-based responses
/// This works without external APIs and can be enhanced later with AWS-hosted AI
class CustomAIService {
  CustomAIService();

  /// Get welcome message based on pandit personality
  Future<String> getWelcomeMessage({String? panditId}) async {
    if (panditId == null) {
      return 'Namaste! Welcome to Vedic Mate. I\'m here to help you with Vedic astrology and spiritual guidance. How may I assist you today? 🙏';
    }

    final pandit = AIPandits.getById(panditId);
    if (pandit == null) {
      return 'Namaste! Welcome. How may I help you today?';
    }

    final name = pandit.name;
    final specializations = pandit.specializations.first;
    final experience = pandit.experienceYears;

    // Personalized greetings based on pandit characteristics
    if (pandit.id.contains('priya') || pandit.id.contains('meera') || pandit.id.contains('anjali')) {
      return 'Namaste! I\'m $name. 🙏 I\'m here to help you with $specializations and guide you with compassion. How may I assist you today?';
    }

    if (pandit.id.contains('rajesh') || pandit.id.contains('ramesh') || pandit.id.contains('ravi')) {
      return 'Pranam! I am $name, your guide in $specializations. With $experience years of experience, I\'m here to help you. What would you like to know?';
    }

    if (pandit.id.contains('swami') || pandit.id.contains('anand') || pandit.id.contains('guru')) {
      return 'Om Namah Shivaya! I am $name. Welcome, seeker. I guide you in $specializations and spiritual wisdom. How may I serve you?';
    }

    if (pandit.id.contains('acharya') || pandit.id.contains('jyotish')) {
      return 'Pranam! I am $name, an Acharya with $experience years of experience in $specializations. How can I assist you today?';
    }

    if (pandit.gender == 'female') {
      return 'Namaste! I\'m $name, specializing in $specializations. I\'m here to help you with Vedic guidance. What can I assist you with today? 🙏';
    }

    return 'Namaste! I\'m $name, specializing in $specializations. With $experience years of experience, I\'m here to help you. What would you like to know?';
  }

  /// Send message and get AI response based on pandit personality
  Future<String> sendMessage(
    String message,
    List<dynamic> history, {
    String? panditId,
  }) async {
    if (panditId == null) {
      return _getGenericResponse(message);
    }

    final pandit = AIPandits.getById(panditId);
    if (pandit == null) {
      return _getGenericResponse(message);
    }

    // Analyze message and generate personality-based response
    return _generatePersonalityResponse(message, history, pandit);
  }

  /// Generate response based on pandit personality and message content
  String _generatePersonalityResponse(
    String message,
    List<dynamic> history,
    AIPanditModel pandit,
  ) {
    final lowerMessage = message.toLowerCase();
    final name = pandit.name;
    final specializations = pandit.specializations;
    final experience = pandit.experienceYears;
    final gender = pandit.gender;

    // Get speaking style based on pandit
    final speakingStyle = _getSpeakingStyle(pandit);
    final isFormal = pandit.id.contains('rajesh') || 
                    pandit.id.contains('ramesh') || 
                    pandit.id.contains('acharya') ||
                    pandit.id.contains('jyotish');
    final isSpiritual = pandit.id.contains('swami') || 
                       pandit.id.contains('anand') || 
                       pandit.id.contains('guru');
    final isWarm = pandit.id.contains('priya') || 
                   pandit.id.contains('meera') || 
                   pandit.id.contains('anjali') ||
                   gender == 'female';

    // Topic-based responses
    if (lowerMessage.contains('kundli') || lowerMessage.contains('birth chart') || lowerMessage.contains('janam kundli')) {
      return _getKundliResponse(pandit, isFormal, isSpiritual, isWarm);
    }

    if (lowerMessage.contains('love') || lowerMessage.contains('relationship') || lowerMessage.contains('marriage') || lowerMessage.contains('partner')) {
      return _getLoveResponse(pandit, isFormal, isSpiritual, isWarm);
    }

    if (lowerMessage.contains('career') || lowerMessage.contains('job') || lowerMessage.contains('business') || lowerMessage.contains('profession')) {
      return _getCareerResponse(pandit, isFormal, isSpiritual, isWarm);
    }

    if (lowerMessage.contains('health') || lowerMessage.contains('illness') || lowerMessage.contains('disease') || lowerMessage.contains('sick')) {
      return _getHealthResponse(pandit, isFormal, isSpiritual, isWarm);
    }

    if (lowerMessage.contains('money') || lowerMessage.contains('wealth') || lowerMessage.contains('finance') || lowerMessage.contains('financial')) {
      return _getMoneyResponse(pandit, isFormal, isSpiritual, isWarm);
    }

    if (lowerMessage.contains('education') || lowerMessage.contains('study') || lowerMessage.contains('exam') || lowerMessage.contains('student')) {
      return _getEducationResponse(pandit, isFormal, isSpiritual, isWarm);
    }

    if (lowerMessage.contains('vastu') || lowerMessage.contains('home') || lowerMessage.contains('house') || lowerMessage.contains('property')) {
      return _getVastuResponse(pandit, isFormal, isSpiritual, isWarm);
    }

    if (lowerMessage.contains('numerology') || lowerMessage.contains('number') || lowerMessage.contains('name')) {
      return _getNumerologyResponse(pandit, isFormal, isSpiritual, isWarm);
    }

    if (lowerMessage.contains('remedy') || lowerMessage.contains('solution') || lowerMessage.contains('upay') || lowerMessage.contains('puja')) {
      return _getRemedyResponse(pandit, isFormal, isSpiritual, isWarm);
    }

    if (lowerMessage.contains('future') || lowerMessage.contains('prediction') || lowerMessage.contains('what will happen')) {
      return _getPredictionResponse(pandit, isFormal, isSpiritual, isWarm);
    }

    // Greeting responses
    if (lowerMessage.contains('hello') || lowerMessage.contains('hi') || lowerMessage.contains('namaste') || lowerMessage.contains('pranam')) {
      return _getGreetingResponse(pandit, isFormal, isSpiritual, isWarm);
    }

    // Question responses
    if (message.contains('?') || lowerMessage.contains('how') || lowerMessage.contains('what') || lowerMessage.contains('why') || lowerMessage.contains('when')) {
      return _getQuestionResponse(pandit, message, isFormal, isSpiritual, isWarm);
    }

    // Default personalized response
    return _getDefaultResponse(pandit, message, isFormal, isSpiritual, isWarm);
  }

  String _getKundliResponse(AIPanditModel pandit, bool isFormal, bool isSpiritual, bool isWarm) {
    final responses = [
      if (isFormal)
        'I understand you\'re asking about Kundli analysis. As an expert in ${pandit.specializations.first}, I can help you understand your birth chart. Please share your birth details (date, time, place) for a detailed analysis. The planetary positions at the time of your birth reveal important insights about your life path.',
      if (isSpiritual)
        'Kundli, or Janam Patrika, is a divine map of your soul\'s journey. The planets and their positions at your birth time reveal your karmic patterns. Share your birth details, and I will help you understand the cosmic influences shaping your destiny.',
      if (isWarm)
        'I\'d be happy to help you with your Kundli! Your birth chart is like a blueprint of your life. To give you accurate guidance, please share your birth date, time, and place. I\'ll analyze it with care and compassion. 🙏',
      'Kundli analysis is one of my specialties. Your birth chart reveals your planetary positions and their effects on your life. Please share your complete birth details (date, time, place) so I can provide you with accurate insights.',
    ];
    return responses[Random().nextInt(responses.length)];
  }

  String _getLoveResponse(AIPanditModel pandit, bool isFormal, bool isSpiritual, bool isWarm) {
    final responses = [
      if (isWarm)
        'Relationships are beautiful aspects of life that need care and understanding. I\'m here to help you with love and relationship guidance. Could you share more details about your situation? Whether it\'s about compatibility, timing, or challenges, I\'ll guide you with empathy. 💕',
      if (isSpiritual)
        'Love is a divine connection between souls. The planets influence our relationships and compatibility. Share your concerns, and I will guide you through the cosmic wisdom to find harmony in your relationships.',
      'Relationship guidance is important. Based on my experience in ${pandit.specializations.first}, I can help you understand compatibility, timing, and remedies. Please share more details about your relationship situation.',
    ];
    return responses[Random().nextInt(responses.length)];
  }

  String _getCareerResponse(AIPanditModel pandit, bool isFormal, bool isSpiritual, bool isWarm) {
    final responses = [
      if (isFormal)
        'Career guidance is one of my specialties. The planets in your chart influence your professional life. To provide accurate guidance, I need to analyze your birth chart. Please share your birth details, and I\'ll help you understand the best career path and timing for opportunities.',
      'Career and profession are influenced by planetary positions. I can help you understand the best career direction, timing for job changes, and remedies for professional growth. Share your birth details for a detailed analysis.',
    ];
    return responses[Random().nextInt(responses.length)];
  }

  String _getHealthResponse(AIPanditModel pandit, bool isFormal, bool isSpiritual, bool isWarm) {
    final responses = [
      if (pandit.specializations.any((s) => s.contains('Health') || s.contains('Medical')))
        'As a medical astrologer, I combine Ayurvedic wisdom with Jyotish to understand health patterns. The planets influence our physical and mental well-being. Please share your birth details and health concerns, and I\'ll guide you with appropriate remedies.',
      'Health is influenced by planetary positions. While I can provide astrological guidance, please also consult medical professionals for serious health issues. Share your birth details and concerns, and I\'ll help you understand the astrological factors.',
    ];
    return responses[Random().nextInt(responses.length)];
  }

  String _getMoneyResponse(AIPanditModel pandit, bool isFormal, bool isSpiritual, bool isWarm) {
    final responses = [
      'Financial prosperity is influenced by planets like Jupiter and Venus. I can help you understand the timing for financial gains, remedies for wealth, and ways to improve your financial situation. Share your birth details for personalized guidance.',
      'Money and wealth are governed by specific planets in your chart. Through astrological analysis, I can guide you on auspicious times for investments, remedies for financial growth, and ways to attract prosperity.',
    ];
    return responses[Random().nextInt(responses.length)];
  }

  String _getEducationResponse(AIPanditModel pandit, bool isFormal, bool isSpiritual, bool isWarm) {
    final responses = [
      if (isWarm)
        'Education is a precious gift! I\'d be happy to help you with educational guidance. The planets influence learning, memory, and academic success. Share your birth details or your child\'s details, and I\'ll provide guidance on studies, exams, and career choices. 📚',
      'Educational success is influenced by Mercury and Jupiter in your chart. I can help you understand the best subjects, timing for exams, and remedies for academic excellence. Please share birth details for analysis.',
    ];
    return responses[Random().nextInt(responses.length)];
  }

  String _getVastuResponse(AIPanditModel pandit, bool isFormal, bool isSpiritual, bool isWarm) {
    final responses = [
      if (pandit.specializations.any((s) => s.contains('Vastu')))
        'Vastu Shastra is my specialization! The energy flow in your home or office affects your life significantly. I can help you identify Vastu defects and suggest remedies. Please share details about your property or send photos if possible.',
      'Vastu Shastra deals with the energy of spaces. Proper Vastu can bring harmony, prosperity, and peace. I can guide you on Vastu principles and remedies. Share details about your home or workplace.',
    ];
    return responses[Random().nextInt(responses.length)];
  }

  String _getNumerologyResponse(AIPanditModel pandit, bool isFormal, bool isSpiritual, bool isWarm) {
    final responses = [
      if (pandit.specializations.any((s) => s.contains('Numerology')))
        'Numerology is my expertise! Numbers have deep spiritual significance. I can analyze your name, birth date, and life path number to provide guidance. Please share your full name and date of birth for a detailed numerological analysis.',
      'Numerology reveals insights through numbers. Your name and birth date carry numerical vibrations that influence your life. Share your details, and I\'ll help you understand your numerological profile.',
    ];
    return responses[Random().nextInt(responses.length)];
  }

  String _getRemedyResponse(AIPanditModel pandit, bool isFormal, bool isSpiritual, bool isWarm) {
    final responses = [
      if (isSpiritual)
        'Remedies are powerful tools to balance planetary influences. Based on your chart, I can suggest mantras, gemstones, pujas, and other remedies. Please share your birth details and the specific issue you\'re facing, and I\'ll provide personalized remedies.',
      'Vedic remedies can help balance planetary energies and resolve issues. I can suggest appropriate remedies like gemstones, mantras, pujas, or lifestyle changes. Share your birth details and concerns for personalized guidance.',
    ];
    return responses[Random().nextInt(responses.length)];
  }

  String _getPredictionResponse(AIPanditModel pandit, bool isFormal, bool isSpiritual, bool isWarm) {
    final responses = [
      if (isFormal)
        'Future predictions require detailed analysis of your birth chart and current planetary transits. Please share your complete birth details (date, time, place), and I\'ll provide insights about upcoming periods in your life.',
      if (isSpiritual)
        'The future is written in the stars, but it\'s not fixed. Through your birth chart, I can see the patterns and possibilities ahead. Share your birth details, and I\'ll guide you on what the planets reveal about your future.',
      'I can provide predictions based on your birth chart and planetary movements. For accurate insights, please share your complete birth details (date, time, place of birth).',
    ];
    return responses[Random().nextInt(responses.length)];
  }

  String _getGreetingResponse(AIPanditModel pandit, bool isFormal, bool isSpiritual, bool isWarm) {
    final responses = [
      if (isSpiritual) 'Om Namah Shivaya! How may I help you today, seeker?',
      if (isFormal) 'Pranam! I\'m here to assist you. What would you like to know?',
      if (isWarm) 'Namaste! 🙏 I\'m glad you\'re here. How can I help you today?',
      'Namaste! How may I assist you with Vedic guidance today?',
    ];
    return responses[Random().nextInt(responses.length)];
  }

  String _getQuestionResponse(AIPanditModel pandit, String message, bool isFormal, bool isSpiritual, bool isWarm) {
    final responses = [
      if (isFormal)
        'That\'s an interesting question. To provide you with accurate guidance, I would need to analyze your birth chart. Please share your birth details (date, time, place), and I\'ll give you a detailed answer based on Vedic astrology principles.',
      if (isSpiritual)
        'A thoughtful question indeed. The answer lies in understanding your karmic patterns and planetary influences. Share your birth details, and I\'ll help you find clarity through cosmic wisdom.',
      if (isWarm)
        'I\'d be happy to help you with that! To give you the best guidance, I\'ll need your birth details. Please share your date, time, and place of birth, and I\'ll provide you with personalized insights. 🙏',
      'To answer your question accurately, I need to analyze your birth chart. Please share your complete birth details (date, time, place), and I\'ll provide you with detailed guidance.',
    ];
    return responses[Random().nextInt(responses.length)];
  }

  String _getDefaultResponse(AIPanditModel pandit, String message, bool isFormal, bool isSpiritual, bool isWarm) {
    final responses = [
      if (isWarm)
        'Thank you for sharing that with me. As ${pandit.name}, I specialize in ${pandit.specializations.first}. To provide you with the best guidance, could you share your birth details (date, time, place)? This will help me give you personalized insights. 🙏',
      if (isFormal)
        'I understand. Based on my ${pandit.experienceYears} years of experience in ${pandit.specializations.first}, I can help you. Please share your birth details for a detailed analysis, and I\'ll provide you with accurate guidance.',
      if (isSpiritual)
        'I hear you, seeker. The cosmos has answers for your concerns. Share your birth details, and I\'ll help you understand the divine plan for your life through Vedic wisdom.',
      'Thank you for your message. I specialize in ${pandit.specializations.first} and would be happy to help. Please share your birth details (date, time, place) so I can provide you with personalized astrological guidance.',
    ];
    return responses[Random().nextInt(responses.length)];
  }

  String _getGenericResponse(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('kundli') || lowerMessage.contains('birth chart')) {
      return 'I can help you with Kundli analysis. Please share your birth details (date, time, place) for a detailed reading.';
    }
    
    if (lowerMessage.contains('love') || lowerMessage.contains('relationship')) {
      return 'I can help you with relationship guidance. Share your birth details and concerns, and I\'ll provide insights.';
    }
    
    if (lowerMessage.contains('career') || lowerMessage.contains('job')) {
      return 'Career guidance is available. Please share your birth details for personalized advice.';
    }
    
    return 'I\'m here to help you with Vedic astrology and spiritual guidance. Please share your birth details (date, time, place) so I can provide you with accurate insights.';
  }

  String _getSpeakingStyle(AIPanditModel pandit) {
    if (pandit.id.contains('rajesh') || pandit.id.contains('ramesh')) {
      return 'formal';
    }
    if (pandit.id.contains('swami') || pandit.id.contains('anand')) {
      return 'spiritual';
    }
    if (pandit.id.contains('priya') || pandit.id.contains('meera')) {
      return 'warm';
    }
    return 'balanced';
  }
}

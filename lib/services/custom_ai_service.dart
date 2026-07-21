import '../models/ai_pandit_model.dart';
import 'dart:math';

/// Custom AI Service that provides personality-based responses
/// This works without external APIs and can be enhanced later with AWS-hosted AI
class CustomAIService {
  CustomAIService();

  /// Get welcome message based on pandit personality
  Future<String> getWelcomeMessage({String? panditId}) async {
    if (panditId == null) {
      return 'Namaste! Welcome to Vedic Mate. I\'m here to help with cultural wellness, reflection, rituals, and spiritual guidance. How may I assist you today? 🙏';
    }

    final pandit = AIPandits.getById(panditId);
    if (pandit == null) {
      return 'Namaste! Welcome. How may I help you today?';
    }

    final name = pandit.name;
    final specializations = pandit.publicSpecializations.first;
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
      return 'Namaste! I\'m $name, specializing in $specializations. I\'m here to help you with reflective Vedic guidance. What can I assist you with today? 🙏';
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

    if (lowerMessage.contains('future') ||
        lowerMessage.contains('prediction') ||
        lowerMessage.contains('what will happen')) {
      return _getReflectionResponse(pandit, isFormal, isSpiritual, isWarm);
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
        'I understand you\'re asking for a personal profile. As an expert in ${pandit.publicSpecializations.first}, I can help you reflect on patterns and routines. Please share your details so I can personalize the guidance.',
      if (isSpiritual)
        'A traditional birth profile can be used as a reflective cultural tool. Share your details, and I will help you explore themes, rituals, and practical next steps without treating them as guaranteed outcomes.',
      if (isWarm)
        'I\'d be happy to help with your personal profile. Please share your birth date, time, and place, and I\'ll respond with care, context, and practical reflection prompts. 🙏',
      'Personal profile guidance is one of my specialties. Please share your complete details so I can provide culturally rooted, reflective guidance.',
    ];
    return responses[Random().nextInt(responses.length)];
  }

  String _getLoveResponse(AIPanditModel pandit, bool isFormal, bool isSpiritual, bool isWarm) {
    final responses = [
      if (isWarm)
        'Relationships are beautiful aspects of life that need care and understanding. I\'m here to help you with love and relationship guidance. Could you share more details about your situation? Whether it\'s about compatibility, timing, or challenges, I\'ll guide you with empathy. 💕',
      if (isSpiritual)
        'Love is a meaningful connection that benefits from patience, communication, and self-awareness. Share your concerns, and I will help you reflect on harmony in your relationship.',
      'Relationship guidance is important. Based on my experience in ${pandit.publicSpecializations.first}, I can help you reflect on compatibility, communication, and supportive routines. Please share more details.',
    ];
    return responses[Random().nextInt(responses.length)];
  }

  String _getCareerResponse(AIPanditModel pandit, bool isFormal, bool isSpiritual, bool isWarm) {
    final responses = [
      if (isFormal)
        'Career guidance is one of my specialties. I can help you reflect on strengths, timing, routines, and decision-making. Share your details and current situation for personalized guidance.',
      'I can help you think through career direction, job changes, and practical steps for professional growth. Share your details for a reflective session.',
    ];
    return responses[Random().nextInt(responses.length)];
  }

  String _getHealthResponse(AIPanditModel pandit, bool isFormal, bool isSpiritual, bool isWarm) {
    final responses = [
      if (pandit.specializations.any((s) => s.contains('Health') || s.contains('Medical')))
        'I can discuss Ayurveda-inspired wellness patterns and reflective routines. Please also consult qualified medical professionals for health concerns.',
      'For wellness questions, I can suggest reflective routines and cultural practices. Please consult medical professionals for diagnosis, treatment, or serious symptoms.',
    ];
    return responses[Random().nextInt(responses.length)];
  }

  String _getMoneyResponse(AIPanditModel pandit, bool isFormal, bool isSpiritual, bool isWarm) {
    final responses = [
      'I can help you reflect on money habits, discipline, and practical routines for financial wellbeing. This is not financial advice.',
      'For finance questions, I can offer reflective prompts and cultural practices for focus and discipline. Please consult a qualified financial advisor before making investment decisions.',
    ];
    return responses[Random().nextInt(responses.length)];
  }

  String _getEducationResponse(AIPanditModel pandit, bool isFormal, bool isSpiritual, bool isWarm) {
    final responses = [
      if (isWarm)
        'Education is a precious gift! I\'d be happy to help with study routines, focus, and reflective planning for exams or subject choices. 📚',
      'I can help you plan study habits, focus rituals, and reflective routines for academic growth.',
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
        'Life planning is my expertise. I can use your name and date as reflective prompts to discuss routines, priorities, and planning.',
      'Your name and date can be used as a reflective framework. Share your details, and I\'ll help you build a practical planning profile.',
    ];
    return responses[Random().nextInt(responses.length)];
  }

  String _getRemedyResponse(AIPanditModel pandit, bool isFormal, bool isSpiritual, bool isWarm) {
    final responses = [
      if (isSpiritual)
        'Remedies can be meaningful cultural routines for reflection and discipline. Share the issue you\'re facing, and I\'ll suggest suitable mantras, puja practices, or lifestyle steps.',
      'I can suggest cultural remedies such as mantras, puja practices, or lifestyle changes for reflective support. Share your concern for personalized guidance.',
    ];
    return responses[Random().nextInt(responses.length)];
  }

  String _getReflectionResponse(AIPanditModel pandit, bool isFormal, bool isSpiritual, bool isWarm) {
    final responses = [
      if (isFormal)
        'I can help you reflect on possibilities and prepare for upcoming decisions, but I cannot guarantee future outcomes. Share your context and I\'ll guide you thoughtfully.',
      if (isSpiritual)
        'The future is shaped by choices, habits, and circumstances. I can help you reflect on patterns and prepare with clarity.',
      'I can offer reflective guidance about possibilities and next steps, not guaranteed predictions. Please share more about your situation.',
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
        'That\'s an interesting question. Please share some context, and I\'ll offer reflective guidance using Vedic wellness principles.',
      if (isSpiritual)
        'A thoughtful question indeed. We can explore your patterns, choices, and supportive practices to help you find clarity.',
      if (isWarm)
        'I\'d be happy to help you with that! Share a little more context, and I\'ll provide thoughtful, personalized guidance. 🙏',
      'To answer well, I need a little more context about your situation. I\'ll provide reflective guidance and practical next steps.',
    ];
    return responses[Random().nextInt(responses.length)];
  }

  String _getDefaultResponse(AIPanditModel pandit, String message, bool isFormal, bool isSpiritual, bool isWarm) {
    final responses = [
      if (isWarm)
        'Thank you for sharing that with me. As ${pandit.name}, I specialize in ${pandit.publicSpecializations.first}. Could you share a little more context so I can personalize the guidance? 🙏',
      if (isFormal)
        'I understand. Based on my ${pandit.experienceYears} years of experience in ${pandit.publicSpecializations.first}, I can help you reflect on this and choose practical next steps.',
      if (isSpiritual)
        'I hear you, seeker. Let us approach this with calm reflection, cultural wisdom, and practical steps.',
      'Thank you for your message. I specialize in ${pandit.publicSpecializations.first} and would be happy to help with reflective Vedic guidance.',
    ];
    return responses[Random().nextInt(responses.length)];
  }

  String _getGenericResponse(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('kundli') || lowerMessage.contains('birth chart')) {
      return 'I can help you with a personal profile for reflection. Please share your details for culturally rooted guidance.';
    }
    
    if (lowerMessage.contains('love') || lowerMessage.contains('relationship')) {
      return 'I can help you with relationship guidance. Share your concerns, and I\'ll provide reflective prompts and practical next steps.';
    }
    
    if (lowerMessage.contains('career') || lowerMessage.contains('job')) {
      return 'Career guidance is available. Share your current situation for reflective planning support.';
    }
    
    return 'I\'m here to help with cultural wellness, reflection, rituals, and spiritual guidance. Share what you need help with, and I\'ll respond thoughtfully.';
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

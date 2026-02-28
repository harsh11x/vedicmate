class InsightService {
  static final InsightService _instance = InsightService._internal();
  factory InsightService() => _instance;
  InsightService._internal();

  // Basic Interpretations Database (Simplified)
  // In a real app, this would be a large JSON or database.

  String getAscendantNature(String sign) {
    switch (sign) {
      case 'Mesha (Aries)': return "You are bold, ambitious, and energetic. A natural leader with a pioneering spirit.";
      case 'Vrishabha (Taurus)': return "You are practical, reliable, and patient. You value stability and comfort.";
      case 'Mithuna (Gemini)': return "You are curious, adaptable, and communicative. Quick-witted and versatile.";
      case 'Karka (Cancer)': return "You are nurturing, emotional, and intuitive. Highly protective of loved ones.";
      case 'Simha (Leo)': return "You are charismatic, generous, and creative. You love being center stage.";
      case 'Kanya (Virgo)': return "You are analytical, detail-oriented, and helpful. A perfectionist at heart.";
      case 'Tula (Libra)': return "You are diplomatic, charming, and fair-minded. You seek harmony in relationships.";
      case 'Vrischika (Scorpio)': return "You are intense, passionate, and secretive. Deeply emotional and resourceful.";
      case 'Dhanu (Sagittarius)': return "You are optimistic, adventurous, and philosophical. A seeker of truth.";
      case 'Makara (Capricorn)': return "You are disciplined, ambitious, and prudent. Focused on long-term goals.";
      case 'Kumbha (Aquarius)': return "You are innovative, independent, and humanitarian. Forward-thinking.";
      case 'Meena (Pisces)': return "You are compassionate, artistic, and gentle. Deeply intuitive and spiritual.";
      default: return "Your nature is a blend of various influences.";
    }
  }

  String getMoonMindset(String sign) {
    // Moon represents the Mind/Emotions
    switch (sign) {
      case 'Mesha (Aries)': return "Your mind is active and impulsive. You react quickly to situations.";
      case 'Vrishabha (Taurus)': return "Your emotions are stable. You find comfort in routine and security.";
      // ... Add others as needed for demo
      case 'Mithuna (Gemini)': return "Your mind is restless and curious. You process emotions intellectually.";
      case 'Karka (Cancer)': return "You feel deeply and are very sensitive to your environment.";
      case 'Simha (Leo)': return "You are emotionally expressive and need appreciation.";
      case 'Kanya (Virgo)': return "You analyze your feelings. You worry about details.";
      case 'Tula (Libra)': return "You seek emotional balance and partnership.";
      case 'Vrischika (Scorpio)': return "Your feelings are intense and transformative.";
      case 'Dhanu (Sagittarius)': return "You are emotionally optimistic and love freedom.";
      case 'Makara (Capricorn)': return "You are emotionally reserved and serious.";
      case 'Kumbha (Aquarius)': return "You detach from emotions to analyze them objectively.";
      case 'Meena (Pisces)': return "You are highly empathetic and absorbent of others' feelings.";
      default: return "";
    }
  }

  List<String> getCareerHints(Map<String, dynamic> planets) {
    List<String> hints = [];
    
    // Check Sun for Authority/Leadership
    final sunSign = planets['Sun']['rashi'];
    if (sunSign.contains('Leo') || sunSign.contains('Aries')) {
      hints.add("Strong potential for leadership roles, management, or government service.");
    }

    // Check Mercury for Business/Communication
    final mercSign = planets['Mercury']['rashi'];
    if (mercSign.contains('Gemini') || mercSign.contains('Virgo')) {
      hints.add("Excellent aptitude for writing, coding, accounting, or business.");
    }
    
    // Check Saturn for Hard Work/Structure
    final satSign = planets['Saturn']['rashi'];
    if (satSign.contains('Capricorn') || satSign.contains('Aquarius') || satSign.contains('Libra')) {
      hints.add("Success through discipline, law, engineering, or long-term projects.");
    }

    return hints;
  }

  List<String> getWealthHints(Map<String, dynamic> planets) {
    List<String> hints = [];
    final jupSign = planets['Jupiter']['rashi'];
    final venSign = planets['Venus']['rashi'];

    if (jupSign.contains('Cancer') || jupSign.contains('Sagittarius') || jupSign.contains('Pisces')) {
      hints.add("Jupiter's strong position indicates abundance and good financial wisdom.");
    }

    if (venSign.contains('Pisces') || venSign.contains('Taurus') || venSign.contains('Libra')) {
      hints.add("Venus suggests wealth through arts, luxury, or partnerships.");
    }
    
    // Dhana Yogas (Simplified check of 2nd/11th lords is hard without house lords calc, so we stick to Kararkas)
    if (hints.isEmpty) hints.add("Steady accumulation of wealth through consistent effort is indicated.");
    
    return hints;
  }

  List<String> getHealthHints(Map<String, dynamic> planets) {
    List<String> hints = [];
    final sunSign = planets['Sun']['rashi'];
    final marsSign = planets['Mars']['rashi'];

    if (sunSign.contains('Libra')) {
       hints.add("Sun is debilitated. Take care of vitality, heart, and eyes.");
    } else if (sunSign.contains('Aries') || sunSign.contains('Leo')) {
       hints.add("Strong vitality and immunity are indicated.");
    }
    
    if (marsSign.contains('Cancer')) {
      hints.add("Mars is debilitating. Watch out for blood or stomach related issues.");
    }

    return hints;
  }
}

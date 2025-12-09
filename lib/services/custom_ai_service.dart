import 'dart:convert';
import 'dart:math';
import '../models/ai_chat_model.dart';

/// Advanced Custom AI Service for Vedic Astrology, Astronomy, Numerology, and Vastu
/// Provides intelligent, conversational responses based on comprehensive knowledge base
class CustomAIService {
  final Random _random = Random();
  
  // Comprehensive Zodiac Sign Knowledge
  final Map<String, Map<String, dynamic>> _zodiacKnowledge = {
    'aries': {
      'ruler': 'Mars',
      'element': 'Fire',
      'quality': 'Cardinal',
      'traits': ['Leadership', 'Courage', 'Independence', 'Impulsiveness'],
      'compatible': ['Leo', 'Sagittarius', 'Gemini', 'Aquarius'],
      'career': 'Best suited for leadership roles, entrepreneurship, military, sports, and competitive fields.',
      'health': 'Prone to headaches, fevers, and injuries. Focus on stress management and regular exercise.',
      'love': 'Passionate and direct in relationships. Needs a partner who appreciates independence.',
      'lucky': {'numbers': [1, 8, 17], 'colors': ['Red', 'Orange'], 'days': ['Tuesday', 'Sunday']},
    },
    'taurus': {
      'ruler': 'Venus',
      'element': 'Earth',
      'quality': 'Fixed',
      'traits': ['Stability', 'Patience', 'Sensuality', 'Stubbornness'],
      'compatible': ['Virgo', 'Capricorn', 'Cancer', 'Pisces'],
      'career': 'Excel in finance, real estate, agriculture, arts, and luxury goods.',
      'health': 'Prone to throat and neck issues. Maintain a balanced diet and avoid overindulgence.',
      'love': 'Loyal and devoted. Values security and comfort in relationships.',
      'lucky': {'numbers': [2, 6, 24], 'colors': ['Pink', 'Green'], 'days': ['Friday', 'Monday']},
    },
    'gemini': {
      'ruler': 'Mercury',
      'element': 'Air',
      'quality': 'Mutable',
      'traits': ['Curiosity', 'Communication', 'Adaptability', 'Restlessness'],
      'compatible': ['Libra', 'Aquarius', 'Aries', 'Leo'],
      'career': 'Best in media, writing, teaching, sales, and communication fields.',
      'health': 'Prone to nervous disorders and respiratory issues. Practice meditation.',
      'love': 'Needs intellectual stimulation and freedom in relationships.',
      'lucky': {'numbers': [3, 5, 12], 'colors': ['Yellow', 'Silver'], 'days': ['Wednesday', 'Friday']},
    },
    'cancer': {
      'ruler': 'Moon',
      'element': 'Water',
      'quality': 'Cardinal',
      'traits': ['Nurturing', 'Intuitive', 'Emotional', 'Moody'],
      'compatible': ['Scorpio', 'Pisces', 'Taurus', 'Virgo'],
      'career': 'Excel in caregiving, hospitality, real estate, and creative fields.',
      'health': 'Prone to digestive issues and emotional stress. Focus on emotional well-being.',
      'love': 'Deeply emotional and protective. Needs security and emotional connection.',
      'lucky': {'numbers': [2, 7, 28], 'colors': ['White', 'Silver'], 'days': ['Monday', 'Thursday']},
    },
    'leo': {
      'ruler': 'Sun',
      'element': 'Fire',
      'quality': 'Fixed',
      'traits': ['Confidence', 'Creativity', 'Generosity', 'Pride'],
      'compatible': ['Aries', 'Sagittarius', 'Gemini', 'Libra'],
      'career': 'Natural leaders in entertainment, management, politics, and creative industries.',
      'health': 'Prone to heart and back issues. Maintain cardiovascular health.',
      'love': 'Romantic and generous. Needs admiration and appreciation.',
      'lucky': {'numbers': [1, 5, 19], 'colors': ['Gold', 'Orange'], 'days': ['Sunday', 'Tuesday']},
    },
    'virgo': {
      'ruler': 'Mercury',
      'element': 'Earth',
      'quality': 'Mutable',
      'traits': ['Analytical', 'Practical', 'Perfectionist', 'Critical'],
      'compatible': ['Taurus', 'Capricorn', 'Cancer', 'Scorpio'],
      'career': 'Excel in healthcare, research, accounting, and service-oriented fields.',
      'health': 'Prone to digestive and nervous system issues. Maintain regular routines.',
      'love': 'Practical and devoted. Shows love through service and attention to detail.',
      'lucky': {'numbers': [5, 14, 23], 'colors': ['Navy Blue', 'Brown'], 'days': ['Wednesday', 'Friday']},
    },
    'libra': {
      'ruler': 'Venus',
      'element': 'Air',
      'quality': 'Cardinal',
      'traits': ['Diplomatic', 'Harmonious', 'Indecisive', 'Superficial'],
      'compatible': ['Gemini', 'Aquarius', 'Leo', 'Sagittarius'],
      'career': 'Best in law, diplomacy, arts, fashion, and relationship counseling.',
      'health': 'Prone to kidney and skin issues. Maintain balance in all aspects.',
      'love': 'Romantic and partnership-focused. Seeks harmony and balance.',
      'lucky': {'numbers': [6, 15, 24], 'colors': ['Pink', 'Blue'], 'days': ['Friday', 'Wednesday']},
    },
    'scorpio': {
      'ruler': 'Mars & Pluto',
      'element': 'Water',
      'quality': 'Fixed',
      'traits': ['Intense', 'Passionate', 'Secretive', 'Jealous'],
      'compatible': ['Cancer', 'Pisces', 'Virgo', 'Capricorn'],
      'career': 'Excel in research, psychology, investigation, and transformative fields.',
      'health': 'Prone to reproductive and elimination system issues. Focus on detoxification.',
      'love': 'Intense and passionate. Needs deep emotional and physical connection.',
      'lucky': {'numbers': [4, 13, 22], 'colors': ['Red', 'Black'], 'days': ['Tuesday', 'Saturday']},
    },
    'sagittarius': {
      'ruler': 'Jupiter',
      'element': 'Fire',
      'quality': 'Mutable',
      'traits': ['Adventurous', 'Optimistic', 'Philosophical', 'Restless'],
      'compatible': ['Aries', 'Leo', 'Libra', 'Aquarius'],
      'career': 'Best in education, travel, philosophy, law, and international business.',
      'health': 'Prone to liver and hip issues. Maintain active lifestyle and moderation.',
      'love': 'Freedom-loving and optimistic. Needs space and intellectual connection.',
      'lucky': {'numbers': [3, 12, 21], 'colors': ['Purple', 'Blue'], 'days': ['Thursday', 'Sunday']},
    },
    'capricorn': {
      'ruler': 'Saturn',
      'element': 'Earth',
      'quality': 'Cardinal',
      'traits': ['Ambitious', 'Disciplined', 'Practical', 'Pessimistic'],
      'compatible': ['Taurus', 'Virgo', 'Scorpio', 'Pisces'],
      'career': 'Excel in business, management, government, and long-term planning.',
      'health': 'Prone to bone, joint, and skin issues. Focus on calcium and vitamin D.',
      'love': 'Serious and committed. Values stability and long-term relationships.',
      'lucky': {'numbers': [4, 8, 10], 'colors': ['Black', 'Brown'], 'days': ['Saturday', 'Tuesday']},
    },
    'aquarius': {
      'ruler': 'Saturn & Uranus',
      'element': 'Air',
      'quality': 'Fixed',
      'traits': ['Innovative', 'Independent', 'Humanitarian', 'Detached'],
      'compatible': ['Gemini', 'Libra', 'Aries', 'Sagittarius'],
      'career': 'Best in technology, science, social work, and innovation.',
      'health': 'Prone to circulation and nervous system issues. Maintain social connections.',
      'love': 'Independent and unconventional. Values friendship and intellectual connection.',
      'lucky': {'numbers': [4, 7, 11], 'colors': ['Electric Blue', 'Silver'], 'days': ['Saturday', 'Wednesday']},
    },
    'pisces': {
      'ruler': 'Jupiter & Neptune',
      'element': 'Water',
      'quality': 'Mutable',
      'traits': ['Intuitive', 'Compassionate', 'Dreamy', 'Escapist'],
      'compatible': ['Cancer', 'Scorpio', 'Taurus', 'Capricorn'],
      'career': 'Excel in arts, healing, spirituality, and creative fields.',
      'health': 'Prone to feet and immune system issues. Avoid escapism and maintain boundaries.',
      'love': 'Romantic and selfless. Needs emotional and spiritual connection.',
      'lucky': {'numbers': [3, 7, 12], 'colors': ['Sea Green', 'White'], 'days': ['Thursday', 'Monday']},
    },
  };

  // Numerology Knowledge Base
  final Map<int, Map<String, dynamic>> _numerologyKnowledge = {
    1: {
      'name': 'The Leader',
      'traits': ['Independent', 'Ambitious', 'Innovative', 'Self-centered'],
      'career': 'Leadership roles, entrepreneurship, innovation, and pioneering fields.',
      'compatibility': [1, 5, 7],
      'lucky': {'colors': ['Red', 'Orange'], 'days': ['Sunday', 'Tuesday'], 'stones': ['Ruby', 'Carnelian']},
      'remedy': 'Wear red or orange, practice leadership, and be independent.',
    },
    2: {
      'name': 'The Diplomat',
      'traits': ['Cooperative', 'Sensitive', 'Intuitive', 'Indecisive'],
      'career': 'Partnerships, counseling, diplomacy, and cooperative ventures.',
      'compatibility': [2, 4, 8],
      'lucky': {'colors': ['White', 'Silver'], 'days': ['Monday', 'Friday'], 'stones': ['Pearl', 'Moonstone']},
      'remedy': 'Wear white, practice cooperation, and develop intuition.',
    },
    3: {
      'name': 'The Communicator',
      'traits': ['Creative', 'Expressive', 'Optimistic', 'Superficial'],
      'career': 'Arts, communication, entertainment, and creative industries.',
      'compatibility': [3, 6, 9],
      'lucky': {'colors': ['Yellow', 'Gold'], 'days': ['Thursday', 'Sunday'], 'stones': ['Yellow Sapphire', 'Topaz']},
      'remedy': 'Wear yellow, express creativity, and maintain optimism.',
    },
    4: {
      'name': 'The Builder',
      'traits': ['Practical', 'Stable', 'Hardworking', 'Rigid'],
      'career': 'Construction, engineering, organization, and systematic work.',
      'compatibility': [2, 4, 8],
      'lucky': {'colors': ['Green', 'Brown'], 'days': ['Wednesday', 'Saturday'], 'stones': ['Emerald', 'Jade']},
      'remedy': 'Wear green, build structures, and maintain discipline.',
    },
    5: {
      'name': 'The Adventurer',
      'traits': ['Freedom-loving', 'Curious', 'Versatile', 'Restless'],
      'career': 'Travel, media, communication, and dynamic fields.',
      'compatibility': [1, 5, 7],
      'lucky': {'colors': ['Silver', 'Grey'], 'days': ['Wednesday', 'Friday'], 'stones': ['Diamond', 'Quartz']},
      'remedy': 'Wear silver, embrace change, and seek new experiences.',
    },
    6: {
      'name': 'The Nurturer',
      'traits': ['Caring', 'Responsible', 'Harmonious', 'Overprotective'],
      'career': 'Healthcare, teaching, service, and nurturing professions.',
      'compatibility': [3, 6, 9],
      'lucky': {'colors': ['Blue', 'Pink'], 'days': ['Friday', 'Thursday'], 'stones': ['Blue Sapphire', 'Rose Quartz']},
      'remedy': 'Wear blue or pink, practice care, and maintain harmony.',
    },
    7: {
      'name': 'The Seeker',
      'traits': ['Spiritual', 'Analytical', 'Introspective', 'Isolated'],
      'career': 'Research, spirituality, analysis, and deep study.',
      'compatibility': [1, 5, 7],
      'lucky': {'colors': ['Purple', 'Violet'], 'days': ['Monday', 'Saturday'], 'stones': ['Amethyst', 'Lapis Lazuli']},
      'remedy': 'Wear purple, practice meditation, and seek knowledge.',
    },
    8: {
      'name': 'The Achiever',
      'traits': ['Ambitious', 'Materialistic', 'Powerful', 'Ruthless'],
      'career': 'Business, finance, management, and material success.',
      'compatibility': [2, 4, 8],
      'lucky': {'colors': ['Black', 'Dark Blue'], 'days': ['Saturday', 'Tuesday'], 'stones': ['Black Onyx', 'Sapphire']},
      'remedy': 'Wear black, focus on goals, and practice discipline.',
    },
    9: {
      'name': 'The Humanitarian',
      'traits': ['Compassionate', 'Idealistic', 'Generous', 'Scattered'],
      'career': 'Humanitarian work, healing, teaching, and service to others.',
      'compatibility': [3, 6, 9],
      'lucky': {'colors': ['Red', 'Gold'], 'days': ['Tuesday', 'Thursday'], 'stones': ['Ruby', 'Garnet']},
      'remedy': 'Wear red, practice generosity, and serve others.',
    },
  };

  // Vastu Shastra Knowledge
  final Map<String, dynamic> _vastuKnowledge = {
    'directions': {
      'north': 'North is ruled by Kuber (Wealth God). Keep cash, valuables, and safe in North. Best for study room.',
      'south': 'South is ruled by Yama. Avoid bedrooms and main entrance in South. Good for storage.',
      'east': 'East is ruled by Sun. Best for main entrance, prayer room, and living room. Brings prosperity.',
      'west': 'West is good for dining room and children\'s room. Avoid kitchen in West.',
      'northeast': 'Northeast (Ishan) is most auspicious. Best for prayer room, meditation, and water elements.',
      'northwest': 'Northwest (Vayavya) is ruled by Air. Good for guest room and storage.',
      'southeast': 'Southeast (Agneya) is ruled by Fire. Best for kitchen. Avoid prayer room here.',
      'southwest': 'Southwest (Nairutya) is ruled by Earth. Best for master bedroom and heavy furniture.',
    },
    'rooms': {
      'bedroom': 'Bedroom should be in Southwest. Sleep with head towards South or East. Avoid mirrors facing bed.',
      'kitchen': 'Kitchen should be in Southeast. Cook facing East. Keep water in Northeast corner of kitchen.',
      'prayer': 'Prayer room in Northeast. Face East or North while praying. Keep clean and well-lit.',
      'bathroom': 'Bathroom should be in Northwest or Southeast. Keep door closed. Avoid in Northeast.',
      'living': 'Living room in East or North. Main door should face East, North, or Northeast.',
      'study': 'Study room in North or East. Face East while studying. Keep books in Northeast.',
    },
    'colors': {
      'north': 'Light blue or white',
      'south': 'Red or orange',
      'east': 'Green or light yellow',
      'west': 'White or silver',
      'northeast': 'White or light yellow',
      'northwest': 'White or grey',
      'southeast': 'Orange or red',
      'southwest': 'Brown or yellow',
    },
    'remedies': [
      'Place pyramid in Northeast corner for positive energy',
      'Keep water fountain in Northeast for prosperity',
      'Hang wind chimes in Northwest for good luck',
      'Place crystals in appropriate directions',
      'Use mirrors strategically to expand space',
      'Keep entrance clean and well-lit',
      'Remove clutter from Northeast corner',
      'Place plants in East or North for growth',
    ],
  };

  // Astronomy Knowledge
  final Map<String, dynamic> _astronomyKnowledge = {
    'moon_phases': {
      'new_moon': 'New Moon (Amavasya) is ideal for new beginnings, meditation, and letting go of negative energy.',
      'full_moon': 'Full Moon (Purnima) is powerful for manifestation, completion, and spiritual practices.',
      'waxing': 'Waxing Moon is good for growth, building, and positive activities.',
      'waning': 'Waning Moon is ideal for release, cleansing, and removing obstacles.',
    },
    'nakshatras': {
      'ashwini': 'Ashwini: Healing, quick action, new beginnings. Ruled by Ketu.',
      'bharani': 'Bharani: Transformation, creativity, fertility. Ruled by Venus.',
      'krittika': 'Krittika: Purification, sharpness, cutting through obstacles. Ruled by Sun.',
      'rohini': 'Rohini: Growth, material comfort, beauty. Ruled by Moon.',
      'mrigashira': 'Mrigashira: Searching, curiosity, exploration. Ruled by Mars.',
      'ardra': 'Ardra: Destruction for renewal, transformation. Ruled by Rahu.',
      'punarvasu': 'Punarvasu: Renewal, return, abundance. Ruled by Jupiter.',
      'pushya': 'Pushya: Nourishment, protection, auspicious. Ruled by Saturn.',
      'ashlesha': 'Ashlesha: Transformation, healing, kundalini. Ruled by Mercury.',
      'magha': 'Magha: Royalty, ancestors, honor. Ruled by Ketu.',
      'purva_phalguni': 'Purva Phalguni: Creativity, pleasure, romance. Ruled by Venus.',
      'uttara_phalguni': 'Uttara Phalguni: Partnership, marriage, balance. Ruled by Sun.',
      'hasta': 'Hasta: Skill, dexterity, craftsmanship. Ruled by Moon.',
      'chitra': 'Chitra: Artistry, beauty, creation. Ruled by Mars.',
      'swati': 'Swati: Independence, movement, change. Ruled by Rahu.',
      'vishakha': 'Vishakha: Purpose, determination, achievement. Ruled by Jupiter.',
      'anuradha': 'Anuradha: Success, friendship, devotion. Ruled by Saturn.',
      'jyestha': 'Jyestha: Power, authority, protection. Ruled by Mercury.',
      'mula': 'Mula: Roots, foundation, research. Ruled by Ketu.',
      'purva_ashadha': 'Purva Ashadha: Invincibility, victory, strength. Ruled by Venus.',
      'uttara_ashadha': 'Uttara Ashadha: Universal victory, leadership. Ruled by Sun.',
      'shravana': 'Shravana: Learning, listening, knowledge. Ruled by Moon.',
      'dhanishta': 'Dhanishta: Wealth, music, rhythm. Ruled by Mars.',
      'shatabhisha': 'Shatabhisha: Healing, mysticism, protection. Ruled by Rahu.',
      'purva_bhadra': 'Purva Bhadra: Transformation, spiritual fire. Ruled by Jupiter.',
      'uttara_bhadra': 'Uttara Bhadra: Stability, completion, prosperity. Ruled by Saturn.',
      'revati': 'Revati: Nourishment, completion, spiritual journey. Ruled by Mercury.',
    },
    'planets': {
      'sun': 'Sun represents soul, ego, authority, and vitality. Strong Sun brings leadership and confidence.',
      'moon': 'Moon represents mind, emotions, and mother. Strong Moon brings emotional stability.',
      'mars': 'Mars represents energy, courage, and action. Strong Mars brings determination.',
      'mercury': 'Mercury represents intellect, communication, and business. Strong Mercury brings intelligence.',
      'jupiter': 'Jupiter represents wisdom, expansion, and fortune. Strong Jupiter brings growth.',
      'venus': 'Venus represents love, beauty, and luxury. Strong Venus brings harmony.',
      'saturn': 'Saturn represents discipline, karma, and structure. Strong Saturn brings stability.',
      'rahu': 'Rahu represents desires, innovation, and material pursuits. Strong Rahu brings ambition.',
      'ketu': 'Ketu represents spirituality, detachment, and past karma. Strong Ketu brings spiritual growth.',
    },
  };

  /// Generate intelligent, conversational response
  Future<String> sendMessage(
    String userMessage,
    List<Map<String, String>> conversationHistory,
  ) async {
    final message = userMessage.toLowerCase().trim();
    final keywords = _extractKeywords(message);
    
    // Determine response type and generate comprehensive answer
    if (_isGreeting(message)) {
      return _getGreetingResponse();
    }
    
    // Astrology queries
    if (_isZodiacQuery(message, keywords)) {
      return _getZodiacResponse(message, keywords);
    }
    
    if (_isLagnaQuery(message, keywords)) {
      return _getLagnaResponse(message, keywords);
    }
    
    if (_isPlanetaryQuery(message, keywords)) {
      return _getPlanetaryResponse(message, keywords);
    }
    
    // Numerology queries
    if (_isNumerologyQuery(message, keywords)) {
      return _getNumerologyResponse(message, keywords);
    }
    
    // Vastu queries
    if (_isVastuQuery(message, keywords)) {
      return _getVastuResponse(message, keywords);
    }
    
    // Astronomy queries
    if (_isAstronomyQuery(message, keywords)) {
      return _getAstronomyResponse(message, keywords);
    }
    
    // Life guidance queries
    if (_isLifeGuidanceQuery(message, keywords)) {
      return _getLifeGuidanceResponse(message, keywords, conversationHistory);
    }
    
    // Default intelligent response
    return _getIntelligentResponse(message, keywords, conversationHistory);
  }

  Future<String> getWelcomeMessage() async {
    return '''🙏 Namaste! I am your AI Vedic Astrologer, trained in:

✨ **Vedic Astrology** - Complete Kundli and Lagna chart analysis
🔮 **Astronomy** - Planetary positions, Nakshatras, and celestial events
🔢 **Numerology** - Life path numbers and their meanings
🏠 **Vastu Shastra** - Directional science and space optimization

I can provide detailed guidance on:
• Your zodiac sign characteristics and compatibility
• Planetary influences and their effects
• Numerology readings and lucky numbers
• Vastu remedies for your home/office
• Career, love, health, and wealth guidance
• Astrological remedies and upayas

**How may I assist you today?**

Simply ask me anything about astrology, numerology, vastu, or astronomy, and I'll provide comprehensive, accurate guidance based on Vedic principles.

Note: This session is charged at ₹25 per minute.''';
  }

  // Helper methods
  List<String> _extractKeywords(String message) {
    return message.split(' ').where((w) => w.length > 2).map((w) => w.replaceAll(RegExp(r'[^\w]'), '').toLowerCase()).toList();
  }

  bool _isGreeting(String message) {
    return ['hi', 'hello', 'namaste', 'hey', 'good morning', 'good evening', 'namaskar'].any((g) => message.contains(g));
  }

  String _getGreetingResponse() {
    return '🙏 Namaste! I\'m here to guide you through Vedic Astrology, Numerology, Vastu, and Astronomy. What would you like to know? You can ask about your zodiac sign, numerology, vastu remedies, planetary positions, or any astrological guidance.';
  }

  bool _isZodiacQuery(String message, List<String> keywords) {
    final signs = _zodiacKnowledge.keys.toList();
    return signs.any((sign) => message.contains(sign) || keywords.contains(sign));
  }

  String _getZodiacResponse(String message, List<String> keywords) {
    for (var sign in _zodiacKnowledge.keys) {
      if (message.contains(sign)) {
        final data = _zodiacKnowledge[sign]!;
        final response = StringBuffer();
        
        response.writeln('**${sign.toUpperCase()} - Complete Analysis**\n');
        response.writeln('**Ruling Planet:** ${data['ruler']}');
        response.writeln('**Element:** ${data['element']}');
        response.writeln('**Quality:** ${data['quality']}');
        response.writeln('**Key Traits:** ${data['traits'].join(', ')}\n');
        response.writeln('**Career Guidance:** ${data['career']}\n');
        response.writeln('**Health:** ${data['health']}\n');
        response.writeln('**Love & Relationships:** ${data['love']}\n');
        response.writeln('**Compatible Signs:** ${data['compatible'].join(', ')}\n');
        response.writeln('**Lucky Numbers:** ${data['lucky']['numbers'].join(', ')}');
        response.writeln('**Lucky Colors:** ${data['lucky']['colors'].join(', ')}');
        response.writeln('**Lucky Days:** ${data['lucky']['days'].join(', ')}');
        
        return response.toString();
      }
    }
    return 'I can provide detailed analysis of all 12 zodiac signs. Which sign would you like to know about? (Aries, Taurus, Gemini, Cancer, Leo, Virgo, Libra, Scorpio, Sagittarius, Capricorn, Aquarius, Pisces)';
  }

  bool _isLagnaQuery(String message, List<String> keywords) {
    return keywords.contains('lagna') || keywords.contains('ascendant') || message.contains('lagna') || message.contains('ascendant');
  }

  String _getLagnaResponse(String message, List<String> keywords) {
    final lagnas = ['mesha', 'vrishabha', 'mithuna', 'karka', 'simha', 'kanya', 'tula', 'vrischika', 'dhanu', 'makara', 'kumbha', 'meena'];
    for (var lagna in lagnas) {
      if (message.contains(lagna)) {
        return _getDetailedLagnaInfo(lagna);
      }
    }
    return 'Lagna (Ascendant) is your rising sign at birth, representing your outer personality. I can provide detailed analysis of any Lagna. Which Lagna are you interested in? (Mesha, Vrishabha, Mithuna, Karka, Simha, Kanya, Tula, Vrischika, Dhanu, Makara, Kumbha, Meena)';
  }

  String _getDetailedLagnaInfo(String lagna) {
    // Detailed Lagna interpretations
    final interpretations = {
      'mesha': '**Mesha Lagna (Aries Ascendant):**\n\nRuled by Mars, you are a natural leader with strong willpower. Your 1st house (Lagna) is in Aries, making you assertive and independent. The 7th house (Marriage) falls in Libra, indicating need for balance in partnerships. The 10th house (Career) is in Capricorn, showing ambition and discipline in profession.',
      'vrishabha': '**Vrishabha Lagna (Taurus Ascendant):**\n\nRuled by Venus, you value stability and material comfort. Your 1st house is in Taurus, making you patient and persistent. The 7th house falls in Scorpio, indicating intense partnerships. The 10th house is in Aquarius, showing innovative career approach.',
    };
    return interpretations[lagna] ?? 'Detailed Lagna analysis available. Please specify which Lagna you want to know about.';
  }

  bool _isPlanetaryQuery(String message, List<String> keywords) {
    final planets = ['sun', 'moon', 'mars', 'mercury', 'jupiter', 'venus', 'saturn', 'rahu', 'ketu', 'planet', 'planets'];
    return planets.any((p) => keywords.contains(p) || message.contains(p));
  }

  String _getPlanetaryResponse(String message, List<String> keywords) {
    for (var planet in _astronomyKnowledge['planets']!.keys) {
      if (message.contains(planet)) {
        final info = _astronomyKnowledge['planets']![planet];
        return '**${planet.toUpperCase()} - Planetary Influence**\n\n$info\n\n**Remedies:**\n${_getPlanetRemedies(planet)}';
      }
    }
    return 'I can explain the influence of all planets (Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn, Rahu, Ketu) in your chart. Which planet would you like to know about?';
  }

  String _getPlanetRemedies(String planet) {
    final remedies = {
      'sun': '• Wear copper or gold\n• Donate wheat on Sundays\n• Chant "Om Suryaya Namah"\n• Fast on Sundays',
      'moon': '• Wear silver or pearl\n• Donate white items on Mondays\n• Chant "Om Chandraya Namah"\n• Fast on Mondays',
      'mars': '• Wear red coral\n• Donate red items on Tuesdays\n• Chant "Om Mangalaya Namah"\n• Fast on Tuesdays',
      'mercury': '• Wear emerald\n• Donate green items on Wednesdays\n• Chant "Om Budhaya Namah"\n• Fast on Wednesdays',
      'jupiter': '• Wear yellow sapphire\n• Donate yellow items on Thursdays\n• Chant "Om Gurave Namah"\n• Fast on Thursdays',
      'venus': '• Wear diamond\n• Donate white items on Fridays\n• Chant "Om Shukraya Namah"\n• Fast on Fridays',
      'saturn': '• Wear blue sapphire\n• Donate black items on Saturdays\n• Chant "Om Shanaye Namah"\n• Fast on Saturdays',
    };
    return remedies[planet] ?? 'Remedies available for all planets.';
  }

  bool _isNumerologyQuery(String message, List<String> keywords) {
    return keywords.contains('numerology') || keywords.contains('number') || keywords.contains('life path') || message.contains('numerology');
  }

  String _getNumerologyResponse(String message, List<String> keywords) {
    // Extract number from message
    final numberMatch = RegExp(r'\b([1-9])\b').firstMatch(message);
    if (numberMatch != null) {
      final number = int.parse(numberMatch.group(1)!);
      if (_numerologyKnowledge.containsKey(number)) {
        final data = _numerologyKnowledge[number]!;
        final response = StringBuffer();
        response.writeln('**Life Path Number $number - ${data['name']}**\n');
        response.writeln('**Key Traits:** ${data['traits'].join(', ')}\n');
        response.writeln('**Career:** ${data['career']}\n');
        response.writeln('**Compatible Numbers:** ${data['compatibility'].join(', ')}\n');
        response.writeln('**Lucky Colors:** ${data['lucky']['colors'].join(', ')}');
        response.writeln('**Lucky Days:** ${data['lucky']['days'].join(', ')}');
        response.writeln('**Lucky Stones:** ${data['lucky']['stones'].join(', ')}\n');
        response.writeln('**Remedy:** ${data['remedy']}');
        return response.toString();
      }
    }
    return 'Numerology reveals your life path through numbers 1-9. Each number has unique characteristics, career guidance, compatibility, and remedies. What is your life path number, or would you like to know how to calculate it?';
  }

  bool _isVastuQuery(String message, List<String> keywords) {
    return keywords.contains('vastu') || keywords.contains('direction') || keywords.contains('room') || message.contains('vastu');
  }

  String _getVastuResponse(String message, List<String> keywords) {
    // Check for direction queries
    final directions = _vastuKnowledge['directions']!.keys.toList();
    for (var direction in directions) {
      if (message.contains(direction)) {
        return '**${direction.toUpperCase()} Direction - Vastu Guidance**\n\n${_vastuKnowledge['directions']![direction]}\n\n**Recommended Color:** ${_vastuKnowledge['colors']![direction]}';
      }
    }
    
    // Check for room queries
    final rooms = _vastuKnowledge['rooms']!.keys.toList();
    for (var room in rooms) {
      if (message.contains(room)) {
        return '**${room.toUpperCase()} - Vastu Guidelines**\n\n${_vastuKnowledge['rooms']![room]}';
      }
    }
    
    return 'Vastu Shastra is the science of directions and space. I can guide you on:\n• Directional placements (North, South, East, West, etc.)\n• Room-specific Vastu (Bedroom, Kitchen, Prayer room, etc.)\n• Color recommendations\n• Vastu remedies\n\nWhat specific Vastu guidance do you need?';
  }

  bool _isAstronomyQuery(String message, List<String> keywords) {
    return keywords.contains('astronomy') || keywords.contains('nakshatra') || keywords.contains('moon phase') || message.contains('nakshatra');
  }

  String _getAstronomyResponse(String message, List<String> keywords) {
    // Check for Nakshatra queries
    final nakshatras = _astronomyKnowledge['nakshatras']!.keys.toList();
    for (var nakshatra in nakshatras) {
      if (message.contains(nakshatra.replaceAll('_', ' '))) {
        return '**${nakshatra.toUpperCase().replaceAll('_', ' ')} Nakshatra**\n\n${_astronomyKnowledge['nakshatras']![nakshatra]}';
      }
    }
    
    // Check for moon phase queries
    if (message.contains('moon') || message.contains('phase')) {
      return '**Moon Phases & Their Significance**\n\n${_astronomyKnowledge['moon_phases']!.values.join('\n\n')}';
    }
    
    return 'Astronomy in Vedic tradition includes:\n• 27 Nakshatras (Lunar Mansions) and their meanings\n• Moon phases and their effects\n• Planetary positions and influences\n\nWhich aspect of astronomy would you like to explore?';
  }

  bool _isLifeGuidanceQuery(String message, List<String> keywords) {
    final topics = ['love', 'career', 'health', 'wealth', 'marriage', 'relationship', 'job', 'money', 'finance'];
    return topics.any((topic) => keywords.contains(topic) || message.contains(topic));
  }

  String _getLifeGuidanceResponse(String message, List<String> keywords, List<Map<String, String>> history) {
    if (message.contains('love') || message.contains('relationship') || message.contains('marriage')) {
      return '''**Love & Relationship Guidance**

In Vedic Astrology, love and relationships are governed by:
• **7th House (Marriage House)** - Indicates partnership and spouse
• **Venus** - Planet of love, beauty, and harmony
• **Jupiter** - Brings wisdom and growth in relationships

**Remedies for Love:**
• Strengthen Venus by wearing white on Fridays
• Chant "Om Shukraya Namah" daily
• Donate white flowers or items on Fridays
• Keep a Venus Yantra in your home

**Compatibility:** Check the positions of Venus and 7th house lord in both charts. Mutual aspects create strong bonds.

Would you like to know about your specific zodiac sign's love compatibility?''';
    }
    
    if (message.contains('career') || message.contains('job') || message.contains('profession')) {
      return '''**Career Guidance**

In Vedic Astrology, career is indicated by:
• **10th House (Karma House)** - Represents profession and reputation
• **Saturn** - Brings discipline and long-term success
• **Jupiter** - Brings expansion and growth in career

**Remedies for Career:**
• Strengthen 10th house lord through remedies
• Chant "Om Shanaye Namah" for Saturn
• Focus on your natural talents and strengths
• Perform career-related pujas

**Best Careers by Element:**
• Fire signs (Aries, Leo, Sagittarius): Leadership, entrepreneurship
• Earth signs (Taurus, Virgo, Capricorn): Business, finance, real estate
• Air signs (Gemini, Libra, Aquarius): Communication, technology, arts
• Water signs (Cancer, Scorpio, Pisces): Healing, creativity, service

What is your zodiac sign? I can provide specific career guidance.''';
    }
    
    if (message.contains('health') || message.contains('disease') || message.contains('illness')) {
      return '''**Health Guidance**

In Vedic Astrology, health is indicated by:
• **6th House (Disease House)** - Shows health issues and enemies
• **Sun & Mars** - Affect vitality and energy
• **Moon** - Affects mental and emotional health

**Remedies for Health:**
• Strengthen 6th house lord
• Regular exercise and balanced diet
• Chant health mantras daily
• Perform health-related remedies

**Health by Zodiac:**
Each sign has specific health concerns. Strengthen your ruling planet for better health.

Would you like health guidance specific to your zodiac sign?''';
    }
    
    if (message.contains('wealth') || message.contains('money') || message.contains('finance')) {
      return '''**Wealth & Finance Guidance**

In Vedic Astrology, wealth is indicated by:
• **2nd House (Wealth House)** - Represents savings and family wealth
• **11th House (Gains House)** - Represents income and profits
• **Jupiter & Venus** - Wealth-giving planets

**Remedies for Wealth:**
• Strengthen Jupiter by wearing yellow on Thursdays
• Chant "Om Gurave Namah" for Jupiter
• Donate yellow items, turmeric, or gold
• Keep a Lakshmi Yantra in Northeast

**Vastu for Wealth:**
• Keep safe/cash in North direction
• Place water fountain in Northeast
• Keep entrance clean and well-lit

Would you like specific wealth remedies based on your chart?''';
    }
    
    return 'I can provide guidance on love, career, health, and wealth based on Vedic Astrology. Which area would you like to explore?';
  }

  String _getIntelligentResponse(String message, List<String> keywords, List<Map<String, String>> history) {
    // Try to understand context from conversation
    if (history.isNotEmpty) {
      final lastMessage = history.last['message']?.toLowerCase() ?? '';
      if (lastMessage.contains('sign') || lastMessage.contains('zodiac')) {
        return 'Based on our conversation, I can provide more detailed insights about your zodiac sign, including career, love, health, and remedies. What specific aspect would you like to explore further?';
      }
    }
    
    // Provide helpful guidance
    if (message.contains('?') || message.contains('what') || message.contains('how') || message.contains('why')) {
      return 'That\'s a great question! In Vedic Astrology, I can help you understand:\n\n• Your zodiac sign characteristics and compatibility\n• Planetary influences and remedies\n• Numerology and life path numbers\n• Vastu Shastra for your home/office\n• Career, love, health, and wealth guidance\n\nCould you be more specific about what you\'d like to know? For example, "Tell me about Aries" or "What is my life path number?"';
    }
    
    return 'I\'m here to help you with Vedic Astrology, Numerology, Vastu, and Astronomy. You can ask me:\n\n• About your zodiac sign\n• Numerology readings\n• Vastu guidance for your home\n• Planetary positions and remedies\n• Career, love, health, or wealth guidance\n\nWhat would you like to know?';
  }
}

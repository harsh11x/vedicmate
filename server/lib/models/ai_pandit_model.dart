class AIPanditModel {
  final String id;
  final String name;
  final String profileImage;
  final List<String> specializations;
  final int experienceYears;
  final double rating;
  final int totalConsultations;
  final List<String> languages;
  final String gender; // male or female
  final String? bio;
  final bool isAvailable;

  AIPanditModel({
    required this.id,
    required this.name,
    required this.profileImage,
    required this.specializations,
    required this.experienceYears,
    required this.rating,
    required this.totalConsultations,
    required this.languages,
    required this.gender,
    this.bio,
    this.isAvailable = true,
  });

  factory AIPanditModel.fromJson(Map<String, dynamic> json) {
    return AIPanditModel(
      id: json['id'] as String,
      name: json['name'] as String,
      profileImage: json['profile_image'] as String,
      specializations: List<String>.from(json['specializations'] as List),
      experienceYears: json['experience_years'] as int,
      rating: (json['rating'] as num).toDouble(),
      totalConsultations: json['total_consultations'] as int,
      languages: List<String>.from(json['languages'] as List),
      gender: json['gender'] as String,
      bio: json['bio'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile_image': profileImage,
      'specializations': specializations,
      'experience_years': experienceYears,
      'rating': rating,
      'total_consultations': totalConsultations,
      'languages': languages,
      'gender': gender,
      'bio': bio,
      'is_available': isAvailable,
    };
  }
}

// Pre-defined AI Pandits with authentic Indian names and profiles
class AIPandits {
  static final List<AIPanditModel> allPandits = _generatePandits();

  static List<AIPanditModel> _generatePandits() {
    return [
      ..._generateDomainPandits('Lal Kitab', 20, 1),
      ..._generateDomainPandits('Vedic Astrology', 20, 21),
      ..._generateDomainPandits('Palmistry', 20, 41),
      ..._generateDomainPandits('Vastu Shastra', 20, 61),
      ..._generateDomainPandits('Numerology', 20, 81),
    ];
  }

  static List<AIPanditModel> _generateDomainPandits(String domain, int count, int startId) {
    final List<AIPanditModel> pandits = [];
    final names = _getNamesForDomain(domain);
    
    for (int i = 0; i < count; i++) {
        final gender = i % 2 == 0 ? 'male' : 'female';
        final name = (i < names.length) ? names[i] : 'Pandit ${domain.split(' ')[0]} ${i+1}';
        final id = 'ai_pandit_${startId + i}';
        
        pandits.add(AIPanditModel(
          id: id,
          name: name,
          profileImage: 'https://ui-avatars.com/api/?name=${name.replaceAll(' ', '+')}&background=${_getColorForDomain(domain)}&color=fff&size=200',
          specializations: [domain, _getSecondarySpec(domain, i), 'Counseling'],
          experienceYears: 10 + (i % 25),
          rating: 4.5 + ((i % 5) / 10),
          totalConsultations: 1000 + (i * 150),
          languages: ['Hindi', 'English', _getRegionalLang(i)],
          gender: gender,
          bio: _generateBio(name, domain, 10 + (i % 25)),
          isAvailable: i % 5 != 0, // 80% available
        ));
    }
    return pandits;
  }

  static String _getSecondarySpec(String domain, int index) {
     final specs = {
       'Lal Kitab': ['Remedies', 'Past Life', 'Karma', 'Totke'],
       'Vedic Astrology': ['Kundli', 'Marriage', 'Career', 'Health'],
       'Palmistry': ['Face Reading', 'Thumb Analysis', 'Life Line', 'Fate Line'],
       'Vastu Shastra': ['Home Vastu', 'Office Vastu', 'Energy Flow', 'Feng Shui'],
       'Numerology': ['Name Correction', 'Mobile Numerology', 'Marriage Date', 'Signature Analysis']
     };
     return specs[domain]![index % 4];
  }

  static String _getRegionalLang(int index) {
    final langs = ['Sanskrit', 'Marathi', 'Tamil', 'Telugu', 'Bengali', 'Gujarati', 'Punjabi', 'Kannada'];
    return langs[index % langs.length];
  }

  static String _getColorForDomain(String domain) {
    switch (domain) {
      case 'Lal Kitab': return 'E17055'; // Red/Orange
      case 'Vedic Astrology': return '6C5CE7'; // Purple
      case 'Palmistry': return '00B894'; // Teal
      case 'Vastu Shastra': return 'FDCB6E'; // Gold
      case 'Numerology': return '0984E3'; // Blue
      default: return '2D3436';
    }
  }

  static String _generateBio(String name, String domain, int exp) {
    return '$name is a distinguished expert in $domain with over $exp years of experience. Known for precise predictions and effective remedies, guiding tailored solutions for modern life challenges.';
  }

  static List<String> _getNamesForDomain(String domain) {
    switch (domain) {
        case 'Lal Kitab': return [
            'Pandit Roop Chand', 'Acharya Ram Lal', 'Guru Bhrigu Nath', 'Pt. Sohan Veer', 'Shastri Om Prakash',
            'Mata Kali Devi', 'Sadhvi Rekha', 'Jyotishi Ananya', 'Devi Sunita', 'Guru Maa Lata',
            'Pt. Kishan Lal', 'Acharya Vinod', 'Swami Satyanand', 'Guru Rajeev', 'Pt. Mohan Das',
            'Sadhvi Geeta', 'Mata Vaishnavi', 'Jyotishi Meena', 'Devi Priya', 'Guru Maa Shanti'
        ];
        case 'Vedic Astrology': return [
            'Acharya Bhaskar', 'Pt. Harish Chandra', 'Swami Vivekananda', 'Guru Brihaspati', 'Shastri Vishnu',
            'Sadhvi Saraswati', 'Mata Parvati', 'Jyotishi Lakshmi', 'Devi Gauri', 'Guru Maa Durga',
            'Pt. Maheshwar', 'Acharya Ganesh', 'Swami Shivanand', 'Guru Adityanath', 'Shastri Narad',
            'Sadhvi Sita', 'Mata Radha', 'Jyotishi Rukmini', 'Devi Savitri', 'Guru Maa Gayatri'
        ];
        case 'Palmistry': return [
            'Pt. Hastiraja', 'Acharya Karandeep', 'Guru Hastamalak', 'Shastri Pant', 'Swami Angira',
            'Devi Rekha', 'Mata Hasini', 'Jyotishi Palmer', 'Sadhvi Hasta', 'Guru Maa Kara',
            'Pt. Shekhar', 'Acharya Pramod', 'Guru Sanjay', 'Shastri Amit', 'Swami Darpan',
            'Devi Nirmala', 'Mata Suman', 'Jyotishi Kavita', 'Sadhvi Poonam', 'Guru Maa Ritu'
        ];
        case 'Vastu Shastra': return [
            'Acharya Vishwakarma', 'Pt. Bhoomi Nath', 'Guru Vastupati', 'Shastri Sthapatya', 'Swami Disha',
            'Mata Vasundhara', 'Sadhvi Ghara', 'Jyotishi Bhavana', 'Devi Griha', 'Guru Maa Shilpa',
            'Pt. Nirman', 'Acharya Rachana', 'Guru Sthir', 'Shastri Kon', 'Swami Ishan',
            'Devi Bhumi', 'Mata Dhara', 'Jyotishi Avani', 'Sadhvi Prithvi', 'Guru Maa Vasu'
        ];
        case 'Numerology': return [
            'Pt. Ankush', 'Acharya Ganit', 'Guru Sankhya', 'Shastri Anki', 'Swami Ekam',
            'Devi Sankhya', 'Mata Anka', 'Jyotishi Ganita', 'Sadhvi Rashmi', 'Guru Maa Tara',
            'Pt. Count', 'Acharya Number', 'Guru Digit', 'Shastri Sum', 'Swami Total',
            'Devi Infinite', 'Mata Zero', 'Jyotishi Plus', 'Sadhvi Minus', 'Guru Maa Div'
        ];
        default: return [];
    }
  }

  // Get all pandits
  static List<AIPanditModel> getAllPandits() => allPandits;

  // Get top rated pandits
  static List<AIPanditModel> getTopRated({int limit = 5}) {
    final sorted = List<AIPanditModel>.from(allPandits)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(limit).toList();
  }

  // Get pandits by specialization
  static List<AIPanditModel> getBySpecialization(String specialization) {
    return allPandits.where((pandit) => 
      pandit.specializations.any((s) => 
        s.toLowerCase().contains(specialization.toLowerCase())
      )
    ).toList();
  }

  // Get male pandits
  static List<AIPanditModel> getMalePandits() {
    return allPandits.where((p) => p.gender == 'male').toList();
  }

  // Get female pandits
  static List<AIPanditModel> getFemalePandits() {
    return allPandits.where((p) => p.gender == 'female').toList();
  }

  // Search pandits by name or specialization
  static List<AIPanditModel> search(String query) {
    final lowerQuery = query.toLowerCase();
    return allPandits.where((pandit) => 
      pandit.name.toLowerCase().contains(lowerQuery) ||
      pandit.specializations.any((s) => s.toLowerCase().contains(lowerQuery)) ||
      pandit.bio!.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  // Get pandit by ID
  static AIPanditModel? getById(String id) {
    try {
      return allPandits.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}


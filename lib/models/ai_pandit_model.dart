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
  static final List<AIPanditModel> allPandits = [
    // Male AI Pandits
    AIPanditModel(
      id: 'ai_pandit_1',
      name: 'Pandit Rajesh Shastri',
      profileImage: 'assets/images/ai_pandits/pandit_rajesh.png',
      specializations: ['Vedic Astrology', 'Kundli Analysis', 'Marriage Matching'],
      experienceYears: 25,
      rating: 4.9,
      totalConsultations: 15000,
      languages: ['Hindi', 'English', 'Sanskrit'],
      gender: 'male',
      bio: 'A renowned Vedic astrologer with 25 years of experience. Specialized in Kundli analysis, marriage matching, and life predictions. Guided thousands towards prosperity and happiness.',
      isAvailable: true,
    ),
    AIPanditModel(
      id: 'ai_pandit_2',
      name: 'Acharya Suresh Joshi',
      profileImage: 'assets/images/ai_pandits/acharya_suresh.png',
      specializations: ['Numerology', 'Vastu Shastra', 'Gemstone Consultation'],
      experienceYears: 20,
      rating: 4.8,
      totalConsultations: 12000,
      languages: ['Hindi', 'English', 'Gujarati', 'Marathi'],
      gender: 'male',
      bio: 'Expert numerologist and Vastu consultant. Known for accurate predictions and practical remedies. Helps clients achieve balance in life through ancient wisdom.',
      isAvailable: true,
    ),
    AIPanditModel(
      id: 'ai_pandit_3',
      name: 'Pandit Vijay Sharma',
      profileImage: 'assets/images/ai_pandits/pandit_vijay.png',
      specializations: ['Palmistry', 'Career Guidance', 'Health Astrology'],
      experienceYears: 18,
      rating: 4.7,
      totalConsultations: 10000,
      languages: ['Hindi', 'English', 'Punjabi'],
      gender: 'male',
      bio: 'Skilled palmist and career counselor. Combines traditional palmistry with modern career guidance. Helps individuals find their true calling.',
      isAvailable: true,
    ),
    AIPanditModel(
      id: 'ai_pandit_4',
      name: 'Guru Mahesh Pandey',
      profileImage: 'assets/images/ai_pandits/guru_mahesh.png',
      specializations: ['KP Astrology', 'Stock Market Predictions', 'Business Astrology'],
      experienceYears: 22,
      rating: 4.9,
      totalConsultations: 13500,
      languages: ['Hindi', 'English', 'Bengali'],
      gender: 'male',
      bio: 'KP astrology specialist with expertise in financial predictions. Helped numerous businessmen and investors with timely guidance.',
      isAvailable: true,
    ),
    AIPanditModel(
      id: 'ai_pandit_5',
      name: 'Jyotish Acharya Ramesh Tripathi',
      profileImage: 'assets/images/ai_pandits/jyotish_ramesh.png',
      specializations: ['Prashna Kundli', 'Muhurat', 'Spiritual Guidance'],
      experienceYears: 30,
      rating: 5.0,
      totalConsultations: 20000,
      languages: ['Hindi', 'English', 'Sanskrit', 'Tamil'],
      gender: 'male',
      bio: 'Senior Jyotish Acharya with 30 years of experience. Expert in Prashna Kundli and finding auspicious timings. A spiritual guide for thousands.',
      isAvailable: true,
    ),
    
    // Female AI Pandits
    AIPanditModel(
      id: 'ai_pandit_6',
      name: 'Sadhvi Priya Devi',
      profileImage: 'assets/images/ai_pandits/sadhvi_priya.png',
      specializations: ['Vedic Astrology', 'Love & Relationships', 'Women Wellness'],
      experienceYears: 15,
      rating: 4.9,
      totalConsultations: 9000,
      languages: ['Hindi', 'English', 'Tamil', 'Telugu'],
      gender: 'female',
      bio: 'Compassionate astrologer specializing in relationship counseling and women\'s wellness. Known for her empathetic approach and accurate predictions.',
      isAvailable: true,
    ),
    AIPanditModel(
      id: 'ai_pandit_7',
      name: 'Jyotishi Meera Kulkarni',
      profileImage: 'assets/images/ai_pandits/jyotishi_meera.png',
      specializations: ['Numerology', 'Name Correction', 'Child Astrology'],
      experienceYears: 12,
      rating: 4.8,
      totalConsultations: 7500,
      languages: ['Hindi', 'English', 'Marathi', 'Kannada'],
      gender: 'female',
      bio: 'Renowned numerologist helping parents choose auspicious names for children. Expert in name corrections and life path analysis.',
      isAvailable: true,
    ),
    AIPanditModel(
      id: 'ai_pandit_8',
      name: 'Panditayin Kavita Iyer',
      profileImage: 'assets/images/ai_pandits/panditayin_kavita.png',
      specializations: ['Vastu Shastra', 'Home Harmony', 'Feng Shui'],
      experienceYears: 16,
      rating: 4.9,
      totalConsultations: 8500,
      languages: ['Hindi', 'English', 'Tamil', 'Malayalam'],
      gender: 'female',
      bio: 'Vastu expert creating harmonious living spaces. Blends traditional Vastu with modern architecture for optimal energy flow.',
      isAvailable: true,
    ),
    AIPanditModel(
      id: 'ai_pandit_9',
      name: 'Acharya Anjali Mishra',
      profileImage: 'assets/images/ai_pandits/acharya_anjali.png',
      specializations: ['Tarot Reading', 'Spiritual Healing', 'Meditation Guidance'],
      experienceYears: 10,
      rating: 4.7,
      totalConsultations: 6000,
      languages: ['Hindi', 'English', 'Bengali'],
      gender: 'female',
      bio: 'Intuitive tarot reader and spiritual healer. Combines tarot wisdom with Vedic knowledge to provide holistic guidance.',
      isAvailable: true,
    ),
    AIPanditModel(
      id: 'ai_pandit_10',
      name: 'Dr. Sunita Acharya',
      profileImage: 'assets/images/ai_pandits/dr_sunita.png',
      specializations: ['Medical Astrology', 'Health Predictions', 'Ayurveda Astrology'],
      experienceYears: 20,
      rating: 4.9,
      totalConsultations: 11000,
      languages: ['Hindi', 'English', 'Gujarati', 'Sanskrit'],
      gender: 'female',
      bio: 'PhD in Jyotish with specialization in medical astrology. Combines Ayurvedic knowledge with astrological insights for health guidance.',
      isAvailable: true,
    ),
    AIPanditModel(
      id: 'ai_pandit_11',
      name: 'Jyotish Guru Lakshmi Menon',
      profileImage: 'https://ui-avatars.com/api/?name=Lakshmi+Menon&background=10AC84&color=fff&size=200',
      specializations: ['Nadi Astrology', 'Past Life Analysis', 'Karma Reading'],
      experienceYears: 18,
      rating: 5.0,
      totalConsultations: 9500,
      languages: ['Hindi', 'English', 'Malayalam', 'Tamil'],
      gender: 'female',
      bio: 'Nadi astrology specialist with deep knowledge of past life karma. Helps seekers understand their karmic journey and life purpose.',
      isAvailable: true,
    ),
    AIPanditModel(
      id: 'ai_pandit_12',
      name: 'Mata Radha Verma',
      profileImage: 'https://ui-avatars.com/api/?name=Radha+Verma&background=EE5A6F&color=fff&size=200',
      specializations: ['Spiritual Counseling', 'Bhakti Yoga', 'Mantra Diksha'],
      experienceYears: 25,
      rating: 4.9,
      totalConsultations: 14000,
      languages: ['Hindi', 'English', 'Sanskrit', 'Punjabi'],
      gender: 'female',
      bio: 'Spiritual guide and devotional teacher. Initiated thousands in mantra sadhana and bhakti practices. Known for her divine presence.',
      isAvailable: true,
    ),
    
    // Additional Male AI Pandits (13-21)
    AIPanditModel(
      id: 'ai_pandit_13',
      name: 'Swami Anand Bharti',
      profileImage: 'https://ui-avatars.com/api/?name=Anand+Bharti&background=FF7979&color=fff&size=200',
      specializations: ['Kundalini Awakening', 'Chakra Healing', 'Meditation'],
      experienceYears: 28,
      rating: 5.0,
      totalConsultations: 18000,
      languages: ['Hindi', 'English', 'Sanskrit'],
      gender: 'male',
      bio: 'Renowned Swami specializing in kundalini awakening and chakra balancing. Trained in Himalayan traditions. Guides seekers toward spiritual enlightenment.',
      isAvailable: true,
    ),
    AIPanditModel(
      id: 'ai_pandit_14',
      name: 'Pandit Keshav Rao',
      profileImage: 'https://ui-avatars.com/api/?name=Keshav+Rao&background=6C5CE7&color=fff&size=200',
      specializations: ['Love Marriage', 'Relationship Problems', 'Family Disputes'],
      experienceYears: 16,
      rating: 4.8,
      totalConsultations: 11500,
      languages: ['Hindi', 'English', 'Telugu', 'Kannada'],
      gender: 'male',
      bio: 'Young dynamic astrologer from Hyderabad. Expert in solving love and relationship issues. Modern approach with traditional wisdom.',
      isAvailable: true,
    ),
    AIPanditModel(
      id: 'ai_pandit_15',
      name: 'Acharya Dinesh Bhatt',
      profileImage: 'https://ui-avatars.com/api/?name=Dinesh+Bhatt&background=00B894&color=fff&size=200',
      specializations: ['Lal Kitab', 'Palmistry', 'Face Reading'],
      experienceYears: 24,
      rating: 4.9,
      totalConsultations: 16000,
      languages: ['Hindi', 'English', 'Punjabi', 'Urdu'],
      gender: 'male',
      bio: 'Lal Kitab specialist from Delhi. Known for simple and effective remedies. Expert in palmistry and face reading.',
      isAvailable: true,
    ),
    AIPanditModel(
      id: 'ai_pandit_16',
      name: 'Jyotish Ravi Shankar',
      profileImage: 'https://ui-avatars.com/api/?name=Ravi+Shankar&background=FD79A8&color=fff&size=200',
      specializations: ['Horary Astrology', 'Match Making', 'Vedic Remedies'],
      experienceYears: 19,
      rating: 4.7,
      totalConsultations: 13000,
      languages: ['Hindi', 'English', 'Marathi'],
      gender: 'male',
      bio: 'Horary astrology expert from Pune. Answers specific questions with precision. Specializes in marriage compatibility.',
      isAvailable: true,
    ),
    AIPanditModel(
      id: 'ai_pandit_17',
      name: 'Pandit Ashok Kumar',
      profileImage: 'https://ui-avatars.com/api/?name=Ashok+Kumar&background=FDCB6E&color=000&size=200',
      specializations: ['Children Education', 'Career Planning', 'Job Predictions'],
      experienceYears: 21,
      rating: 4.8,
      totalConsultations: 14500,
      languages: ['Hindi', 'English', 'Bengali'],
      gender: 'male',
      bio: 'Education and career specialist from Kolkata. Helps students and professionals find right career path. Practical guidance.',
      isAvailable: true,
    ),
    AIPanditModel(
      id: 'ai_pandit_18',
      name: 'Guru Balachandra Upadhyay',
      profileImage: 'https://ui-avatars.com/api/?name=Balachandra+Upadhyay&background=74B9FF&color=fff&size=200',
      specializations: ['South Indian Astrology', 'Nadi Jyotish', 'Temple Astrology'],
      experienceYears: 32,
      rating: 5.0,
      totalConsultations: 22000,
      languages: ['Hindi', 'English', 'Tamil', 'Malayalam', 'Telugu'],
      gender: 'male',
      bio: 'Traditional South Indian astrologer from Tamil Nadu. Expert in Nadi Jyotish and temple astrology. Ancient palm leaf predictions.',
      isAvailable: true,
    ),
    AIPanditModel(
      id: 'ai_pandit_19',
      name: 'Pandit Gopal Das',
      profileImage: 'https://ui-avatars.com/api/?name=Gopal+Das&background=A29BFE&color=fff&size=200',
      specializations: ['Bhakti Path', 'Krishna Consciousness', 'Devotional Astrology'],
      experienceYears: 27,
      rating: 4.9,
      totalConsultations: 17500,
      languages: ['Hindi', 'English', 'Bengali', 'Sanskrit'],
      gender: 'male',
      bio: 'Devotee of Lord Krishna from Vrindavan. Combines astrology with bhakti philosophy. Spiritual solutions through devotion.',
      isAvailable: true,
    ),
    AIPanditModel(
      id: 'ai_pandit_20',
      name: 'Dr. Arjun Deshmukh',
      profileImage: 'https://ui-avatars.com/api/?name=Arjun+Deshmukh&background=55EFC4&color=000&size=200',
      specializations: ['Research Astrology', 'Statistical Predictions', 'Modern Techniques'],
      experienceYears: 14,
      rating: 4.7,
      totalConsultations: 9500,
      languages: ['Hindi', 'English', 'Marathi'],
      gender: 'male',
      bio: 'PhD in Jyotish with research-based approach. Combines statistics with astrology. Modern scientific perspective.',
      isAvailable: true,
    ),
    AIPanditModel(
      id: 'ai_pandit_21',
      name: 'Pandit Narayan Swamy',
      profileImage: 'https://ui-avatars.com/api/?name=Narayan+Swamy&background=FF6B6B&color=fff&size=200',
      specializations: ['Deity Worship', 'Puja Vidhi', 'Religious Rituals'],
      experienceYears: 35,
      rating: 5.0,
      totalConsultations: 25000,
      languages: ['Hindi', 'English', 'Kannada', 'Tamil', 'Sanskrit'],
      gender: 'male',
      bio: 'Temple priest and ritual expert from Karnataka. Guides on proper deity worship and puja procedures. Preserves ancient traditions.',
      isAvailable: true,
    ),
    
    // Additional Female AI Pandits (22-30)
    AIPanditModel(
      id: 'ai_pandit_22',
      name: 'Sadhvi Gayatri Devi',
      profileImage: 'https://ui-avatars.com/api/?name=Gayatri+Devi&background=FDA7DF&color=fff&size=200',
      specializations: ['Women Empowerment', 'Marriage Counseling', 'Family Harmony'],
      experienceYears: 17,
      rating: 4.9,
      totalConsultations: 12000,
      languages: ['Hindi', 'English', 'Punjabi'],
      gender: 'female',
      bio: 'Women empowerment advocate from Delhi. Specializes in marriage counseling and family issues. Empathetic and supportive.',
      isAvailable: true,
    ),
    AIPanditModel(
      id: 'ai_pandit_23',
      name: 'Jyotishi Parvati Sharma',
      profileImage: 'https://ui-avatars.com/api/?name=Parvati+Sharma&background=81ECEC&color=000&size=200',
      specializations: ['Pregnancy Astrology', 'Child Birth', 'Motherhood Guidance'],
      experienceYears: 13,
      rating: 4.8,
      totalConsultations: 8500,
      languages: ['Hindi', 'English', 'Gujarati'],
      gender: 'female',
      bio: 'Pregnancy and childbirth specialist from Ahmedabad. Guides expecting mothers. Expert in child astrology and naming.',
      isAvailable: true,
    ),
    AIPanditModel(
      id: 'ai_pandit_24',
      name: 'Dr. Shreya Patel',
      profileImage: 'https://ui-avatars.com/api/?name=Shreya+Patel&background=FFEAA7&color=000&size=200',
      specializations: ['Psychology Astrology', 'Mental Health', 'Emotional Healing'],
      experienceYears: 11,
      rating: 4.7,
      totalConsultations: 7000,
      languages: ['Hindi', 'English', 'Gujarati'],
      gender: 'female',
      bio: 'Psychologist and astrologer from Mumbai. Combines psychology with Jyotish. Helps with anxiety, depression, and stress.',
      isAvailable: true,
    ),
    AIPanditModel(
      id: 'ai_pandit_25',
      name: 'Mata Durga Bhawani',
      profileImage: 'https://ui-avatars.com/api/?name=Durga+Bhawani&background=FF7675&color=fff&size=200',
      specializations: ['Shakti Worship', 'Tantra Vidya', 'Goddess Worship'],
      experienceYears: 29,
      rating: 5.0,
      totalConsultations: 19000,
      languages: ['Hindi', 'English', 'Bengali', 'Sanskrit'],
      gender: 'female',
      bio: 'Shakti worshipper from West Bengal. Expert in tantric practices and goddess worship. Empowers through divine feminine energy.',
      isAvailable: true,
    ),
    AIPanditModel(
      id: 'ai_pandit_26',
      name: 'Panditayin Shalini Iyer',
      profileImage: 'https://ui-avatars.com/api/?name=Shalini+Iyer&background=74B9FF&color=fff&size=200',
      specializations: ['Vedic Chanting', 'Mantra Therapy', 'Sound Healing'],
      experienceYears: 15,
      rating: 4.8,
      totalConsultations: 10500,
      languages: ['Hindi', 'English', 'Tamil', 'Malayalam', 'Sanskrit'],
      gender: 'female',
      bio: 'Vedic chanting expert from Chennai. Teaches proper pronunciation and benefits of mantras. Sound healing specialist.',
      isAvailable: true,
    ),
    AIPanditModel(
      id: 'ai_pandit_27',
      name: 'Jyotish Guru Anita Rao',
      profileImage: 'https://ui-avatars.com/api/?name=Anita+Rao&background=A29BFE&color=fff&size=200',
      specializations: ['Business Astrology', 'Partnership Analysis', 'Company Formation'],
      experienceYears: 18,
      rating: 4.9,
      totalConsultations: 13500,
      languages: ['Hindi', 'English', 'Telugu', 'Kannada'],
      gender: 'female',
      bio: 'Business astrology expert from Bangalore. Former CA turned astrologer. Helps entrepreneurs and businesses thrive.',
      isAvailable: true,
    ),
    AIPanditModel(
      id: 'ai_pandit_28',
      name: 'Sadhvi Kamala Devi',
      profileImage: 'https://ui-avatars.com/api/?name=Kamala+Devi&background=FD79A8&color=fff&size=200',
      specializations: ['Beauty Astrology', 'Fashion Guidance', 'Auspicious Colors'],
      experienceYears: 12,
      rating: 4.6,
      totalConsultations: 8000,
      languages: ['Hindi', 'English', 'Marathi'],
      gender: 'female',
      bio: 'Beauty and fashion astrologer from Mumbai. Guides on auspicious colors, gemstones, and styling based on planets.',
      isAvailable: true,
    ),
    AIPanditModel(
      id: 'ai_pandit_29',
      name: 'Acharya Deepa Pandey',
      profileImage: 'https://ui-avatars.com/api/?name=Deepa+Pandey&background=00B894&color=fff&size=200',
      specializations: ['Dream Interpretation', 'Symbols Meaning', 'Subconscious Mind'],
      experienceYears: 14,
      rating: 4.7,
      totalConsultations: 9000,
      languages: ['Hindi', 'English', 'Bengali'],
      gender: 'female',
      bio: 'Dream interpretation specialist from Varanasi. Decodes messages from dreams. Understands subconscious mind through Jyotish.',
      isAvailable: true,
    ),
    AIPanditModel(
      id: 'ai_pandit_30',
      name: 'Jyotishi Rekha Nair',
      profileImage: 'https://ui-avatars.com/api/?name=Rekha+Nair&background=55EFC4&color=000&size=200',
      specializations: ['Travel Astrology', 'Foreign Settlement', 'Immigration'],
      experienceYears: 16,
      rating: 4.8,
      totalConsultations: 11000,
      languages: ['Hindi', 'English', 'Malayalam', 'Tamil'],
      gender: 'female',
      bio: 'Travel and foreign settlement expert from Kerala. Guides on abroad opportunities. Immigration timing specialist.',
      isAvailable: true,
    ),
    
    // Super Specialized Pandits (31-34)
    AIPanditModel(
      id: 'ai_pandit_31',
      name: 'Pandit Vikram Singh Rathore',
      profileImage: 'https://ui-avatars.com/api/?name=Vikram+Rathore&background=E17055&color=fff&size=200',
      specializations: ['Royal Astrology', 'Political Predictions', 'Leadership Guidance'],
      experienceYears: 26,
      rating: 4.9,
      totalConsultations: 15500,
      languages: ['Hindi', 'English', 'Rajasthani'],
      gender: 'male',
      bio: 'From royal Rajput family of Rajasthan. Advisor to political leaders. Expert in power, authority, and leadership astrology.',
      isAvailable: true,
    ),
    AIPanditModel(
      id: 'ai_pandit_32',
      name: 'Dr. Madhavi Krishnan',
      profileImage: 'https://ui-avatars.com/api/?name=Madhavi+Krishnan&background=FDCB6E&color=000&size=200',
      specializations: ['Ayurveda Jyotish', 'Herbal Remedies', 'Natural Healing'],
      experienceYears: 19,
      rating: 4.9,
      totalConsultations: 14000,
      languages: ['Hindi', 'English', 'Tamil', 'Malayalam', 'Sanskrit'],
      gender: 'female',
      bio: 'Ayurvedic doctor and astrologer from Kerala. Combines ancient Ayurveda with Jyotish. Natural healing through herbs and planets.',
      isAvailable: true,
    ),
    AIPanditModel(
      id: 'ai_pandit_33',
      name: 'Pandit Jagdish Chandra',
      profileImage: 'https://ui-avatars.com/api/?name=Jagdish+Chandra&background=6C5CE7&color=fff&size=200',
      specializations: ['Sports Astrology', 'Competition Success', 'Victory Timing'],
      experienceYears: 13,
      rating: 4.7,
      totalConsultations: 8500,
      languages: ['Hindi', 'English'],
      gender: 'male',
      bio: 'Young sports astrologer from Delhi. Guides athletes and competitors. Timing specialist for competitions and matches.',
      isAvailable: true,
    ),
    AIPanditModel(
      id: 'ai_pandit_34',
      name: 'Mata Saraswati Upadhyay',
      profileImage: 'https://ui-avatars.com/api/?name=Saraswati+Upadhyay&background=FDA7DF&color=fff&size=200',
      specializations: ['Education Astrology', 'Student Guidance', 'Exam Success'],
      experienceYears: 22,
      rating: 4.8,
      totalConsultations: 16500,
      languages: ['Hindi', 'English', 'Sanskrit'],
      gender: 'female',
      bio: 'Education specialist from Varanasi. Former teacher turned astrologer. Helps students excel in studies and exams.',
      isAvailable: true,
    ),
  ];

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


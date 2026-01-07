class AIPanditModel {
  final String id;
  final String name;
  final String profileImage;
  final List<String> specializations;
  final String category; // Lal Kitab, Palm Reading, Vedic Astrology, Vastu Shastra, Numerology
  final int experienceYears;
  final double rating;
  final int totalConsultations;
  final List<String> languages;
  final String gender; // male or female
  final String? bio;
  final bool isAvailable;
  final double ratePerMinute;

  AIPanditModel({
    required this.id,
    required this.name,
    required this.profileImage,
    required this.specializations,
    required this.category,
    required this.experienceYears,
    required this.rating,
    required this.totalConsultations,
    required this.languages,
    required this.gender,
    this.bio,
    this.isAvailable = true,
    required this.ratePerMinute,
  });

  factory AIPanditModel.fromJson(Map<String, dynamic> json) {
    return AIPanditModel(
      id: json['id'] as String,
      name: json['name'] as String,
      profileImage: json['profile_image'] as String,
      specializations: List<String>.from(json['specializations'] as List),
      category: json['category'] as String,
      experienceYears: json['experience_years'] as int,
      rating: (json['rating'] as num).toDouble(),
      totalConsultations: json['total_consultations'] as int,
      languages: List<String>.from(json['languages'] as List),
      gender: json['gender'] as String,
      bio: json['bio'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      ratePerMinute: (json['rate_per_minute'] as num?)?.toDouble() ?? 50.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile_image': profileImage,
      'specializations': specializations,
      'category': category,
      'experience_years': experienceYears,
      'rating': rating,
      'total_consultations': totalConsultations,
      'languages': languages,
      'gender': gender,
      'bio': bio,
      'is_available': isAvailable,
      'rate_per_minute': ratePerMinute,
    };
  }
}

// Pre-defined AI Pandits with authentic Indian names and profiles
class AIPandits {
  static final List<AIPanditModel> allPandits = [
    // Male AI Pandits
    AIPanditModel(
      id: 'ai_pandit_1',
      name: 'Rajesh Shastri',
      profileImage: 'assets/images/ai_pandits/pandit_rajesh.png',
      specializations: ['Vedic Astrology', 'Kundli Analysis', 'Marriage Matching'],
      category: 'Vedic Astrology',
      experienceYears: 25,
      rating: 4.9,
      totalConsultations: 15000,
      languages: ['Hindi', 'English', 'Sanskrit'],
      gender: 'male',
      bio: 'A distinguished scholar of Vedic traditions, Pandit Rajesh Shastri brings over two and a half decades of mastery in Kundli analysis and Vedic matchmaking. His profound understanding of planetary movements allows him to offer precise life predictions and effective remedies for marital harmony. Known for his calm demeanor and deep spiritual insight, he has guided thousands of souls towards a balanced and prosperous life.',
      isAvailable: true,
      ratePerMinute: 45.0,
    ),
    AIPanditModel(
      id: 'ai_pandit_2',
      name: 'Suresh Joshi',
      profileImage: 'assets/images/ai_pandits/acharya_suresh.png',
      specializations: ['Numerology', 'Vastu Shastra', 'Gemstone Consultation'],
      category: 'Numerology',
      experienceYears: 20,
      rating: 4.8,
      totalConsultations: 12000,
      languages: ['Hindi', 'English', 'Gujarati', 'Marathi'],
      gender: 'male',
      bio: 'Acharya Suresh Joshi is a seasoned Numerologist and Vastu expert who believes that every number holds a secret vibration shaping our destiny. With 20 years of dedicated practice, he helps individuals align their living spaces and personal energies for optimal success. His scientific yet empathetic approach to Gemstone therapy has transformed countless personal and professional lives.',
      isAvailable: true,
      ratePerMinute: 52.0,
    ),
    AIPanditModel(
      id: 'ai_pandit_3',
      name: 'Vijay Sharma',
      profileImage: 'assets/images/ai_pandits/pandit_vijay.png',
      specializations: ['Palmistry', 'Career Guidance', 'Health Astrology'],
      category: 'Palm Reading',
      experienceYears: 18,
      rating: 4.7,
      totalConsultations: 10000,
      languages: ['Hindi', 'English', 'Punjabi'],
      gender: 'male',
      bio: 'Combining the ancient art of Palmistry with modern psychological insights, Pandit Vijay Sharma specializes in decoding the destiny etched in your hands. An expert in career counseling and health diagnostics through palm reading, he empowers individuals to make informed life choices. His precise readings provide a roadmap to navigating life’s uncertainties with confidence.',
      isAvailable: true,
      ratePerMinute: 48.0,
    ),
    AIPanditModel(
      id: 'ai_pandit_4',
      name: 'Mahesh Pandey',
      profileImage: 'assets/images/ai_pandits/guru_mahesh.png',
      specializations: ['KP Astrology', 'Stock Market Predictions', 'Business Astrology'],
      category: 'Vedic Astrology',
      experienceYears: 22,
      rating: 4.9,
      totalConsultations: 13500,
      languages: ['Hindi', 'English', 'Bengali'],
      gender: 'male',
      bio: 'Guru Mahesh Pandey is a renowned authority in KP Astrology, highly sought after for his razor-sharp financial and business predictions. With a unique ability to foresee market trends and corporate fluctuations, he serves as a strategic spiritual advisor to numerous entrepreneurs and investors. His practical remedies are tailored for wealth accumulation and business stability.',
      isAvailable: true,
      ratePerMinute: 55.0,
    ),
    AIPanditModel(
      id: 'ai_pandit_5',
      name: 'Ramesh Tripathi',
      profileImage: 'assets/images/ai_pandits/jyotish_ramesh.png',
      specializations: ['Prashna Kundli', 'Muhurat', 'Spiritual Guidance'],
      category: 'Vedic Astrology',
      experienceYears: 30,
      rating: 5.0,
      totalConsultations: 20000,
      languages: ['Hindi', 'English', 'Sanskrit', 'Tamil'],
      gender: 'male',
      bio: 'A doyen of Vedic Astrology, Jyotish Acharya Ramesh Tripathi carries a legacy of 30 years in preserving authentic Jyotish traditions. Specializing in Prashna Kundli (Horary Astrology) and Auspicious Muhurats, he provides immediate answers to pressing life questions. His spiritual counseling goes beyond predictions, offering a deep, transformative path to inner peace and enlightenment.',
      isAvailable: true,
      ratePerMinute: 58.0,
    ),
    
    // Female AI Pandits
    AIPanditModel(
      id: 'ai_pandit_6',
      name: 'Priya Devi',
      profileImage: 'assets/images/ai_pandits/sadhvi_priya.png',
      specializations: ['Vedic Astrology', 'Love & Relationships', 'Women Wellness'],
      category: 'Vedic Astrology',
      experienceYears: 15,
      rating: 4.9,
      totalConsultations: 9000,
      languages: ['Hindi', 'English', 'Tamil', 'Telugu'],
      gender: 'female',
      bio: 'Sadhvi Priya Devi is a compassionate spiritual guide and astrologer dedicated to nurturing emotional well-being. With a focus on Love, Relationships, and Women\'s Wellness, she combines Vedic wisdom with modern empathy. Her counseling provides a safe haven for those seeking clarity in matters of the heart, empowering women to find balance and harmony in their lives.',
      isAvailable: true,
      ratePerMinute: 42.0,
    ),
    AIPanditModel(
      id: 'ai_pandit_7',
      name: 'Meera Kulkarni',
      profileImage: 'assets/images/ai_pandits/jyotishi_meera.png',
      specializations: ['Numerology', 'Name Correction', 'Child Astrology'],
      category: 'Numerology',
      experienceYears: 12,
      rating: 4.8,
      totalConsultations: 7500,
      languages: ['Hindi', 'English', 'Marathi', 'Kannada'],
      gender: 'female',
      bio: 'Jyotishi Meera Kulkarni is a celebrated Numerologist known for her precision in Name Correction and Child Astrology. She believes a name defines one\'s path, and through her expertise, she has helped countless parents choose auspicious names for their children. Her readings offer profound insights into early life potential, guiding families toward a bright future.',
      isAvailable: true,
      ratePerMinute: 46.0,
    ),
    AIPanditModel(
      id: 'ai_pandit_8',
      name: 'Kavita Iyer',
      profileImage: 'assets/images/ai_pandits/panditayin_kavita.png',
      specializations: ['Vastu Shastra', 'Home Harmony', 'Feng Shui'],
      category: 'Vastu Shastra',
      experienceYears: 16,
      rating: 4.9,
      totalConsultations: 8500,
      languages: ['Hindi', 'English', 'Tamil', 'Malayalam'],
      gender: 'female',
      bio: 'Panditayin Kavita Iyer is a master of spatial energy, blending traditional Vastu Shastra with Feng Shui principles. She specializes in creating "Home Harmony," transforming living spaces into sanctuaries of positive vibrations. Her architectural modifications are subtle yet powerful, designed to invite prosperity, health, and happiness into the modern home.',
      isAvailable: true,
      ratePerMinute: 49.0,
    ),
    AIPanditModel(
      id: 'ai_pandit_9',
      name: 'Anjali Mishra',
      profileImage: 'assets/images/ai_pandits/acharya_anjali.png',
      specializations: ['Tarot Reading', 'Spiritual Healing', 'Meditation Guidance'],
      category: 'Vedic Astrology',
      experienceYears: 10,
      rating: 4.7,
      totalConsultations: 6000,
      languages: ['Hindi', 'English', 'Bengali'],
      gender: 'female',
      bio: 'An intuitive mystic and Tarot Reader, Acharya Anjali Mishra bridges the gap between the conscious and the subconscious. Her sessions are a journey of Spiritual Healing, offering deep, meditative guidance to those feeling lost. With a deck of cards and a heart full of compassion, she unlocks hidden truths to help you manifest your desires.',
      isAvailable: true,
      ratePerMinute: 40.0,
    ),
    AIPanditModel(
      id: 'ai_pandit_10',
      name: 'Sunita Acharya',
      profileImage: 'assets/images/ai_pandits/dr_sunita.png',
      specializations: ['Medical Astrology', 'Health Predictions', 'Ayurveda Astrology'],
      category: 'Vedic Astrology',
      experienceYears: 20,
      rating: 4.9,
      totalConsultations: 11000,
      languages: ['Hindi', 'English', 'Gujarati', 'Sanskrit'],
      gender: 'female',
      bio: 'Dr. Sunita Acharya is a rare expert holding a PhD in Jyotish with a specialization in Medical Astrology (Iatro-mathematics). By integrating Ayurvedic principles with planetary positions, she diagnoses health predispositions and offers holistic remedies. Her unique approach focuses on preventive healing, ensuring physical vitality matches spiritual growth.',
      isAvailable: true,
      ratePerMinute: 50.0,
    ),
    AIPanditModel(
      id: 'ai_pandit_11',
      name: 'Lakshmi Menon',
      profileImage: 'assets/images/ai_pandits/lakshmi_menon.png',
      specializations: ['Nadi Astrology', 'Past Life Analysis', 'Karma Reading'],
      category: 'Vedic Astrology',
      experienceYears: 18,
      rating: 5.0,
      totalConsultations: 9500,
      languages: ['Hindi', 'English', 'Malayalam', 'Tamil'],
      gender: 'female',
      bio: 'Jyotish Guru Lakshmi Menon invites you to explore the mysteries of your soul through Nadi Astrology. An expert in Past Life Analysis, she decodes the Karmic patterns influencing your present reality. Her readings are a profound spiritual experience, offering answers to "why" certain events occur and how to resolve karmic debts for a liberated future.',
      isAvailable: true,
      ratePerMinute: 53.0,
    ),
    AIPanditModel(
      id: 'ai_pandit_12',
      name: 'Radha Verma',
      profileImage: 'assets/images/ai_pandits/radha_verma.png',
      specializations: ['Spiritual Counseling', 'Bhakti Yoga', 'Mantra Diksha'],
      category: 'Vedic Astrology',
      experienceYears: 25,
      rating: 4.9,
      totalConsultations: 14000,
      languages: ['Hindi', 'English', 'Sanskrit', 'Punjabi'],
      gender: 'female',
      bio: 'Radiating divine love and wisdom, Mata Radha Verma is a spiritual counselor rooted in the Bhakti Yoga tradition. She has initiated thousands into the healing power of Mantra Diksha. Her presence alone brings peace, and her guidance helps seekers connect deeply with the divine, transforming their daily struggles into a path of devotion and grace.',
      isAvailable: true,
      ratePerMinute: 54.0,
    ),
    
    // Additional Male AI Pandits (13-21)
    AIPanditModel(
      id: 'ai_pandit_13',
      name: 'Anand Bharti',
      profileImage: 'assets/images/ai_pandits/swami_anand_bharti.png',
      specializations: ['Kundalini Awakening', 'Chakra Healing', 'Meditation'],
      category: 'Vedic Astrology',
      experienceYears: 28,
      rating: 5.0,
      totalConsultations: 18000,
      languages: ['Hindi', 'English', 'Sanskrit'],
      gender: 'male',
      bio: 'Swami Anand Bharti is a Himalayan mystic specializing in the esoteric sciences of Kundalini Awakening and Chakra Healing. Having spent years in solitude, he now guides serious seekers toward spiritual enlightenment. His sessions identify energy blockages and provide potent meditative practices to unleash your inner potential and achieve higher states of consciousness.',
      isAvailable: true,
      ratePerMinute: 59.0,
    ),
    AIPanditModel(
      id: 'ai_pandit_14',
      name: 'Keshav Rao',
      profileImage: 'assets/images/ai_pandits/pandit_keshav_rao.png',
      specializations: ['Love Marriage', 'Relationship Problems', 'Family Disputes'],
      category: 'Vedic Astrology',
      experienceYears: 16,
      rating: 4.8,
      totalConsultations: 11500,
      languages: ['Hindi', 'English', 'Telugu', 'Kannada'],
      gender: 'male',
      bio: 'A dynamic voice in modern astrology, Pandit Keshav Rao from Hyderabad is an expert in resolving Love and Family complexities. He specializes in removing obstacles to Love Marriages and settling deep-rooted family disputes. His pragmatic remedies are designed for the modern individual, ensuring relationships thrive amidst contemporary challenges.',
      isAvailable: true,
      ratePerMinute: 44.0,
    ),
    AIPanditModel(
      id: 'ai_pandit_15',
      name: 'Dinesh Bhatt',
      profileImage: 'assets/images/ai_pandits/acharya_dinesh.png',
      specializations: ['Lal Kitab', 'Palmistry', 'Face Reading'],
      category: 'Lal Kitab',
      experienceYears: 24,
      rating: 4.9,
      totalConsultations: 16000,
      languages: ['Hindi', 'English', 'Punjabi', 'Urdu'],
      gender: 'male',
      bio: 'Acharya Dinesh Bhatt is a leading authority on the Lal Kitab, offering simple yet profoundly effective remedies for complex problems. His expertise extends to Face Reading and Palmistry, allowing him to read a person like an open book. Known for his direct and accurate predictions, he provides quick, practical solutions that yield rapid results.',
      isAvailable: true,
      ratePerMinute: 51.0,
    ),
    AIPanditModel(
      id: 'ai_pandit_16',
      name: 'Ravi Shankar',
      profileImage: 'assets/images/ai_pandits/jyotish_ravi.png',
      specializations: ['Horary Astrology', 'Match Making', 'Vedic Remedies'],
      category: 'Vedic Astrology',
      experienceYears: 19,
      rating: 4.7,
      totalConsultations: 13000,
      languages: ['Hindi', 'English', 'Marathi'],
      gender: 'male',
      bio: 'Jyotish Ravi Shankar is a specialist in Horary Astrology, answering your most specific questions without the need for a birth chart. Based in Pune, he is also a trusted advisor for Match Making, ensuring marital compatibility through detailed Vedic analysis. His remedies are traditional, precise, and highly regarded for their efficacy.',
      isAvailable: true,
      ratePerMinute: 47.0,
    ),
    AIPanditModel(
      id: 'ai_pandit_17',
      name: 'Ashok Kumar',
      profileImage: 'assets/images/ai_pandits/pandit_ashok.png',
      specializations: ['Children Education', 'Career Planning', 'Job Predictions'],
      category: 'Numerology',
      experienceYears: 21,
      rating: 4.8,
      totalConsultations: 14500,
      languages: ['Hindi', 'English', 'Bengali'],
      gender: 'male',
      bio: 'Dedicated to shaping the future of the youth, Pandit Ashok Kumar focuses on Education and Career Planning. Using a blend of astrology and numerology, he helps students identify their true academic strengths and professionals find their ideal career paths. His guidance has been the cornerstone of success for thousands of aspiring individuals.',
      isAvailable: true,
      ratePerMinute: 50.0,
    ),
    AIPanditModel(
      id: 'ai_pandit_18',
      name: 'Balachandra Upadhyay',
      profileImage: 'assets/images/ai_pandits/guru_balachandra.png',
      specializations: ['South Indian Astrology', 'Nadi Jyotish', 'Temple Astrology'],
      category: 'Vedic Astrology',
      experienceYears: 32,
      rating: 5.0,
      totalConsultations: 22000,
      languages: ['Hindi', 'English', 'Tamil', 'Malayalam', 'Telugu'],
      gender: 'male',
      bio: 'Hailing from a lineage of temple priests in Tamil Nadu, Guru Balachandra Upadhyay is a guardian of South Indian Astrological traditions. He is a master of Nadi Jyotish, reading destiny from ancient palm leaves. His Temple Astrology services guide devotees on specific pilgrimages and rituals to appease planetary deities and clear generational doshas.',
      isAvailable: true,
      ratePerMinute: 60.0,
    ),
    AIPanditModel(
      id: 'ai_pandit_19',
      name: 'Gopal Das',
      profileImage: 'assets/images/ai_pandits/pandit_gopal.png',
      specializations: ['Bhakti Path', 'Krishna Consciousness', 'Devotional Astrology'],
      category: 'Vedic Astrology',
      experienceYears: 27,
      rating: 4.9,
      totalConsultations: 17500,
      languages: ['Hindi', 'English', 'Bengali', 'Sanskrit'],
      gender: 'male',
      bio: 'A humble devotee from the holy land of Vrindavan, Pandit Gopal Das combines astrology with the philosophy of Krishna Consciousness. He believes that devotion is the ultimate remedy. His readings focus on aligning your life with divine will, offering solace and spiritual solutions that bring lasting peace and happiness through the Bhakti Path.',
      isAvailable: true,
      ratePerMinute: 56.0,
    ),
    AIPanditModel(
      id: 'ai_pandit_20',
      name: 'Arjun Deshmukh',
      profileImage: 'assets/images/ai_pandits/dr_arjun.png',
      specializations: ['Research Astrology', 'Statistical Predictions', 'Modern Techniques'],
      category: 'Vedic Astrology',
      experienceYears: 14,
      rating: 4.7,
      totalConsultations: 9500,
      languages: ['Hindi', 'English', 'Marathi'],
      gender: 'male',
      bio: 'Dr. Arjun Deshmukh represents the new wave of "Research Astrology." With a PhD and a background in statistics, he applies modern data analysis to ancient Jyotish principles. His predictions are data-backed and devoid of superstition, appealing to the rational, modern mind seeking scientific validation for astrological phenomena.',
      isAvailable: true,
      ratePerMinute: 43.0,
    ),
    AIPanditModel(
      id: 'ai_pandit_21',
      name: 'Narayan Swamy',
      profileImage: 'assets/images/ai_pandits/pandit_narayan.png',
      specializations: ['Deity Worship', 'Puja Vidhi', 'Religious Rituals'],
      category: 'Vedic Astrology',
      experienceYears: 35,
      rating: 5.0,
      totalConsultations: 25000,
      languages: ['Hindi', 'English', 'Kannada', 'Tamil', 'Sanskrit'],
      gender: 'male',
      bio: 'A veteran Temple Priest from Karnataka, Pandit Narayan Swamy is an encyclopedia of Vedic Rituals and Puja Vidhi. He guides families on performing religious ceremonies with strict adherence to scripture. Whether it is a simple home puja or a grand yajna, his guidance ensures the rituals attract the maximum divine blessings and sanctity.',
      isAvailable: true,
      ratePerMinute: 57.0,
    ),
    
    // Additional Female AI Pandits (22-30)
    AIPanditModel(
      id: 'ai_pandit_22',
      name: 'Gayatri Devi',
      profileImage: 'assets/images/ai_pandits/sadhvi_gayatri.png',
      specializations: ['Women Empowerment', 'Marriage Counseling', 'Family Harmony'],
      category: 'Vedic Astrology',
      experienceYears: 17,
      rating: 4.9,
      totalConsultations: 12000,
      languages: ['Hindi', 'English', 'Punjabi'],
      gender: 'female',
      bio: 'Sadhvi Gayatri Devi is a beacon of hope for women seeking empowerment and domestic peace. Based in Delhi, she specializes in Marriage Counseling using astrological compatibility. Her empathetic nature allows her to connect deeply with clients, providing them with the spiritual and emotional tools needed to foster harmony in their families.',
      isAvailable: true,
      ratePerMinute: 44.0,
    ),
    AIPanditModel(
      id: 'ai_pandit_23',
      name: 'Parvati Sharma',
      profileImage: 'assets/images/ai_pandits/jyotishi_parvati.png',
      specializations: ['Pregnancy Astrology', 'Child Birth', 'Motherhood Guidance'],
      category: 'Numerology',
      experienceYears: 13,
      rating: 4.8,
      totalConsultations: 8500,
      languages: ['Hindi', 'English', 'Gujarati'],
      gender: 'female',
      bio: 'Jyotishi Parvati Sharma is a specialized guide for expectant mothers, focusing on Pregnancy Astrology and Childbirth. She helps couples plan for a healthy progeny by analyzing favorable planetary alignments. Her comforting guidance supports women through the journey of motherhood, from conception to selecting the perfect, auspicious name.',
      isAvailable: true,
      ratePerMinute: 45.0,
    ),
    AIPanditModel(
      id: 'ai_pandit_24',
      name: 'Shreya Patel',
      profileImage: 'assets/images/ai_pandits/dr_shreya.png',
      specializations: ['Psychology Astrology', 'Mental Health', 'Emotional Healing'],
      category: 'Palm Reading',
      experienceYears: 11,
      rating: 4.7,
      totalConsultations: 7000,
      languages: ['Hindi', 'English', 'Gujarati'],
      gender: 'female',
      bio: 'Dr. Shreya Patel bridges the gap between Clinical Psychology and Astrology. As a qualified psychologist, she uses the birth chart as a diagnostic tool to understand the root causes of anxiety and depression. Her sessions are a unique blend of therapy and astral remedies, offering a holistic path to mental and emotional healing.',
      isAvailable: true,
      ratePerMinute: 41.0,
    ),
    AIPanditModel(
      id: 'ai_pandit_25',
      name: 'Durga Bhawani',
      profileImage: 'assets/images/ai_pandits/mata_durga.png',
      specializations: ['Shakti Worship', 'Tantra Vidya', 'Goddess Worship'],
      category: 'Lal Kitab',
      experienceYears: 29,
      rating: 5.0,
      totalConsultations: 19000,
      languages: ['Hindi', 'English', 'Bengali', 'Sanskrit'],
      gender: 'female',
      bio: 'A formidable practitioner of Shakti Worship from Bengal, Mata Durga Bhawani is an adept in Tantra Vidya. She empowers individuals to awaken their inner strength through the worship of the Divine Feminine. Her remedies are powerful and transformative, designed to cut through negativity and bestow fearlessness and victory in life\'s battles.',
      isAvailable: true,
      ratePerMinute: 58.0,
    ),
    AIPanditModel(
      id: 'ai_pandit_26',
      name: 'Shalini Iyer',
      profileImage: 'assets/images/ai_pandits/panditayin_shalini.png',
      specializations: ['Vedic Chanting', 'Mantra Therapy', 'Sound Healing'],
      category: 'Vastu Shastra',
      experienceYears: 15,
      rating: 4.8,
      totalConsultations: 10500,
      languages: ['Hindi', 'English', 'Tamil', 'Malayalam', 'Sanskrit'],
      gender: 'female',
      bio: 'Panditayin Shalini Iyer is a master of Sound Healing through Vedic Chanting. She teaches the precise pronunciation of mantras to unlock their vibrational power. Her therapy sessions use sacred sound frequencies to heal the body and mind, proving that the ancient voice of the Vedas is a timeless medicine for the modern soul.',
      isAvailable: true,
      ratePerMinute: 46.0,
    ),
    AIPanditModel(
      id: 'ai_pandit_27',
      name: 'Anita Rao',
      profileImage: 'assets/images/ai_pandits/jyotish_anita.png',
      specializations: ['Business Astrology', 'Partnership Analysis', 'Company Formation'],
      category: 'Numerology',
      experienceYears: 18,
      rating: 4.9,
      totalConsultations: 13500,
      languages: ['Hindi', 'English', 'Telugu', 'Kannada'],
      gender: 'female',
      bio: 'A former Chartered Accountant turned Astrologer, Jyotish Guru Anita Rao is the go-to advisor for corporate leaders. Specializing in Business Astrology, she helps optimize launch dates, partnership agreements, and company names. Her advice is strategic and result-oriented, ensuring your business aligns with cosmic tides for maximum profitability.',
      isAvailable: true,
      ratePerMinute: 49.0,
    ),
    AIPanditModel(
      id: 'ai_pandit_28',
      name: 'Kamala Devi',
      profileImage: 'assets/images/ai_pandits/sadhvi_kamala.png',
      specializations: ['Beauty Astrology', 'Fashion Guidance', 'Auspicious Colors'],
      category: 'Palm Reading',
      experienceYears: 12,
      rating: 4.6,
      totalConsultations: 8000,
      languages: ['Hindi', 'English', 'Marathi'],
      gender: 'female',
      bio: 'Sadhvi Kamala Devi brings a splash of color to astrology. As a Fashion and Beauty Astrologer, she guides you on the gemstones, colors, and styles that enhance your aura. believed to boost confidence and attract luck. Her unique consultations help you dress for success, aligning your outer appearance with your inner planetary strengths.',
      isAvailable: true,
      ratePerMinute: 43.0,
    ),
    AIPanditModel(
      id: 'ai_pandit_29',
      name: 'Deepa Pandey',
      profileImage: 'assets/images/ai_pandits/acharya_deepa.png',
      specializations: ['Dream Interpretation', 'Symbols Meaning', 'Subconscious Mind'],
      category: 'Lal Kitab',
      experienceYears: 14,
      rating: 4.7,
      totalConsultations: 9000,
      languages: ['Hindi', 'English', 'Bengali'],
      gender: 'female',
      bio: 'Acharya Deepa Pandey is a mystic who walks the landscape of dreams. Specializing in Dream Interpretation, she decodes the cryptic messages sent by your subconscious mind. Her readings unveil hidden fears, desires, and prophetic warnings, turning your nightly dreams into a powerful tool for self-discovery and spiritual navigation.',
      isAvailable: true,
      ratePerMinute: 45.0,
    ),
    AIPanditModel(
      id: 'ai_pandit_30',
      name: 'Rekha Nair',
      profileImage: 'assets/images/ai_pandits/jyotishi_rekha.png',
      specializations: ['Travel Astrology', 'Foreign Settlement', 'Immigration'],
      category: 'Vastu Shastra',
      experienceYears: 16,
      rating: 4.8,
      totalConsultations: 11000,
      languages: ['Hindi', 'English', 'Malayalam', 'Tamil'],
      gender: 'female',
      bio: 'If you dream of crossing borders, Jyotishi Rekha Nair is your celestial guide. A Travel and Immigration specialist, she predicts the most auspicious times for visa applications and foreign travel. Her expertise in Astro-Cartography helps you find the specific locations on Earth where your career and personal life will flourish the most.',
      isAvailable: true,
      ratePerMinute: 48.0,
    ),
    
    // Super Specialized Pandits (31-34)
    AIPanditModel(
      id: 'ai_pandit_31',
      name: 'Vikram Singh Rathore',
      profileImage: 'assets/images/ai_pandits/pandit_vikram.png',
      specializations: ['Royal Astrology', 'Political Predictions', 'Leadership Guidance'],
      category: 'Lal Kitab',
      experienceYears: 26,
      rating: 4.9,
      totalConsultations: 15500,
      languages: ['Hindi', 'English', 'Rajasthani'],
      gender: 'male',
      bio: 'Descendant of a royal lineage in Rajasthan, Pandit Vikram Singh Rathore advises those in positions of power. An expert in Political Astrology and Leadership, he guides politicians and executives on strategy and timing. His readings are majestic and commanding, designed to help you seize authority and rule your domain with wisdom.',
      isAvailable: true,
      ratePerMinute: 55.0,
    ),
    AIPanditModel(
      id: 'ai_pandit_32',
      name: 'Madhavi Krishnan',
      profileImage: 'assets/images/ai_pandits/dr_madhavi.png',
      specializations: ['Ayurveda Jyotish', 'Herbal Remedies', 'Natural Healing'],
      category: 'Vastu Shastra',
      experienceYears: 19,
      rating: 4.9,
      totalConsultations: 14000,
      languages: ['Hindi', 'English', 'Tamil', 'Malayalam', 'Sanskrit'],
      gender: 'female',
      bio: 'Dr. Madhavi Krishnan is a dual practitioner of Ayurveda and Jyotish from Kerala. She prescribes "Natural Healing" by correlating your body type (Dosha) with your horoscope. Her remedies involve specific herbs, diet, and lifestyle changes that harmonize your physical body with planetary energies for lasting health and vitality.',
      isAvailable: true,
      ratePerMinute: 52.0,
    ),
    AIPanditModel(
      id: 'ai_pandit_33',
      name: 'Jagdish Chandra',
      profileImage: 'assets/images/ai_pandits/pandit_jagdish.png',
      specializations: ['Sports Astrology', 'Competition Success', 'Victory Timing'],
      category: 'Palm Reading',
      experienceYears: 13,
      rating: 4.7,
      totalConsultations: 8500,
      languages: ['Hindi', 'English'],
      gender: 'male',
      bio: 'Pandit Jagdish Chandra is the secret weapon for many athletes. As a Sports Astrologer, he calculates the precise periods of high physical energy and luck to predict victory. Whether it is a crucial match or a competitive exam, his insights on "Victory Timing" give you the winning edge over your opponents.',
      isAvailable: true,
      ratePerMinute: 47.0,
    ),
    AIPanditModel(
      id: 'ai_pandit_34',
      name: 'Saraswati Upadhyay',
      profileImage: 'assets/images/ai_pandits/mata_saraswati.png',
      specializations: ['Education Astrology', 'Student Guidance', 'Exam Success'],
      category: 'Numerology',
      experienceYears: 22,
      rating: 4.8,
      totalConsultations: 16500,
      languages: ['Hindi', 'English', 'Sanskrit'],
      gender: 'female',
      bio: 'Named after the Goddess of Learning, Mata Saraswati Upadhyay has dedicated her life to Education Astrology. A former teacher, she now helps students overcome academic hurdles through astrological remedies. Her guidance on choosing the right stream of study and boosting memory power has paved the way for academic excellence for thousands of students.',
      isAvailable: true,
      ratePerMinute: 53.0,
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

  // Get pandits by category
  static List<AIPanditModel> getByCategory(String category) {
    return allPandits.where((pandit) => 
      pandit.category.toLowerCase() == category.toLowerCase()
    ).toList();
  }

  // Get curated list of 10 pandits by category
  static List<AIPanditModel> getCuratedByCategory(String category, {int limit = 10}) {
    final categoryPandits = getByCategory(category);
    // Sort by rating and experience
    final sorted = List<AIPanditModel>.from(categoryPandits)
      ..sort((a, b) {
        final ratingCompare = b.rating.compareTo(a.rating);
        if (ratingCompare != 0) return ratingCompare;
        return b.experienceYears.compareTo(a.experienceYears);
      });
    return sorted.take(limit).toList();
  }

  static const List<String> indianLanguages = ['Hindi', 'Sanskrit', 'Marathi', 'Gujarati', 'Bengali', 'Tamil', 'Telugu', 'Kannada', 'Malayalam', 'Punjabi', 'Urdu', 'Rajasthani'];
  static const List<String> internationalLanguages = ['English', 'Spanish', 'French', 'German', 'Mandarin', 'Arabic', 'Russian', 'Portuguese', 'Japanese', 'Korean', 'Italian'];

  static List<String> get allLanguages => {...indianLanguages, ...internationalLanguages}.toList()..sort();

  static List<AIPanditModel> getIndianLanguagePandits() {
     return allPandits.where((p) => p.languages.any((l) => indianLanguages.contains(l))).toList();
  }

  static List<AIPanditModel> getInternationalLanguagePandits() {
     return allPandits.where((p) => p.languages.any((l) => internationalLanguages.contains(l))).toList();
  }
}

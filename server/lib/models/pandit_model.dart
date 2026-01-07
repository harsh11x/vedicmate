class PanditModel {
  final String id;
  final String name;
  final String? profileImage;
  final List<String> specializations;
  final int experienceYears;
  final double rating;
  final int totalReviews;
  final List<String> languages;
  final Map<String, double> servicePricing; // service_type -> price
  final String? bio;
  final List<String>? certifications;
  final bool isVerified;
  final bool isAvailable;
  final DateTime? lastActive;
  final Map<String, dynamic>? availability; // Calendar availability

  PanditModel({
    required this.id,
    required this.name,
    this.profileImage,
    required this.specializations,
    required this.experienceYears,
    required this.rating,
    required this.totalReviews,
    required this.languages,
    required this.servicePricing,
    this.bio,
    this.certifications,
    this.isVerified = false,
    this.isAvailable = true,
    this.lastActive,
    this.availability,
  });

  factory PanditModel.fromJson(Map<String, dynamic> json) {
    return PanditModel(
      id: json['id'] as String,
      name: json['name'] as String,
      profileImage: json['profile_image'] as String?,
      specializations: List<String>.from(json['specializations'] as List),
      experienceYears: json['experience_years'] as int,
      rating: (json['rating'] as num).toDouble(),
      totalReviews: json['total_reviews'] as int,
      languages: List<String>.from(json['languages'] as List),
      servicePricing: Map<String, double>.from(
        (json['service_pricing'] as Map).map(
          (k, v) => MapEntry(k as String, (v as num).toDouble()),
        ),
      ),
      bio: json['bio'] as String?,
      certifications: json['certifications'] != null
          ? List<String>.from(json['certifications'] as List)
          : null,
      isVerified: json['is_verified'] as bool? ?? false,
      isAvailable: json['is_available'] as bool? ?? true,
      lastActive: json['last_active'] != null
          ? DateTime.parse(json['last_active'] as String)
          : null,
      availability: json['availability'] as Map<String, dynamic>?,
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
      'total_reviews': totalReviews,
      'languages': languages,
      'service_pricing': servicePricing,
      'bio': bio,
      'certifications': certifications,
      'is_verified': isVerified,
      'is_available': isAvailable,
      'last_active': lastActive?.toIso8601String(),
      'availability': availability,
    };
  }
}


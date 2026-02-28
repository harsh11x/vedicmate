enum UserRole { client, pandit, admin }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final UserRole role;
  final DateTime createdAt;
  final bool isVerified;
  final Map<String, dynamic>? metadata;

  final DateTime? birthDate;
  final String? birthTime;
  final String? birthPlace;
  final double? latitude;
  final double? longitude;
  final String? timezone;
  final String? preferredAyanamsa;
  final String? preferredChartStyle;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    required this.role,
    required this.createdAt,
    this.isVerified = false,
    this.metadata,
    this.birthDate,
    this.birthTime,
    this.birthPlace,
    this.latitude,
    this.longitude,
    this.timezone,
    this.preferredAyanamsa,
    this.preferredChartStyle,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      profileImage: json['profile_image'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => UserRole.client,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      isVerified: json['is_verified'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
      birthDate: json['birth_date'] != null ? DateTime.parse(json['birth_date']) : null,
      birthTime: json['birth_time'] as String?,
      birthPlace: json['birth_place_name'] as String?,
      latitude: json['birth_latitude'] != null ? (json['birth_latitude'] as num).toDouble() : null,
      longitude: json['birth_longitude'] != null ? (json['birth_longitude'] as num).toDouble() : null,
      timezone: json['birth_timezone'] as String?,
      preferredAyanamsa: json['preferred_ayanamsa'] as String?,
      preferredChartStyle: json['preferred_chart_style'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_image': profileImage,
      'role': role.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'is_verified': isVerified,
      'metadata': metadata,
      'birth_date': birthDate?.toIso8601String(),
      'birth_time': birthTime,
      'birth_place_name': birthPlace,
      'birth_latitude': latitude,
      'birth_longitude': longitude,
      'birth_timezone': timezone,
      'preferred_ayanamsa': preferredAyanamsa,
      'preferred_chart_style': preferredChartStyle,
    };
  }
}


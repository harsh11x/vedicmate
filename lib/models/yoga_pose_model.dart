class YogaPose {
  final String id;
  final String nameEnglish;
  final String nameSanskrit;
  final String category;
  final String difficulty;
  final String duration;
  final String imagePath;
  final List<String> benefits;
  final List<String> instructions;
  final List<String> precautions;

  YogaPose({
    required this.id,
    required this.nameEnglish,
    required this.nameSanskrit,
    required this.category,
    required this.difficulty,
    required this.duration,
    required this.imagePath,
    required this.benefits,
    required this.instructions,
    required this.precautions,
  });

  factory YogaPose.fromJson(Map<String, dynamic> json) {
    return YogaPose(
      id: json['id'] as String,
      nameEnglish: json['name_english'] as String,
      nameSanskrit: json['name_sanskrit'] as String,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      duration: json['duration'] as String,
      imagePath: json['image_path'] as String,
      benefits: List<String>.from(json['benefits'] as List),
      instructions: List<String>.from(json['instructions'] as List),
      precautions: List<String>.from(json['precautions'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_english': nameEnglish,
      'name_sanskrit': nameSanskrit,
      'category': category,
      'difficulty': difficulty,
      'duration': duration,
      'image_path': imagePath,
      'benefits': benefits,
      'instructions': instructions,
      'precautions': precautions,
    };
  }
}

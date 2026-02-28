class TimelineEvent {
  final String id;
  final String title;
  final String period; // e.g., "Rigvedic Period"
  final String yearRange; // e.g., "1500-1000 BCE"
  final String description;
  final String detailedDescription;
  final List<String> relatedScriptures;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;

  TimelineEvent({
    required this.id,
    required this.title,
    required this.period,
    required this.yearRange,
    required this.description,
    required this.detailedDescription,
    required this.relatedScriptures,
    this.imageUrl,
    this.metadata,
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      period: json['period'] as String,
      yearRange: json['yearRange'] as String,
      description: json['description'] as String,
      detailedDescription: json['detailedDescription'] as String,
      relatedScriptures: List<String>.from(json['relatedScriptures'] ?? []),
      imageUrl: json['imageUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'period': period,
      'yearRange': yearRange,
      'description': description,
      'detailedDescription': detailedDescription,
      'relatedScriptures': relatedScriptures,
      'imageUrl': imageUrl,
      'metadata': metadata,
    };
  }
}

class ReviewModel {
  final String id;
  final String bookingId;
  final String clientId;
  final String panditId;
  final double rating;
  final double knowledgeRating;
  final double communicationRating;
  final double punctualityRating;
  final String? comment;
  final List<String>? photos;
  final List<String>? videos;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.bookingId,
    required this.clientId,
    required this.panditId,
    required this.rating,
    required this.knowledgeRating,
    required this.communicationRating,
    required this.punctualityRating,
    this.comment,
    this.photos,
    this.videos,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      clientId: json['client_id'] as String,
      panditId: json['pandit_id'] as String,
      rating: (json['rating'] as num).toDouble(),
      knowledgeRating: (json['knowledge_rating'] as num).toDouble(),
      communicationRating: (json['communication_rating'] as num).toDouble(),
      punctualityRating: (json['punctuality_rating'] as num).toDouble(),
      comment: json['comment'] as String?,
      photos: json['photos'] != null
          ? List<String>.from(json['photos'] as List)
          : null,
      videos: json['videos'] != null
          ? List<String>.from(json['videos'] as List)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'client_id': clientId,
      'pandit_id': panditId,
      'rating': rating,
      'knowledge_rating': knowledgeRating,
      'communication_rating': communicationRating,
      'punctuality_rating': punctualityRating,
      'comment': comment,
      'photos': photos,
      'videos': videos,
      'created_at': createdAt.toIso8601String(),
    };
  }
}


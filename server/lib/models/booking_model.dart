enum BookingStatus { pending, confirmed, completed, cancelled }

class BookingModel {
  final String id;
  final String clientId;
  final String panditId;
  final String serviceType;
  final DateTime scheduledAt;
  final int duration; // in minutes
  final double amount;
  final double platformFee;
  final double gst;
  final double totalAmount;
  final BookingStatus status;
  final String? callType; // video or audio
  final String? meetingLink;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? notes;

  BookingModel({
    required this.id,
    required this.clientId,
    required this.panditId,
    required this.serviceType,
    required this.scheduledAt,
    required this.duration,
    required this.amount,
    required this.platformFee,
    required this.gst,
    required this.totalAmount,
    required this.status,
    this.callType,
    this.meetingLink,
    required this.createdAt,
    this.completedAt,
    this.notes,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      panditId: json['pandit_id'] as String,
      serviceType: json['service_type'] as String,
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      duration: json['duration'] as int,
      amount: (json['amount'] as num).toDouble(),
      platformFee: (json['platform_fee'] as num).toDouble(),
      gst: (json['gst'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      callType: json['call_type'] as String?,
      meetingLink: json['meeting_link'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'pandit_id': panditId,
      'service_type': serviceType,
      'scheduled_at': scheduledAt.toIso8601String(),
      'duration': duration,
      'amount': amount,
      'platform_fee': platformFee,
      'gst': gst,
      'total_amount': totalAmount,
      'status': status.toString().split('.').last,
      'call_type': callType,
      'meeting_link': meetingLink,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'notes': notes,
    };
  }
}


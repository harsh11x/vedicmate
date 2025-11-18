class AIChatMessage {
  final String id;
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final bool isTyping;

  AIChatMessage({
    required this.id,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.isTyping = false,
  });

  factory AIChatMessage.fromJson(Map<String, dynamic> json) {
    return AIChatMessage(
      id: json['id'] ?? '',
      message: json['message'] ?? '',
      isUser: json['isUser'] ?? false,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isTyping: json['isTyping'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'isTyping': isTyping,
    };
  }
}

class AIChatSession {
  final String id;
  final String userId;
  final DateTime startTime;
  DateTime? endTime;
  final double ratePerMinute; // Rs. 25 per minute
  double totalCost;
  List<AIChatMessage> messages;
  bool isActive;

  AIChatSession({
    required this.id,
    required this.userId,
    required this.startTime,
    this.endTime,
    this.ratePerMinute = 25.0,
    this.totalCost = 0.0,
    this.messages = const [],
    this.isActive = true,
  });

  // Calculate cost based on duration
  double calculateCost() {
    final end = endTime ?? DateTime.now();
    final duration = end.difference(startTime);
    final minutes = duration.inSeconds / 60.0;
    return minutes * ratePerMinute;
  }

  // Get duration in minutes
  double getDurationInMinutes() {
    final end = endTime ?? DateTime.now();
    final duration = end.difference(startTime);
    return duration.inSeconds / 60.0;
  }

  factory AIChatSession.fromJson(Map<String, dynamic> json) {
    return AIChatSession(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : DateTime.now(),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      ratePerMinute: (json['ratePerMinute'] ?? 25.0).toDouble(),
      totalCost: (json['totalCost'] ?? 0.0).toDouble(),
      messages: (json['messages'] as List<dynamic>?)
              ?.map((m) => AIChatMessage.fromJson(m))
              .toList() ??
          [],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'ratePerMinute': ratePerMinute,
      'totalCost': totalCost,
      'messages': messages.map((m) => m.toJson()).toList(),
      'isActive': isActive,
    };
  }
}

class WalletTransaction {
  final String id;
  final String userId;
  final double amount;
  final TransactionType type;
  final String description;
  final DateTime timestamp;
  final String? referenceId;

  WalletTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.description,
    required this.timestamp,
    this.referenceId,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == 'TransactionType.${json['type']}',
        orElse: () => TransactionType.debit,
      ),
      description: json['description'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      referenceId: json['referenceId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'type': type.toString().split('.').last,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'referenceId': referenceId,
    };
  }
}

enum TransactionType {
  credit, // Adding money to wallet
  debit, // Deducting money from wallet
}

class UserWallet {
  final String userId;
  double balance;
  List<WalletTransaction> transactions;
  final DateTime createdAt;
  DateTime updatedAt;

  UserWallet({
    required this.userId,
    this.balance = 0.0,
    this.transactions = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserWallet.fromJson(Map<String, dynamic> json) {
    return UserWallet(
      userId: json['userId'] ?? '',
      balance: (json['balance'] ?? 0.0).toDouble(),
      transactions: (json['transactions'] as List<dynamic>?)
              ?.map((t) => WalletTransaction.fromJson(t))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'balance': balance,
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// Order model for tracking purchases and deliveries
import 'package:flutter/material.dart';

enum PaymentStatus {
  pending,
  completed,
  failed,
  refunded;

  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  Color get color {
    switch (this) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.refunded:
        return Colors.purple;
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentStatus.pending:
        return Icons.schedule;
      case PaymentStatus.completed:
        return Icons.check_circle;
      case PaymentStatus.failed:
        return Icons.cancel;
      case PaymentStatus.refunded:
        return Icons.replay;
    }
  }
}

enum DeliveryStatus {
  processing,
  confirmed,
  shipped,
  outForDelivery,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case DeliveryStatus.processing:
        return 'Processing';
      case DeliveryStatus.confirmed:
        return 'Confirmed';
      case DeliveryStatus.shipped:
        return 'Shipped';
      case DeliveryStatus.outForDelivery:
        return 'Out for Delivery';
      case DeliveryStatus.delivered:
        return 'Delivered';
      case DeliveryStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case DeliveryStatus.processing:
        return Colors.orange;
      case DeliveryStatus.confirmed:
        return Colors.blue;
      case DeliveryStatus.shipped:
        return Colors.indigo;
      case DeliveryStatus.outForDelivery:
        return Colors.teal;
      case DeliveryStatus.delivered:
        return Colors.green;
      case DeliveryStatus.cancelled:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case DeliveryStatus.processing:
        return Icons.hourglass_top;
      case DeliveryStatus.confirmed:
        return Icons.check_circle_outline;
      case DeliveryStatus.shipped:
        return Icons.local_shipping;
      case DeliveryStatus.outForDelivery:
        return Icons.delivery_dining;
      case DeliveryStatus.delivered:
        return Icons.check_circle;
      case DeliveryStatus.cancelled:
        return Icons.cancel;
    }
  }

  int get stepIndex {
    switch (this) {
      case DeliveryStatus.processing:
        return 0;
      case DeliveryStatus.confirmed:
        return 1;
      case DeliveryStatus.shipped:
        return 2;
      case DeliveryStatus.outForDelivery:
        return 3;
      case DeliveryStatus.delivered:
        return 4;
      case DeliveryStatus.cancelled:
        return -1;
    }
  }
}

class OrderItem {
  final String id;
  final String title;
  final double price;
  final int quantity;
  final String image;

  OrderItem({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.image,
  });

  double get total => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'quantity': quantity,
      'image': image,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      image: json['image'] ?? '',
    );
  }
}

class ShippingAddress {
  final String name;
  final String phone;
  final String email;
  final String addressLine1;
  final String city;
  final String state;
  final String zip;

  ShippingAddress({
    required this.name,
    required this.phone,
    required this.email,
    required this.addressLine1,
    required this.city,
    required this.state,
    required this.zip,
  });

  String get fullAddress => '$addressLine1, $city, $state - $zip';

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'addressLine1': addressLine1,
      'city': city,
      'state': state,
      'zip': zip,
    };
  }

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      addressLine1: json['addressLine1'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zip: json['zip'] ?? '',
    );
  }
}

class Order {
  final String id;
  final String orderId; // Human readable order ID like "VED-2026-001234"
  final DateTime orderDate;
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double deliveryCharge;
  final double totalAmount;
  final PaymentStatus paymentStatus;
  final String? paymentId;
  final DeliveryStatus deliveryStatus;
  final ShippingAddress shippingAddress;
  final DateTime? expectedDeliveryDate;
  final DateTime? actualDeliveryDate;
  final String? trackingNumber;
  final String? cancellationReason;
  final List<OrderTimeline>? timeline;

  Order({
    required this.id,
    required this.orderId,
    required this.orderDate,
    required this.items,
    required this.subtotal,
    this.tax = 0,
    this.deliveryCharge = 0,
    required this.totalAmount,
    required this.paymentStatus,
    this.paymentId,
    required this.deliveryStatus,
    required this.shippingAddress,
    this.expectedDeliveryDate,
    this.actualDeliveryDate,
    this.trackingNumber,
    this.cancellationReason,
    this.timeline,
  });

  /// Check if order can be cancelled
  /// Orders can only be cancelled if they are processing or confirmed
  bool get canCancel {
    return deliveryStatus == DeliveryStatus.processing ||
        deliveryStatus == DeliveryStatus.confirmed;
  }

  /// Get total item count
  int get totalItems => items.length;
  
  /// Get total quantity
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'orderDate': orderDate.toIso8601String(),
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'deliveryCharge': deliveryCharge,
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus.name,
      'paymentId': paymentId,
      'deliveryStatus': deliveryStatus.name,
      'shippingAddress': shippingAddress.toJson(),
      'expectedDeliveryDate': expectedDeliveryDate?.toIso8601String(),
      'actualDeliveryDate': actualDeliveryDate?.toIso8601String(),
      'trackingNumber': trackingNumber,
      'cancellationReason': cancellationReason,
      'timeline': timeline?.map((e) => e.toJson()).toList(),
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      orderId: (json['orderId'] ?? json['order_id']) ?? '',
      orderDate: DateTime.parse(json['orderDate'] ?? json['created_at'] ?? DateTime.now().toIso8601String()),
      items: (json['items'] as List)
          .map((e) => OrderItem.fromJson(e))
          .toList(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      deliveryCharge: (json['deliveryCharge'] ?? json['delivery_charge'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? json['total_amount'] ?? 0).toDouble(),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == (json['paymentStatus'] ?? json['payment_status']),
        orElse: () => PaymentStatus.pending,
      ),
      paymentId: json['paymentId'] ?? json['payment_id'],
      deliveryStatus: DeliveryStatus.values.firstWhere(
        (e) => e.name == (json['deliveryStatus'] ?? json['delivery_status']),
        orElse: () => DeliveryStatus.processing,
      ),
      shippingAddress: ShippingAddress.fromJson(json['shippingAddress'] ?? json['shipping_address'] ?? {}),
      expectedDeliveryDate: (json['expectedDeliveryDate'] ?? json['expected_delivery_date']) != null
          ? DateTime.parse(json['expectedDeliveryDate'] ?? json['expected_delivery_date'])
          : null,
      actualDeliveryDate: (json['actualDeliveryDate'] ?? json['actual_delivery_date']) != null
          ? DateTime.parse(json['actualDeliveryDate'] ?? json['actual_delivery_date'])
          : null,
      trackingNumber: json['trackingNumber'] ?? json['tracking_number'],
      cancellationReason: json['cancellationReason'] ?? json['cancellation_reason'],
      timeline: json['timeline'] != null
          ? (json['timeline'] as List)
              .map((e) => OrderTimeline.fromJson(e))
              .toList()
          : null,
    );
  }
}

class OrderTimeline {
  final DeliveryStatus status;
  final DateTime timestamp;
  final String? description;
  final String? location;

  OrderTimeline({
    required this.status,
    required this.timestamp,
    this.description,
    this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
      'location': location,
    };
  }

  factory OrderTimeline.fromJson(Map<String, dynamic> json) {
    return OrderTimeline(
      status: DeliveryStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DeliveryStatus.processing,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      description: json['description'],
      location: json['location'],
    );
  }
}

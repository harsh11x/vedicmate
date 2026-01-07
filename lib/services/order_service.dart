import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart';

class OrderService {
  static const String _ordersKey = 'user_orders';
  
  // Generate a unique order ID
  String _generateOrderId() {
    final now = DateTime.now();
    final random = Random().nextInt(9999).toString().padLeft(4, '0');
    return 'VED-${now.year}-$random';
  }

  // Save a new order
  Future<Order> createOrder({
    required List<OrderItem> items,
    required double subtotal,
    required double tax,
    required double deliveryCharge,
    required double totalAmount,
    required ShippingAddress shippingAddress,
    String? paymentId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    
    // Create new order
    final order = Order(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      orderId: _generateOrderId(),
      orderDate: DateTime.now(),
      items: items,
      subtotal: subtotal,
      tax: tax,
      deliveryCharge: deliveryCharge,
      totalAmount: totalAmount,
      paymentStatus: paymentId != null ? PaymentStatus.completed : PaymentStatus.pending,
      paymentId: paymentId,
      deliveryStatus: DeliveryStatus.processing,
      shippingAddress: shippingAddress,
      expectedDeliveryDate: DateTime.now().add(const Duration(days: 7)),
      timeline: [
        OrderTimeline(
          status: DeliveryStatus.processing,
          timestamp: DateTime.now(),
          description: 'Order placed successfully',
        ),
      ],
    );
    
    // Get existing orders
    final orders = await getOrders();
    orders.insert(0, order);
    
    // Save to SharedPreferences
    final ordersJson = orders.map((e) => e.toJson()).toList();
    await prefs.setString('${_ordersKey}_$userId', jsonEncode(ordersJson));
    
    return order;
  }

  // Get all orders for current user
  Future<List<Order>> getOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    
    final ordersString = prefs.getString('${_ordersKey}_$userId');
    if (ordersString == null) {
      return _getMockOrders();
    }
    
    try {
      final ordersList = jsonDecode(ordersString) as List;
      final orders = ordersList.map((e) => Order.fromJson(e)).toList();
      // If no orders, return mock data for demo
      if (orders.isEmpty) {
        return _getMockOrders();
      }
      return orders;
    } catch (e) {
      return _getMockOrders();
    }
  }

  // Get a single order by ID
  Future<Order?> getOrderById(String orderId) async {
    final orders = await getOrders();
    try {
      return orders.firstWhere((o) => o.id == orderId || o.orderId == orderId);
    } catch (e) {
      return null;
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, DeliveryStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    
    final orders = await getOrders();
    final index = orders.indexWhere((o) => o.id == orderId || o.orderId == orderId);
    
    if (index != -1) {
      final order = orders[index];
      final updatedTimeline = [
        ...?order.timeline,
        OrderTimeline(
          status: status,
          timestamp: DateTime.now(),
          description: _getStatusDescription(status),
        ),
      ];
      
      final updatedOrder = Order(
        id: order.id,
        orderId: order.orderId,
        orderDate: order.orderDate,
        items: order.items,
        subtotal: order.subtotal,
        tax: order.tax,
        deliveryCharge: order.deliveryCharge,
        totalAmount: order.totalAmount,
        paymentStatus: order.paymentStatus,
        paymentId: order.paymentId,
        deliveryStatus: status,
        shippingAddress: order.shippingAddress,
        expectedDeliveryDate: order.expectedDeliveryDate,
        actualDeliveryDate: status == DeliveryStatus.delivered ? DateTime.now() : order.actualDeliveryDate,
        trackingNumber: order.trackingNumber,
        timeline: updatedTimeline,
      );
      
      orders[index] = updatedOrder;
      final ordersJson = orders.map((e) => e.toJson()).toList();
      await prefs.setString('${_ordersKey}_$userId', jsonEncode(ordersJson));
    }
  }

  String _getStatusDescription(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.processing:
        return 'Order is being processed';
      case DeliveryStatus.confirmed:
        return 'Order confirmed by seller';
      case DeliveryStatus.shipped:
        return 'Order has been shipped';
      case DeliveryStatus.outForDelivery:
        return 'Order is out for delivery';
      case DeliveryStatus.delivered:
        return 'Order delivered successfully';
      case DeliveryStatus.cancelled:
        return 'Order has been cancelled';
    }
  }

  // Generate mock orders for demo purposes
  List<Order> _getMockOrders() {
    final now = DateTime.now();
    
    return [
      Order(
        id: '1',
        orderId: 'VED-2026-0001',
        orderDate: now.subtract(const Duration(days: 2)),
        items: [
          OrderItem(
            id: 'rudraksha_5',
            title: '5 Mukhi Rudraksha',
            price: 1499,
            quantity: 1,
            image: 'assets/images/remedies/rudraksha.png',
          ),
        ],
        subtotal: 1499,
        tax: 269.82,
        deliveryCharge: 50,
        totalAmount: 1818.82,
        paymentStatus: PaymentStatus.completed,
        paymentId: 'pay_NxT5Q8v2mRkLp',
        deliveryStatus: DeliveryStatus.shipped,
        shippingAddress: ShippingAddress(
          name: 'Test User',
          phone: '+91 9876543210',
          email: 'test@example.com',
          addressLine1: '123, ABC Society, Near XYZ Road',
          city: 'Mumbai',
          state: 'Maharashtra',
          zip: '400001',
        ),
        expectedDeliveryDate: now.add(const Duration(days: 3)),
        trackingNumber: 'AWBIND12345678',
        timeline: [
          OrderTimeline(
            status: DeliveryStatus.processing,
            timestamp: now.subtract(const Duration(days: 2)),
            description: 'Order placed successfully',
          ),
          OrderTimeline(
            status: DeliveryStatus.confirmed,
            timestamp: now.subtract(const Duration(days: 2, hours: 2)),
            description: 'Order confirmed by seller',
          ),
          OrderTimeline(
            status: DeliveryStatus.shipped,
            timestamp: now.subtract(const Duration(days: 1)),
            description: 'Order has been shipped',
            location: 'Mumbai Warehouse',
          ),
        ],
      ),
      Order(
        id: '2',
        orderId: 'VED-2026-0002',
        orderDate: now.subtract(const Duration(days: 10)),
        items: [
          OrderItem(
            id: 'yantra_1',
            title: 'Shree Yantra',
            price: 2999,
            quantity: 1,
            image: 'assets/images/remedies/yantra.png',
          ),
          OrderItem(
            id: 'mala_1',
            title: 'Tulsi Mala',
            price: 499,
            quantity: 2,
            image: 'assets/images/remedies/mala.png',
          ),
        ],
        subtotal: 3997,
        tax: 719.46,
        deliveryCharge: 0,
        totalAmount: 4716.46,
        paymentStatus: PaymentStatus.completed,
        paymentId: 'pay_MwR4P7u1nQjKo',
        deliveryStatus: DeliveryStatus.delivered,
        shippingAddress: ShippingAddress(
          name: 'Test User',
          phone: '+91 9876543210',
          email: 'test@example.com',
          addressLine1: '123, ABC Society, Near XYZ Road',
          city: 'Mumbai',
          state: 'Maharashtra',
          zip: '400001',
        ),
        expectedDeliveryDate: now.subtract(const Duration(days: 3)),
        actualDeliveryDate: now.subtract(const Duration(days: 4)),
        trackingNumber: 'AWBIND87654321',
        timeline: [
          OrderTimeline(
            status: DeliveryStatus.processing,
            timestamp: now.subtract(const Duration(days: 10)),
            description: 'Order placed successfully',
          ),
          OrderTimeline(
            status: DeliveryStatus.confirmed,
            timestamp: now.subtract(const Duration(days: 10, hours: 1)),
            description: 'Order confirmed by seller',
          ),
          OrderTimeline(
            status: DeliveryStatus.shipped,
            timestamp: now.subtract(const Duration(days: 8)),
            description: 'Order has been shipped',
            location: 'Delhi Warehouse',
          ),
          OrderTimeline(
            status: DeliveryStatus.outForDelivery,
            timestamp: now.subtract(const Duration(days: 4, hours: 6)),
            description: 'Order is out for delivery',
            location: 'Local Delivery Hub',
          ),
          OrderTimeline(
            status: DeliveryStatus.delivered,
            timestamp: now.subtract(const Duration(days: 4)),
            description: 'Order delivered successfully',
          ),
        ],
      ),
      Order(
        id: '3',
        orderId: 'VED-2026-0003',
        orderDate: now.subtract(const Duration(hours: 5)),
        items: [
          OrderItem(
            id: 'gemstone_1',
            title: 'Blue Sapphire (Neelam)',
            price: 15999,
            quantity: 1,
            image: 'assets/images/remedies/gemstone.png',
          ),
        ],
        subtotal: 15999,
        tax: 2879.82,
        deliveryCharge: 0,
        totalAmount: 18878.82,
        paymentStatus: PaymentStatus.completed,
        paymentId: 'pay_OyS6R9w3oSlMq',
        deliveryStatus: DeliveryStatus.processing,
        shippingAddress: ShippingAddress(
          name: 'Test User',
          phone: '+91 9876543210',
          email: 'test@example.com',
          addressLine1: '456, XYZ Apartments, Main Road',
          city: 'Delhi',
          state: 'Delhi',
          zip: '110001',
        ),
        expectedDeliveryDate: now.add(const Duration(days: 7)),
        timeline: [
          OrderTimeline(
            status: DeliveryStatus.processing,
            timestamp: now.subtract(const Duration(hours: 5)),
            description: 'Order placed successfully',
          ),
        ],
      ),
    ];
  }

  // Clear all orders (for testing)
  Future<void> clearOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    await prefs.remove('${_ordersKey}_$userId');
  }
}

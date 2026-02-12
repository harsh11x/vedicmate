import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart';

class OrderService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Create a new order in Supabase
  Future<Order?> createOrder({
    required List<OrderItem> items,
    required double subtotal,
    required double tax,
    required double deliveryCharge,
    required double totalAmount,
    required ShippingAddress shippingAddress,
    String? paymentId,
    required String userId,
  }) async {
    try {
      final orderId = 'VED-${DateTime.now().millisecondsSinceEpoch}';
      
      final orderData = {
        'user_id': userId,
        'order_id': orderId,
        'items': items.map((e) => e.toJson()).toList(),
        'subtotal': subtotal,
        'tax': tax,
        'delivery_charge': deliveryCharge,
        'total_amount': totalAmount,
        'payment_status': paymentId != null ? 'completed' : 'pending',
        'payment_id': paymentId,
        'delivery_status': 'processing',
        'shipping_address': shippingAddress.toJson(),
        'expected_delivery_date': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('orders')
          .insert(orderData)
          .select()
          .single();

      debugPrint('✅ Order created in Supabase: $orderId');
      return Order.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error creating order: $e');
      return null;
    }
  }

  /// Get all orders for a user
  Future<List<Order>> getOrders(String userId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((order) => Order.fromJson(order))
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching orders: $e');
      return [];
    }
  }

  /// Get a single order by ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select()
          .eq('order_id', orderId)
          .single();

      return Order.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error fetching order: $e');
      return null;
    }
  }

  /// Update order payment status
  Future<bool> updatePaymentStatus({
    required String orderId,
    required String paymentId,
    required String paymentStatus,
  }) async {
    try {
      await _supabase.from('orders').update({
        'payment_id': paymentId,
        'payment_status': paymentStatus,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('order_id', orderId);

      debugPrint('✅ Order payment updated: $orderId');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating payment: $e');
      return false;
    }
  }

  /// Update order delivery status
  Future<bool> updateDeliveryStatus({
    required String orderId,
    required DeliveryStatus status,
  }) async {
    try {
      final statusString = status.toString().split('.').last;
      
      await _supabase.from('orders').update({
        'delivery_status': statusString,
        'updated_at': DateTime.now().toIso8601String(),
        if (status == DeliveryStatus.delivered)
          'actual_delivery_date': DateTime.now().toIso8601String(),
      }).eq('order_id', orderId);

      debugPrint('✅ Order delivery status updated: $orderId -> $statusString');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating delivery status: $e');
      return false;
    }
  }

  /// Cancel an order
  Future<bool> cancelOrder(String orderId) async {
    try {
      await _supabase.from('orders').update({
        'delivery_status': 'cancelled',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('order_id', orderId);

      debugPrint('✅ Order cancelled: $orderId');
      return true;
    } catch (e) {
      debugPrint('❌ Error cancelling order: $e');
      return false;
    }
  }

  /// Get order statistics
  Future<Map<String, dynamic>> getOrderStats(String userId) async {
    try {
      final orders = await getOrders(userId);
      
      return {
        'total_orders': orders.length,
        'total_spent': orders.fold<double>(
          0.0,
          (sum, order) => sum + order.totalAmount,
        ),
        'pending_orders': orders.where((o) => o.deliveryStatus == DeliveryStatus.processing).length,
        'completed_orders': orders.where((o) => o.deliveryStatus == DeliveryStatus.delivered).length,
      };
    } catch (e) {
      debugPrint('❌ Error calculating stats: $e');
      return {
        'total_orders': 0,
        'total_spent': 0.0,
        'pending_orders': 0,
        'completed_orders': 0,
      };
    }
  }
}

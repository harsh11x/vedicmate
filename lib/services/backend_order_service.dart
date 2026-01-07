import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../config/api_config.dart';
import '../models/order_model.dart';

/// Backend Order Service for syncing orders with AWS server
class BackendOrderService {
  final http.Client _client;
  
  BackendOrderService({http.Client? client}) : _client = client ?? http.Client();
  
  /// Get headers with user authentication
  Map<String, String> _getHeaders() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return {
      'Content-Type': 'application/json',
      if (userId != null) 'x-user-id': userId,
    };
  }
  
  /// Check if backend is available
  Future<bool> isBackendAvailable() async {
    try {
      final response = await _client
          .get(Uri.parse(ApiConfig.healthUrl))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Backend not available: $e');
      return false;
    }
  }
  
  /// Fetch all orders from backend for current user
  Future<List<Order>> getOrders() async {
    try {
      final response = await _client.get(
        Uri.parse(ApiConfig.ordersUrl),
        headers: _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((json) => Order.fromJson(json))
              .toList();
        }
      }
      
      debugPrint('Failed to fetch orders: ${response.statusCode}');
      return [];
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      return [];
    }
  }
  
  /// Fetch single order by ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      final response = await _client.get(
        Uri.parse(ApiConfig.orderDetailUrl(orderId)),
        headers: _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Order.fromJson(data['data']);
        }
      }
      
      debugPrint('Failed to fetch order: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('Error fetching order: $e');
      return null;
    }
  }
  
  /// Create new order on backend
  Future<Order?> createOrder({
    required List<OrderItem> items,
    required double subtotal,
    required double tax,
    required double deliveryCharge,
    required double totalAmount,
    required ShippingAddress shippingAddress,
    String? paymentId,
  }) async {
    try {
      final orderData = {
        'items': items.map((item) => item.toJson()).toList(),
        'subtotal': subtotal,
        'tax': tax,
        'deliveryCharge': deliveryCharge,
        'totalAmount': totalAmount,
        'shippingAddress': shippingAddress.toJson(),
        'paymentId': paymentId,
        'userId': FirebaseAuth.instance.currentUser?.uid,
      };
      
      final response = await _client.post(
        Uri.parse(ApiConfig.ordersUrl),
        headers: _getHeaders(),
        body: json.encode(orderData),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          debugPrint('Order created successfully: ${data['data']['orderId']}');
          return Order.fromJson(data['data']);
        }
      }
      
      debugPrint('Failed to create order: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('Error creating order: $e');
      return null;
    }
  }
  
  /// Cancel an order
  Future<Order?> cancelOrder(String orderId, {String? reason}) async {
    try {
      final response = await _client.put(
        Uri.parse(ApiConfig.cancelOrderUrl(orderId)),
        headers: _getHeaders(),
        body: json.encode({
          'reason': reason ?? 'Cancelled by user',
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          debugPrint('Order cancelled successfully');
          return Order.fromJson(data['data']);
        }
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        throw Exception(data['error'] ?? 'Cannot cancel this order');
      }
      
      debugPrint('Failed to cancel order: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('Error cancelling order: $e');
      rethrow;
    }
  }
  
  /// Fetch products from backend
  Future<List<Map<String, dynamic>>> getProducts({
    String? category,
    bool activeOnly = true,
    bool featuredOnly = false,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (category != null) queryParams['category'] = category;
      if (activeOnly) queryParams['active'] = 'true';
      if (featuredOnly) queryParams['featured'] = 'true';
      
      final uri = Uri.parse(ApiConfig.productsUrl).replace(queryParameters: queryParams);
      
      final response = await _client.get(
        uri,
        headers: _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      
      debugPrint('Failed to fetch products: ${response.statusCode}');
      return [];
    } catch (e) {
      debugPrint('Error fetching products: $e');
      return [];
    }
  }
  
  /// Dispose client
  void dispose() {
    _client.close();
  }
}

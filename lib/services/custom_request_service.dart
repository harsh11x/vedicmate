import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/config/env.dart';

class CustomRequestService {
  static String get _baseUrl => EnvConfig.apiBaseUrl;

  // Create TBD custom request (no payment - price discussed after contact)
  static Future<Map<String, dynamic>> createTbdRequest({
    required String userId,
    required String userName,
    required String userEmail,
    required String userPhone,
    required String serviceType,
    required String date,
    required String timeSlot,
    required String requirements,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/custom-requests/create-tbd'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'userName': userName,
          'userEmail': userEmail,
          'userPhone': userPhone,
          'serviceType': serviceType,
          'date': date,
          'timeSlot': timeSlot,
          'requirements': requirements,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to submit: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Create custom request order (with payment)
  static Future<Map<String, dynamic>> createOrder({
    required String userId,
    required String userName,
    required String userEmail,
    required String userPhone,
    required String serviceType,
    required String date,
    required String timeSlot,
    required String requirements,
    required int amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/custom-requests/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'userName': userName,
          'userEmail': userEmail,
          'userPhone': userPhone,
          'serviceType': serviceType,
          'date': date,
          'timeSlot': timeSlot,
          'requirements': requirements,
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create order: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Verify PayU payment
  static Future<Map<String, dynamic>> verifyPayment({
    required String orderId,
    required String txnid, // PayU Transaction ID
    required String paymentMode,
    required String status,
    required String amount,
    // Add other fields as needed by your backend
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/custom-requests/verify-payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'orderId': orderId,
          'txnid': txnid,
          'paymentMode': paymentMode,
          'status': status,
          'amount': amount,
          'gateway': 'PayU',
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Payment verification failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get user orders
  static Future<List<dynamic>> getUserOrders(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/custom-requests/user/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['orders'] ?? [];
      } else {
        throw Exception('Failed to fetch orders: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

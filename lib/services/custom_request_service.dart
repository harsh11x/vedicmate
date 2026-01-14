import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomRequestService {
  static const String serverUrl = 'https://18.218.161.253:3001';

  // Create custom request order
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
        Uri.parse('$serverUrl/api/custom-requests/create'),
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

  // Verify payment
  static Future<Map<String, dynamic>> verifyPayment({
    required String orderId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/api/custom-requests/verify-payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'orderId': orderId,
          'razorpayPaymentId': razorpayPaymentId,
          'razorpayOrderId': razorpayOrderId,
          'razorpaySignature': razorpaySignature,
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
        Uri.parse('$serverUrl/api/custom-requests/user/$userId'),
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

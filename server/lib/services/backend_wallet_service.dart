// Backend Wallet Service - Connects to AWS server
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/env.dart';

class BackendWalletService {
  final String baseUrl;

  BackendWalletService({String? customUrl})
      : baseUrl = customUrl ?? EnvConfig.apiBaseUrl;

  /// Get wallet balance from backend
  Future<double> getBalance(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/wallet/balance/$userId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['balance'] as num).toDouble();
        }
      }

      throw Exception('Failed to get balance');
    } catch (e) {
      print('❌ Backend wallet balance error: $e');
      // Return 0 if backend is unavailable
      return 0.0;
    }
  }

  /// Add money to wallet
  Future<Map<String, dynamic>> addMoney(
    String userId,
    double amount, {
    String type = 'recharge',
    String description = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/wallet/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'amount': amount,
          'type': type,
          'description': description,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return {
            'success': true,
            'newBalance': (data['newBalance'] as num).toDouble(),
            'transaction': data['transaction'],
          };
        }
      }

      throw Exception('Failed to add money');
    } catch (e) {
      print('❌ Backend wallet add error: $e');
      rethrow;
    }
  }

  /// Deduct money from wallet
  Future<Map<String, dynamic>> deductMoney(
    String userId,
    double amount, {
    String type = 'service',
    String description = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/wallet/deduct'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'amount': amount,
          'type': type,
          'description': description,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return {
            'success': true,
            'newBalance': (data['newBalance'] as num).toDouble(),
            'transaction': data['transaction'],
          };
        }
      } else if (response.statusCode == 402) {
        // Insufficient balance
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Insufficient balance');
      }

      throw Exception('Failed to deduct money');
    } catch (e) {
      print('❌ Backend wallet deduct error: $e');
      rethrow;
    }
  }

  /// Get transaction history
  Future<List<dynamic>> getTransactions(String userId, {int limit = 50}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/wallet/transactions/$userId?limit=$limit'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['transactions'] as List;
        }
      }

      return [];
    } catch (e) {
      print('❌ Backend wallet transactions error: $e');
      return [];
    }
  }
}


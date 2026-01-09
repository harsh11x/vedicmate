import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_client.dart';

class ProductService {
  final ApiClient _client;

  ProductService(this._client);

  Future<List<Map<String, dynamic>>> getProducts({String? category}) async {
    try {
      final endpoint = category != null && category != 'All'
          ? '/products?category=${category.toLowerCase()}'
          : '/products';
      
      final response = await _client.get(endpoint);
      
      if (response['success'] == true) {
        return List<Map<String, dynamic>>.from(response['data']);
      } else {
        throw Exception(response['error'] ?? 'Failed to load products');
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getProductById(String id) async {
    try {
      final response = await _client.get('/products/$id');
      
      if (response['success'] == true) {
        return Map<String, dynamic>.from(response['data']);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching product details: $e');
      return null;
    }
  }
}

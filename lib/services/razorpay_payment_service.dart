import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../core/config/env.dart';

class RazorpayPaymentResult {
  final bool success;
  final String? paymentId;
  final String? orderId;
  final String? signature;
  final String? error;

  const RazorpayPaymentResult({
    required this.success,
    this.paymentId,
    this.orderId,
    this.signature,
    this.error,
  });
}

class RazorpayPaymentService {
  RazorpayPaymentService();

  Razorpay? _razorpay;
  Completer<RazorpayPaymentResult>? _activePayment;
  String? _activeUserId;
  double? _activeAmount;
  String? _activePurpose;

  void initialize() {
    if (_razorpay != null) return;
    _razorpay = Razorpay()
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError)
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void dispose() {
    _razorpay?.clear();
    _razorpay = null;
  }

  Future<RazorpayPaymentResult> pay({
    required double amount,
    required String userId,
    required String userName,
    required String userEmail,
    required String userPhone,
    required String description,
    required String purpose,
    Map<String, dynamic>? metadata,
  }) async {
    initialize();

    if (_activePayment != null && !_activePayment!.isCompleted) {
      return const RazorpayPaymentResult(
        success: false,
        error: 'Another payment is already in progress.',
      );
    }

    final order = await _createOrder(
      amount: amount,
      userId: userId,
      purpose: purpose,
      description: description,
      metadata: metadata,
    );

    _activePayment = Completer<RazorpayPaymentResult>();
    _activeUserId = userId;
    _activeAmount = amount;
    _activePurpose = purpose;

    final options = {
      'key': order['keyId'],
      'order_id': order['orderId'],
      'amount': order['amount'],
      'currency': order['currency'] ?? 'INR',
      'name': 'VedicMate',
      'description': description,
      'prefill': {
        'name': userName,
        'email': userEmail,
        'contact': userPhone,
      },
      'notes': {
        'userId': userId,
        'purpose': purpose,
        ...?metadata,
      },
      'theme': {'color': '#FC6A03'},
    };

    try {
      _razorpay!.open(options);
    } catch (e) {
      _complete(
        RazorpayPaymentResult(success: false, error: e.toString()),
      );
    }

    return _activePayment!.future;
  }

  Future<RazorpayPaymentResult> payExistingOrder({
    required String keyId,
    required String orderId,
    required double amount,
    required String userId,
    required String userName,
    required String userEmail,
    required String userPhone,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    initialize();

    if (_activePayment != null && !_activePayment!.isCompleted) {
      return const RazorpayPaymentResult(
        success: false,
        error: 'Another payment is already in progress.',
      );
    }

    _activePayment = Completer<RazorpayPaymentResult>();

    final options = {
      'key': keyId,
      'order_id': orderId,
      'amount': (amount * 100).round(),
      'currency': 'INR',
      'name': 'VedicMate',
      'description': description,
      'prefill': {
        'name': userName,
        'email': userEmail,
        'contact': userPhone,
      },
      'notes': {
        'userId': userId,
        ...?metadata,
      },
      'theme': {'color': '#FC6A03'},
    };

    try {
      _razorpay!.open(options);
    } catch (e) {
      _complete(
        RazorpayPaymentResult(success: false, error: e.toString()),
      );
    }

    return _activePayment!.future;
  }

  Future<Map<String, dynamic>> _createOrder({
    required double amount,
    required String userId,
    required String purpose,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await http.post(
      Uri.parse('${EnvConfig.apiBaseUrl}/api/payment/create-order'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount': amount,
        'currency': 'INR',
        'receipt': '${purpose}_${DateTime.now().millisecondsSinceEpoch}',
        'userId': userId,
        'purpose': purpose,
        'description': description,
        'metadata': metadata ?? {},
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['error'] ?? 'Failed to create Razorpay order');
    }

    final order = body['order'] as Map<String, dynamic>;
    return {
      'keyId': body['keyId'],
      'orderId': order['id'],
      'amount': order['amount'],
      'currency': order['currency'],
    };
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_activePurpose == null) {
      _complete(
        RazorpayPaymentResult(
          success: true,
          paymentId: response.paymentId,
          orderId: response.orderId,
          signature: response.signature,
        ),
      );
      return;
    }

    try {
      final verifyResponse = await http.post(
        Uri.parse('${EnvConfig.apiBaseUrl}/api/payment/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'razorpay_order_id': response.orderId,
          'razorpay_payment_id': response.paymentId,
          'razorpay_signature': response.signature,
          'userId': _activeUserId,
          'amount': _activeAmount,
          'purpose': _activePurpose,
        }),
      );

      final body = jsonDecode(verifyResponse.body) as Map<String, dynamic>;
      if (verifyResponse.statusCode != 200 || body['success'] != true) {
        _complete(
          RazorpayPaymentResult(
            success: false,
            paymentId: response.paymentId,
            orderId: response.orderId,
            signature: response.signature,
            error: body['error'] ?? 'Payment verification failed',
          ),
        );
        return;
      }

      _complete(
        RazorpayPaymentResult(
          success: true,
          paymentId: response.paymentId,
          orderId: response.orderId,
          signature: response.signature,
        ),
      );
    } catch (e) {
      _complete(
        RazorpayPaymentResult(
          success: false,
          paymentId: response.paymentId,
          orderId: response.orderId,
          signature: response.signature,
          error: e.toString(),
        ),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _complete(
      RazorpayPaymentResult(
        success: false,
        error: response.message ?? 'Payment failed',
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('Razorpay external wallet selected: ${response.walletName}');
  }

  void _complete(RazorpayPaymentResult result) {
    final completer = _activePayment;
    if (completer != null && !completer.isCompleted) {
      completer.complete(result);
    }
    _activePayment = null;
    _activeUserId = null;
    _activeAmount = null;
    _activePurpose = null;
  }
}

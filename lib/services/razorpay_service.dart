import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';
import 'wallet_service.dart';

class RazorpayService {
  late Razorpay _razorpay;
  final WalletService _walletService = WalletService();
  
  // Razorpay Test Credentials
  static const String _razorpayKeyId = 'rzp_test_RgI11B14JouAQQ';
  static const String _razorpayKeySecret = 'g1xgpVfDcSrHnJsKT2J1u1O1';

  void initialize({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onFailure,
    required Function(ExternalWalletResponse) onExternalWallet,
  }) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onFailure);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
  }

  void dispose() {
    _razorpay.clear();
  }

  Future<void> openCheckout({
    required double amount,
    required String userId,
    required String userName,
    required String userEmail,
    required String userPhone,
  }) async {
    var options = {
      'key': _razorpayKeyId,
      'amount': (amount * 100).toInt(), // Amount in paise
      'name': 'Vedic Mate',
      'description': 'Add money to wallet',
      'prefill': {
        'contact': userPhone,
        'email': userEmail,
        'name': userName,
      },
      'theme': {
        'color': '#FF6B35', // AppTheme.primaryOrange
      },
      'modal': {
        'ondismiss': () {
          print('Razorpay checkout dismissed');
        }
      },
      'notes': {
        'user_id': userId,
        'purpose': 'wallet_recharge',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error opening Razorpay: $e');
    }
  }

  Future<bool> handlePaymentSuccess(
    PaymentSuccessResponse response,
    String userId,
    double amount,
  ) async {
    try {
      // Add money to wallet
      final success = await _walletService.addMoney(
        userId,
        amount,
        response.paymentId ?? '',
      );

      if (success) {
        print('Payment successful: ${response.paymentId}');
        print('Amount: ₹$amount added to wallet');
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error handling payment success: $e');
      return false;
    }
  }
}

// Custom Request Payment Methods
extension CustomRequestPayment on RazorpayService {
  Future<void> openCustomRequestCheckout({
    required String razorpayKeyId,
    required String razorpayOrderId,
    required int amount,
    required String userName,
    required String userEmail,
    required String userPhone,
    required String serviceType,
  }) async {
    var options = {
      'key': razorpayKeyId,
      'amount': amount * 100, // Amount in paise
      'currency': 'INR',
      'name': 'VedicMate',
      'description': 'Custom Request - $serviceType',
      'order_id': razorpayOrderId,
      'prefill': {
        'contact': userPhone,
        'email': userEmail,
        'name': userName,
      },
      'theme': {
        'color': '#FF6B35',
      },
      'modal': {
        'ondismiss': () {
          debugPrint('Payment cancelled by user');
        }
      },
      'notes': {
        'service_type': serviceType,
        'purpose': 'custom_request',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error opening Razorpay: $e');
    }
  }
}

// Payment amounts preset
class PaymentPresets {
  static const List<int> amounts = [
    100,
    200,
    500,
    1000,
    2000,
    5000,
  ];

  static String getAmountLabel(int amount) {
    return '₹$amount';
  }

  static String getAmountWithBonus(int amount) {
    if (amount >= 1000) {
      final bonus = (amount * 0.05).toInt(); // 5% bonus
      return '₹$amount + ₹$bonus bonus';
    }
    return '₹$amount';
  }
}

import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';
import 'wallet_service.dart';

class RazorpayService {
  late Razorpay _razorpay;
  final WalletService _walletService = WalletService();
  
  static const String _razorpayKeyId = String.fromEnvironment(
    'RAZORPAY_KEY_ID',
    defaultValue: '',
  );

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

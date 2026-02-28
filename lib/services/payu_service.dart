import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:payu_checkoutpro_flutter/PayUConstantKeys.dart';
import 'package:payu_checkoutpro_flutter/payu_checkoutpro_flutter.dart';
import '../core/config/env.dart';

class PayUService implements PayUCheckoutProProtocol {
  static final PayUService _instance = PayUService._internal();
  factory PayUService() => _instance;
  
  late PayUCheckoutProFlutter _payUCheckoutProFlutter;
  
  // Callbacks
  Function(Map<String, dynamic>)? _onPaymentSuccess;
  Function(Map<String, dynamic>)? _onPaymentFailure;
  Function(Map<String, dynamic>)? _onPaymentCancel;

  PayUService._internal() {
    _payUCheckoutProFlutter = PayUCheckoutProFlutter(this);
  }

  // Credentials from EnvConfig
  static const String _merchantKey = EnvConfig.payUMerchantKey;
  static const String _merchantSalt = EnvConfig.payUMerchantSalt;
  static const bool _isProduction = EnvConfig.payUProduction;

  Future<void> openCheckout({
    required String txnid,
    required String amount,
    required String productInfo,
    required String firstName,
    required String email,
    required String phone,
    required Function(Map<String, dynamic>) onPaymentSuccess,
    required Function(Map<String, dynamic>) onPaymentFailure,
    required Function(Map<String, dynamic>) onPaymentCancel,
  }) async {
    _onPaymentSuccess = onPaymentSuccess;
    _onPaymentFailure = onPaymentFailure;
    _onPaymentCancel = onPaymentCancel;

    var payUPaymentParams = {
      PayUPaymentParamKey.key: _merchantKey,
      PayUPaymentParamKey.transactionId: txnid,
      PayUPaymentParamKey.amount: amount,
      PayUPaymentParamKey.productInfo: productInfo,
      PayUPaymentParamKey.firstName: firstName,
      PayUPaymentParamKey.email: email,
      PayUPaymentParamKey.phone: phone,
      PayUPaymentParamKey.ios_surl: "https://www.payumoney.com/mobileapp/payumoney/success.php",
      PayUPaymentParamKey.ios_furl: "https://www.payumoney.com/mobileapp/payumoney/failure.php",
      PayUPaymentParamKey.android_surl: "https://www.payumoney.com/mobileapp/payumoney/success.php",
      PayUPaymentParamKey.android_furl: "https://www.payumoney.com/mobileapp/payumoney/failure.php",
      PayUPaymentParamKey.environment: _isProduction ? "0" : "1", // 0 for Prod, 1 for Test (Verify this mapping for 1.4.0)
      PayUPaymentParamKey.userCredential: "$_merchantKey:$email", // Common format, might need adjustment
      PayUPaymentParamKey.additionalParam: {
        PayUAdditionalParamKeys.udf1: "udf1",
        PayUAdditionalParamKeys.udf2: "udf2",
        PayUAdditionalParamKeys.udf3: "udf3",
        PayUAdditionalParamKeys.udf4: "udf4",
        PayUAdditionalParamKeys.udf5: "udf5",
      },
    };

    var payUCheckoutProConfig = {
      PayUCheckoutProConfigKeys.primaryColor: "#fc6a03",
      PayUCheckoutProConfigKeys.secondaryColor: "#ffffff",
      PayUCheckoutProConfigKeys.merchantName: "Vedic Mate",
      PayUCheckoutProConfigKeys.merchantLogo: "logo",
      PayUCheckoutProConfigKeys.showExitConfirmationOnCheckoutScreen: true,
      PayUCheckoutProConfigKeys.showExitConfirmationOnPaymentScreen: true,
      PayUCheckoutProConfigKeys.showExitConfirmationOnCheckoutScreen: true,
    };

    try {
      _payUCheckoutProFlutter.openCheckoutScreen(
        payUPaymentParams: payUPaymentParams,
        payUCheckoutProConfig: payUCheckoutProConfig,
      );
    } catch (e) {
      debugPrint("PayU Checkout Error: $e");
      onPaymentFailure({"error": e.toString()});
    }
  }

  // PayUCheckoutProProtocol Implementation

  @override
  void generateHash(Map response) {
    // response contains hashName, hashString
    // We need to calculate hash and send back
    // Map response = {hashName: "payment_hash", hashString: "key|txnid|amount|..."}
    
    try {
      String hashName = response[PayUHashConstantsKeys.hashName] ?? "";
      String hashString = response[PayUHashConstantsKeys.hashString] ?? "";
      
      if (hashName.isNotEmpty && hashString.isNotEmpty) {
        // For V1 hash, logic is usually hashString + salt
        // But SDK usually provides the string needing salt
        // Let's assume hashString just needs salt appended
        
        String finalString = hashString;
        if (!hashString.contains(_merchantSalt)) {
             finalString = "$hashString$_merchantSalt";
        }
        
        var bytes = utf8.encode(finalString);
        var digest = sha512.convert(bytes);
        String calculatedHash = digest.toString();
        
        _payUCheckoutProFlutter.hashGenerated(hash: {hashName: calculatedHash});
      }
    } catch (e) {
      debugPrint("Hash Verification Error: $e");
    }
  }

  @override
  void onPaymentSuccess(dynamic response) {
    _onPaymentSuccess?.call(Map<String, dynamic>.from(response));
  }

  @override
  void onPaymentFailure(dynamic response) {
    _onPaymentFailure?.call(Map<String, dynamic>.from(response));
  }

  @override
  void onPaymentCancel(Map? response) {
    _onPaymentCancel?.call(Map<String, dynamic>.from(response ?? {}));
  }

  @override
  void onError(Map? response) {
    _onPaymentFailure?.call(Map<String, dynamic>.from(response ?? {'error': 'Unknown Error'}));
  }
}

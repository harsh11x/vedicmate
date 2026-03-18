import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// In-App Purchase service for wallet credits.
/// Configure product IDs in App Store Connect (iOS) and Play Console (Android).
class IAPService {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  static const Set<String> _productIds = {
    'wallet_50', 'wallet_100', 'wallet_200', 'wallet_500',
    'wallet_1000', 'wallet_2000', 'wallet_5000',
  };

  Future<void> init() async {
    if (!await _iap.isAvailable()) return;

    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (e) => debugPrint('IAP purchase stream error: $e'),
    );
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) continue;
      if (purchase.status == PurchaseStatus.error) {
        debugPrint('Purchase error: ${purchase.error}');
        continue;
      }
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        _handlePurchase(purchase);
      }
      if (purchase.pendingCompletePurchase) {
        InAppPurchase.instance.completePurchase(purchase);
      }
    }
  }

  void _handlePurchase(PurchaseDetails purchase) {
    // Callback to backend to credit wallet - integrate with your server
    debugPrint('Purchase completed: ${purchase.productID}');
  }

  /// Restore previous purchases. Call when user taps "Restore Purchases".
  Future<RestoreResult> restorePurchases() async {
    try {
      if (!await _iap.isAvailable()) {
        return RestoreResult(restored: false, message: 'Store not available');
      }
      await _iap.restorePurchases();
      return RestoreResult(
        restored: true,
        message: 'Restore completed. If you had previous wallet purchases, your balance will be updated shortly.',
      );
    } catch (e) {
      debugPrint('Restore error: $e');
      return RestoreResult(restored: false, message: 'Restore failed: ${e.toString()}');
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}

class RestoreResult {
  final bool restored;
  final String message;

  RestoreResult({required this.restored, required this.message});
}

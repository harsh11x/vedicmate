import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to check if user has "Vedic Mate Pro" access
/// 
/// Returns true if user has an active Pro subscription
final hasProAccessProvider = FutureProvider<bool>((ref) async {
  // TODO: Implement actual pro check via your backend or PayU subscription status
  return false;
});

/// Enum for subscription status
enum SubscriptionStatus {
  active,
  expired,
  trial,
  none,
}

/// Provider for subscription status
final subscriptionStatusProvider = FutureProvider<SubscriptionStatus>((ref) async {
  // TODO: Implement actual status check
  return SubscriptionStatus.none;
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/revenuecat_service.dart';

/// Provider for RevenueCat service instance
final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService();
});

/// Stream provider for customer info updates
/// 
/// Automatically updates when customer makes a purchase, restores purchases,
/// or subscription status changes
final customerInfoStreamProvider = StreamProvider<CustomerInfo>((ref) {
  final service = ref.watch(revenueCatServiceProvider);
  return service.customerInfoStream;
});

/// Provider for current customer info
/// 
/// Fetches the latest customer info from RevenueCat
final customerInfoProvider = FutureProvider<CustomerInfo>((ref) async {
  final service = ref.watch(revenueCatServiceProvider);
  return await service.getCustomerInfo();
});

/// Provider to check if user has "Vedic Mate Pro" access
/// 
/// Returns true if user has an active Pro subscription
final hasProAccessProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(revenueCatServiceProvider);
  return await service.hasProAccess();
});

/// Provider for active subscriptions
/// 
/// Returns a map of active entitlements
final activeSubscriptionsProvider = FutureProvider<Map<String, EntitlementInfo>>((ref) async {
  final customerInfo = await ref.watch(customerInfoProvider.future);
  return customerInfo.entitlements.active;
});

/// Enum for subscription status
enum SubscriptionStatus {
  active,
  expired,
  trial,
  none,
}

/// Provider for subscription status
/// 
/// Determines the current subscription state based on entitlements
final subscriptionStatusProvider = FutureProvider<SubscriptionStatus>((ref) async {
  final customerInfo = await ref.watch(customerInfoProvider.future);
  final proEntitlement = customerInfo.entitlements.active[RevenueCatService.proEntitlementId];
  
  if (proEntitlement == null) {
    // Check if there was a previous subscription that expired
    final allEntitlements = customerInfo.entitlements.all;
    if (allEntitlements.containsKey(RevenueCatService.proEntitlementId)) {
      return SubscriptionStatus.expired;
    }
    return SubscriptionStatus.none;
  }
  
  // Check if in trial period
  if (proEntitlement.periodType == PeriodType.trial) {
    return SubscriptionStatus.trial;
  }
  
  return SubscriptionStatus.active;
});

/// Provider for available offerings
/// 
/// Fetches all available subscription packages from RevenueCat
final offeringsProvider = FutureProvider<Offerings?>((ref) async {
  final service = ref.watch(revenueCatServiceProvider);
  return await service.getOfferings();
});

/// Provider for current offering
/// 
/// Returns the default/current offering configured in RevenueCat dashboard
final currentOfferingProvider = FutureProvider<Offering?>((ref) async {
  final offerings = await ref.watch(offeringsProvider.future);
  return offerings?.current;
});

/// Provider for available packages in current offering
/// 
/// Returns list of purchasable packages
final availablePackagesProvider = FutureProvider<List<Package>>((ref) async {
  final offering = await ref.watch(currentOfferingProvider.future);
  return offering?.availablePackages ?? [];
});

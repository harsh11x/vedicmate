// RevenueCat Integration - Quick Start Examples
// Copy these examples into your code to implement subscription features

// ============================================================================
// Example 1: Check if user has Pro access
// ============================================================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vedicmate/providers/subscription_provider.dart';

class MyPremiumFeature extends ConsumerWidget {
  const MyPremiumFeature({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasProAccess = ref.watch(hasProAccessProvider);

    return hasProAccess.when(
      data: (hasPro) {
        if (hasPro) {
          return const Text('Welcome, Pro User! 🎉');
        } else {
          return ElevatedButton(
            onPressed: () => context.push('/subscription/paywall'),
            child: const Text('Upgrade to Pro'),
          );
        }
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, _) => Text('Error: $error'),
    );
  }
}

// ============================================================================
// Example 2: Gate a premium feature with automatic paywall
// ============================================================================
import 'package:vedicmate/widgets/pro_feature_gate.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProFeatureGate(
      child: Scaffold(
        appBar: AppBar(title: const Text('Premium Feature')),
        body: const Center(
          child: Text('This is premium content!'),
        ),
      ),
      onPaywallDismissed: () {
        // User dismissed paywall without purchasing
        Navigator.of(context).pop();
      },
    );
  }
}

// ============================================================================
// Example 3: Show paywall manually
// ============================================================================
import 'package:vedicmate/services/revenuecat_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

Future<void> showSubscriptionPaywall(BuildContext context) async {
  final service = RevenueCatService();
  final result = await service.showPaywall();

  switch (result) {
    case PaywallResult.purchased:
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Welcome to Pro!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      break;
    case PaywallResult.restored:
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Purchases restored!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      break;
    case PaywallResult.cancelled:
      // User dismissed
      break;
    case PaywallResult.error:
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading paywall'),
            backgroundColor: Colors.red,
          ),
        );
      }
      break;
  }
}

// ============================================================================
// Example 4: Get customer subscription info
// ============================================================================
class SubscriptionInfoWidget extends ConsumerWidget {
  const SubscriptionInfoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerInfo = ref.watch(customerInfoProvider);

    return customerInfo.when(
      data: (info) {
        final activeEntitlements = info.entitlements.active;
        final hasPro = activeEntitlements.containsKey('Vedic Mate Pro');

        return Column(
          children: [
            Text('Status: ${hasPro ? 'Pro' : 'Free'}'),
            if (hasPro) ...[
              const SizedBox(height: 8),
              Text('Active since: ${info.originalPurchaseDate ?? 'N/A'}'),
            ],
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, _) => Text('Error: $error'),
    );
  }
}

// ============================================================================
// Example 5: Add Pro badge to feature
// ============================================================================
import 'package:vedicmate/widgets/pro_feature_gate.dart';

class FeatureCard extends StatelessWidget {
  final String title;
  final bool isPremium;

  const FeatureCard({
    super.key,
    required this.title,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Row(
          children: [
            Text(title),
            if (isPremium) ...[
              const SizedBox(width: 8),
              const ProBadge(size: 12),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Example 6: Pro feature button with automatic paywall
// ============================================================================
class MyScreen extends ConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Features')),
      body: Center(
        child: ProFeatureButton(
          label: 'Advanced Analysis',
          icon: Icons.analytics,
          showBadge: true,
          onPressed: () {
            // This only runs if user has Pro access
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdvancedAnalysisScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================================
// Example 7: Restore purchases
// ============================================================================
Future<void> restorePurchases(BuildContext context, WidgetRef ref) async {
  try {
    final service = RevenueCatService();
    await service.restorePurchases();

    // Refresh subscription state
    ref.invalidate(customerInfoProvider);
    ref.invalidate(hasProAccessProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Purchases restored!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to restore: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// ============================================================================
// Example 8: Navigate to Customer Center
// ============================================================================
void openCustomerCenter(BuildContext context) {
  context.push('/subscription/customer-center');
}

// ============================================================================
// Example 9: Check subscription status
// ============================================================================
class SubscriptionStatusBanner extends ConsumerWidget {
  const SubscriptionStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(subscriptionStatusProvider);

    return status.when(
      data: (subscriptionStatus) {
        switch (subscriptionStatus) {
          case SubscriptionStatus.active:
            return Container(
              padding: const EdgeInsets.all(12),
              color: Colors.green,
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Pro Active',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          case SubscriptionStatus.trial:
            return Container(
              padding: const EdgeInsets.all(12),
              color: Colors.orange,
              child: const Row(
                children: [
                  Icon(Icons.access_time, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Free Trial',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          case SubscriptionStatus.expired:
            return Container(
              padding: const EdgeInsets.all(12),
              color: Colors.red,
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Subscription Expired',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/subscription/paywall'),
                    child: const Text(
                      'Renew',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          case SubscriptionStatus.none:
            return const SizedBox.shrink();
        }
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

// ============================================================================
// Example 10: Identify user after login
// ============================================================================
import 'package:firebase_auth/firebase_auth.dart';

Future<void> onUserLogin(User user) async {
  final service = RevenueCatService();
  await service.identifyUser(user.uid);
  
  // Now RevenueCat knows this user and will sync subscriptions
  // across devices
}

// ============================================================================
// Example 11: Logout user from RevenueCat
// ============================================================================
Future<void> onUserLogout() async {
  final service = RevenueCatService();
  await service.logoutUser();
  
  // This resets RevenueCat to anonymous user
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/revenuecat_service.dart';
import '../../providers/subscription_provider.dart';

/// Customer Center Screen
/// 
/// Displays RevenueCat's native Customer Center UI for subscription management.
/// Users can view their subscription, manage billing, and contact support.
class CustomerCenterScreen extends ConsumerStatefulWidget {
  const CustomerCenterScreen({super.key});

  @override
  ConsumerState<CustomerCenterScreen> createState() => _CustomerCenterScreenState();
}

class _CustomerCenterScreenState extends ConsumerState<CustomerCenterScreen> {
  @override
  void initState() {
    super.initState();
    _showCustomerCenter();
  }

  Future<void> _showCustomerCenter() async {
    try {
      final service = ref.read(revenueCatServiceProvider);
      await service.showCustomerCenter();
      
      // Refresh subscription state after customer center is dismissed
      if (mounted) {
        ref.invalidate(customerInfoProvider);
        ref.invalidate(hasProAccessProvider);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load Customer Center: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while Customer Center is being presented
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// Alternative custom Customer Center implementation
/// 
/// Use this if you want more control over the subscription management UI
class CustomCustomerCenterScreen extends ConsumerWidget {
  const CustomCustomerCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerInfoAsync = ref.watch(customerInfoProvider);
    final subscriptionStatus = ref.watch(subscriptionStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Subscription'),
      ),
      body: customerInfoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(customerInfoProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (customerInfo) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Subscription Status Card
                _buildStatusCard(context, ref, customerInfo, subscriptionStatus),
                const SizedBox(height: 24),

                // Active Subscriptions
                if (customerInfo.entitlements.active.isNotEmpty) ...[
                  const Text(
                    'Active Subscriptions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...customerInfo.entitlements.active.values.map((entitlement) {
                    return _buildEntitlementCard(entitlement);
                  }),
                  const SizedBox(height: 24),
                ],

                // Actions
                _buildActionButton(
                  context,
                  icon: Icons.restore,
                  label: 'Restore Purchases',
                  onPressed: () => _handleRestore(context, ref),
                ),
                const SizedBox(height: 12),
                
                if (customerInfo.entitlements.active.isEmpty)
                  _buildActionButton(
                    context,
                    icon: Icons.shopping_cart,
                    label: 'Subscribe to Pro',
                    onPressed: () => _navigateToPaywall(context),
                    isPrimary: true,
                  ),
                
                const SizedBox(height: 24),

                // Account Info
                _buildAccountInfo(customerInfo),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    WidgetRef ref,
    customerInfo,
    AsyncValue<SubscriptionStatus> subscriptionStatus,
  ) {
    return subscriptionStatus.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (status) {
        IconData icon;
        Color color;
        String title;
        String subtitle;

        switch (status) {
          case SubscriptionStatus.active:
            icon = Icons.check_circle;
            color = Colors.green;
            title = 'Vedic Mate Pro';
            subtitle = 'Your subscription is active';
            break;
          case SubscriptionStatus.trial:
            icon = Icons.access_time;
            color = Colors.orange;
            title = 'Free Trial';
            subtitle = 'Enjoying your trial period';
            break;
          case SubscriptionStatus.expired:
            icon = Icons.error_outline;
            color = Colors.red;
            title = 'Subscription Expired';
            subtitle = 'Renew to continue enjoying Pro features';
            break;
          case SubscriptionStatus.none:
            icon = Icons.info_outline;
            color = Colors.grey;
            title = 'Free Plan';
            subtitle = 'Upgrade to unlock premium features';
            break;
        }

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(icon, size: 48, color: color),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEntitlementCard(entitlement) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entitlement.identifier,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (entitlement.expirationDate != null) ...[
              const SizedBox(height: 8),
              Text(
                'Expires: ${_formatDate(entitlement.expirationDate!)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
            if (entitlement.willRenew) ...[
              const SizedBox(height: 4),
              const Text(
                'Will renew automatically',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: isPrimary ? Colors.orange : null,
        foregroundColor: isPrimary ? Colors.white : null,
      ),
    );
  }

  Widget _buildAccountInfo(customerInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoRow('User ID', customerInfo.originalAppUserId),
        if (customerInfo.originalPurchaseDate != null)
          _buildInfoRow(
            'Customer Since',
            _formatDate(customerInfo.originalPurchaseDate!),
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _handleRestore(BuildContext context, WidgetRef ref) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final service = ref.read(revenueCatServiceProvider);
      await service.restorePurchases();
      
      // Refresh subscription state
      ref.invalidate(customerInfoProvider);
      ref.invalidate(hasProAccessProvider);
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Purchases restored successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToPaywall(BuildContext context) {
    Navigator.of(context).pushNamed('/subscription/paywall');
  }
}

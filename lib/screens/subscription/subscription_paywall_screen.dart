import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import '../../services/revenuecat_service.dart';
import '../../providers/subscription_provider.dart';

/// Subscription Paywall Screen
/// 
/// Displays RevenueCat's native paywall UI with available subscription packages.
/// Users can purchase subscriptions, restore purchases, or dismiss the paywall.
class SubscriptionPaywallScreen extends ConsumerStatefulWidget {
  const SubscriptionPaywallScreen({super.key});

  @override
  ConsumerState<SubscriptionPaywallScreen> createState() => _SubscriptionPaywallScreenState();
}

class _SubscriptionPaywallScreenState extends ConsumerState<SubscriptionPaywallScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _showPaywall();
  }

  Future<void> _showPaywall() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = ref.read(revenueCatServiceProvider);
      final result = await service.showPaywall();
      
      if (mounted) {
        // Handle paywall result
        if (result == PaywallResult.purchased) {
          // User made a purchase
          _handlePurchaseSuccess();
        } else if (result == PaywallResult.restored) {
          // User restored purchases
          _handleRestoreSuccess();
        } else if (result == PaywallResult.cancelled) {
          // User dismissed paywall
          Navigator.of(context).pop(false);
        } else if (result == PaywallResult.error) {
          // Error occurred
          setState(() {
            _errorMessage = 'An error occurred. Please try again.';
            _isLoading = false;
          });
        } else {
          Navigator.of(context).pop(false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load paywall: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _handlePurchaseSuccess() {
    // Refresh subscription state
    ref.invalidate(customerInfoProvider);
    ref.invalidate(hasProAccessProvider);
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Welcome to Vedic Mate Pro!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
    
    // Close paywall
    Navigator.of(context).pop(true);
  }

  void _handleRestoreSuccess() {
    // Refresh subscription state
    ref.invalidate(customerInfoProvider);
    ref.invalidate(hasProAccessProvider);
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Purchases restored successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
    
    // Close paywall
    Navigator.of(context).pop(true);
  }

  Future<void> _retryPaywall() async {
    await _showPaywall();
  }

  @override
  Widget build(BuildContext context) {
    // If error occurred, show error screen with retry option
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Subscription'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Oops!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _retryPaywall,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show loading indicator while paywall is being presented
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// Alternative custom paywall implementation
/// 
/// Use this if you want more control over the paywall UI
class CustomSubscriptionPaywallScreen extends ConsumerStatefulWidget {
  const CustomSubscriptionPaywallScreen({super.key});

  @override
  ConsumerState<CustomSubscriptionPaywallScreen> createState() => _CustomSubscriptionPaywallScreenState();
}

class _CustomSubscriptionPaywallScreenState extends ConsumerState<CustomSubscriptionPaywallScreen> {
  bool _isLoading = false;
  Package? _selectedPackage;

  @override
  Widget build(BuildContext context) {
    final offeringsAsync = ref.watch(offeringsProvider);
    final hasProAccess = ref.watch(hasProAccessProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade to Pro'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: offeringsAsync.when(
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
                onPressed: () => ref.invalidate(offeringsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (offerings) {
          final currentOffering = offerings?.current;
          
          if (currentOffering == null || currentOffering.availablePackages.isEmpty) {
            return const Center(
              child: Text('No subscription packages available'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const Icon(
                  Icons.auto_awesome,
                  size: 80,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Vedic Mate Pro',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Unlock premium features and elevate your spiritual journey',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),

                // Features
                _buildFeatureItem(Icons.chat, 'Unlimited AI Pandit consultations'),
                _buildFeatureItem(Icons.stars, 'Advanced horoscope readings'),
                _buildFeatureItem(Icons.favorite, 'Premium Kundli matching'),
                _buildFeatureItem(Icons.block, 'Ad-free experience'),
                _buildFeatureItem(Icons.support_agent, 'Priority support'),
                const SizedBox(height: 32),

                // Packages
                ...currentOffering.availablePackages.map((package) {
                  return _buildPackageCard(package);
                }),
                const SizedBox(height: 24),

                // Purchase button
                ElevatedButton(
                  onPressed: _isLoading || _selectedPackage == null
                      ? null
                      : _handlePurchase,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Subscribe Now',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 16),

                // Restore purchases
                TextButton(
                  onPressed: _isLoading ? null : _handleRestore,
                  child: const Text('Restore Purchases'),
                ),
                const SizedBox(height: 8),

                // Terms
                Text(
                  'Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(Package package) {
    final isSelected = _selectedPackage?.identifier == package.identifier;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedPackage = package),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.orange.withOpacity(0.1) : null,
        ),
        child: Row(
          children: [
            Radio<Package>(
              value: package,
              groupValue: _selectedPackage,
              onChanged: (value) => setState(() => _selectedPackage = value),
              activeColor: Colors.orange,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.storeProduct.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    package.storeProduct.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              package.storeProduct.priceString,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePurchase() async {
    if (_selectedPackage == null) return;

    setState(() => _isLoading = true);

    try {
      final service = ref.read(revenueCatServiceProvider);
      await service.purchasePackage(_selectedPackage!);
      
      if (mounted) {
        // Refresh subscription state
        ref.invalidate(customerInfoProvider);
        ref.invalidate(hasProAccessProvider);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Welcome to Vedic Mate Pro!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Close paywall
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleRestore() async {
    setState(() => _isLoading = true);

    try {
      final service = ref.read(revenueCatServiceProvider);
      await service.restorePurchases();
      
      if (mounted) {
        // Refresh subscription state
        ref.invalidate(customerInfoProvider);
        ref.invalidate(hasProAccessProvider);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Purchases restored successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

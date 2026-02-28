import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Subscription Paywall Screen Placeholder
class SubscriptionPaywallScreen extends ConsumerWidget {
  const SubscriptionPaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'Subscriptions are currently unavailable.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('We are upgrading our payment system.'),
          ],
        ),
      ),
    );
  }
}

/// Alternative custom paywall implementation placeholder
class CustomSubscriptionPaywallScreen extends ConsumerWidget {
  const CustomSubscriptionPaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SubscriptionPaywallScreen();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Customer Center Screen Placeholder
class CustomerCenterScreen extends ConsumerWidget {
  const CustomerCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Subscription')),
      body: const Center(
        child: Text('Subscription management is currently unavailable.'),
      ),
    );
  }
}

/// Alternative custom Customer Center implementation placeholder
class CustomCustomerCenterScreen extends ConsumerWidget {
  const CustomCustomerCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const CustomerCenterScreen();
  }
}

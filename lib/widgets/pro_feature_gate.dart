import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/subscription_provider.dart';
import '../screens/subscription/subscription_paywall_screen.dart';

/// Pro Feature Gate Widget
/// 
/// Wraps premium features and automatically shows paywall if user doesn't have Pro access.
/// Use this widget to gate any premium content in your app.
/// 
/// Example:
/// ```dart
/// ProFeatureGate(
///   child: PremiumFeatureScreen(),
///   onPaywallDismissed: () => Navigator.pop(context),
/// )
/// ```
class ProFeatureGate extends ConsumerWidget {
  /// The premium content to display if user has Pro access
  final Widget child;
  
  /// Optional callback when paywall is dismissed without purchase
  final VoidCallback? onPaywallDismissed;
  
  /// Optional custom loading widget
  final Widget? loadingWidget;
  
  /// Optional custom error widget builder
  final Widget Function(Object error)? errorBuilder;

  const ProFeatureGate({
    super.key,
    required this.child,
    this.onPaywallDismissed,
    this.loadingWidget,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasProAccessAsync = ref.watch(hasProAccessProvider);

    return hasProAccessAsync.when(
      loading: () => loadingWidget ?? const _DefaultLoadingWidget(),
      error: (error, stack) {
        if (errorBuilder != null) {
          return errorBuilder!(error);
        }
        return _DefaultErrorWidget(
          error: error,
          onRetry: () => ref.invalidate(hasProAccessProvider),
        );
      },
      data: (hasProAccess) {
        if (hasProAccess) {
          // User has Pro access, show the premium content
          return child;
        } else {
          // User doesn't have Pro access, show paywall
          return _PaywallGate(
            onDismissed: onPaywallDismissed,
          );
        }
      },
    );
  }
}

/// Internal widget that shows the paywall
class _PaywallGate extends StatefulWidget {
  final VoidCallback? onDismissed;

  const _PaywallGate({this.onDismissed});

  @override
  State<_PaywallGate> createState() => _PaywallGateState();
}

class _PaywallGateState extends State<_PaywallGate> {
  @override
  void initState() {
    super.initState();
    // Show paywall immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPaywall();
    });
  }

  Future<void> _showPaywall() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const SubscriptionPaywallScreen(),
        fullscreenDialog: true,
      ),
    );

    if (mounted && result != true) {
      // User dismissed paywall without purchasing
      widget.onDismissed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// Default loading widget
class _DefaultLoadingWidget extends StatelessWidget {
  const _DefaultLoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Checking subscription status...'),
          ],
        ),
      ),
    );
  }
}

/// Default error widget
class _DefaultErrorWidget extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _DefaultErrorWidget({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                'Failed to check subscription status',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple Pro Badge Widget
/// 
/// Shows a "PRO" badge that can be used in UI to indicate premium features
class ProBadge extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? textColor;

  const ProBadge({
    super.key,
    this.size = 16,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.5,
        vertical: size * 0.25,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.orange,
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Text(
        'PRO',
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: size,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Pro Feature Button
/// 
/// A button that shows a Pro badge and triggers the paywall when tapped
/// if the user doesn't have Pro access
class ProFeatureButton extends ConsumerWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool showBadge;

  const ProFeatureButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasProAccessAsync = ref.watch(hasProAccessProvider);

    return hasProAccessAsync.when(
      loading: () => ElevatedButton.icon(
        onPressed: null,
        icon: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        label: Text(label),
      ),
      error: (_, __) => ElevatedButton.icon(
        onPressed: null,
        icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
        label: Text(label),
      ),
      data: (hasProAccess) {
        return ElevatedButton.icon(
          onPressed: hasProAccess
              ? onPressed
              : () => _showPaywall(context, ref),
          icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label),
              if (showBadge && !hasProAccess) ...[
                const SizedBox(width: 8),
                const ProBadge(size: 12),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _showPaywall(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const SubscriptionPaywallScreen(),
        fullscreenDialog: true,
      ),
    );

    if (result == true) {
      // User purchased, refresh and call onPressed
      ref.invalidate(hasProAccessProvider);
      onPressed?.call();
    }
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

/// RevenueCat service for managing subscriptions and in-app purchases
/// 
/// This service provides a centralized interface for:
/// - SDK initialization and configuration
/// - User identification
/// - Subscription status and entitlement checking
/// - Purchase flows
/// - Customer info management
/// - Paywall and Customer Center presentation
class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  // API Keys
  static const String _apiKey = 'sk_CKKcFusxMhnBDBPFkIJGjaWHqJYQt';
  
  // Entitlement identifier
  static const String proEntitlementId = 'Vedic Mate Pro';
  
  bool _isInitialized = false;
  final _customerInfoController = StreamController<CustomerInfo>.broadcast();
  
  /// Stream of customer info updates
  Stream<CustomerInfo> get customerInfoStream => _customerInfoController.stream;

  /// Initialize RevenueCat SDK
  /// 
  /// Should be called during app startup, after Firebase initialization
  /// but before any purchase-related operations.
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('⚠️ RevenueCat: Already initialized');
      return;
    }

    try {
      debugPrint('🛒 RevenueCat: Initializing SDK...');
      
      // Configure SDK
      final configuration = PurchasesConfiguration(_apiKey);
      
      // Enable debug logs in debug mode
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }
      
      // Initialize
      await Purchases.configure(configuration);
      
      // Listen to customer info updates
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        debugPrint('🛒 RevenueCat: Customer info updated');
        _customerInfoController.add(customerInfo);
      });
      
      _isInitialized = true;
      debugPrint('✅ RevenueCat: Initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ RevenueCat: Initialization failed - $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Identify user with RevenueCat
  /// 
  /// Links the user's app user ID (typically Firebase UID) with RevenueCat.
  /// This enables cross-platform subscription syncing.
  /// 
  /// [userId] - Unique identifier for the user (e.g., Firebase UID)
  Future<void> identifyUser(String userId) async {
    _ensureInitialized();
    
    try {
      debugPrint('🛒 RevenueCat: Identifying user: $userId');
      await Purchases.logIn(userId);
      debugPrint('✅ RevenueCat: User identified successfully');
    } catch (e) {
      debugPrint('❌ RevenueCat: Failed to identify user - $e');
      rethrow;
    }
  }

  /// Log out the current user
  /// 
  /// Should be called when user signs out of the app
  Future<void> logoutUser() async {
    _ensureInitialized();
    
    try {
      debugPrint('🛒 RevenueCat: Logging out user');
      await Purchases.logOut();
      debugPrint('✅ RevenueCat: User logged out successfully');
    } catch (e) {
      debugPrint('❌ RevenueCat: Failed to logout user - $e');
      rethrow;
    }
  }

  /// Get current customer info
  /// 
  /// Returns the latest customer information including:
  /// - Active subscriptions
  /// - Entitlements
  /// - Purchase history
  Future<CustomerInfo> getCustomerInfo() async {
    _ensureInitialized();
    
    try {
      debugPrint('🛒 RevenueCat: Fetching customer info');
      final customerInfo = await Purchases.getCustomerInfo();
      debugPrint('✅ RevenueCat: Customer info retrieved');
      return customerInfo;
    } catch (e) {
      debugPrint('❌ RevenueCat: Failed to get customer info - $e');
      rethrow;
    }
  }

  /// Check if user has "Vedic Mate Pro" entitlement
  /// 
  /// Returns true if the user has an active subscription with the Pro entitlement
  Future<bool> hasProAccess() async {
    try {
      final customerInfo = await getCustomerInfo();
      final hasAccess = customerInfo.entitlements.active.containsKey(proEntitlementId);
      debugPrint('🛒 RevenueCat: Pro access check - $hasAccess');
      return hasAccess;
    } catch (e) {
      debugPrint('❌ RevenueCat: Failed to check Pro access - $e');
      return false;
    }
  }

  /// Get all available offerings
  /// 
  /// Offerings contain packages (products) that can be purchased
  Future<Offerings?> getOfferings() async {
    _ensureInitialized();
    
    try {
      debugPrint('🛒 RevenueCat: Fetching offerings');
      final offerings = await Purchases.getOfferings();
      
      if (offerings.current == null) {
        debugPrint('⚠️ RevenueCat: No current offering available');
      } else {
        debugPrint('✅ RevenueCat: Found ${offerings.current!.availablePackages.length} packages');
      }
      
      return offerings;
    } catch (e) {
      debugPrint('❌ RevenueCat: Failed to get offerings - $e');
      rethrow;
    }
  }

  /// Purchase a package
  /// 
  /// Initiates the purchase flow for the given package.
  /// Returns the updated customer info if successful.
  /// 
  /// Throws [PlatformException] if purchase fails or is cancelled
  Future<CustomerInfo> purchasePackage(Package package) async {
    _ensureInitialized();
    
    try {
      debugPrint('🛒 RevenueCat: Initiating purchase for ${package.identifier}');
      final purchaseResult = await Purchases.purchasePackage(package);
      debugPrint('✅ RevenueCat: Purchase successful');
      return purchaseResult.customerInfo;
    } catch (e) {
      debugPrint('❌ RevenueCat: Purchase failed - $e');
      rethrow;
    }
  }

  /// Restore previous purchases
  /// 
  /// Useful for users who reinstalled the app or switched devices
  Future<CustomerInfo> restorePurchases() async {
    _ensureInitialized();
    
    try {
      debugPrint('🛒 RevenueCat: Restoring purchases');
      final customerInfo = await Purchases.restorePurchases();
      debugPrint('✅ RevenueCat: Purchases restored');
      return customerInfo;
    } catch (e) {
      debugPrint('❌ RevenueCat: Failed to restore purchases - $e');
      rethrow;
    }
  }

  /// Get wallet credits offering
  /// 
  /// Returns the offering containing wallet credit packages
  Future<Offering?> getWalletOffering() async {
    _ensureInitialized();
    
    try {
      debugPrint('🛒 RevenueCat: Fetching wallet offering');
      final offerings = await Purchases.getOfferings();
      
      // Try to get 'wallet_credits' offering, fallback to current
      final walletOffering = offerings.all['wallet_credits'] ?? offerings.current;
      
      if (walletOffering == null) {
        debugPrint('⚠️ RevenueCat: No wallet offering available');
      } else {
        debugPrint('✅ RevenueCat: Found wallet offering with ${walletOffering.availablePackages.length} packages');
      }
      
      return walletOffering;
    } catch (e) {
      debugPrint('❌ RevenueCat: Failed to get wallet offering - $e');
      rethrow;
    }
  }

  /// Purchase wallet credits (consumable)
  /// 
  /// Initiates purchase of wallet credits. After successful purchase,
  /// the app should add the corresponding amount to the user's wallet in Supabase.
  /// 
  /// Returns the updated customer info if successful.
  Future<CustomerInfo> purchaseWalletCredit(Package package) async {
    _ensureInitialized();
    
    try {
      debugPrint('🛒 RevenueCat: Purchasing wallet credit - ${package.identifier}');
      final purchaseResult = await Purchases.purchasePackage(package);
      debugPrint('✅ RevenueCat: Wallet credit purchase successful');
      return purchaseResult.customerInfo;
    } catch (e) {
      debugPrint('❌ RevenueCat: Wallet credit purchase failed - $e');
      rethrow;
    }
  }

  /// Purchase a product (non-consumable or one-time)
  /// 
  /// Initiates purchase of a remedy product or other one-time purchase.
  /// After successful purchase, the app should create an order in Supabase.
  /// 
  /// Returns the updated customer info if successful.
  Future<CustomerInfo> purchaseProduct(Package package) async {
    _ensureInitialized();
    
    try {
      debugPrint('🛒 RevenueCat: Purchasing product - ${package.identifier}');
      final purchaseResult = await Purchases.purchasePackage(package);
      debugPrint('✅ RevenueCat: Product purchase successful');
      return purchaseResult.customerInfo;
    } catch (e) {
      debugPrint('❌ RevenueCat: Product purchase failed - $e');
      rethrow;
    }
  }

  /// Get specific offering by identifier
  /// 
  /// [offeringId] - The identifier of the offering to fetch
  Future<Offering?> getOfferingById(String offeringId) async {
    _ensureInitialized();
    
    try {
      debugPrint('🛒 RevenueCat: Fetching offering: $offeringId');
      final offerings = await Purchases.getOfferings();
      final offering = offerings.all[offeringId];
      
      if (offering == null) {
        debugPrint('⚠️ RevenueCat: Offering not found: $offeringId');
      } else {
        debugPrint('✅ RevenueCat: Found offering: $offeringId');
      }
      
      return offering;
    } catch (e) {
      debugPrint('❌ RevenueCat: Failed to get offering - $e');
      rethrow;
    }
  }

  /// Find a package by its identifier across all offerings
  /// 
  /// [packageIdentifier] - The identifier of the package to search for (e.g. 'gem_stone_ruby')
  Future<Package?> findPackage(String packageIdentifier) async {
    _ensureInitialized();
    
    try {
      debugPrint('🛒 RevenueCat: Searching for package: $packageIdentifier');
      final offerings = await Purchases.getOfferings();
      
      // search in current offering first
      if (offerings.current != null) {
        final package = offerings.current!.availablePackages
            .firstWhere((p) => p.identifier == packageIdentifier, orElse: () => null as Package); // null check workaround
            
        // ignore: unnecessary_null_comparison
        if (package != null) return package;
      }
      
      // search in all other offerings
      for (final offering in offerings.all.values) {
        try {
          final package = offering.availablePackages
              .firstWhere((p) => p.identifier == packageIdentifier);
          return package;
        } catch (_) {
          // continue searching
        }
      }
      
      debugPrint('⚠️ RevenueCat: Package not found: $packageIdentifier');
      return null;
    } catch (e) {
      debugPrint('❌ RevenueCat: Error searching for package - $e');
      return null;
    }
  }

  /// Present RevenueCat paywall
  /// 
  /// Shows the native paywall UI configured in RevenueCat dashboard.
  /// Returns a [PaywallResult] indicating the outcome.
  /// 
  /// [offering] - Optional specific offering to display. If null, uses current offering.
  Future<PaywallResult> showPaywall({Offering? offering}) async {
    _ensureInitialized();
    
    try {
      debugPrint('🛒 RevenueCat: Presenting paywall');
      
      final result = await RevenueCatUI.presentPaywall(
        offering: offering,
      );
      
      debugPrint('✅ RevenueCat: Paywall result - $result');
      return result;
    } catch (e) {
      debugPrint('❌ RevenueCat: Failed to show paywall - $e');
      rethrow;
    }
  }

  /// Present RevenueCat paywall if needed
  /// 
  /// Automatically shows paywall only if user doesn't have the specified entitlement.
  /// 
  /// [requiredEntitlementIdentifier] - Entitlement to check (defaults to Pro)
  Future<PaywallResult> showPaywallIfNeeded({
    String? requiredEntitlementIdentifier,
  }) async {
    _ensureInitialized();
    
    try {
      debugPrint('🛒 RevenueCat: Checking if paywall needed');
      
      final result = await RevenueCatUI.presentPaywallIfNeeded(
        requiredEntitlementIdentifier ?? proEntitlementId,
      );
      
      debugPrint('✅ RevenueCat: Paywall if needed result - $result');
      return result;
    } catch (e) {
      debugPrint('❌ RevenueCat: Failed to show paywall if needed - $e');
      rethrow;
    }
  }

  /// Present Customer Center
  /// 
  /// Shows the native Customer Center UI for subscription management.
  /// Users can view their subscription, manage billing, and contact support.
  Future<void> showCustomerCenter() async {
    _ensureInitialized();
    
    try {
      debugPrint('🛒 RevenueCat: Presenting Customer Center');
      await RevenueCatUI.presentCustomerCenter();
      debugPrint('✅ RevenueCat: Customer Center presented');
    } catch (e) {
      debugPrint('❌ RevenueCat: Failed to show Customer Center - $e');
      rethrow;
    }
  }

  /// Check if SDK is initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('RevenueCat SDK not initialized. Call initialize() first.');
    }
  }

  /// Dispose resources
  void dispose() {
    _customerInfoController.close();
  }
}

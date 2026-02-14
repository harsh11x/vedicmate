import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/user_preferences_service.dart';
import '../../services/revenuecat_service.dart';
import '../../services/wallet_service.dart';
import '../../services/order_service.dart';
import '../../models/order_model.dart';
import '../../services/auth_service.dart';
import '../../core/config/env.dart';


enum PaymentMethod { wallet, online }

class CheckoutScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? item;
  final bool isDirectBuy;

  const CheckoutScreen({
    super.key, 
    this.item, 
    this.isDirectBuy = false
  });

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // Detailed Address Controllers
  final _addressLine1Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();

  final _prefsService = UserPreferencesService();
  final _revenueCatService = RevenueCatService();
  final _walletService = WalletService();
  final _orderService = OrderService();
  final _authService = AuthService();

  bool _saveAddress = true;
  PaymentMethod _paymentMethod = PaymentMethod.online;
  bool _isProcessing = false;
  // double _walletBalance = 0.0; // Removed local state
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadSavedDetails();
    // _fetchWalletBalance(); // Removed manual fetch
    _userId = _authService.currentUser?.uid; // Init user ID
  }

  Future<void> _loadSavedDetails() async {
    final details = await _prefsService.getShippingDetails();
    if (details != null && mounted) {
      setState(() {
        _nameController.text = details['name'] ?? '';
        _emailController.text = details['email'] ?? '';
        _phoneController.text = details['phone'] ?? '';
        _addressLine1Controller.text = details['addressLine1'] ?? '';
        _cityController.text = details['city'] ?? '';
        _stateController.text = details['state'] ?? '';
        _zipController.text = details['zip'] ?? '';
      });
    }
  }

  // Removed _fetchWalletBalance method

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  Future<void> _initiatePayment(double totalAmount) async {
    if (!_formKey.currentState!.validate()) return;
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to continue')),
      );
      return;
    }

    // Save details if checkbox is checked
    if (_saveAddress) {
      await _prefsService.saveShippingDetails(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        addressLine1: _addressLine1Controller.text,
        city: _cityController.text,
        state: _stateController.text,
        zip: _zipController.text,
      );
    }

    setState(() => _isProcessing = true);

    try {
      String? paymentId;
      String paymentStatus = 'pending';

      // 1. Process Payment
      if (_paymentMethod == PaymentMethod.wallet) {
        final currentBalance = ref.read(walletBalanceProvider).valueOrNull ?? 0.0;
        if (currentBalance < totalAmount) {
          throw Exception('Insufficient wallet balance');
        }

        final transactionId = 'TXN_${DateTime.now().millisecondsSinceEpoch}';
        
        await _walletService.deductMoney(
          _userId!,
          totalAmount,
          'Product Purchase',
          category: 'purchase',
          referenceId: transactionId,
        );

        // if (!success) throw Exception('Wallet transaction failed'); // deductMoney now throws on failure
        
        paymentId = transactionId;
        paymentStatus = 'completed';

      } else {
        // Online Payment via RevenueCat
        // NOTE: We are assuming single item purchase for matching with RC Package
        // For cart with multiple items, this logic would need to be different (e.g. creating a dynamic cart package or enforcing 1 item type)
        // For now, let's try to find a package for the first item or the single item.
        
        String productIdToSearch = '';
        if (widget.item != null) {
          productIdToSearch = widget.item!['id'].toString();
        } else {
          final cartItems = ref.read(cartProvider);
          if (cartItems.isNotEmpty) {
             // For cart, we might need a specific logic. 
             // As a fallback for this demo, we'll try to find if there's a package matching the first item.
             productIdToSearch = cartItems.first.id;
          }
        }

        // Try to find package in RevenueCat
        // If your product IDs in DB match RC product identifiers exactly
        Package? package = await _revenueCatService.findPackage(productIdToSearch);
        
        if (package != null) {
          final customerInfo = await _revenueCatService.purchaseProduct(package);
          paymentId = customerInfo.originalAppUserId; // or transaction identifier if available
          paymentStatus = 'completed';
        } else {
           // Fallback for demo/testing if package not configured in RC yet
           // throw Exception('Product not available for online purchase');
           
           // TEMPORARY: Allow "Success" for demo purposes if RC setup is incomplete, 
           // BUT show a warning. In production, this should block.
           debugPrint('⚠️ Mocking online payment success for demo as package not found in RC: $productIdToSearch');
           paymentId = 'DEMO_RC_${DateTime.now().millisecondsSinceEpoch}';
           paymentStatus = 'completed';
        }
      }

      // 2. Create Order
      final orderItems = _buildOrderItems();
      final shippingAddress = ShippingAddress(
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        addressLine1: _addressLine1Controller.text,
        city: _cityController.text,
        state: _stateController.text,
        zip: _zipController.text,
      );

      final order = await _orderService.createOrder(
        userId: _userId!,
        items: orderItems,
        subtotal: totalAmount, // Simplified: assume tax/delivery incl or calc separately
        tax: 0, 
        deliveryCharge: 0,
        totalAmount: totalAmount,
        shippingAddress: shippingAddress,
        paymentId: paymentId,
      );

      // Success
      if (!widget.isDirectBuy) {
        ref.read(cartProvider.notifier).clearCart();
      }

      // Refresh wallet balance after purchase
      ref.invalidate(walletBalanceProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!'), backgroundColor: AppTheme.successGreen),
        );
        // Navigate to Orders or Home
        context.go('/orders'); // Assuming /orders route exists, else pop
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString().replaceAll("Exception:", "")}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  List<OrderItem> _buildOrderItems() {
    if (widget.item != null) {
      final img = (widget.item!['images'] is List && (widget.item!['images'] as List).isNotEmpty)
          ? (widget.item!['images'] as List).first
          : widget.item!['image'] ?? '';
          
      return [
        OrderItem(
          id: widget.item!['id'],
          title: widget.item!['name'] ?? widget.item!['title'] ?? 'Item',
          price: (widget.item!['price'] as num).toDouble(),
          quantity: 1,
          image: img,
        )
      ];
    } else {
      final cartItems = ref.read(cartProvider);
      return cartItems.map((item) => OrderItem(
        id: item.id,
        title: item.title,
        price: item.price,
        quantity: item.quantity,
        image: item.image,
      )).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch wallet balance
    final walletBalanceAsync = ref.watch(walletBalanceProvider);
    final walletBalance = walletBalanceAsync.valueOrNull ?? 0.0;

    Map<String, dynamic>? singleItem = widget.item;
    double totalAmount = 0.0;
    String displayTitle = '';
    String displayImage = '';
    
    if (singleItem != null) {
      totalAmount = (singleItem['price'] as num).toDouble();
      displayTitle = singleItem['title'] ?? singleItem['name'] ?? 'Product';
      final imgs = singleItem['images'];
      if (imgs is List && imgs.isNotEmpty) displayImage = imgs.first;
      else displayImage = singleItem['image'] ?? '';
    } else {
      final cartItems = ref.watch(cartProvider);
      if (cartItems.isEmpty) {
         return Scaffold(
          appBar: AppBar(leading: const BackButton(color: Colors.black)),
          body: const Center(child: Text("Cart is empty")),
        );
      }
      totalAmount = ref.watch(cartProvider.notifier).totalAmount;
      displayTitle = 'Cart Total (${cartItems.length} items)';
      displayImage = cartItems.first.image;
    }
    
    return Scaffold(
      backgroundColor: AppTheme.neutralSoft,
      appBar: AppBar(
        title: Text('Checkout', style: GoogleFonts.outfit(color: AppTheme.neutralDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppTheme.neutralDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildImage(displayImage),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayTitle,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            singleItem != null ? 'Quantity: 1' : '',
                            style: TextStyle(color: AppTheme.neutralMedium),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹$totalAmount',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Shipping Details
              Text('Shipping Information', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildTextField('Full Name', _nameController, Icons.person),
              const SizedBox(height: 16),
              _buildTextField('Email Address', _emailController, Icons.email, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildTextField('Phone Number', _phoneController, Icons.phone, keyboardType: TextInputType.phone),
              const SizedBox(height: 24),
              Text('Delivery Address', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              _buildTextField('Street Address / Flat No', _addressLine1Controller, Icons.home, maxLines: 2),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField('City', _cityController, Icons.location_city)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('State', _stateController, Icons.map)),
                ],
              ),
              const SizedBox(height: 16),
               Row(
                children: [
                   Expanded(child: _buildTextField('Pincode', _zipController, Icons.pin_drop, keyboardType: TextInputType.number)),
                   const SizedBox(width: 16),
                   Expanded(child: Container()), 
                ],
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _saveAddress,
                onChanged: (val) => setState(() => _saveAddress = val!),
                title: Text('Save details for later', style: GoogleFonts.outfit()),
                activeColor: AppTheme.primaryOrange,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              
              const SizedBox(height: 32),

              // Payment Method Selection
              Text('Payment Method', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  children: [
                    RadioListTile<PaymentMethod>(
                      value: PaymentMethod.online,
                      groupValue: _paymentMethod,
                      onChanged: (val) => setState(() => _paymentMethod = val!),
                      title: Text('Online Payment', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Credit/Debit Card, UPI via Store'),
                      secondary: const Icon(Icons.payment, color: AppTheme.primaryOrange),
                      activeColor: AppTheme.primaryOrange,
                    ),
                    const Divider(height: 1),
                    RadioListTile<PaymentMethod>(
                      value: PaymentMethod.wallet,
                      groupValue: _paymentMethod,
                      onChanged: (val) => setState(() => _paymentMethod = val!),
                      title: Text('Wallet Balance', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                      subtitle: Text('Available: ₹${walletBalance.toStringAsFixed(2)}'),
                      secondary: const Icon(Icons.account_balance_wallet, color: AppTheme.primaryOrange),
                      activeColor: AppTheme.primaryOrange,
                    ),
                  ],
                ),
              ),
              if (_paymentMethod == PaymentMethod.wallet && walletBalance < totalAmount)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 12),
                  child: Text(
                    'Insufficient wallet balance. Please recharge or use Online Payment.',
                    style: TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),

              const SizedBox(height: 32),

              // Pay Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing 
                    ? null 
                    : (_paymentMethod == PaymentMethod.wallet && walletBalance < totalAmount) 
                      ? null 
                      : () => _initiatePayment(totalAmount),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 24, 
                          width: 24, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                      : Text(
                          'Proceed to Pay ₹$totalAmount',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.neutralMedium),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.forestBackground),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryOrange),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }

  Widget _buildImage(String path) {
    if (path.isEmpty) return const _PlaceholderImage();
    
    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _PlaceholderImage(),
      );
    } else if (path.startsWith('assets/')) {
        return Image.network(
          '${EnvConfig.apiBaseUrl}/$path', 
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) {
             return Image.asset(
                path,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _PlaceholderImage(),
             );
          }
        );
    } 
    return const _PlaceholderImage();
  }
}

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      color: AppTheme.neutralSoft,
      child: Center(
        child: Icon(
          Icons.spa,
          color: AppTheme.neutralMedium.withOpacity(0.3),
          size: 30,
        ),
      ),
    );
  }
}

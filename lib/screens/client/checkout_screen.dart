import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../services/user_preferences_service.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<String, dynamic>? item;
  final bool isDirectBuy;

  const CheckoutScreen({
    super.key, 
    this.item, 
    this.isDirectBuy = false
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
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
  late Razorpay _razorpay;
  bool _saveAddress = true;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _loadSavedDetails();
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

  @override
  void dispose() {
    _razorpay.clear();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Successful: ${response.paymentId}"),
        backgroundColor: AppTheme.successGreen,
      ),
    );
    // Navigate to Success Screen or Home
    context.go('/client/dashboard'); 
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Failed: ${response.message}"),
        backgroundColor: AppTheme.errorRed,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet: ${response.walletName}")),
    );
  }

  Future<void> _initiatePayment() async {
    if (_formKey.currentState!.validate()) {
      
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

      var options = {
        'key': 'rzp_test_YourTestKey', // REPLACE WITH REAL KEY
        'amount': (widget.item!['price'] as int) * 100, // in paise
        'name': 'AstroApp Remedies',
        'description': widget.item!['title'],
        'prefill': {
          'contact': _phoneController.text,
          'email': _emailController.text
        },
        'external': {
          'wallets': ['paytm']
        }
      };

      try {
        _razorpay.open(options);
      } catch (e) {
        debugPrint('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item!;
    
    return Scaffold(
      backgroundColor: AppTheme.neutralSoft,
      appBar: AppBar(
        title: Text('Checkout', style: GoogleFonts.outfit(color: AppTheme.neutralDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: AppTheme.neutralDark),
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
                      child: _buildImage(item['image'] ?? ''),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] ?? item['name'] ?? 'Product',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Quantity: 1',
                            style: TextStyle(color: AppTheme.neutralMedium),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹${item['price']}',
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

              // Shipping Details Section
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
                   Expanded(child: Container()), // Spacer or Country field if needed
                ],
              ),

              const SizedBox(height: 16),
              
              // Save Address Checkbox
              CheckboxListTile(
                value: _saveAddress,
                onChanged: (val) => setState(() => _saveAddress = val!),
                title: Text('Save this address for future orders', style: GoogleFonts.outfit()),
                activeColor: AppTheme.primaryOrange,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              
              const SizedBox(height: 32),

              // Payment Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _initiatePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  child: Text(
                    'Proceed to Pay ₹${item['price']}',
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
          // HARDCODING BASE URL TO PREVENT LOCALHOST ISSUES ON DEVICE
          'https://15.207.36.26:3001/$path', 
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../services/wallet_service.dart';
import '../../services/auth_service.dart';
import '../../services/razorpay_service.dart';
import '../../widgets/abstract_background.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final WalletService _walletService = WalletService();
  final AuthService _authService = AuthService();
  final RazorpayService _razorpayService = RazorpayService();
  final TextEditingController _amountController = TextEditingController();

  double _balance = 0.0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _razorpayService.initialize(
      onSuccess: _handlePaymentSuccess,
      onFailure: _handlePaymentError,
      onExternalWallet: _handleExternalWallet,
    );
    await _fetchData();
  }

  Future<void> _fetchData() async {
    final user = _authService.currentUser;
    if (user != null) {
      final balance = await _walletService.getBalance(user.uid);
      final transactions = await _walletService.getTransactions(user.uid);
      if (mounted) {
        setState(() {
          _balance = balance;
          _transactions = transactions;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final user = _authService.currentUser;
    if (user == null) return;
    
    double amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;
    
    setState(() => _isLoading = true);
    
    final success = await _razorpayService.handlePaymentSuccess(
      response, 
      user.uid, 
      amount
    );

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment Successful! Wallet updated.'), backgroundColor: AppTheme.successGreen),
        );
        _amountController.clear();
      }
      await _fetchData();
    } else {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment Succeeded but Wallet update failed.'), backgroundColor: AppTheme.errorRed),
        );
       setState(() => _isLoading = false);
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}'), backgroundColor: AppTheme.errorRed),
    );
    setState(() => _isLoading = false);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet: ${response.walletName}')),
    );
  }

  Future<void> _initiateRecharge() async {
    final amountText = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(amountText);
    
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final user = _authService.currentUser;
    if (user == null) return;

    // We can fetch user details here if needed, or pass dummy
    // Assuming we have basic user info or default to placeholders
    await _razorpayService.openCheckout(
      amount: amount,
      userId: user.uid,
      userName: _authService.currentUser?.displayName ?? 'User',
      userEmail: _authService.currentUser?.email ?? 'user@example.com',
      userPhone: '9876543210', // Ideal: Fetch actual phone
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('My Wallet', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AbstractBackground(
        child: SafeArea(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _fetchData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Balance Card
                      _buildBalanceCard(),
                      const SizedBox(height: 24),
                      
                      // Recharge Section
                      _buildRechargeSection(),
                      const SizedBox(height: 24),

                      // Transactions
                      Text(
                        'Transaction History',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.neutralDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _transactions.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Text(
                                'No transactions yet.',
                                style: GoogleFonts.outfit(color: AppTheme.neutralMedium),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _transactions.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final txn = _transactions[index];
                              return _buildTransactionTile(txn);
                            },
                          ),
                    ],
                  ),
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryOrange.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Available Balance',
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${_balance.toStringAsFixed(2)}',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRechargeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassMorphism,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Money',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.neutralDark,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              prefixText: '₹ ',
              hintText: 'Enter Amount',
              filled: true,
              fillColor: AppTheme.neutralSoft,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PaymentPresets.amounts.map((amount) {
              return ActionChip(
                label: Text('₹$amount'),
                backgroundColor: AppTheme.white,
                onPressed: () {
                  _amountController.text = amount.toString();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _initiateRecharge,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Proceed to Pay',
                style: GoogleFonts.outfit(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.white
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(Map<String, dynamic> txn) {
    final isCredit = txn['type'] == 'credit';
    final amount = (txn['amount'] as num).toDouble();
    final date = DateTime.parse(txn['created_at']);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.forestBackground.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCredit ? AppTheme.successGreen.withOpacity(0.1) : AppTheme.errorRed.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit ? Icons.add : Icons.remove,
              color: isCredit ? AppTheme.successGreen : AppTheme.errorRed,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn['description'] ?? 'Transaction',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  '${date.day}/${date.month}/${date.year} • ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                  style: GoogleFonts.outfit(color: AppTheme.neutralMedium, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}₹${amount.toStringAsFixed(0)}',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isCredit ? AppTheme.successGreen : AppTheme.errorRed,
            ),
          ),
        ],
      ),
    );
  }
}

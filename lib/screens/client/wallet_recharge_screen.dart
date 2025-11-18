import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../services/wallet_service.dart';
import '../../services/razorpay_service.dart';
import '../../widgets/modern_components.dart';
import '../../models/ai_chat_model.dart';

class WalletRechargeScreen extends StatefulWidget {
  const WalletRechargeScreen({super.key});

  @override
  State<WalletRechargeScreen> createState() => _WalletRechargeScreenState();
}

class _WalletRechargeScreenState extends State<WalletRechargeScreen> {
  final WalletService _walletService = WalletService();
  final RazorpayService _razorpayService = RazorpayService();
  final TextEditingController _customAmountController = TextEditingController();

  double _walletBalance = 0.0;
  List<WalletTransaction> _recentTransactions = [];
  bool _isLoading = true;
  int? _selectedPresetAmount;
  
  final String _userId = 'demo_user_123'; // Replace with actual user ID
  final String _userName = 'Demo User';
  final String _userEmail = 'demo@example.com';
  final String _userPhone = '1234567890';

  @override
  void initState() {
    super.initState();
    _razorpayService.initialize(
      onSuccess: _handlePaymentSuccess,
      onFailure: _handlePaymentFailure,
      onExternalWallet: _handleExternalWallet,
    );
    _loadWalletData();
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    _customAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadWalletData() async {
    setState(() => _isLoading = true);
    
    _walletBalance = await _walletService.getBalance(_userId);
    _recentTransactions = await _walletService.getRecentTransactions(_userId);
    
    setState(() => _isLoading = false);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final amount = _selectedPresetAmount?.toDouble() ?? 
                   double.tryParse(_customAmountController.text) ?? 0.0;
    
    final success = await _razorpayService.handlePaymentSuccess(
      response,
      _userId,
      amount,
    );

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('₹$amount added to wallet successfully!'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        _loadWalletData();
        setState(() {
          _selectedPresetAmount = null;
          _customAmountController.clear();
        });
      }
    }
  }

  void _handlePaymentFailure(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${response.message}'),
        backgroundColor: AppTheme.errorRed,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External wallet selected: ${response.walletName}'),
      ),
    );
  }

  void _initiatePayment(double amount) {
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    _razorpayService.openCheckout(
      amount: amount,
      userId: _userId,
      userName: _userName,
      userEmail: _userEmail,
      userPhone: _userPhone,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Wallet Balance Card
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppTheme.primaryOrange,
                          AppTheme.primaryDeep,
                          AppTheme.accentGold,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppTheme.glowShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet,
                                color: AppTheme.white,
                                size: 32,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Available Balance',
                              style: TextStyle(
                                color: AppTheme.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '₹${_walletBalance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppTheme.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Quick Recharge Amounts
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quick Recharge',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.neutralDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1.2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: PaymentPresets.amounts.length,
                          itemBuilder: (context, index) {
                            final amount = PaymentPresets.amounts[index];
                            final isSelected = _selectedPresetAmount == amount;
                            
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedPresetAmount = amount;
                                  _customAmountController.clear();
                                });
                                _initiatePayment(amount.toDouble());
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? AppTheme.primaryGradient
                                      : null,
                                  color: isSelected ? null : AppTheme.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.transparent
                                        : AppTheme.primaryOrange.withOpacity(0.3),
                                    width: 2,
                                  ),
                                  boxShadow: isSelected
                                      ? AppTheme.glowShadow
                                      : AppTheme.softShadow,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '₹$amount',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? AppTheme.white
                                            : AppTheme.primaryOrange,
                                      ),
                                    ),
                                    if (amount >= 1000) ...[
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppTheme.white.withOpacity(0.25)
                                              : AppTheme.successGreen.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '+5% Bonus',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? AppTheme.white
                                                : AppTheme.successGreen,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Custom Amount
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Custom Amount',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.neutralDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppTheme.softShadow,
                            border: Border.all(
                              color: AppTheme.primaryOrange.withOpacity(0.2),
                            ),
                          ),
                          child: TextField(
                            controller: _customAmountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.currency_rupee),
                              hintText: 'Enter amount',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                            onChanged: (value) {
                              setState(() => _selectedPresetAmount = null);
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        ModernActionButton(
                          text: 'Add Money',
                          icon: Icons.add,
                          onPressed: () {
                            final amount = double.tryParse(_customAmountController.text) ?? 0.0;
                            _initiatePayment(amount);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Recent Transactions
                  if (_recentTransactions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recent Transactions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.neutralDark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: AppTheme.softShadow,
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _recentTransactions.length,
                              separatorBuilder: (context, index) => Divider(
                                color: AppTheme.neutralLight.withOpacity(0.2),
                                height: 1,
                              ),
                              itemBuilder: (context, index) {
                                final transaction = _recentTransactions[index];
                                final isCredit = transaction.type == TransactionType.credit;
                                
                                return ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: (isCredit
                                              ? AppTheme.successGreen
                                              : AppTheme.errorRed)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                                      color: isCredit ? AppTheme.successGreen : AppTheme.errorRed,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    transaction.description,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${transaction.timestamp.day}/${transaction.timestamp.month}/${transaction.timestamp.year} ${transaction.timestamp.hour}:${transaction.timestamp.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  trailing: Text(
                                    '${isCredit ? '+' : '-'}₹${transaction.amount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: isCredit ? AppTheme.successGreen : AppTheme.errorRed,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../services/wallet_service.dart';
import '../../services/razorpay_service.dart';
import '../../widgets/modern_components.dart';
import '../../models/ai_chat_model.dart';
import '../../providers/wallet_provider.dart';

class WalletRechargeScreen extends ConsumerStatefulWidget {
  const WalletRechargeScreen({super.key});

  @override
  ConsumerState<WalletRechargeScreen> createState() => _WalletRechargeScreenState();
}

class _WalletRechargeScreenState extends ConsumerState<WalletRechargeScreen> {
  final RazorpayService _razorpayService = RazorpayService();
  final TextEditingController _customAmountController = TextEditingController();

  bool _isLoading = false;
  int? _selectedPresetAmount;
  double? _pendingAmount;
  
  String? _userId;
  String _userName = 'User';
  String _userEmail = '';
  String _userPhone = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _razorpayService.initialize(
      onSuccess: _handlePaymentSuccess,
      onFailure: _handlePaymentFailure,
      onExternalWallet: _handleExternalWallet,
    );
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    _customAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to recharge wallet')),
        );
      }
      return;
    }

    // Handle guest users
    final isGuest = user.isAnonymous;
    setState(() {
      _userId = isGuest ? 'guest_${user.uid}' : user.uid;
      _userName = isGuest ? 'Guest User' : (user.displayName ?? 'User');
      _userEmail = user.email ?? 'guest@vedicmate.com';
      _userPhone = user.phoneNumber ?? '0000000000';
    });

    // Load user data from Firestore if available
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (userDoc.exists) {
        final data = userDoc.data();
        setState(() {
          _userName = data?['displayName'] ?? _userName;
          _userEmail = data?['email'] ?? _userEmail;
          _userPhone = data?['phoneNumber'] ?? _userPhone;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_userId == null || _pendingAmount == null) return;

    setState(() => _isLoading = true);
    
    final success = await _razorpayService.handlePaymentSuccess(
      response,
      _userId!,
      _pendingAmount!,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      
      if (success) {
        // Refresh wallet balance
        ref.invalidate(walletBalanceProvider);
        ref.invalidate(walletTransactionsProvider);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('₹${_pendingAmount!.toStringAsFixed(2)} added to wallet successfully!'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        
        setState(() {
          _selectedPresetAmount = null;
          _customAmountController.clear();
          _pendingAmount = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add money to wallet. Please contact support.'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
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
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to recharge wallet'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    if (amount < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimum recharge amount is ₹10'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() {
      _pendingAmount = amount;
    });

    _razorpayService.openCheckout(
      amount: amount,
      userId: _userId!,
      userName: _userName,
      userEmail: _userEmail,
      userPhone: _userPhone,
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletBalanceAsync = ref.watch(walletBalanceProvider);
    final transactionsAsync = ref.watch(walletTransactionsProvider);

    if (_userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Wallet Recharge')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet Recharge'),
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
                        walletBalanceAsync.when(
                          data: (balance) => Text(
                            '₹${balance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppTheme.white,
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          loading: () => const CircularProgressIndicator(
                            color: AppTheme.white,
                          ),
                          error: (_, __) => const Text(
                            '₹0.00',
                            style: TextStyle(
                              color: AppTheme.white,
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                            ),
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
                  transactionsAsync.when(
                    data: (transactions) {
                      if (transactions.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      
                      return Padding(
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
                                itemCount: transactions.length,
                                separatorBuilder: (context, index) => Divider(
                                  color: AppTheme.neutralLight.withOpacity(0.2),
                                  height: 1,
                                ),
                                itemBuilder: (context, index) {
                                  final transaction = transactions[index];
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
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }
}

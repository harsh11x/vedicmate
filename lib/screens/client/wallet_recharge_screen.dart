import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/wallet_provider.dart';
import '../../services/wallet_service.dart';
import '../../services/auth_service.dart';
import '../../services/razorpay_payment_service.dart';
import '../../widgets/abstract_background.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  final WalletService _walletService = WalletService();
  final AuthService _authService = AuthService();
  final RazorpayPaymentService _razorpayService = RazorpayPaymentService();

  bool _isLoading = true;
  bool _isProcessingRecharge = false;
  List<Map<String, dynamic>> _transactions = [];
  
  // Wallet credit amounts
  final List<int> _rechargeAmounts = [50, 100, 200, 500, 1000, 2000, 5000];

  @override
  void initState() {
    super.initState();
    _razorpayService.initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final user = _authService.currentUser;
    if (user != null) {
      setState(() => _isLoading = true);
      
      try {
        final transactions = await _walletService.getTransactions(user.uid);
        
        if (mounted) {
          setState(() {
            _transactions = transactions;
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint('Error fetching wallet data: $e');
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _initiateRecharge(int amount) async {
    final user = _authService.currentUser;
    if (user == null) {
      _showError('Please login to recharge your wallet.');
      return;
    }

    if (_isProcessingRecharge) return;
    setState(() => _isProcessingRecharge = true);

    try {
      final result = await _razorpayService.pay(
        amount: amount.toDouble(),
        userId: user.uid,
        userName: user.displayName ?? 'User',
        userEmail: user.email ?? 'user@example.com',
        userPhone: user.phoneNumber ?? '9999999999',
        description: 'Wallet recharge',
        purpose: 'wallet_recharge',
        metadata: {'walletAmount': amount},
      );

      if (!mounted) return;

      if (result.success) {
        await _handlePaymentSuccess(
          user.uid,
          amount.toDouble(),
          result.paymentId ??
              result.orderId ??
              'RAZORPAY_${DateTime.now().millisecondsSinceEpoch}',
        );
      } else {
        _showError(result.error ?? 'Payment failed or was cancelled.');
      }
    } catch (e) {
      _showError(
          'Unable to start Razorpay. Add server keys and try again.\n$e');
    } finally {
      if (mounted) {
        setState(() => _isProcessingRecharge = false);
      }
    }
  }

  Future<void> _handlePaymentSuccess(String userId, double amount, String txnid) async {
    try {
      // Add credits to Supabase wallet
      final success = await _walletService.addMoney(
        userId,
        amount,
        txnid,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('₹$amount added to wallet successfully!'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
        // Refresh provider and data
        ref.invalidate(walletBalanceProvider);
        await _fetchData();
      } else {
        _showError('Payment successful but failed to update wallet. Please contact support.');
      }
    } catch (e) {
      _showError('Error updating wallet: $e');
    } finally {}
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
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

                        // Recharge Options
                        _buildRechargeGrid(),
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
            '₹${ref.watch(walletBalanceProvider).valueOrNull?.toStringAsFixed(2) ?? "0.00"}',
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

  Widget _buildRechargeGrid() {
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
          if (_isProcessingRecharge)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Opening Razorpay checkout...',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: AppTheme.neutralMedium,
                    ),
                  ),
                ],
              ),
            ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: _rechargeAmounts.length,
            itemBuilder: (context, index) {
              final amount = _rechargeAmounts[index];
              return _buildRechargeCard(amount);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRechargeCard(int amount) {
    return InkWell(
      onTap: _isProcessingRecharge ? null : () => _initiateRecharge(amount),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: _isProcessingRecharge
              ? AppTheme.white.withOpacity(0.7)
              : AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryOrange.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '₹$amount',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryOrange,
              ),
            ),
          ],
        ),
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
              color: isCredit
                  ? AppTheme.successGreen.withOpacity(0.1)
                  : AppTheme.errorRed.withOpacity(0.1),
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

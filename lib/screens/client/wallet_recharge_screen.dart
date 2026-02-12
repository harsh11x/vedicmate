import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../services/wallet_service.dart';
import '../../services/auth_service.dart';
import '../../services/revenuecat_service.dart';
import '../../widgets/abstract_background.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  final WalletService _walletService = WalletService();
  final AuthService _authService = AuthService();
  final RevenueCatService _revenueCatService = RevenueCatService();

  double _balance = 0.0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _transactions = [];
  List<Package> _walletPackages = [];

  // Wallet credit amounts mapped to their values
  final Map<String, int> _walletAmounts = {
    'wallet_50': 50,
    'wallet_100': 100,
    'wallet_200': 200,
    'wallet_500': 500,
    'wallet_1000': 1000,
    'wallet_2000': 2000,
    'wallet_5000': 5000,
  };

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final user = _authService.currentUser;
    if (user != null) {
      setState(() => _isLoading = true);
      
      final balance = await _walletService.getBalance(user.uid);
      final transactions = await _walletService.getTransactions(user.uid);
      
      // Fetch wallet offerings from RevenueCat
      try {
        final offering = await _revenueCatService.getWalletOffering();
        final packages = offering?.availablePackages ?? [];
        
        if (mounted) {
          setState(() {
            _balance = balance;
            _transactions = transactions;
            _walletPackages = packages;
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint('Error fetching wallet offerings: $e');
        if (mounted) {
          setState(() {
            _balance = balance;
            _transactions = transactions;
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _purchaseWalletCredit(Package package) async {
    final user = _authService.currentUser;
    if (user == null) {
      _showError('Please login to purchase wallet credits');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Purchase via RevenueCat
      final customerInfo = await _revenueCatService.purchaseWalletCredit(package);
      
      // Get the amount from package identifier
      final amount = _walletAmounts[package.identifier] ?? 0;
      
      if (amount > 0) {
        // Add credits to Supabase wallet
        final success = await _walletService.addMoney(
          user.uid,
          amount.toDouble(),
          customerInfo.originalAppUserId, // Use RevenueCat user ID as reference
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
          await _fetchData();
        } else {
          _showError('Failed to update wallet balance');
        }
      }
    } catch (e) {
      debugPrint('Purchase error: $e');
      if (e.toString().contains('cancelled')) {
        // User cancelled, don't show error
      } else {
        _showError('Purchase failed: ${e.toString()}');
      }
      setState(() => _isLoading = false);
    }
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

                        // Wallet Credit Packages
                        _buildWalletPackagesSection(),
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

  Widget _buildWalletPackagesSection() {
    if (_walletPackages.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.glassMorphism,
        child: Column(
          children: [
            const Icon(Icons.info_outline, color: AppTheme.neutralMedium, size: 48),
            const SizedBox(height: 16),
            Text(
              'Wallet credits not available',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.neutralDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please configure wallet credit products in RevenueCat dashboard',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppTheme.neutralMedium,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

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
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: _walletPackages.length,
            itemBuilder: (context, index) {
              final package = _walletPackages[index];
              final amount = _walletAmounts[package.identifier] ?? 0;
              
              return _buildPackageCard(package, amount);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(Package package, int amount) {
    return InkWell(
      onTap: () => _purchaseWalletCredit(package),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
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
            const SizedBox(height: 4),
            Text(
              package.storeProduct.priceString,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: AppTheme.neutralMedium,
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

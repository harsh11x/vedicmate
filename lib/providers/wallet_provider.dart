import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/wallet_service.dart';
import '../models/ai_chat_model.dart';

// Wallet Service Provider
final walletServiceProvider = Provider<WalletService>((ref) {
  return WalletService();
});

// Current User ID Provider - gets from Firebase Auth
final currentUserIdProvider = Provider<String?>((ref) {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return null;
    return user.uid;
  } catch (e) {
    return null;
  }
});

// Wallet Balance Provider - Syncs across the app
final walletBalanceProvider = FutureProvider<double>((ref) async {
  final walletService = ref.watch(walletServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return 0.0;
  return await walletService.getBalance(userId);
});

// Wallet Provider - Full wallet data
final walletProvider = FutureProvider<UserWallet>((ref) async {
  final walletService = ref.watch(walletServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    throw Exception('User not logged in');
  }
  return await walletService.getWallet(userId);
});

// Wallet Transactions Provider
final walletTransactionsProvider =
    FutureProvider<List<WalletTransaction>>((ref) async {
  final walletService = ref.watch(walletServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  return await walletService.getRecentTransactions(userId, limit: 50);
});

// Notifier for wallet operations that refresh the balance
class WalletNotifier extends StateNotifier<AsyncValue<double>> {
  WalletNotifier(this._walletService, this._userId)
      : super(const AsyncValue.loading()) {
    _loadBalance();
  }

  final WalletService _walletService;
  final String _userId;

  Future<void> _loadBalance() async {
    if (_userId.isEmpty) {
      state = const AsyncValue.data(0.0);
      return;
    }
    state = const AsyncValue.loading();
    try {
      final balance = await _walletService.getBalance(_userId);
      state = AsyncValue.data(balance);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> addMoney(double amount, String paymentId) async {
    try {
      if (_userId.isEmpty) return false;
      final success = await _walletService.addMoney(_userId, amount, paymentId);
      if (success) {
        await _loadBalance();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deductMoney(double amount, String description,
      {String? referenceId}) async {
    try {
      if (_userId.isEmpty) return false;
      final success = await _walletService
          .deductMoney(_userId, amount, description, referenceId: referenceId);
      if (success) {
        await _loadBalance();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<void> refresh() async {
    await _loadBalance();
  }
}

// Wallet Notifier Provider
final walletNotifierProvider =
    StateNotifierProvider<WalletNotifier, AsyncValue<double>>((ref) {
  final walletService = ref.watch(walletServiceProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    return WalletNotifier(
        walletService, ''); // Will fail closed in WalletService usage
  }

  return WalletNotifier(walletService, userId);
});

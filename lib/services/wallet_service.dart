import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ai_chat_model.dart';

class WalletService {
  static const String _walletKey = 'user_wallet';
  static const String _transactionsKey = 'wallet_transactions';

  // Get wallet balance
  Future<double> getBalance(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final walletData = prefs.getString('${_walletKey}_$userId');
    
    if (walletData != null) {
      final wallet = UserWallet.fromJson(jsonDecode(walletData));
      return wallet.balance;
    }
    
    return 0.0;
  }

  // Get user wallet
  Future<UserWallet> getWallet(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final walletData = prefs.getString('${_walletKey}_$userId');
    
    if (walletData != null) {
      return UserWallet.fromJson(jsonDecode(walletData));
    }
    
    // Create new wallet if doesn't exist
    final newWallet = UserWallet(
      userId: userId,
      balance: 0.0,
      transactions: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await _saveWallet(newWallet);
    return newWallet;
  }

  // Add money to wallet (via Razorpay)
  Future<bool> addMoney(String userId, double amount, String paymentId) async {
    try {
      final wallet = await getWallet(userId);
      
      final transaction = WalletTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        amount: amount,
        type: TransactionType.credit,
        description: 'Money added via Razorpay',
        timestamp: DateTime.now(),
        referenceId: paymentId,
      );
      
      wallet.balance += amount;
      wallet.transactions = [...wallet.transactions, transaction];
      wallet.updatedAt = DateTime.now();
      
      await _saveWallet(wallet);
      return true;
    } catch (e) {
      print('Error adding money: $e');
      return false;
    }
  }

  // Deduct money from wallet
  Future<bool> deductMoney(String userId, double amount, String description, {String? referenceId}) async {
    try {
      final wallet = await getWallet(userId);
      
      if (wallet.balance < amount) {
        return false; // Insufficient balance
      }
      
      final transaction = WalletTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        amount: amount,
        type: TransactionType.debit,
        description: description,
        timestamp: DateTime.now(),
        referenceId: referenceId,
      );
      
      wallet.balance -= amount;
      wallet.transactions = [...wallet.transactions, transaction];
      wallet.updatedAt = DateTime.now();
      
      await _saveWallet(wallet);
      return true;
    } catch (e) {
      print('Error deducting money: $e');
      return false;
    }
  }

  // Check if user has sufficient balance
  Future<bool> hasSufficientBalance(String userId, double requiredAmount) async {
    final balance = await getBalance(userId);
    return balance >= requiredAmount;
  }

  // Get recent transactions
  Future<List<WalletTransaction>> getRecentTransactions(String userId, {int limit = 10}) async {
    final wallet = await getWallet(userId);
    final transactions = wallet.transactions.toList();
    transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return transactions.take(limit).toList();
  }

  // Save wallet to local storage
  Future<void> _saveWallet(UserWallet wallet) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_walletKey}_${wallet.userId}',
      jsonEncode(wallet.toJson()),
    );
  }

  // Clear wallet data (for testing)
  Future<void> clearWallet(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_walletKey}_$userId');
  }
}

class AIChatService {
  static const String _sessionsKey = 'ai_chat_sessions';
  final WalletService _walletService = WalletService();

  // Start a new AI chat session
  Future<AIChatSession> startSession(String userId) async {
    final session = AIChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      startTime: DateTime.now(),
      ratePerMinute: 25.0,
      messages: [],
      isActive: true,
    );
    
    await _saveSession(session);
    return session;
  }

  // End a chat session and deduct charges
  Future<Map<String, dynamic>> endSession(String userId, String sessionId) async {
    try {
      final session = await getSession(sessionId);
      
      if (session == null || !session.isActive) {
        return {
          'success': false,
          'message': 'Session not found or already ended',
        };
      }
      
      session.endTime = DateTime.now();
      session.isActive = false;
      session.totalCost = session.calculateCost();
      
      // Deduct money from wallet
      final deducted = await _walletService.deductMoney(
        userId,
        session.totalCost,
        'AI Pandit Chat - ${session.getDurationInMinutes().toStringAsFixed(2)} minutes',
        referenceId: sessionId,
      );
      
      if (!deducted) {
        return {
          'success': false,
          'message': 'Insufficient wallet balance',
          'totalCost': session.totalCost,
          'duration': session.getDurationInMinutes(),
        };
      }
      
      await _saveSession(session);
      
      return {
        'success': true,
        'message': 'Session ended successfully',
        'totalCost': session.totalCost,
        'duration': session.getDurationInMinutes(),
      };
    } catch (e) {
      print('Error ending session: $e');
      return {
        'success': false,
        'message': 'Error ending session: $e',
      };
    }
  }

  // Add message to session
  Future<void> addMessage(String sessionId, AIChatMessage message) async {
    final session = await getSession(sessionId);
    if (session != null) {
      session.messages = [...session.messages, message];
      await _saveSession(session);
    }
  }

  // Get session by ID
  Future<AIChatSession?> getSession(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionData = prefs.getString('${_sessionsKey}_$sessionId');
    
    if (sessionData != null) {
      return AIChatSession.fromJson(jsonDecode(sessionData));
    }
    
    return null;
  }

  // Get active session for user
  Future<AIChatSession?> getActiveSession(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    for (var key in keys) {
      if (key.startsWith(_sessionsKey)) {
        final sessionData = prefs.getString(key);
        if (sessionData != null) {
          final session = AIChatSession.fromJson(jsonDecode(sessionData));
          if (session.userId == userId && session.isActive) {
            return session;
          }
        }
      }
    }
    
    return null;
  }

  // Get current session cost
  Future<double> getCurrentSessionCost(String sessionId) async {
    final session = await getSession(sessionId);
    return session?.calculateCost() ?? 0.0;
  }

  // Save session to local storage
  Future<void> _saveSession(AIChatSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_sessionsKey}_${session.id}',
      jsonEncode(session.toJson()),
    );
  }

  // Get all user sessions
  Future<List<AIChatSession>> getUserSessions(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final sessions = <AIChatSession>[];
    
    for (var key in keys) {
      if (key.startsWith(_sessionsKey)) {
        final sessionData = prefs.getString(key);
        if (sessionData != null) {
          final session = AIChatSession.fromJson(jsonDecode(sessionData));
          if (session.userId == userId) {
            sessions.add(session);
          }
        }
      }
    }
    
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    return sessions;
  }
}

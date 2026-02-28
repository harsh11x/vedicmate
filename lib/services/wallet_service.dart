import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/ai_chat_model.dart';

class WalletService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService = AuthService();

  // Get current wallet balance from Supabase
  Future<double> getBalance(String userId) async {
    // 1. Check if guest - NO, guests now have real wallets in DB (initialized to 5000)
    // if (userId.startsWith('guest_') || userId.contains('anonymous')) {
    //   return 5000.0;
    // }

    try {
      final response = await _supabase
          .from('wallets')
          .select('balance')
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        // Create wallet if it doesn't exist
        await _createWallet(userId);
        // If guest, we just gave them 5000, if new user, we gave 50
        final isGuest = _authService.currentUser?.isAnonymous ?? false;
        return isGuest ? 5000.0 : 50.0;
      }

      var balance = (response['balance'] as num).toDouble();

      // Check for broken guest wallet (0 balance, no history) and fix it
      final isGuest = _authService.currentUser?.isAnonymous ?? false;
      if (balance == 0 && isGuest) {
        try {
          final txns = await _supabase
              .from('transactions')
              .select('id')
              .eq('wallet_id', userId)
              .limit(1);
          if (txns.isEmpty) {
            debugPrint('Fixing guest wallet: adding 5000 bonus');
            // Add bonus transaction
            await _supabase.from('transactions').insert({
              'wallet_id': userId,
              'amount': 5000.0,
              'type': 'credit',
              'category': 'recharge',
              'description': 'Guest Welcome Bonus',
              'reference_id':
                  'GUEST_BONUS_${DateTime.now().millisecondsSinceEpoch}',
              'status': 'completed',
              'created_at': DateTime.now().toIso8601String(),
            });

            // Update wallet
            await _supabase
                .from('wallets')
                .update({'balance': 5000.0}).eq('user_id', userId);
            return 5000.0;
          }
        } catch (e) {
          debugPrint('Error fixing guest wallet: $e');
        }
      }

      return balance;
    } catch (e) {
      debugPrint('WalletService: Error fetching balance -> $e');
      // Re-throw to let caller handle the error properly
      rethrow;
    }
  }

  // Adapter for WalletProvider: Get full UserWallet object
  // Synced from Supabase
  Future<UserWallet> getWallet(String userId) async {
    // 1. Guest Handling - removed, fetch from DB like everyone else
    // if (userId.startsWith('guest_') || userId.contains('anonymous')) { ... }

    final balance = await getBalance(userId);
    final txns = await getRecentTransactions(userId);

    return UserWallet(
      userId: userId,
      balance: balance,
      transactions: txns,
      createdAt: DateTime.now(), // approximation or fetch from DB
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _createWallet(String uid) async {
    try {
      // Check if guest for initial bonus
      final isGuest = _authService.currentUser?.isAnonymous ?? false;
      final initialBalance = isGuest ? 5000.0 : 50.0;

      await _supabase.from('wallets').insert({
        'user_id': uid,
        'balance': initialBalance,
        'currency': 'INR',
      });

      // Insert welcome bonus transaction
      await _supabase.from('transactions').insert({
        'wallet_id': uid,
        'amount': initialBalance,
        'type': 'credit',
        'category': 'recharge',
        'description': isGuest ? 'Guest Welcome Bonus' : 'Signup Bonus',
        'reference_id': '${isGuest ? "GUEST" : "SIGNUP"}_BONUS_${DateTime.now().millisecondsSinceEpoch}',
        'status': 'completed',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error creating wallet: $e');
    }
  }

  // Get transaction history (List<Map> for internal, List<WalletTransaction> for Provider)
  Future<List<Map<String, dynamic>>> getTransactions(String userId) async {
    try {
      final response = await _supabase
          .from('transactions')
          .select()
          .eq('wallet_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('WalletService: Error fetching detailed txns -> $e');
      return [];
    }
  }

  // Public method matching WalletProvider expectation
  Future<List<WalletTransaction>> getRecentTransactions(String userId,
      {int limit = 50}) async {
    // if (userId.startsWith('guest_')) return []; // Allow guests to see history

    try {
      final response = await _supabase
          .from('transactions')
          .select()
          .eq('wallet_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List).map((data) {
        return WalletTransaction(
          id: data['id'] ?? '',
          userId: data['wallet_id'] ??
              userId, // 'wallet_id' in DB, 'userId' in model
          amount: (data['amount'] as num).toDouble(),
          type: data['type'] == 'credit'
              ? TransactionType.credit
              : TransactionType.debit,
          description: data['description'] ?? '',
          timestamp: DateTime.parse(data['created_at']),
          referenceId: data['reference_id'],
        );
      }).toList();
    } catch (e) {
      debugPrint('WalletService: Error fetching recent transactions -> $e');
      return [];
    }
  }

  // Add (Recharge) funds
  Future<bool> addMoney(String userId, double amount, String paymentId) async {
    try {
      // First ensure wallet exists
      await getBalance(userId); // This will create wallet if not exists

      // 1. Insert Transaction
      await _supabase.from('transactions').insert({
        'wallet_id': userId,
        'amount': amount,
        'type': 'credit',
        'category': 'recharge',
        'description': 'Wallet Recharge via PayU',
        'reference_id': paymentId,
        'status': 'completed',
        'created_at': DateTime.now().toIso8601String(),
      });

      // 2. Fetch current & update
      final currentBalance = await getBalance(userId);
      final newBalance = currentBalance + amount;

      await _supabase.from('wallets').update({
        'balance': newBalance,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);

      debugPrint(
          'WalletService: Added ₹$amount to wallet. New balance: ₹$newBalance');
      return true;
    } catch (e) {
      debugPrint('Error adding money: $e');
      return false;
    }
  }

  // Deduct funds (for Chats/Calls)
  // Deduct funds (for Chats/Calls/Orders)
  Future<bool> deductMoney(String userId, double amount, String description,
      {String? referenceId, String category = 'consultation'}) async {
    debugPrint(
        'WalletService: Attempting to deduct ₹$amount for user $userId. Reason: $description');

    // 0. Validation
    if (amount <= 0) {
      throw Exception('Invalid amount: $amount');
    }

    try {
      final currentBalance = await getBalance(userId);
      debugPrint('WalletService: Current balance is ₹$currentBalance');

      if (currentBalance < amount) {
        throw Exception(
            'Insufficient balance. Need ₹$amount, have ₹$currentBalance');
      }

      // 1. Transaction
      try {
        await _supabase.from('transactions').insert({
          'wallet_id': userId,
          'amount': amount,
          'type': 'debit',
          'category': category,
          'description': description,
          'reference_id': referenceId,
          'status': 'completed',
          'created_at': DateTime.now().toIso8601String(),
        });
        debugPrint('WalletService: Transaction log created successfully');
      } catch (e) {
        debugPrint('WalletService: Failed to insert transaction log: $e');
        throw Exception('Transaction Log Failed: $e');
      }

      // 2. Update Balance
      try {
        final newBalance = currentBalance - amount;
        await _supabase.from('wallets').update({
          'balance': newBalance,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('user_id', userId);
        debugPrint('WalletService: Wallet balance updated to ₹$newBalance');
        return true;
      } catch (e) {
        debugPrint('WalletService: Failed to update wallet balance: $e');
        // Critical error: Transaction logged but balance not updated.
        // In a real app, we'd need a compensation transaction or atomic updates (RPC).
        throw Exception('Balance Update Failed: $e');
      }
    } catch (e) {
      debugPrint('WalletService: Error deducting money: $e');
      rethrow;
    }
  }

  Future<bool> hasSufficientBalance(
      String userId, double requiredAmount) async {
    final balance = await getBalance(userId);
    return balance >= requiredAmount;
  }
}

// RESTORED AI CHAT SERVICE (Local/Prefs based mostly, but uses WalletService)
class AIChatService {
  static const String _sessionsKey = 'ai_chat_sessions';
  final WalletService _walletService = WalletService();

  // Start a new AI chat session for a specific pandit
  Future<AIChatSession> startSession(String userId, String panditId) async {
    final session = AIChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      panditId: panditId,
      startTime: DateTime.now(),
      ratePerMinute: 25.0,
      messages: [],
      isActive: true,
      isStarted: false, // Not started until user confirms
    );

    await saveSession(session);
    return session;
  }

  // Get or create session for a specific pandit
  Future<AIChatSession> getOrCreateSession(
      String userId, String panditId) async {
    // First, try to get the most recent active session for this pandit
    final sessions = await getUserSessionsByPandit(userId, panditId);

    AIChatSession? activeSession;
    try {
      activeSession = sessions.firstWhere(
        (s) => s.isActive && !s.isStarted,
      );
    } catch (e) {
      try {
        activeSession = sessions.firstWhere(
          (s) => s.isActive,
        );
      } catch (e2) {
        // No active session found
      }
    }

    // If no active session exists, create a new one
    if (activeSession == null ||
        activeSession.id.isEmpty ||
        activeSession.endTime != null) {
      return await startSession(userId, panditId);
    }

    return activeSession;
  }

  // Get all sessions for a specific pandit
  Future<List<AIChatSession>> getUserSessionsByPandit(
      String userId, String panditId) async {
    final allSessions = await getUserSessions(userId);
    return allSessions.where((s) => s.panditId == panditId).toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  // End a chat session and deduct charges
  Future<Map<String, dynamic>> endSession(
      String userId, String sessionId) async {
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

      await saveSession(session);

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
      await saveSession(session);
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

  // Get active session for user and pandit
  Future<AIChatSession?> getActiveSession(String userId,
      {String? panditId}) async {
    try {
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 1),
        onTimeout: () => throw TimeoutException('SharedPreferences timeout'),
      );

      // Try to get a cached active session key first
      final activeSessionKey = prefs.getString('active_session_$userId');
      if (activeSessionKey != null) {
        try {
          final sessionData =
              prefs.getString('${_sessionsKey}_$activeSessionKey');
          if (sessionData != null) {
            final session = AIChatSession.fromJson(jsonDecode(sessionData));
            if (session.isActive) {
              return session;
            }
          }
        } catch (e) {
          print('⚠️ Error reading cached session: $e');
        }
      }

      // Fallback: iterate through keys (but limit to first 50 to prevent hang)
      final keys = prefs.getKeys();
      int checked = 0;
      for (var key in keys) {
        if (checked++ > 50) break; // Limit iteration to prevent hang
        if (key.startsWith(_sessionsKey)) {
          try {
            final sessionData = prefs.getString(key);
            if (sessionData != null) {
              final session = AIChatSession.fromJson(jsonDecode(sessionData));
              if (session.userId == userId && session.isActive) {
                // Cache the active session key for faster lookup next time
                await prefs.setString('active_session_$userId', session.id);
                return session;
              }
            }
          } catch (e) {
            print('⚠️ Error parsing session: $e');
            continue;
          }
        }
      }
    } catch (e) {
      print('⚠️ Error getting active session: $e');
      return null;
    }

    return null;
  }

  // Get current session cost
  Future<double> getCurrentSessionCost(String sessionId) async {
    final session = await getSession(sessionId);
    return session?.calculateCost() ?? 0.0;
  }

  // Save session to local storage
  Future<void> saveSession(AIChatSession session) async {
    try {
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 1),
        onTimeout: () => throw TimeoutException('SharedPreferences timeout'),
      );
      await prefs.setString(
        '${_sessionsKey}_${session.id}',
        jsonEncode(session.toJson()),
      );
      // Cache active session key for faster lookup
      if (session.isActive) {
        await prefs.setString(
            'active_session_${session.userId}_${session.panditId}', session.id);
      }
    } catch (e) {
      print('⚠️ Error saving session: $e');
    }
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

  // Clear chat history for a specific pandit
  Future<void> clearPanditHistory(String userId, String panditId) async {
    final sessions = await getUserSessionsByPandit(userId, panditId);
    final prefs = await SharedPreferences.getInstance();

    for (var session in sessions) {
      await prefs.remove('${_sessionsKey}_${session.id}');
      if (session.isActive) {
        await prefs.remove('active_session_${userId}_${panditId}');
      }
    }
  }
}

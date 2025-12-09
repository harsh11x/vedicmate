import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../../core/theme/app_theme.dart';
import '../../models/ai_chat_model.dart';
import '../../services/wallet_service.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/api_providers.dart';
import '../../widgets/modern_components.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class AIPanditChatScreen extends ConsumerStatefulWidget {
  final String? panditId;
  
  const AIPanditChatScreen({super.key, this.panditId});

  @override
  ConsumerState<AIPanditChatScreen> createState() => _AIPanditChatScreenState();
}

class _AIPanditChatScreenState extends ConsumerState<AIPanditChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final WalletService _walletService = WalletService();
  final AIChatService _chatService = AIChatService();

  List<AIChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;
  double _walletBalance = 0.0;
  AIChatSession? _currentSession;
  Timer? _costTimer;
  double _currentCost = 0.0;
  int _elapsedSeconds = 0;
  
  String? _userId;

  @override
  void initState() {
    super.initState();
    // NO async operations in initState - UI must render first!
    // Initialize after first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Use microtask to defer initialization even further
      Future.microtask(() => _initializeChat());
    });
  }

  Future<void> _initializeChat() async {
    if (!mounted) return;
    
    // Set loading state
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      
      // Allow everyone - regular users, guest users, and even unauthenticated users
      String userId;
      if (user == null) {
        // Create a temporary guest ID for unauthenticated users
        userId = 'guest_temp_${DateTime.now().millisecondsSinceEpoch}';
        print('✅ Using temporary guest session: $userId');
      } else {
        // Handle authenticated users (regular or anonymous)
        userId = user.isAnonymous ? 'guest_${user.uid}' : user.uid;
        print('✅ User authenticated: ${user.isAnonymous ? "Guest" : "Regular"} - ID: $userId');
      }
      
      setState(() {
        _userId = userId;
        _walletBalance = 5000.0; // Default optimistic value
      });
      
      // Create local session immediately (no async wait)
      _currentSession = AIChatSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        startTime: DateTime.now(),
      );
      _startCostTimer();
      
      // UI is ready NOW - stop loading immediately
      setState(() => _isLoading = false);
      
      // Everything else happens in background
      _initializeInBackground();
      
    } catch (e) {
      print('❌ Error in _initializeChat: $e');
      // Still show UI even if initialization fails
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // All heavy operations happen here in background
  Future<void> _initializeInBackground() async {
    if (!mounted || _userId == null) return;
    
    try {
      // Try to get active session (non-blocking, with timeout)
      AIChatSession? activeSession;
      try {
        activeSession = await _chatService.getActiveSession(_userId!).timeout(
          const Duration(seconds: 1),
          onTimeout: () => null,
        );
      } catch (e) {
        print('⚠️ Session check error: $e');
      }
      
      if (activeSession != null && mounted) {
        setState(() {
          _currentSession = activeSession!;
          _messages = activeSession!.messages;
          _elapsedSeconds = activeSession!.getDurationInSeconds();
          _currentCost = activeSession!.calculateCost();
        });
      } else {
        // Try to save current session (non-blocking)
        try {
          await _chatService.startSession(_userId!).timeout(
            const Duration(seconds: 1),
            onTimeout: () => _currentSession!,
          );
        } catch (e) {
          print('⚠️ Session save error: $e');
        }
      }
      
      // Load welcome message
      _loadWelcomeMessage();
      
      // Check wallet balance
      _checkWalletBalance();
      
    } catch (e) {
      print('⚠️ Background init error: $e');
      // Ignore - app continues working
    }
  }

  // Check wallet balance in background (non-blocking)
  Future<void> _checkWalletBalance() async {
    if (_userId == null) return;
    
    try {
      final balance = await _walletService.getBalance(_userId!).timeout(
        const Duration(seconds: 3),
        onTimeout: () => 5000.0,
      );
      if (mounted) {
        setState(() {
          _walletBalance = balance;
        });
        
        // Show insufficient balance dialog if needed (non-blocking)
        if (_walletBalance < 25.0 && _messages.isEmpty) {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Low Balance'),
                  content: Text(
                    'Your balance is low (₹${_walletBalance.toStringAsFixed(2)}). You may need to recharge soon.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Continue'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/wallet/recharge');
                      },
                      child: const Text('Recharge'),
                    ),
                  ],
                ),
              );
            }
          });
        }
      }
    } catch (e) {
      print('⚠️ Background wallet check failed: $e');
      // Ignore - use default balance
    }
  }

  // Load welcome message asynchronously (non-blocking)
  Future<void> _loadWelcomeMessage() async {
    try {
      final geminiService = ref.read(geminiServiceProvider);
      final welcomeMessage = await geminiService.getWelcomeMessage().timeout(
        const Duration(seconds: 10),
        onTimeout: () => '🙏 Namaste! Welcome to AI Pandit.\n\nI am your Vedic Astrology guide. How may I help you today?',
      );
      
      if (mounted && _currentSession != null) {
        final aiMessage = AIChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          message: welcomeMessage,
          isUser: false,
          timestamp: DateTime.now(),
        );
        setState(() {
          _messages.add(aiMessage);
        });
        await _chatService.addMessage(_currentSession!.id, aiMessage);
        _scrollToBottom();
      }
    } catch (e) {
      print('⚠️ Error loading welcome message: $e');
      // Use fallback welcome message
      if (mounted && _currentSession != null) {
        final aiMessage = AIChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          message: '🙏 Namaste! Welcome to AI Pandit.\n\nI am your Vedic Astrology guide. How may I help you today?',
          isUser: false,
          timestamp: DateTime.now(),
        );
        setState(() {
          _messages.add(aiMessage);
        });
        await _chatService.addMessage(_currentSession!.id, aiMessage);
        _scrollToBottom();
      }
    }
  }

  void _startCostTimer() {
    _costTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _currentSession != null && _currentSession!.isActive) {
        setState(() {
          _elapsedSeconds++;
          _currentCost = _currentSession!.calculateCost();
        });
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _costTimer?.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _userId == null || _currentSession == null) return;
    
    final messageText = _messageController.text.trim();
    _messageController.clear();

    // Add user message
    final userMessage = AIChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: messageText,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
    });
    
    await _chatService.addMessage(_currentSession!.id, userMessage);
    _scrollToBottom();

    // Get AI response from Gemini
    try {
      // Check if user is asking for Kundli - if so, try to get their birth details
      String enhancedMessage = messageText;
      if (messageText.toLowerCase().contains(RegExp(r'(kundli|birth chart|horoscope|janam kundli|rasi|lagna)'))) {
        try {
          // Get actual Firebase user ID (not guest_ prefix)
          final user = FirebaseAuth.instance.currentUser;
          final firestoreUserId = user?.uid ?? _userId;
          
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(firestoreUserId)
              .get();
          
          if (userDoc.exists) {
            final userData = userDoc.data();
            final dob = userData?['dateOfBirth'] as Timestamp?;
            final place = userData?['placeOfBirth'] as String?;
            final time = userData?['timeOfBirth'] as String?;
            final name = userData?['displayName'] as String? ?? 'User';
            
            if (dob != null && place != null && time != null) {
              enhancedMessage = '''
$messageText

[I have my birth details:
Name: $name
Date of Birth: ${dob.toDate().day}/${dob.toDate().month}/${dob.toDate().year}
Time of Birth: $time
Place of Birth: $place

Please use these details to generate my complete Kundli analysis.]
''';
            }
          }
        } catch (e) {
          // If we can't get birth details, continue with original message
          print('Could not fetch birth details: $e');
        }
      }
      
      // Build conversation history for Gemini
      final conversationHistory = _messages
          .where((m) => m.id != _messages.last.id) // Exclude current message
          .map((m) => {
                'isUser': m.isUser.toString(),
                'message': m.message,
              })
          .toList();

      // Use Gemini AI as the primary AI agent
      final geminiService = ref.read(geminiServiceProvider);
      print('📤 Sending message to Gemini: ${enhancedMessage.substring(0, enhancedMessage.length > 100 ? 100 : enhancedMessage.length)}...');
      final aiResponse = await geminiService.sendMessage(
        enhancedMessage,
        conversationHistory,
        panditId: widget.panditId,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('❌ Gemini API timeout after 30 seconds');
          return 'I apologize, but the response is taking longer than expected. Please try again or check your internet connection.';
        },
      );
      print('📥 Received response from Gemini: ${aiResponse.substring(0, aiResponse.length > 100 ? 100 : aiResponse.length)}...');

      final aiMessage = AIChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(aiMessage);
        _isTyping = false;
      });
      
      await _chatService.addMessage(_currentSession!.id, aiMessage);
      _scrollToBottom();
    } catch (e) {
      setState(() => _isTyping = false);
      _showError('Failed to get AI response: ${e.toString()}');
      print('Error getting AI response: $e');
    }
  }

  Future<void> _endSession() async {
    if (_userId == null || _currentSession == null) return;

    // Refresh wallet balance
    _walletBalance = await _walletService.getBalance(_userId!);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('End AI Pandit Session?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Duration: ${(_elapsedSeconds / 60).toStringAsFixed(2)} minutes'),
            const SizedBox(height: 8),
            Text(
              'Total Cost: ₹${_currentCost.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppTheme.primaryOrange,
              ),
            ),
            const SizedBox(height: 8),
            Text('Wallet Balance: ₹${_walletBalance.toStringAsFixed(2)}'),
            if (_walletBalance < _currentCost)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '⚠️ Insufficient balance! Please recharge.',
                  style: TextStyle(
                    color: AppTheme.errorRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('End & Pay'),
          ),
        ],
      ),
    );

    if (confirmed == true && _currentSession != null) {
      setState(() => _isLoading = true);
      
      final result = await _chatService.endSession(_userId!, _currentSession!.id);
      
      setState(() => _isLoading = false);
      
      if (result['success']) {
        _costTimer?.cancel();
        
        // Refresh wallet balance in provider
        ref.invalidate(walletBalanceProvider);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Session ended. ₹${result['totalCost'].toStringAsFixed(2)} deducted from wallet.',
              ),
              backgroundColor: AppTheme.successGreen,
            ),
          );
          context.pop();
        }
      } else {
        _showError(result['message'] ?? 'Failed to end session');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI Pandit', style: TextStyle(fontSize: 18)),
            Text(
              '₹25/min • ₹${_currentCost.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final walletBalanceAsync = ref.watch(walletBalanceProvider);
              final balance = walletBalanceAsync.valueOrNull ?? _walletBalance;
              return Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '₹${balance.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () => context.push('/ai-pandit/voice-call'),
            tooltip: 'Switch to Voice Call',
          ),
          IconButton(
            icon: const Icon(Icons.stop_circle_outlined),
            onPressed: _endSession,
            tooltip: 'End Session',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Cost indicator
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.warningAmber.withOpacity(0.1),
                        AppTheme.accentGoldLight,
                      ],
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: AppTheme.warningAmber.withOpacity(0.3),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer, size: 16, color: AppTheme.warningAmber),
                      const SizedBox(width: 8),
                      Text(
                        '${(_elapsedSeconds ~/ 60)}:${(_elapsedSeconds % 60).toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.neutralDark,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Cost: ₹${_currentCost.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryOrange,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Messages
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isTyping) {
                        return _buildTypingIndicator();
                      }
                      return _buildMessage(_messages[index]);
                    },
                  ),
                ),
                
                // Input field
                _buildMessageInput(),
              ],
            ),
    );
  }

  Widget _buildMessage(AIChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: message.isUser
              ? AppTheme.primaryGradient
              : null,
          color: message.isUser ? null : AppTheme.neutralSoft,
          borderRadius: BorderRadius.circular(20),
          boxShadow: message.isUser ? AppTheme.glowShadow : AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isUser)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: AppTheme.goldGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: AppTheme.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'AI Pandit',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: AppTheme.accentGold,
                    ),
                  ),
                ],
              ),
            if (!message.isUser) const SizedBox(height: 8),
            Text(
              message.message,
              style: TextStyle(
                color: message.isUser ? AppTheme.white : AppTheme.neutralDark,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: message.isUser
                    ? AppTheme.white.withOpacity(0.7)
                    : AppTheme.neutralLight,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.neutralSoft,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.softShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(1),
            const SizedBox(width: 4),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        final delay = index * 0.2;
        final animValue = (value - delay).clamp(0.0, 1.0);
        return Opacity(
          opacity: 0.3 + (animValue * 0.7),
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.primaryOrange,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted && _isTyping) {
          setState(() {});
        }
      },
    );
  }

  Widget _buildMessageInput() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Quick Action Buttons
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: AppTheme.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _QuickActionChip(
                  label: 'My Kundli',
                  icon: Icons.stars,
                  onTap: () {
                    _messageController.text = 'Generate my Kundli and give me complete analysis';
                    _sendMessage();
                  },
                ),
                const SizedBox(width: 8),
                _QuickActionChip(
                  label: 'Future Prediction',
                  icon: Icons.auto_awesome,
                  onTap: () {
                    _messageController.text = 'What does my future hold? Give me predictions';
                    _sendMessage();
                  },
                ),
                const SizedBox(width: 8),
                _QuickActionChip(
                  label: 'Numerology',
                  icon: Icons.numbers,
                  onTap: () {
                    _messageController.text = 'Calculate my numerology and give me detailed reading';
                    _sendMessage();
                  },
                ),
                const SizedBox(width: 8),
                _QuickActionChip(
                  label: 'Current Planets',
                  icon: Icons.wb_twilight,
                  onTap: () {
                    _messageController.text = 'Tell me about current planetary positions and their effects';
                    _sendMessage();
                  },
                ),
                const SizedBox(width: 8),
                _QuickActionChip(
                  label: 'Moon Phase',
                  icon: Icons.brightness_2,
                  onTap: () {
                    _messageController.text = 'What is the current moon phase and its significance?';
                    _sendMessage();
                  },
                ),
              ],
            ),
          ),
        ),
        // Input Field
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.white,
            boxShadow: AppTheme.mediumShadow,
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.neutralSoft,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Ask your question...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.glowShadow,
                  ),
                  child: IconButton(
                    onPressed: _isTyping ? null : _sendMessage,
                    icon: const Icon(Icons.send),
                    color: AppTheme.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primaryOrange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryOrange.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppTheme.primaryOrange),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

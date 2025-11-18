import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../core/theme/app_theme.dart';
import '../../models/ai_chat_model.dart';
import '../../services/gemini_service.dart';
import '../../services/custom_ai_service.dart';
import '../../services/wallet_service.dart';
import '../../widgets/modern_components.dart';

class AIPanditChatScreen extends StatefulWidget {
  const AIPanditChatScreen({super.key});

  @override
  State<AIPanditChatScreen> createState() => _AIPanditChatScreenState();
}

class _AIPanditChatScreenState extends State<AIPanditChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiService _geminiService = GeminiService();
  final CustomAIService _customAIService = CustomAIService();
  bool _useCustomAI = true; // Toggle to use custom AI instead of Gemini
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
  
  final String _userId = 'demo_user_123'; // Replace with actual user ID

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    setState(() => _isLoading = true);
    
    // Check wallet balance
    _walletBalance = await _walletService.getBalance(_userId);
    
      // Check for active session or create new one
    var activeSession = await _chatService.getActiveSession(_userId);
    
    if (activeSession != null) {
      _currentSession = activeSession;
      _messages = activeSession.messages;
      _startCostTimer();
    } else {
      _currentSession = await _chatService.startSession(_userId);
      // Add welcome message
      final welcomeMessage = _useCustomAI 
          ? await _customAIService.getWelcomeMessage()
          : await _geminiService.getWelcomeMessage();
      final aiMessage = AIChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: welcomeMessage,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(aiMessage);
      await _chatService.addMessage(_currentSession!.id, aiMessage);
      _startCostTimer();
    }
    
    setState(() => _isLoading = false);
    _scrollToBottom();
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
    if (_messageController.text.trim().isEmpty) return;
    
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

      // Get AI response
    try {
      final conversationHistory = _messages
          .map((m) => {
                'isUser': m.isUser.toString(),
                'message': m.message,
              })
          .toList();

      String aiResponse;
      if (_useCustomAI) {
        // Use custom AI trained on Kundli/Lagna data
        aiResponse = await _customAIService.sendMessage(
          messageText,
          conversationHistory,
        );
      } else {
        // Fallback to Gemini (if needed)
        aiResponse = await _geminiService.sendMessage(
          messageText,
          conversationHistory,
        );
      }

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
      _showError('Failed to get response. Please try again.');
    }
  }

  Future<void> _endSession() async {
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
      
      final result = await _chatService.endSession(_userId, _currentSession!.id);
      
      setState(() => _isLoading = false);
      
      if (result['success']) {
        _costTimer?.cancel();
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
        _showError(result['message']);
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
          Container(
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
                  '₹${_walletBalance.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
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
    return Container(
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
    );
  }
}

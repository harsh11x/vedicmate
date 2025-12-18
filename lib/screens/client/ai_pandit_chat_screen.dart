import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:ui';
import 'dart:math' as Math;
import '../../core/theme/app_theme.dart';
import '../../models/ai_chat_model.dart';
import '../../services/wallet_service.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/api_providers.dart';
import '../../widgets/modern_components.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/ai_pandit_model.dart';

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
  bool _usingFallback = false;
  double _walletBalance = 0.0;
  AIChatSession? _currentSession;
  Timer? _costTimer;
  double _currentCost = 0.0;
  int _elapsedSeconds = 0;
  
  String? _userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(() => _initializeChat());
    });
  }

  Future<void> _initializeChat() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      
      String userId;
      if (user == null) {
        userId = 'guest_temp_${DateTime.now().millisecondsSinceEpoch}';
      } else {
        userId = user.isAnonymous ? 'guest_${user.uid}' : user.uid;
      }
      
      setState(() {
        _userId = userId;
        _walletBalance = 5000.0;
      });
      
      _currentSession = AIChatSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        startTime: DateTime.now(),
      );
      _startCostTimer();
      
      setState(() => _isLoading = false);
      
      _initializeInBackground();
      
    } catch (e) {
      print('❌ Error in _initializeChat: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _initializeInBackground() async {
    if (!mounted || _userId == null) return;
    
    try {
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
        try {
          await _chatService.startSession(_userId!).timeout(
            const Duration(seconds: 1),
            onTimeout: () => _currentSession!,
          );
        } catch (e) {
          print('⚠️ Session save error: $e');
        }
      }
      
      _loadWelcomeMessage();
      _checkWalletBalance();
      
    } catch (e) {
      print('⚠️ Background init error: $e');
    }
  }

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
    }
  }

  Future<void> _loadWelcomeMessage() async {
    try {
      // Try Gemini first
      final geminiService = ref.read(geminiServiceProvider);
      String welcomeMessage;
      
      try {
        welcomeMessage = await geminiService.getWelcomeMessage().timeout(
          const Duration(seconds: 5),
        );
      } catch (e) {
        // Fallback to Custom AI
        print('⚠️ Gemini welcome failed, using fallback: $e');
        final customAI = ref.read(customAIServiceProvider);
        welcomeMessage = await customAI.getWelcomeMessage();
        _usingFallback = true;
      }
      
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

    // AI Processing
    try {
      String aiResponse;
      
      // 1. Prepare context
      String enhancedMessage = messageText;
      if (messageText.toLowerCase().contains(RegExp(r'(kundli|birth chart|horoscope|janam kundli|rasi|lagna)'))) {
        try {
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
              enhancedMessage = '''$messageText
[Context: Name: $name, DOB: ${dob.toDate()}, Time: $time, Place: $place]''';
            }
          }
        } catch (e) {
          print('Could not fetch birth details: $e');
        }
      }
      
      final conversationHistory = _messages
          .where((m) => m.id != _messages.last.id)
          .map((m) => {'isUser': m.isUser.toString(), 'message': m.message})
          .toList();

      // 2. Try Gemini
      try {
        if (_usingFallback) throw Exception('Already using fallback');
        
        final geminiService = ref.read(geminiServiceProvider);
        print('📤 Sending to Gemini...');
        aiResponse = await geminiService.sendMessage(
          enhancedMessage,
          conversationHistory,
          panditId: widget.panditId,
        ).timeout(const Duration(seconds: 15));
        
      } catch (e) {
        // 3. Fallback to Custom AI
        print('⚠️ Gemini failed ($e), switching to fallback...');
        _usingFallback = true;
        
        final customAI = ref.read(customAIServiceProvider);
        aiResponse = await customAI.sendMessage(
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

      if (mounted) {
        setState(() {
          _messages.add(aiMessage);
          _isTyping = false;
        });
        
        await _chatService.addMessage(_currentSession!.id, aiMessage);
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTyping = false);
        _showError('AI Connection Error. Please try again.');
        print('Critical AI Error: $e');
      }
    }
  }

  Future<void> _endSession() async {
    if (_userId == null || _currentSession == null) return;

    _walletBalance = await _walletService.getBalance(_userId!);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppTheme.white,
        title: const Text('End Consultation?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Duration', '${(_elapsedSeconds / 60).toStringAsFixed(1)} mins'),
            const SizedBox(height: 8),
            _buildInfoRow('Total Cost', '₹${_currentCost.toStringAsFixed(2)}', isBold: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continue Chat', style: TextStyle(color: AppTheme.neutralMedium)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
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
        ref.invalidate(walletBalanceProvider);
        if (mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Session ended. ₹${result['totalCost'].toStringAsFixed(2)} paid.'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
      } else {
        _showError(result['message'] ?? 'Failed to end session');
      }
    }
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.neutralMedium)),
        Text(value, style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          color: isBold ? AppTheme.primaryOrange : AppTheme.neutralDark,
          fontSize: isBold ? 16 : 14,
        )),
      ],
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.celestialVoid, // Dark celestial background
      body: Stack(
        children: [
          // 1. Cosmic Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.celestialVoid,
                  AppTheme.celestialBlue,
                  Colors.black,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          
          // 2. Stars / Stardust Overlay (Optional: using static noise or dots)
          Positioned.fill(
             child: Opacity(
               opacity: 0.1,
               child: Image.network(
                 'https://www.transparenttextures.com/patterns/stardust.png',
                 repeat: ImageRepeat.repeat,
                 errorBuilder: (_,__,___) => const SizedBox(),
               ),
             ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                _buildCostIndicator(),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isTyping) {
                        return _buildTypingIndicator();
                      }
                      final prevMessage = index > 0 ? _messages[index - 1] : null;
                      final isSequence = prevMessage != null && prevMessage.isUser == _messages[index].isUser;
                      
                      return _buildMessage(_messages[index], isSequence);
                    },
                  ),
                ),
                _buildMessageInput(),
              ],
            ),
          ),
          
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange)),
            ),
        ],
      ),
    );
  }

  Widget _buildMessage(AIChatMessage message, bool isSequence) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Align(
        alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(
            bottom: isSequence ? 4 : 16,
            left: message.isUser ? 50 : 0,
            right: message.isUser ? 0 : 50,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: message.isUser 
              ? BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: const Radius.circular(20),
                    bottomRight: const Radius.circular(4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryOrange.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                )
              : AppTheme.glassMorphism.copyWith(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(20),
                  ),
                   gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.message,
                style: GoogleFonts.inter(
                  color: Colors.white, // Always white text on dark/glass backgrounds
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: AppTheme.glassMorphism.copyWith(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
             _TypingDots(), // Using local widget
             const SizedBox(width: 8),
             Text(
               'AI is typing...',
               style: GoogleFonts.inter(
                 fontSize: 12,
                 color: Colors.white.withOpacity(0.7),
               ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  _QuickActionChip('🔮 Future', onTap: () => _fillAndSend('Predict my future based on my chart')),
                  const SizedBox(width: 8),
                  _QuickActionChip('❤️ Love', onTap: () => _fillAndSend('How is my love life looking?')),
                  const SizedBox(width: 8),
                  _QuickActionChip('💼 Career', onTap: () => _fillAndSend('What are my career prospects?')),
                  const SizedBox(width: 8),
                   _QuickActionChip('✨ Luck', onTap: () => _fillAndSend('What are my lucky colors and numbers?')),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.neutralSoft,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.neutralLight.withOpacity(0.3)),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Ask anything...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        isDense: true,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryOrange,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _fillAndSend(String text) {
    _messageController.text = text;
    _sendMessage();
  }
  Widget _buildCostIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.white.withOpacity(0.05),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_outlined, size: 14, color: AppTheme.accentGold),
          const SizedBox(width: 4),
          Text(
            '${(_elapsedSeconds ~/ 60).toString().padLeft(2, '0')}:${(_elapsedSeconds % 60).toString().padLeft(2, '0')}',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
          ),
          const Spacer(),
          Text(
            'Cost: ₹${_currentCost.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: 12, 
              color: AppTheme.primaryOrange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
     AIPanditModel? pandit;
     if (widget.panditId != null) {
       pandit = AIPandits.getById(widget.panditId!);
     }
     
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primaryOrange.withOpacity(0.2),
            backgroundImage: pandit != null ? (pandit.profileImage.startsWith('assets/') ? AssetImage(pandit.profileImage) as ImageProvider : NetworkImage(pandit.profileImage)) : null,
            child: pandit == null ? const Icon(Icons.person, size: 16, color: AppTheme.primaryOrange) : null,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pandit?.name ?? 'AI Vedic Pandit',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppTheme.successGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Online',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.phone, color: Colors.white),
          onPressed: () => context.push('/ai-pandit/voice-call?panditId=${widget.panditId}'),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: _endSession,
        ),
      ],
    );
  }
}



class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final double start = index * 0.2;
              final double end = start + 0.4;
              final double value = _controller.value;
              
              double opacity = 0.2;
              if (value >= start && value <= end) {
                // Peak is in the middle of the interval
                final double t = (value - start) / 0.4;
                opacity = 0.2 + (0.8 * Math.sin(t * Math.pi));
              }

              return Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(opacity),
                  shape: BoxShape.circle,
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

class LoadingAnimationWidget extends StatefulWidget {
  @override
  _LoadingAnimationWidgetState createState() => _LoadingAnimationWidgetState();
}

class _LoadingAnimationWidgetState extends State<LoadingAnimationWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(3, (index) {
        return ScaleTransition(
          scale: DelayTween(begin: 0.5, end: 1.0, delay: index * 0.2).animate(_controller),
          child: Container(
            width: 8, height: 8,
            decoration: const BoxDecoration(color: AppTheme.primaryOrange, shape: BoxShape.circle),
          ),
        );
      }),
    );
  }
}

class DelayTween extends Tween<double> {
  final double delay;
  DelayTween({double? begin, double? end, required this.delay}) : super(begin: begin, end: end);

  @override
  double lerp(double t) {
    return super.lerp((Math.sin((t - delay) * 2 * Math.pi) + 1) / 2);
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip(this.label, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primaryOrange.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryOrange.withOpacity(0.2)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppTheme.primaryOrange,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

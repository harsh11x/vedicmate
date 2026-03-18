import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:ui';
import 'dart:math' as Math;
import '../../core/theme/app_theme.dart';
import '../../models/ai_chat_model.dart';
import '../../services/wallet_service.dart'; // contains AIChatService (wallet deductions disabled in service)
import '../../providers/wallet_provider.dart'; // for currentUserIdProvider
import '../../providers/api_providers.dart';
import '../../widgets/modern_components.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/ai_pandit_model.dart';
import '../../widgets/numerology_input_dialog.dart';
import '../../widgets/ai_message_widgets.dart';
import '../../utils/profile_completeness.dart';
import '../../widgets/language_selector.dart';
import 'kundli/widgets/kundli_details_sheet.dart';

class AIPanditChatScreen extends ConsumerStatefulWidget {
  final String? panditId;
  
  const AIPanditChatScreen({super.key, this.panditId});

  @override
  ConsumerState<AIPanditChatScreen> createState() => _AIPanditChatScreenState();
}

class _AIPanditChatScreenState extends ConsumerState<AIPanditChatScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  final AIChatService _chatService = AIChatService();
  
  // Get the actual pandit ID to use (default to first pandit if not provided)
  String get _panditId => widget.panditId ?? 'ai_pandit_1';

  List<AIChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;
  bool _usingFallback = false;
  AIChatSession? _currentSession;
  bool _isChatStarted = false; // Whether user has started the chat
  bool _isViewingOnly = false; // Whether user is just viewing history
  bool _isStartingChat = false; // Whether chat is currently being started
  String _currentLanguage = 'en';
  
  String? _userId;
  static const String _bilingualStyleHint =
      'Reply in casual bilingual Hinglish (Hindi+English mix). '
      'Friendly, helpful, and practical. Not pure Hindi. Use simple everyday language.';
  Map<String, dynamic>? _userProfile;

  String _buildUserContextBlock() {
    final p = _userProfile;
    if (p == null || p.isEmpty) return '';
    final name = (p['name'] ?? '').toString().trim();
    final email = (p['email'] ?? '').toString().trim();
    final phone = (p['phone'] ?? '').toString().trim();
    final birth = (p['birth_details'] ?? p['birthDetails']);
    final numerology = (p['numerology'] ?? p['numerologyProperties']);

    return [
      'USER_CONTEXT (use for personalization; do not ask again if present):',
      if (name.isNotEmpty) '- Name: $name',
      if (email.isNotEmpty) '- Email: $email',
      if (phone.isNotEmpty) '- Phone: $phone',
      if (birth != null) '- Birth details: $birth',
      if (numerology != null) '- Numerology: $numerology',
    ].join('\n');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(() => _initializeChat());
    });
    

  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Strict Session Termination: End if app is paused, minimized or detached
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
       print('📱 App backgrounded/closed: Ending session strictly.');
       _endSession(isBackground: true);
    }

    // No wallet refresh needed (free mode)
  }

  // ref.listen should be placed in the build method


  @override
  void dispose() {
    print('👋 Chat Screen Disposing: Ending session.');
    _endSession(); // Ensure session ends when screen is closed
    
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _messageFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Use the provider's userId to ensure consistency
      final providerUserId = ref.read(currentUserIdProvider);
      String userId;
      
      if (providerUserId != null) {
        userId = providerUserId;
      } else {
        // Fallback to Firebase Auth
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          userId = 'guest_temp_${DateTime.now().millisecondsSinceEpoch}';
        } else {
          userId = user.isAnonymous ? 'guest_${user.uid}' : user.uid;
        }
      }
      
      setState(() {
        _userId = userId;
      });
      print('✅ Chat screen using userId: $userId');
      
      // Get or create session for this specific pandit
      print('📝 Getting or creating session for userId: $userId, panditId: $_panditId');
      try {
        _currentSession = await _chatService.getOrCreateSession(userId, _panditId);
        if (_currentSession != null) {
          print('✅ Session obtained: ${_currentSession!.id}, isStarted: ${_currentSession!.isStarted}, isActive: ${_currentSession!.isActive}');
        } else {
          print('❌ Session is null after getOrCreateSession');
          throw Exception('Failed to create session');
        }
      } catch (e) {
        print('❌ Error getting/creating session: $e');
        throw e;
      }
      
      // Load previous messages for this pandit
      if (_currentSession != null && _currentSession!.messages.isNotEmpty) {
        print('📨 Loading ${_currentSession!.messages.length} previous messages');
        setState(() {
          _messages = _currentSession!.messages;
          _isChatStarted = _currentSession!.isStarted;
          _isViewingOnly = !_currentSession!.isStarted;
        });
      } else {
        print('ℹ️ No previous messages found');
      }
      
      setState(() => _isLoading = false);
      
      // Check profile completeness for AI enhancements
      _checkProfileCompleteness();

      // Fetch user profile once for personalization (best-effort)
      try {
        _userProfile = await ProfileCompleteness.getUserProfileForAI();
      } catch (_) {}
      
      // Don't show dialog automatically - wait for user to click Start button
      if (_isChatStarted) {
        _loadWelcomeMessage();
      }
      
    } catch (e) {
      print('❌ Error in _initializeChat: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showStartChatDialog() async {
    // Don't show dialog if chat is already started
    if (_isChatStarted && !_isViewingOnly) {
      print('ℹ️ Chat already started, skipping dialog');
      return;
    }
    
    // Don't show dialog if chat is currently being started
    if (_isStartingChat) {
      print('ℹ️ Chat is already being started, skipping dialog');
      return;
    }
    
    if (!mounted) {
      print('❌ Cannot show dialog: widget not mounted');
      return;
    }
    
    print('📱 Showing start chat dialog');
    final shouldStart = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryOrange, AppTheme.accentGold],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Start Chat?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Would you like to start a chat with this AI Pandit?',
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.neutralMedium,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'View History Only',
              style: TextStyle(color: AppTheme.neutralMedium),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Start Chat'),
          ),
        ],
      ),
    );

    if (shouldStart == true) {
      print('✅ User chose to start chat');
      setState(() {
        _isStartingChat = true;
      });
      
      await _startChat();
      
      setState(() {
        _isStartingChat = false;
      });
      
      // Verify chat actually started
      if (!_isChatStarted) {
        print('⚠️ Chat did not start after _startChat() call');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to start chat. Please try again.'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      } else {
        print('✅ Chat started successfully!');
      }
    } else {
      print('ℹ️ User chose to view history only');
      setState(() {
        _isViewingOnly = true;
      });
    }
  }

  Future<void> _startChat() async {
    print('🚀 Starting chat...');
    
    // Ensure we have userId
    if (_userId == null) {
      print('❌ Cannot start chat: _userId is null, trying to get it...');
      final providerUserId = ref.read(currentUserIdProvider);
      if (providerUserId != null) {
        setState(() {
          _userId = providerUserId;
        });
        print('✅ Got userId from provider: $_userId');
      } else {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final userId = user.isAnonymous ? 'guest_${user.uid}' : user.uid;
          setState(() {
            _userId = userId;
          });
          print('✅ Got userId from Firebase: $_userId');
        } else {
          print('❌ Cannot start chat: No user found');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error: User not found. Please try again.'),
                backgroundColor: AppTheme.errorRed,
              ),
            );
          }
          return;
        }
      }
    }
    
    // Create session if it doesn't exist
    if (_currentSession == null) {
      print('⚠️ Session not found, creating new session...');
      try {
        _currentSession = await _chatService.getOrCreateSession(_userId!, _panditId);
        print('✅ Session created: ${_currentSession?.id}');
      } catch (e) {
        print('❌ Error creating session: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating session: $e'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
        return;
      }
    }
    
    if (_currentSession == null) {
      print('❌ Cannot start chat: Failed to create session');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Failed to create chat session. Please try again.'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
      return;
    }

    try {
      // Mark session as started immediately
      _currentSession!.isStarted = true;
      _currentSession!.isActive = true;
      await _chatService.saveSession(_currentSession!);
      print('✅ Session marked as started and saved');

      if (mounted) {
        setState(() {
          _isChatStarted = true;
          _isViewingOnly = false;
        });
        print('✅ State updated: _isChatStarted=true, _isViewingOnly=false');
      }

      // Add welcome message if no messages exist
      if (_messages.isEmpty) {
        _loadWelcomeMessage();
      }
      
      // Focus the text field after starting chat
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _messageFocusNode.requestFocus();
            print('✅ Text field focused');
          }
        });
      }
      
      print('✅ Chat started successfully!');
    } catch (e) {
      print('❌ Error starting chat: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting chat: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _startWalletCheckTimer() {
    // Wallet system removed (free mode)
  }

  Future<void> _stopChatDueToInsufficientFunds() async {
    // Wallet system removed (free mode)
  }

  void _showInsufficientFundsDialog() {
    // Wallet system removed (free mode)
  }


  // Wallet system removed (free mode)

  Future<void> _loadWelcomeMessage() async {
    try {
      final customAI = ref.read(customAIServiceProvider);
      final welcomeMessage = await customAI.getWelcomeMessage(panditId: _panditId);
      
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


  // NEW: Strict Session Ending Logic
  Future<void> _endSession({bool isBackground = false}) async {
    if (_currentSession == null || !_currentSession!.isActive) return;
    
    // Stop timers immediately
    
    print('🛑 Ending session ${_currentSession!.id} (Background: $isBackground)');
    
    try {
      await _chatService.endSession(_userId!, _currentSession!.id);
      
      // Update local state if UI is still active
      if (mounted) {
        setState(() {
          _isChatStarted = false;
          _isViewingOnly = true;
        });
      }
    } catch (e) {
      print('❌ Error strictly ending session: $e');
    }
  }

  // Check profile completeness for AI enhancements
  Future<void> _checkProfileCompleteness() async {
    // User requested to disable profile completion popup
    // We will just log the status for debugging purposes
    final pandit = AIPandits.getById(_panditId);
    final category = pandit?.category ?? '';
    
    final isNumerologyPandit = category == 'Numerology';
    final isVedicPandit = ['Vedic Astrology', 'Lal Kitab'].contains(category);
    
    try {
      final profileCheck = await ProfileCompleteness.checkProfile(
        checkNumerology: isNumerologyPandit,
        checkBirthDetails: isVedicPandit,
      );
      
      if (!profileCheck.isComplete) {
        print('ℹ️ Profile incomplete for AI context: ${profileCheck.missingFields}');
        // Dialog suppressed as per user request
      } else {
        print('✅ Profile complete for AI context');
      }
    } catch (e) {
      print('⚠️ Error checking profile completeness: $e');
    }
  }

  void _showProfileCompletionDialog(String missingFields) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person_outline, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Complete Your Profile',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'For personalized AI predictions, please complete your profile with:',
              style: TextStyle(fontSize: 15, color: AppTheme.neutralMedium),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryOrange.withOpacity(0.2)),
              ),
              child: Text(
                missingFields,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.neutralDark,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/profile/edit');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Complete Profile'),
          ),
        ],
      ),
    );
  }

  // NEW: Clear Chat Implementation
  Future<void> _clearChat() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat History?'),
        content: const Text(
          'This will permanently delete all messages for this Pandit. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorRed),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (_userId != null) {
        // End active session first if running
        await _endSession();
        
        await _chatService.clearPanditHistory(_userId!, _panditId);
        setState(() {
          _messages.clear();
          _currentSession = null;
          _isChatStarted = false;
          _isViewingOnly = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat history cleared')),
        );
        
        // Re-initialize to reset state correctly
        _initializeChat(); 
      }
    }
  }

  // Cost timer removed (free mode)


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
    // Check if chat is started
    if (!_isChatStarted || _isViewingOnly) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please start the chat to send messages'),
          backgroundColor: AppTheme.warningAmber,
          action: SnackBarAction(
            label: 'Start Chat',
            textColor: Colors.white,
            onPressed: () => _startChat(),
          ),
        ),
      );
      return;
    }

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
      
      // Ensure we have profile cached (best-effort)
      _userProfile ??= await ProfileCompleteness.getUserProfileForAI();
      
      final conversationHistory = _messages
          .where((m) => m.id != _messages.last.id)
          .map((m) => {'isUser': m.isUser.toString(), 'message': m.message})
          .toList();

      final context = _buildUserContextBlock();
      final styledMessage = [
        _bilingualStyleHint,
        'Do NOT repeat "Welcome to Vedic Mate" or generic greetings unless the user greets you.',
        if (context.isNotEmpty) context,
        'User said: $messageText',
      ].join('\n\n');

      // 2. Try Local AI (backend)
      try {
        if (_usingFallback) throw Exception('Already using fallback');
        
        final localAIService = ref.read(localAIServiceProvider);
        print('📤 Sending to Local AI (Qwen 2.5)...');
        aiResponse = await localAIService.sendMessage(
          styledMessage, // enforce bilingual casual style
          conversationHistory,
          panditId: _panditId,
          userId: _userId,
          targetLanguage: _currentLanguage,
          userProfile: _userProfile, // Pass profile object
        ).timeout(const Duration(seconds: 60));
        
      } catch (e) {
        // 3. Fallback to Gemini (if configured), else Custom AI
        try {
          final gemini = ref.read(geminiServiceProvider);
          print('⚠️ Local AI failed ($e), trying Gemini...');
          aiResponse = await gemini.sendMessage(
            styledMessage,
            conversationHistory,
            panditId: _panditId,
          ).timeout(const Duration(seconds: 30));
        } catch (e2) {
          print('⚠️ Gemini failed ($e2), using Custom AI fallback...');
          _usingFallback = true;
          final customAI = ref.read(customAIServiceProvider);
          aiResponse = await customAI.sendMessage(
            styledMessage,
            conversationHistory,
            panditId: _panditId,
          );
        }
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
        setState(() {
          _isTyping = false;
          _messages.add(AIChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            message: 'I apologize, I\'m having trouble connecting right now. Please check your internet and try again. 🙏',
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
        _showError('AI connection issue. Please try again.');
        print('Critical AI Error: $e');
        _scrollToBottom();
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
      backgroundColor: AppTheme.neutralSoft,
      body: Stack(
          children: [
          // Beautiful gradient background matching app theme
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                      colors: [
                  AppTheme.white,
                  AppTheme.primarySoft,
                  AppTheme.neutralSoft,
                ],
                stops: const [0.0, 0.3, 1.0],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                if (!_isChatStarted) _buildStartButton(),
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
              color: AppTheme.neutralDark.withOpacity(0.3),
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
                  color: message.isUser 
                      ? Colors.white // White text for user messages (gradient background)
                      : AppTheme.neutralDark, // Dark text for AI messages (light background)
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
                  color: message.isUser 
                      ? Colors.white.withOpacity(0.5) // White timestamp for user messages
                      : AppTheme.neutralMedium, // Dark timestamp for AI messages
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
        margin: const EdgeInsets.only(bottom: 16, left: 0, right: 50),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryOrange.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryOrange.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
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
                 color: AppTheme.neutralMedium,
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
            if (!_panditId.startsWith('ai_pandit_')) ...[
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
            ],
            Row(
              children: [
                if (_isChatStarted && !_isViewingOnly)
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.neutralMedium.withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.add, color: AppTheme.primaryOrange, size: 20),
                    ),
                    onPressed: () async {
                      final result = await showModalBottomSheet<String>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const KundliDetailsSheet(),
                      );
                      
                      if (result != null && result.isNotEmpty) {
                        _fillAndSend("Here are my birth details for Kundli analysis:\n\n$result");
                      }
                    },
                  ),
                Expanded(
              child: Container(
                decoration: BoxDecoration(
                      color: AppTheme.neutralSoft,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.forestBackground.withOpacity(0.3)),
                    ),
                    child: TextField(
                      controller: _messageController,
                      focusNode: _messageFocusNode,
                      readOnly: !_isChatStarted || _isViewingOnly,
                      enabled: true, // Always enabled to allow focus
                      decoration: InputDecoration(
                        hintText: _isChatStarted && !_isViewingOnly 
                            ? 'Ask anything...' 
                            : 'Tap to start chat...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        isDense: true,
                        ),
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) {
                        if (_isChatStarted && !_isViewingOnly) {
                          _sendMessage();
                        }
                      },
                      onTap: () {
                        if (!_isChatStarted || _isViewingOnly) {
                          _showStartChatDialog();
                        } else {
                          // Focus the field when chat is started
                          _messageFocusNode.requestFocus();
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _isChatStarted && !_isViewingOnly ? _sendMessage : () {
                    if (!_isChatStarted) {
                      _showStartChatDialog();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                      gradient: _isChatStarted && !_isViewingOnly 
                          ? AppTheme.primaryGradient
                          : LinearGradient(
                              colors: [
                                AppTheme.forestBackground,
                                AppTheme.forestBackground,
                              ],
                            ),
                      boxShadow: _isChatStarted && !_isViewingOnly ? [
                        const BoxShadow(
                          color: AppTheme.primaryOrange,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        )
                      ] : null,
                    ),
                    child: Icon(
                      Icons.send_rounded, 
                      color: _isChatStarted && !_isViewingOnly 
                          ? Colors.white 
                          : AppTheme.neutralMedium, 
                      size: 22,
                    ),
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
  Widget _buildStartButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border(bottom: BorderSide(color: AppTheme.forestBackground.withOpacity(0.5))),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryOrange.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Free AI Chat',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.successGreen,
                      ),
                    ),
                    Text(
                      'No wallet needed',
                      style: GoogleFonts.inter(fontSize: 11, color: AppTheme.neutralMedium),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: (_isStartingChat || _isChatStarted)
                    ? null
                    : () => _showStartChatDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: (_isStartingChat || _isChatStarted)
                      ? AppTheme.forestBackground
                      : AppTheme.primaryOrange,
                  foregroundColor: (_isStartingChat || _isChatStarted)
                      ? AppTheme.neutralMedium
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: (_isStartingChat || _isChatStarted) ? 0 : 4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isStartingChat)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neutralMedium),
                        ),
                      )
                    else
                      Icon(
                        Icons.play_arrow,
                        size: 18,
                      ),
                    const SizedBox(width: 4),
                    Text(
                      _isStartingChat ? 'Starting...' : 'Start Chat',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      'Language:',
                      style: GoogleFonts.inter(
                        color: AppTheme.neutralMedium,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    LanguageSelector(
                      initialLanguageCode: _currentLanguage,
                      onLanguageSelected: (code, name) {
                        setState(() {
                          _currentLanguage = code;
                        });
                        print('🌐 Chat language set to: $name ($code)');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCostIndicator() {
    return const SizedBox.shrink();
  }

  Widget _buildAppBar() {
     AIPanditModel? pandit;
     pandit = AIPandits.getById(_panditId);
     
    return AppBar(
      backgroundColor: AppTheme.white,
      elevation: 0,
      shadowColor: AppTheme.primaryOrange.withOpacity(0.1),
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.neutralDark),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            // Fallback for deep links or broken stack
            context.go('/client/dashboard');
          }
        },
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
                  color: AppTheme.neutralDark,
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
                      color: AppTheme.neutralMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        Tooltip(
          message: 'Voice Call (Free)',
          child: IconButton(
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.phone, color: AppTheme.primaryOrange),
              ],
            ),
            onPressed: () {
              context.push('/ai-pandit/voice-call?panditId=$_panditId');
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: AppTheme.errorRed),
          tooltip: 'Clear Chat',
          onPressed: _clearChat,
        ),
        IconButton(
          icon: const Icon(Icons.exit_to_app, color: AppTheme.neutralDark),
          tooltip: 'End Session',
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
                  color: AppTheme.primaryOrange.withOpacity(opacity),
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

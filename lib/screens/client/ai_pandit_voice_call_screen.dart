import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_theme.dart';
import '../../models/ai_chat_model.dart';
import '../../services/wallet_service.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/api_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/ai_pandit_model.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/language_selector.dart';

class AIPanditVoiceCallScreen extends ConsumerStatefulWidget {
  final String? panditId;
  
  const AIPanditVoiceCallScreen({super.key, this.panditId});

  @override
  ConsumerState<AIPanditVoiceCallScreen> createState() => _AIPanditVoiceCallScreenState();
}

class _AIPanditVoiceCallScreenState extends ConsumerState<AIPanditVoiceCallScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  final WalletService _walletService = WalletService();
  final AIChatService _chatService = AIChatService();
  
  // Speech services
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  // State variables
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isCallActive = false;
  bool _isCallStarted = false; // Whether user has started the call
  bool _isLoading = false;
  String _recognizedText = '';
  String _currentLanguage = 'en';
  double _walletBalance = 0.0;
  AIChatSession? _currentSession;
  Timer? _costTimer;
  Timer? _walletCheckTimer; // Timer to check wallet balance during call
  double _currentCost = 0.0;
  int _elapsedSeconds = 0;
  static const double _minimumBalance = 50.0; // Minimum ₹50 required
  
  // Conversation history
  List<Map<String, String>> _conversationHistory = [];
  
  // Animation controllers
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  String? _userId;

  // Supported languages for voice recognition
  final Map<String, String> _supportedLanguages = {
    'en': 'English',
    'hi': 'Hindi',
    'ur': 'Urdu',
    'zh': 'Chinese',
    'ar': 'Arabic',
    'bn': 'Bengali',
    'ta': 'Tamil',
    'te': 'Telugu',
    'mr': 'Marathi',
    'gu': 'Gujarati',
    'pa': 'Punjabi',
    'kn': 'Kannada',
    'ml': 'Malayalam',
    'or': 'Odia',
    'as': 'Assamese',
    'ne': 'Nepali',
    'si': 'Sinhala',
    'th': 'Thai',
    'vi': 'Vietnamese',
    'ja': 'Japanese',
    'ko': 'Korean',
    'fr': 'French',
    'de': 'German',
    'es': 'Spanish',
    'it': 'Italian',
    'pt': 'Portuguese',
    'ru': 'Russian',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupAnimations();
    _setupTTS();
    // NO async operations in initState - UI must render first!
    // Initialize after first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Use microtask to defer initialization even further
      Future.microtask(() => _initializeVoiceCall());
      _watchWalletBalance();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh wallet balance when app comes back to foreground
    if (state == AppLifecycleState.resumed && _userId != null) {
      _checkWalletBalance();
    }
  }

  void _watchWalletBalance() {
    // Watch wallet provider for real-time updates
    ref.listen<AsyncValue<double>>(walletBalanceProvider, (previous, next) {
      next.whenData((balance) {
        if (mounted && (_walletBalance != balance || previous?.value != balance)) {
          setState(() {
            _walletBalance = balance;
          });
          print('✅ Wallet balance updated from provider: ₹$_walletBalance');
        }
      });
    });
    
    // Also get initial balance from provider
    final balanceAsync = ref.read(walletBalanceProvider);
    balanceAsync.whenData((balance) {
      if (mounted) {
        setState(() {
          _walletBalance = balance;
        });
        print('✅ Initial wallet balance from provider: ₹$_walletBalance');
      }
    });
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _setupTTS() async {
    await _flutterTts.setLanguage(_currentLanguage);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
      // Auto-start listening after AI finishes speaking
      if (_isCallActive) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _startListening();
        });
      }
    });
  }

  Future<void> _initializeVoiceCall() async {
    if (!mounted) return;
    
    // Use the provider's userId to ensure consistency
    final providerUserId = ref.read(currentUserIdProvider);
    String userId;
    
    if (providerUserId != null) {
      userId = providerUserId;
    } else {
      // Fallback to Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Create a temporary guest ID for unauthenticated users
        userId = 'guest_temp_${DateTime.now().millisecondsSinceEpoch}';
        print('✅ Using temporary guest session: $userId');
      } else {
        // Handle authenticated users (regular or anonymous)
        userId = user.isAnonymous ? 'guest_${user.uid}' : user.uid;
        print('✅ User authenticated: ${user.isAnonymous ? "Guest" : "Regular"} - ID: $userId');
      }
    }
    
    setState(() {
      _userId = userId;
      _isLoading = false;
    });
    print('✅ Voice call screen using userId: $userId');
    
    // Get or create session for this specific pandit
    _currentSession = await _chatService.getOrCreateSession(userId, widget.panditId ?? 'default');
    
    // Check wallet balance AFTER session is loaded
    await _checkWalletBalance();
    
    // Also get balance from provider as backup
    final balanceAsync = ref.read(walletBalanceProvider);
    balanceAsync.whenData((balance) {
      if (mounted) {
        setState(() {
          _walletBalance = balance;
        });
        print('✅ Wallet balance from provider on init: ₹$_walletBalance');
      }
    });
    
    // Don't start call automatically - wait for user to click Start button
  }

  Future<void> _checkWalletBalance() async {
    if (_userId == null) return;
    
    try {
      // First, try to get balance from provider (most up-to-date)
      final balanceAsync = ref.read(walletBalanceProvider);
      balanceAsync.whenData((balance) {
        if (mounted) {
          setState(() {
            _walletBalance = balance;
          });
          print('✅ Wallet balance from provider: ₹$_walletBalance');
        }
      });
      
      // Also use wallet service directly as backup
      final balance = await _walletService.getBalance(_userId!);
      
      // Refresh the provider to ensure it's up-to-date
      ref.invalidate(walletBalanceProvider);
      
      if (mounted) {
        setState(() {
          _walletBalance = balance;
        });
        print('✅ Wallet balance updated from service: ₹$_walletBalance');
      }
    } catch (e) {
      print('⚠️ Wallet check failed: $e');
      // Try to get balance from provider as fallback
      try {
        final balanceAsync = ref.read(walletBalanceProvider);
        balanceAsync.whenData((balance) {
          if (mounted) {
            setState(() {
              _walletBalance = balance;
            });
            print('✅ Wallet balance from provider fallback: ₹$_walletBalance');
          }
        });
      } catch (e2) {
        print('⚠️ Provider fallback also failed: $e2');
        if (mounted) {
          setState(() {
            _walletBalance = 0.0;
          });
        }
      }
    }
  }

  Future<void> _showStartCallDialog() async {
    if (!mounted || _walletBalance < _minimumBalance) {
      _showInsufficientFundsDialog();
      return;
    }

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
              child: const Icon(Icons.phone, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Start Voice Call?',
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
              'Would you like to start a voice call with this AI Pandit?',
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.neutralMedium,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryOrange.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: AppTheme.primaryOrange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Call charges: ₹25/minute\nMinimum balance required: ₹50',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.neutralDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.account_balance_wallet, size: 16, color: AppTheme.successGreen),
                const SizedBox(width: 6),
                Text(
                  'Your balance: ₹${_walletBalance.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.successGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
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
            child: const Text('Start Call'),
          ),
        ],
      ),
    );

    if (shouldStart == true) {
      await _startCall();
    }
  }

  Future<void> _startCall() async {
    if (_currentSession == null || _userId == null) return;

    // Check wallet balance immediately
    await _checkWalletBalance();
    if (_walletBalance < _minimumBalance) {
      _showInsufficientFundsDialog();
      return;
    }

    // Mark session as started immediately
    _currentSession!.isStarted = true;
    _currentSession!.isActive = true;
    await _chatService.saveSession(_currentSession!);

    setState(() {
      _isCallStarted = true;
      _isCallActive = true;
    });
    
    // Start timers immediately
    _startCostTimer();
    _startWalletCheckTimer();

    // Initialize call in background
    _initializeInBackground();
  }

  void _startWalletCheckTimer() {
    _walletCheckTimer?.cancel();
    _walletCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (!_isCallStarted || !_isCallActive) {
        timer.cancel();
        return;
      }

      await _checkWalletBalance();
      
      // Check if balance is insufficient (less than cost for 1 more minute)
      if (_walletBalance < 25.0) {
        timer.cancel();
        _stopCallDueToInsufficientFunds();
      }
    });
  }

  Future<void> _stopCallDueToInsufficientFunds() async {
    if (_currentSession == null) return;

    // Stop timers
    _costTimer?.cancel();
    _walletCheckTimer?.cancel();
    await _speech.stop();
    await _flutterTts.stop();

    // Mark session as inactive
    _currentSession!.isActive = false;
    _currentSession!.endTime = DateTime.now();
    await _chatService.saveSession(_currentSession!);

    setState(() {
      _isCallStarted = false;
      _isCallActive = false;
      _isListening = false;
      _isSpeaking = false;
    });

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.error_outline, color: AppTheme.errorRed, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Insufficient Funds',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your wallet balance is insufficient to continue the call.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.neutralMedium,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Current Balance: ₹${_walletBalance.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.errorRed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK', style: TextStyle(color: AppTheme.neutralMedium)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/payment/wallet');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Recharge Wallet'),
            ),
          ],
        ),
      );
    }
  }

  void _showInsufficientFundsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.account_balance_wallet, color: AppTheme.errorRed, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Insufficient Balance',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You need a minimum balance of ₹$_minimumBalance to start a chat or call with an AI Pandit.',
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.neutralMedium,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Current Balance: ₹${_walletBalance.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.errorRed,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.neutralMedium)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/payment/wallet');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Recharge Wallet'),
          ),
        ],
      ),
    );
  }

  // All heavy operations happen here in background
  Future<void> _initializeInBackground() async {
    if (!mounted || _userId == null) return;
    
    try {
      // Request microphone permission (non-blocking)
      try {
        final micPermission = await Permission.microphone.request().timeout(
          const Duration(seconds: 2),
          onTimeout: () => PermissionStatus.denied,
        );
        if (!micPermission.isGranted && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Microphone permission is required for voice calls'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      } catch (e) {
        print('⚠️ Mic permission error: $e');
      }
      
      // Initialize speech recognition (non-blocking)
      try {
        final available = await _speech.initialize(
          onStatus: (status) {
            if (status == 'done' || status == 'notListening') {
              if (mounted) setState(() => _isListening = false);
            }
          },
          onError: (error) {
            if (mounted) setState(() => _isListening = false);
          },
        ).timeout(
          const Duration(seconds: 2),
          onTimeout: () => false,
        );
        
        if (!available && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Speech recognition not available'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      } catch (e) {
        print('⚠️ Speech init error: $e');
      }
      
      // Try to get active session (non-blocking)
      try {
        final activeSession = await _chatService.getActiveSession(_userId!).timeout(
          const Duration(seconds: 1),
          onTimeout: () => null,
        );
        
        if (activeSession != null && mounted) {
          setState(() {
            _currentSession = activeSession;
            _conversationHistory = activeSession.messages.map((m) => {
              'isUser': m.isUser.toString(),
              'message': m.message,
            }).toList();
            _elapsedSeconds = activeSession.getDurationInSeconds();
            _currentCost = activeSession.calculateCost();
          });
        }
      } catch (e) {
        print('⚠️ Session check error: $e');
      }
      
      // Start welcome message
      _speakWelcomeMessage();
      
      // Check wallet balance
      _checkWalletBalance();
      
    } catch (e) {
      print('⚠️ Background init error: $e');
      // Ignore - app continues working
    }
  }

  // Remove duplicate - using the one defined earlier

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

  Future<void> _speakWelcomeMessage() async {
    try {
      String welcomeMessage = 'Namaste! I am your AI Vedic Pandit. How may I help you today?';
      
      // Detect language and set welcome message
      if (_currentLanguage == 'hi') {
        welcomeMessage = 'नमस्ते! मैं आपका AI वैदिक पंडित हूं। मैं आज आपकी कैसे सहायता कर सकता हूं?';
      } else if (_currentLanguage == 'ur') {
        welcomeMessage = 'السلام علیکم! میں آپ کا AI ویدک پنڈت ہوں۔ میں آج آپ کی کس طرح مدد کر سکتا ہوں؟';
      } else if (_currentLanguage == 'zh') {
        welcomeMessage = '你好！我是您的AI吠陀占星师。我今天如何为您提供帮助？';
      }
      
      // Speak with timeout to prevent hanging
      await _speak(welcomeMessage).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('⚠️ TTS timeout, continuing anyway');
        },
      );
      
      // Start listening after welcome message
      if (mounted && _isCallActive) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && _isCallActive && !_isSpeaking) {
            _startListening();
          }
        });
      }
    } catch (e) {
      print('⚠️ Error in welcome message: $e');
      // Continue anyway - start listening
      if (mounted && _isCallActive) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && _isCallActive && !_isSpeaking) {
            _startListening();
          }
        });
      }
    }
  }

  Future<void> _startListening() async {
    // Check if call is started
    if (!_isCallStarted || !_isCallActive) {
      _showStartCallDialog();
      return;
    }
    
    if (_isSpeaking || _isListening) return;
    
    setState(() {
      _isListening = true;
      _recognizedText = '';
    });
    
    await _speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
        });
        
        if (result.finalResult) {
          _processUserSpeech(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      localeId: _currentLanguage,
      listenMode: stt.ListenMode.confirmation,
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _processUserSpeech(String userMessage) async {
    if (userMessage.trim().isEmpty || _userId == null || _currentSession == null) {
      _startListening();
      return;
    }
    
    await _stopListening();
    
    // Detect language from user speech
    final detectedLang = _detectLanguage(userMessage);
    if (detectedLang != _currentLanguage) {
      setState(() => _currentLanguage = detectedLang);
      await _flutterTts.setLanguage(detectedLang);
    }
    
    // Check if user is asking for Kundli - if so, try to get their birth details
    String enhancedMessage = userMessage;
    if (userMessage.toLowerCase().contains(RegExp(r'(kundli|birth chart|horoscope|janam kundli|rasi|lagna)'))) {
      try {
        // Get actual Firebase user ID (not guest_ prefix)
        final user = FirebaseAuth.instance.currentUser;
        final firestoreUserId = user?.uid ?? _userId;
        
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(firestoreUserId)
            .get()
            .timeout(const Duration(seconds: 3), onTimeout: () {
              throw TimeoutException('Firestore query timeout');
            });
        
        if (userDoc.exists) {
          final userData = userDoc.data();
          final dob = userData?['dateOfBirth'] as Timestamp?;
          final place = userData?['placeOfBirth'] as String?;
          final time = userData?['timeOfBirth'] as String?;
          final name = userData?['displayName'] as String? ?? 'User';
          
          if (dob != null && place != null && time != null) {
            enhancedMessage = '''
$userMessage

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
        print('Could not fetch birth details: $e');
      }
    }
    
    // Add user message to session
    final userChatMessage = AIChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: userMessage,
      isUser: true,
      timestamp: DateTime.now(),
    );
    await _chatService.addMessage(_currentSession!.id, userChatMessage);
    
    // Add to conversation history
    _conversationHistory.add({
      'isUser': 'true',
      'message': userMessage,
    });
    
    // Show user message in UI
    setState(() {
      _recognizedText = userMessage;
    });
    
    // Get AI response from Gemini
    try {
      final geminiService = ref.read(geminiServiceProvider);
      final aiResponse = await geminiService.sendMessage(
        enhancedMessage,
        _conversationHistory,
        panditId: widget.panditId,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => 'I apologize, but the response is taking longer than expected. Please try again.',
      );
      
      // Add AI response to session
      final aiChatMessage = AIChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      );
      await _chatService.addMessage(_currentSession!.id, aiChatMessage);
      
      // Add AI response to history
      _conversationHistory.add({
        'isUser': 'false',
        'message': aiResponse,
      });
      
      // Speak AI response
      await _speak(aiResponse);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting AI response: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
      print('Error processing speech: $e');
      _startListening();
    }
  }

  Future<void> _speak(String text) async {
    if (!_isCallActive) return;
    
    setState(() => _isSpeaking = true);
    
    await _flutterTts.speak(text);
  }

  String _detectLanguage(String text) {
    // Check for Hindi (Devanagari script)
    if (RegExp(r'[\u0900-\u097F]').hasMatch(text)) return 'hi';
    // Check for Urdu (Arabic script)
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(text) && !RegExp(r'[\u0900-\u097F]').hasMatch(text)) return 'ur';
    // Check for Chinese
    if (RegExp(r'[\u4E00-\u9FFF]').hasMatch(text)) return 'zh';
    // Check for Arabic
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(text)) return 'ar';
    // Check for Bengali
    if (RegExp(r'[\u0980-\u09FF]').hasMatch(text)) return 'bn';
    // Check for Tamil
    if (RegExp(r'[\u0B80-\u0BFF]').hasMatch(text)) return 'ta';
    // Check for Telugu
    if (RegExp(r'[\u0C00-\u0C7F]').hasMatch(text)) return 'te';
    // Check for Marathi
    if (RegExp(r'[\u0900-\u097F]').hasMatch(text)) return 'mr';
    // Check for Gujarati
    if (RegExp(r'[\u0A80-\u0AFF]').hasMatch(text)) return 'gu';
    // Check for Punjabi
    if (RegExp(r'[\u0A00-\u0A7F]').hasMatch(text)) return 'pa';
    // Check for Kannada
    if (RegExp(r'[\u0C80-\u0CFF]').hasMatch(text)) return 'kn';
    // Check for Malayalam
    if (RegExp(r'[\u0D00-\u0D7F]').hasMatch(text)) return 'ml';
    // Default to English
    return 'en';
  }

  Future<void> _endCall() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('End Voice Call?'),
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
      setState(() {
        _isCallActive = false;
        _isListening = false;
        _isSpeaking = false;
      });
      
      await _speech.stop();
      await _flutterTts.stop();
      _costTimer?.cancel();
      
      final result = await _chatService.endSession(_userId ?? 'anonymous', _currentSession!.id);
      
      if (result['success'] && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Call ended. ₹${result['totalCost'].toStringAsFixed(2)} deducted from wallet.',
            ),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        context.pop();
      }
    }
  }

  void _changeLanguage(String languageCode) {
    setState(() => _currentLanguage = languageCode);
    _flutterTts.setLanguage(languageCode);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Language changed to ${_supportedLanguages[languageCode]}'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.celestialVoid,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Language',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _supportedLanguages.length,
                itemBuilder: (context, index) {
                  final code = _supportedLanguages.keys.elementAt(index);
                  final name = _supportedLanguages[code]!;
                  final isSelected = _currentLanguage == code;
                  
                  return ListTile(
                    onTap: () {
                      _changeLanguage(code);
                      Navigator.pop(context);
                    },
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryOrange.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        code.toUpperCase(),
                        style: TextStyle(
                          color: isSelected ? AppTheme.primaryOrange : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Text(
                      name,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected ? const Icon(Icons.check_circle, color: AppTheme.primaryOrange) : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _speech.stop();
    _flutterTts.stop();
    _costTimer?.cancel();
    _walletCheckTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.celestialVoid,
      body: Stack(
          children: [
          // 1. Background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                      colors: [
                  Color(0xFF0F172A), // Deep Slate
                  Color(0xFF1E293B), // Slate 800
                  Colors.black,
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Image.network(
                'https://www.transparenttextures.com/patterns/stardust.png',
                repeat: ImageRepeat.repeat,
                errorBuilder: (_,__,___) => const SizedBox(),
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                if (!_isCallStarted) _buildStartButton(),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Dynamic Avatar with Waves
                        GestureDetector(
                          onTap: () {
                            if (!_isCallStarted) {
                              _showStartCallDialog();
                            }
                          },
                          child: SizedBox(
                            height: 300,
                            width: 300,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                              // Radiating Waves (Only when speaking)
                              if (_isSpeaking)
                                ...List.generate(3, (index) {
                                  return TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration: Duration(milliseconds: 1500 + (index * 500)),
                                    curve: Curves.easeOutQuad, // Smooth expansion
                                    builder: (context, value, child) {
                                      return Container(
                                        width: 150 + (value * 150), // Expand outwards
                                        height: 150 + (value * 150),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppTheme.primaryOrange.withOpacity((1 - value) * 0.5),
                                            width: 2,
                                          ),
                                        ),
                                      );
                                    },
                                    onEnd: () {
                                      // Loop manually if needed or use Repeat (TweenAnimationBuilder doesn't loop easily, 
                                      // better to use the _pulseController with Staggered animations in a real app, 
                                      // but for now we use the existing pulse or a simplified version)
                                    },
                                  );
                                }),
                                
                              // Pulse Animation for Listening/Speaking
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                                    scale: _isSpeaking 
                                        ? 1.0 + (_pulseController.value * 0.1) // Subtle bounce when speaking
                                        : 1.0 + (_pulseController.value * 0.05), // Gentle breath when listening
                              child: Container(
                                      width: 160,
                                      height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                        gradient: _isSpeaking ? AppTheme.primaryGradient : AppTheme.goldGradient,
                                  boxShadow: [
                                    BoxShadow(
                                            color: (_isSpeaking ? AppTheme.primaryOrange : AppTheme.accentGold).withOpacity(0.6),
                                            blurRadius: 40,
                                            spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                      padding: const EdgeInsets.all(4),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.black, // Border between gradient and image
                                        ),
                                        padding: const EdgeInsets.all(2),
                                        child: _buildAvatarImage(),
                                ),
                              ),
                            );
                          },
                              ),
                            ],
                          ),
                        ),
                      ),
                        
                        const SizedBox(height: 40),
                        
                        // Status Text
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                          _isSpeaking
                              ? 'AI Pandit is speaking...'
                              : _isListening
                                    ? 'Listening to you...'
                                    : 'Thinking...',
                            key: ValueKey(_isSpeaking ? 'speak' : (_isListening ? 'listen' : 'think')),
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.9),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Live Transcription
                        if (_recognizedText.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            margin: const EdgeInsets.symmetric(horizontal: 32),
                            decoration: AppTheme.glassMorphism.copyWith(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _recognizedText,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                // Bottom Controls
                _buildBottomControls(),
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

  Widget _buildAvatarImage() {
    AIPanditModel? currentPandit;
    if (widget.panditId != null) {
      try {
        currentPandit = AIPandits.allPandits.firstWhere((p) => p.id == widget.panditId);
      } catch (_) {}
    }
    
    return CircleAvatar(
      backgroundColor: AppTheme.neutralDark,
      backgroundImage: currentPandit != null 
          ? (currentPandit.profileImage.startsWith('assets/') 
              ? AssetImage(currentPandit.profileImage) as ImageProvider
              : NetworkImage(currentPandit.profileImage))
                              : null,
      child: currentPandit == null 
          ? const Icon(Icons.person, size: 60, color: Colors.white54) 
                                  : null,
    );
  }

  Widget _buildStartButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 18,
            color: _walletBalance >= _minimumBalance
                ? AppTheme.successGreen
                : AppTheme.errorRed,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Balance: ₹${_walletBalance.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (_walletBalance < _minimumBalance)
                  Text(
                    'Minimum ₹${_minimumBalance.toStringAsFixed(0)} required',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.errorRed,
                    ),
                  ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _walletBalance >= _minimumBalance
                ? () => _showStartCallDialog()
                : () => _showInsufficientFundsDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _walletBalance >= _minimumBalance
                  ? AppTheme.primaryOrange
                  : Colors.white.withOpacity(0.2),
              foregroundColor: _walletBalance >= _minimumBalance
                  ? Colors.white
                  : Colors.white.withOpacity(0.5),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: _walletBalance >= _minimumBalance ? 4 : 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.play_arrow,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  'Start Call',
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
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 30),
            onPressed: () => context.pop(),
          ),
          Column(
            children: [
              Text(
                'VOICE CALL',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 2),
              if (_isCallStarted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.successGreen.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      Container(width: 6, height: 6, decoration: BoxDecoration(color: AppTheme.successGreen, shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text(
                        '${(_elapsedSeconds ~/ 60).toString().padLeft(2, '0')}:${(_elapsedSeconds % 60).toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
          LanguageSelector(
            initialLanguageCode: _currentLanguage,
            isDark: true, // Voice screen has dark background
            onLanguageSelected: (code, name) {
              _changeLanguage(code);
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            onPressed: () => context.pushReplacement('/ai-pandit/chat?panditId=${widget.panditId}'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      margin: const EdgeInsets.only(bottom: 30, left: 24, right: 24),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      decoration: AppTheme.glassMorphism.copyWith(
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ControlIcon(
            icon: Icons.mic_off,
            color: Colors.white,
            onTap: () {
              if (!_isCallStarted) {
                _showStartCallDialog();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mute not implemented yet')));
              }
            },
          ),
           _ControlIcon(
            icon: Icons.call_end,
            color: Colors.white,
            bgColor: AppTheme.errorRed,
            size: 64,
            iconSize: 32,
            onTap: _endCall,
          ),
           _ControlIcon(
            icon: Icons.volume_up,
            color: Colors.white,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Speaker toggle not implemented yet')));
            },
          ),
        ],
      ),
    );
  }
}




class _ControlIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color? bgColor;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  const _ControlIcon({
    required this.icon,
    required this.color,
    this.bgColor,
    required this.onTap,
    this.size = 50,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor ?? Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
          border: bgColor == null ? Border.all(color: Colors.white.withOpacity(0.2)) : null,
          boxShadow: bgColor != null ? [
            BoxShadow(color: bgColor!.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))
          ] : null,
        ),
        child: Icon(icon, color: color, size: iconSize),
            ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_theme.dart';
import '../../models/ai_chat_model.dart';
import '../../services/gemini_service.dart';
import '../../services/wallet_service.dart';

class AIPanditVoiceCallScreen extends StatefulWidget {
  const AIPanditVoiceCallScreen({super.key});

  @override
  State<AIPanditVoiceCallScreen> createState() => _AIPanditVoiceCallScreenState();
}

class _AIPanditVoiceCallScreenState extends State<AIPanditVoiceCallScreen> with TickerProviderStateMixin {
  final GeminiService _geminiService = GeminiService();
  final WalletService _walletService = WalletService();
  final AIChatService _chatService = AIChatService();
  
  // Speech services
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  // State variables
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isCallActive = false;
  bool _isLoading = false;
  String _recognizedText = '';
  String _currentLanguage = 'en';
  double _walletBalance = 0.0;
  AIChatSession? _currentSession;
  Timer? _costTimer;
  double _currentCost = 0.0;
  int _elapsedSeconds = 0;
  
  // Conversation history
  List<Map<String, String>> _conversationHistory = [];
  
  // Animation controllers
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  final String _userId = 'demo_user_123';

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
    _initializeVoiceCall();
    _setupAnimations();
    _setupTTS();
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
    setState(() => _isLoading = true);
    
    // Request microphone permission
    final micPermission = await Permission.microphone.request();
    if (!micPermission.isGranted) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission is required for voice calls'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
        context.pop();
      }
      return;
    }
    
    // Initialize speech recognition
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        setState(() => _isListening = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Speech recognition error: ${error.errorMsg}'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      },
    );
    
    if (!available) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speech recognition not available'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
        context.pop();
      }
      return;
    }
    
    // Check wallet balance
    _walletBalance = await _walletService.getBalance(_userId);
    
    // Create new session
    _currentSession = await _chatService.startSession(_userId);
    _startCostTimer();
    
    setState(() {
      _isLoading = false;
      _isCallActive = true;
    });
    
    // Start with welcome message
    _speakWelcomeMessage();
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

  Future<void> _speakWelcomeMessage() async {
    String welcomeMessage = 'Namaste! I am your AI Vedic Pandit. How may I help you today?';
    
    // Detect language and set welcome message
    if (_currentLanguage == 'hi') {
      welcomeMessage = 'नमस्ते! मैं आपका AI वैदिक पंडित हूं। मैं आज आपकी कैसे सहायता कर सकता हूं?';
    } else if (_currentLanguage == 'ur') {
      welcomeMessage = 'السلام علیکم! میں آپ کا AI ویدک پنڈت ہوں۔ میں آج آپ کی کس طرح مدد کر سکتا ہوں؟';
    } else if (_currentLanguage == 'zh') {
      welcomeMessage = '你好！我是您的AI吠陀占星师。我今天如何为您提供帮助？';
    }
    
    await _speak(welcomeMessage);
  }

  Future<void> _startListening() async {
    if (!_isCallActive || _isSpeaking || _isListening) return;
    
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
    if (userMessage.trim().isEmpty) {
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
    
    // Add to conversation history
    _conversationHistory.add({
      'isUser': 'true',
      'message': userMessage,
    });
    
    // Show user message in UI
    setState(() {
      _recognizedText = userMessage;
    });
    
    // Get AI response
    try {
      final aiResponse = await _geminiService.sendMessage(
        userMessage,
        _conversationHistory,
      );
      
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
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
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
      
      final result = await _chatService.endSession(_userId, _currentSession!.id);
      
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

  @override
  void dispose() {
    _speech.stop();
    _flutterTts.stop();
    _costTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI Pandit Voice Call', style: TextStyle(fontSize: 18)),
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
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              context.pushReplacement('/ai-pandit/chat');
            },
            tooltip: 'Switch to Chat',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: _changeLanguage,
            itemBuilder: (context) => _supportedLanguages.entries.map((entry) {
              return PopupMenuItem(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
          ),
          IconButton(
            icon: const Icon(Icons.stop_circle_outlined),
            onPressed: _endCall,
            tooltip: 'End Call',
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
                
                // Main content
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // AI Pandit Avatar
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _isSpeaking ? _pulseAnimation.value : 1.0,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  gradient: AppTheme.goldGradient,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.yellowPrimary.withOpacity(0.5),
                                      blurRadius: 30,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.auto_awesome,
                                  size: 60,
                                  color: AppTheme.white,
                                ),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Status text
                        Text(
                          _isSpeaking
                              ? 'AI Pandit is speaking...'
                              : _isListening
                                  ? 'Listening...'
                                  : 'Tap to speak',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.neutralDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Recognized text
                        if (_recognizedText.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 32),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.neutralSoft,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _recognizedText,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        
                        const SizedBox(height: 32),
                        
                        // Voice button
                        GestureDetector(
                          onTap: _isCallActive && !_isSpeaking
                              ? (_isListening ? _stopListening : _startListening)
                              : null,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: _isListening
                                  ? AppTheme.primaryGradient
                                  : null,
                              color: _isListening ? null : AppTheme.neutralLight,
                              shape: BoxShape.circle,
                              boxShadow: _isListening
                                  ? AppTheme.glowShadow
                                  : AppTheme.softShadow,
                            ),
                            child: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              size: 40,
                              color: _isListening ? AppTheme.white : AppTheme.neutralMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}


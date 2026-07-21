import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class KundliChatWidget extends ConsumerStatefulWidget {
  final String contextTopic;
  final String kundliName;

  const KundliChatWidget({
    super.key,
    required this.contextTopic,
    required this.kundliName,
  });

  @override
  ConsumerState<KundliChatWidget> createState() => _KundliChatWidgetState();
}

class _KundliChatWidgetState extends ConsumerState<KundliChatWidget> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addSystemMessage(_getWelcomeMessage());
  }

  String _getWelcomeMessage() {
    final name = widget.kundliName;
    switch (widget.contextTopic) {
      case 'Basic':
        return "Namaste! I am your AI Astrologer. What are your questions about $name's basic details, panchang, or birth particulars?";
      case 'Charts':
        return "Greetings! I can analyze the Lagna, Navamsha, and other charts for $name. What would you like to know about the planetary positions?";
      case 'Tables':
        return "Hello! I can help you interpret the Planetary degrees, Ashtakvarga, or Vimshottari Dasha table. What catches your eye?";
      case 'Report':
        return "Welcome! I have analyzed the predictions. Do you have specific questions about $name's health, career, or relationships mentioned in the report?";
      default:
        return "Namaste! How can I assist you with this Kundli today?";
    }
  }

  void _addSystemMessage(String text) {
    setState(() {
      _messages.add({
        'text': text,
        'isUser': false,
        'timestamp': DateTime.now(),
      });
    });
  }

  void _handleSend() {
    if (_messageController.text.trim().isEmpty) return;

    final text = _messageController.text;
    _messageController.clear();

    setState(() {
      _messages.add({
        'text': text,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
      _isTyping = true;
    });

    _scrollToBottom();

    // Simulate AI response
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add({
            'text': "I understand you are asking about '$text' regarding ${widget.contextTopic}. Here is a detailed astrological insight... (Mock Response)",
            'isUser': false,
            'timestamp': DateTime.now(),
          });
        });
        _scrollToBottom();
      }
    });

  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: AppTheme.divineGold,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.auto_awesome, color: AppTheme.divineGold),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Astro AI Assistant",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    "Context: ${widget.contextTopic}",
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        
        // Chat Area
        Expanded(
          child: Container(
            color: AppTheme.divineBackground,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['isUser'] as bool;
                return _buildMessageBubble(msg['text'] as String, isUser);
              },
            ),
          ),
        ),

        // Typing Indicator
        if (_isTyping)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const SizedBox(width: 8),
                Text(
                  "AI is analyzing stars...",
                  style: TextStyle(color: AppTheme.neutralMedium, fontStyle: FontStyle.italic, fontSize: 12),
                ),
              ],
            ),
          ),

        // Input Area
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Ask about your ${widget.contextTopic}...",
                      hintStyle: TextStyle(color: AppTheme.neutralMedium),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.divineBackground,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _handleSend,
                  backgroundColor: AppTheme.divineGold,
                  mini: true,
                  elevation: 2,
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.divineGold : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          boxShadow: AppTheme.softShadow,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : AppTheme.divineInk,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

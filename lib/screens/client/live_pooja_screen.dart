import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class LivePoojaScreen extends StatefulWidget {
  const LivePoojaScreen({super.key});

  @override
  State<LivePoojaScreen> createState() => _LivePoojaScreenState();
}

class _LivePoojaScreenState extends State<LivePoojaScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLiked = false;
  int _viewerCount = 124;
  Timer? _randomTimer;

  @override
  void initState() {
    super.initState();
    // Simulate incoming messages/viewers
    _startSimulation();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _randomTimer?.cancel();
    super.dispose();
  }

  void _startSimulation() {
    _randomTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _viewerCount += (timer.tick % 2 == 0 ? 1 : -1);
          _messages.add(ChatMessage(
            name: 'Devotee ${100 + timer.tick}', 
            message: _getRandomMessage(),
            isSystem: false,
          ));
          if (_messages.length > 50) _messages.removeAt(0);
        });
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 60,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  String _getRandomMessage() {
    const msgs = ['Jai Shree Ram', 'Om Namah Shivaya', 'Har Har Mahadev', 'Beautiful darshan', 'Jai Mata Di', 'Blessed'];
    return msgs[DateTime.now().microsecond % msgs.length];
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(name: 'You', message: _messageController.text, isSystem: false));
      _messageController.clear();
    });
    // Auto scroll
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

  void _showGiftSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Send Offering', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildGiftItem('Flower', '₹11', '🌸'),
                _buildGiftItem('Diya', '₹21', '🪔'),
                _buildGiftItem('Coconut', '₹51', '🥥'),
                _buildGiftItem('Sweets', '₹101', '🍬'),
                _buildGiftItem('Garland', '₹251', '🌺'),
                _buildGiftItem('Kalash', '₹501', '🏺'),
                _buildGiftItem('Vastram', '₹1001', '🧣'),
                _buildGiftItem('Gold Coin', '₹5001', '🪙'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGiftItem(String name, String price, String emoji) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _triggerGiftAnimation(emoji, name);
      },
      child: Column(
        children: [
          Container(
            height: 50,
            width: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          Text(price, style: const TextStyle(color: AppTheme.yellowPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _triggerGiftAnimation(String emoji, String name) {
    // Add a system message
    setState(() {
      _messages.add(ChatMessage(name: 'You', message: 'offered $name $emoji', isSystem: true));
    });
    // Show snackbar or visual confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Offering sent to Pandit Ji! $emoji'),
        backgroundColor: AppTheme.primaryOrange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Video Player Placeholder
          Positioned.fill(
            child: Container(
              color: Colors.black,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1604169728250-9bb6d8a7c293?q=80&w=1000&auto=format&fit=crop', // Fire Temple image
                    fit: BoxFit.cover,
                    errorBuilder: (c,e,s) => Container(color: Colors.grey[900]),
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.3),
                  ),
                ],
              ),
            ),
          ),

          // 2. Top Bar
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                       const CircleAvatar(
                        radius: 16,
                        backgroundImage: AssetImage('assets/images/pandit_avatar.png'), 
                        // Fallback handling not strictly needed if asset missing, will show grey
                       ),
                       const SizedBox(width: 8),
                       Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text('Acharya Ji', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                           Text('$_viewerCount watching', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 10)),
                         ],
                       ),
                       const SizedBox(width: 8),
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                         decoration: BoxDecoration(color: AppTheme.errorRed, borderRadius: BorderRadius.circular(4)),
                         child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                       ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
              ],
            ),
          ),

          // 3. Bottom Gradient
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 300,
            child: Container(
               decoration: BoxDecoration(
                 gradient: LinearGradient(
                   begin: Alignment.topCenter,
                   end: Alignment.bottomCenter,
                   colors: [Colors.transparent, Colors.black.withOpacity(0.8), Colors.black],
                 ),
               ),
            ),
          ),

          // 4. Chat Area
          Positioned(
            left: 16,
            bottom: 80,
            right: 100, // Leave space for side buttons
            height: 200,
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.white],
                  stops: [0.0, 0.3],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.zero,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${msg.name}: ', style: TextStyle(color: msg.isSystem ? AppTheme.yellowPrimary : Colors.white.withOpacity(0.7), fontWeight: FontWeight.bold, fontSize: 13)),
                        Expanded(child: Text(msg.message, style: TextStyle(color: msg.isSystem ? AppTheme.yellowPrimary : Colors.white, fontSize: 13))),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // 5. Bottom Input Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.black.withOpacity(0.5),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Say something...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _showGiftSheet,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE91E63), // Pink Gift Color
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.card_giftcard, color: Colors.white, size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      setState(() => _isLiked = !_isLiked);
                      if (_isLiked) {
                        // Animation trigger
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? Colors.red : Colors.white,
                        size: 24,
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

class ChatMessage {
  final String name;
  final String message;
  final bool isSystem;

  ChatMessage({required this.name, required this.message, required this.isSystem});
}

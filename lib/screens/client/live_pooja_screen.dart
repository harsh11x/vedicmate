import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../core/theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../providers/auth_provider.dart';

class LivePoojaScreen extends ConsumerStatefulWidget {
  const LivePoojaScreen({super.key});

  @override
  ConsumerState<LivePoojaScreen> createState() => _LivePoojaScreenState();
}

class _LivePoojaScreenState extends ConsumerState<LivePoojaScreen> with TickerProviderStateMixin {
  late IO.Socket _socket;
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Map<String, dynamic>> _messages = [];
  Map<String, dynamic>? _activeGift; // For animation
  bool _isLive = false;
  late AnimationController _giftAnimController;
  late Animation<double> _giftScaleAnim;

  // WebRTC
  final _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  
  final List<Map<String, dynamic>> _gifts = [
    {'id': 'g1', 'name': 'Flower', 'icon': '🌸', 'price': 11},
    {'id': 'g2', 'name': 'Diya', 'icon': '🪔', 'price': 21},
    {'id': 'g3', 'name': 'Coconut', 'icon': '🥥', 'price': 51},
    {'id': 'g4', 'name': 'Incense', 'icon': '🥢', 'price': 11},
    {'id': 'g5', 'name': 'Mala', 'icon': '📿', 'price': 101},
    {'id': 'g6', 'name': 'Sweets', 'icon': '🍬', 'price': 51},
    {'id': 'g7', 'name': 'Fruits', 'icon': '🍎', 'price': 51},
    {'id': 'g8', 'name': 'Modak', 'icon': '🥟', 'price': 21},
    {'id': 'g9', 'name': 'Bell', 'icon': '🔔', 'price': 101},
    {'id': 'g10', 'name': 'Conch', 'icon': '🐚', 'price': 151},
    {'id': 'g11', 'name': 'Thali', 'icon': '🍽️', 'price': 251},
    {'id': 'g12', 'name': 'Kalash', 'icon': '🏺', 'price': 501},
    {'id': 'g13', 'name': 'Shawl', 'icon': '🧣', 'price': 501},
    {'id': 'g14', 'name': 'Cow', 'icon': '🐄', 'price': 1100}, // Gho daan
    {'id': 'g15', 'name': 'Temple', 'icon': '💒', 'price': 5100},
  ];

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _connectSocket();
    
    _giftAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    _giftScaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.5).chain(CurveTween(curve: Curves.elasticOut)), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.5, end: 1.0), weight: 10),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeInBack)), weight: 20),
    ]).animate(_giftAnimController);

    _giftAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _activeGift = null);
        _giftAnimController.reset();
      }
    });
  }

  Future<void> _initRenderers() async {
    await _remoteRenderer.initialize();
  }

  void _connectSocket() {
    _socket = IO.io(ApiConfig.baseUrl.replaceAll('/api', ''), <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    _socket.connect();

    _socket.onConnect((_) {
      print('✅ Connected to Socket for Live Pooja');
      print('🔌 Socket ID: ${_socket.id}');
      final user = ref.read(authStateProvider).value;
      print('👤 Joining as: ${user?.displayName ?? 'User'}');
      _socket.emit('join-pooja', {'name': user?.displayName ?? 'User'});
    });

    _socket.on('session-live', (data) {
      print('🎥 RECEIVED session-live event! Data: $data');
      if (mounted) setState(() => _isLive = true);
    });

    _socket.on('session-ended', (data) {
      print('🛑 RECEIVED session-ended event! Data: $data');
      if (mounted) setState(() => _isLive = false);
      _closePeerConnection();
    });

    _socket.on('new-pooja-message', (data) {
      if (mounted) {
        setState(() {
          _messages.add(data);
        });
        _scrollToBottom();
      }
    });

    _socket.on('gift-received', (data) {
      if (mounted) {
        setState(() {
          _activeGift = data;
        });
        _giftAnimController.forward();
        
        // Add gift notif to chat too
        setState(() {
          _messages.add({
            'type': 'gift',
            'senderName': data['senderName'],
            'giftName': data['giftName'],
            'amount': data['amount'],
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
        });
        _scrollToBottom();
      }
    });

    // WebRTC Signaling
    _socket.on('offer', (data) async {
       print("Received WebRTC Offer from ${data['sender']}");
       final sdp = data['sdp'];
       final senderId = data['sender'];
       
       await _createPeerConnection(senderId);
       
       await _peerConnection?.setRemoteDescription(RTCSessionDescription(sdp['sdp'], sdp['type']));
       
       final answer = await _peerConnection?.createAnswer();
       await _peerConnection?.setLocalDescription(answer!);
       
       _socket.emit('answer', {
         'target': senderId,
         'sdp': answer!.toMap(),
       });
    });

    _socket.on('ice-candidate', (data) async {
       if (_peerConnection != null) {
         final candidate = data['candidate'];
         await _peerConnection?.addCandidate(RTCIceCandidate(
           candidate['candidate'], 
           candidate['sdpMid'], 
           candidate['sdpMLineIndex']
         ));
       }
    });
  }

  Future<void> _createPeerConnection(String senderId) async {
    _closePeerConnection();
    
    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
      ]
    };
    
    _peerConnection = await createPeerConnection(config);
    
    _peerConnection?.onIceCandidate = (candidate) {
       _socket.emit('ice-candidate', {
         'target': senderId,
         'candidate': candidate.toMap(),
       });
    };
    
    _peerConnection?.onTrack = (event) {
       if (event.track.kind == 'video') {
         setState(() {
           _remoteRenderer.srcObject = event.streams[0];
         });
       }
    };
  }
  
  void _closePeerConnection() {
    _peerConnection?.close();
    _peerConnection = null;
    _remoteRenderer.srcObject = null;
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _sendMessage() {
    if (_chatController.text.trim().isEmpty) return;
    
    final user = ref.read(authStateProvider).value;
    final msg = _chatController.text.trim();
    
    _socket.emit('pooja-message', {
      'senderName': user?.displayName ?? 'User',
      'message': msg,
    });
    
    _chatController.clear();
  }

  void _sendGift(Map<String, dynamic> gift) {
    // Logic to deduct balance would be here (via API call).
    // For now we assume successful dedication and emit socket event.
    
    final user = ref.read(authStateProvider).value;
    
    _socket.emit('send-gift', {
      'senderName': user?.displayName ?? 'User',
      'giftName': gift['name'],
      'giftIcon': gift['icon'],
      'amount': gift['price'],
    });
    
    Navigator.pop(context); // Close sheet
  }

  void _showGiftSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 400,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send a Gift',
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _gifts.length,
                itemBuilder: (context, index) {
                  final gift = _gifts[index];
                  return GestureDetector(
                    onTap: () => _sendGift(gift),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.neutralSoft,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.forestBackground),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(gift['icon'], style: const TextStyle(fontSize: 32)),
                          const SizedBox(height: 4),
                          Text(
                            gift['name'],
                            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '₹${gift['price']}',
                            style: GoogleFonts.outfit(fontSize: 10, color: AppTheme.primaryOrange),
                          ),
                        ],
                      ),
                    ),
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
    _socket.disconnect();
    _socket.dispose();
    _chatController.dispose();
    _scrollController.dispose();
    _giftAnimController.dispose();
    _remoteRenderer.dispose();
    _closePeerConnection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            children: [
              // 2. Video Player Area (Dynamic)
              Container(
                height: 250,
                width: double.infinity,
                color: Colors.black,
                child: _isLive
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          RTCVideoView(
                            _remoteRenderer,
                            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                          ),
                          Positioned(
                            top: 40,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ),
                        ],
                      )
                    : _buildOfflinePlaceholder(),
              ),
              Expanded(
                child: Container(
                  color: Colors.black, // Background for the rest of the screen
                ),
              ),
            ],
          ),

          // 2. Chat Overlay (Bottom Left)
          Positioned(
            left: 0,
            bottom: 80,
            width: MediaQuery.of(context).size.width * 0.7,
            height: 300,
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black],
                  stops: [0.0, 0.2],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  if (msg['type'] == 'gift') {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.yellowPrimary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${msg['senderName']} ',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                  ),
                                  const TextSpan(
                                    text: 'sent ',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  TextSpan(
                                    text: '${msg['giftName']}! ',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.white24,
                          child: Text(
                            (msg['senderName'] as String)[0].toUpperCase(),
                            style: const TextStyle(fontSize: 10, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg['senderName'],
                                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                              ),
                              Text(
                                msg['message'],
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // 3. Bottom Input Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _chatController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Say something...',
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send_rounded, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _showGiftSheet,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryOrange,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.card_giftcard, color: Colors.white, size: 24),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // 4. Close Button (Top Right)
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
          
          // 5. Gift Animation Overlay
          if (_activeGift != null)
             Positioned.fill(
               child: Center(
                 child: ScaleTransition(
                   scale: _giftScaleAnim,
                   child: Column(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       Text(
                         _activeGift!['giftIcon'],
                         style: const TextStyle(fontSize: 100),
                       ),
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                         decoration: BoxDecoration(
                           color: Colors.black54,
                           borderRadius: BorderRadius.circular(20),
                         ),
                         child: Column(
                           children: [
                             Text(
                               '${_activeGift!['senderName']}',
                               style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                             ),
                             Text(
                               'sent ${_activeGift!['giftName']}',
                               style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.yellowPrimary),
                             ),
                           ],
                         ),
                       ),
                     ],
                   ),
                 ),
               ),
             ),
        ],
      ),
    );
  }

  Widget _buildOfflinePlaceholder() {
    // Always show "Waiting for Panditji" regardless of time
    // Stream will appear whenever admin starts it
    return Container(
      width: double.infinity,
      color: const Color(0xFF1A1A1A),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.live_tv, size: 48, color: Colors.orange),
          const SizedBox(height: 16),
          Text(
            'Waiting for Panditji...',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'The session will start shortly.',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
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

class _LivePoojaScreenState extends ConsumerState<LivePoojaScreen> with SingleTickerProviderStateMixin {
  late IO.Socket _socket;
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  
  bool _isLive = false;
  bool _isConnecting = true;
  bool _isFullscreen = false;
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _chatController = TextEditingController();
  
  // Gift animation
  Map<String, dynamic>? _activeGift;
  late AnimationController _giftAnimController;
  late Animation<double> _giftScaleAnim;

  @override
  void initState() {
    super.initState();
    
    // Initialize gift animation
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
    
    _initializeEverything();
  }

  Future<void> _initializeEverything() async {
    print('🎬 Initializing Live Pooja Screen...');
    
    // 1. Initialize video renderer
    await _remoteRenderer.initialize();
    print('✅ Video renderer initialized');
    
    // 2. Connect to socket
    _connectSocket();
    
    // 3. Check if session is live
    await _checkIfLive();
  }

  Future<void> _checkIfLive() async {
    try {
      // Use the new active endpoint
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl.replaceAll('/api', '')}/api/live-sessions/active'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final isActive = data['success'] == true && data['active'] == true;
        
        print('📡 Session status: ${isActive ? "LIVE" : "OFFLINE"}');
        
        if (mounted) {
          setState(() {
            _isLive = isActive;
            _isConnecting = false;
          });
        }
      } else {
        print('❌ Failed to check session: ${response.statusCode}');
        if (mounted) {
          setState(() => _isConnecting = false);
        }
      }
    } catch (e) {
      print('❌ Error checking session: $e');
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  void _connectSocket() {
    _socket = IO.io(
      ApiConfig.baseUrl.replaceAll('/api', ''),
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket.connect();

    _socket.onConnect((_) {
      print('✅ Socket connected: ${_socket.id}');
      final user = ref.read(authStateProvider).value;
      _socket.emit('join-pooja', {'name': user?.displayName ?? 'User'});
    });

    _socket.on('session-live', (_) {
      print('🎥 Session went LIVE!');
      if (mounted) setState(() => _isLive = true);
    });

    _socket.on('session-ended', (_) {
      print('🛑 Session ended');
      if (mounted) setState(() => _isLive = false);
      _closePeerConnection();
    });

    _socket.on('user-joined', (data) {
      print('👤 User joined: $data');
    });


    _socket.on('offer', (data) async {
      print('📨 Received offer from admin');
      await _handleOffer(data['sdp'], data['sender']);
    });

    _socket.on('ice-candidate', (data) async {
      print('🧊 Received ICE candidate');
      if (_peerConnection != null && data['candidate'] != null) {
        await _peerConnection!.addCandidate(
          RTCIceCandidate(
            data['candidate']['candidate'],
            data['candidate']['sdpMid'],
            data['candidate']['sdpMLineIndex'],
          ),
        );
      }
    });

    _socket.on('new-pooja-message', (data) {
      if (mounted) {
        setState(() => _messages.add(data));
      }
    });
    
    _socket.on('gift-received', (data) {
      print('🎁 Gift received: ${data['giftName']} from ${data['senderName']}');
      if (mounted) {
        setState(() {
          _activeGift = data;
          _messages.add({
            'type': 'gift',
            'senderName': data['senderName'],
            'message': 'Sent ${data['giftName']}',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
        });
        _giftAnimController.forward(from: 0.0);
      }
    });

    // Handle Gift Errors (Insufficient Funds)
    _socket.on('gift-error', (data) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Gift failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  Future<void> _handleOffer(dynamic sdp, String senderId) async {
    try {
      print('🔄 Creating peer connection...');
      // Create peer connection
      _peerConnection = await createPeerConnection({
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
          {'urls': 'stun:stun1.l.google.com:19302'},
        ]
      });
      print('✅ Peer connection created');

      // Track connection state
      _peerConnection!.onConnectionState = (state) {
        print('🔗 Connection state: $state');
      };

      _peerConnection!.onIceConnectionState = (state) {
        print('🧊 ICE connection state: $state');
      };

      // Handle ICE candidates
      _peerConnection!.onIceCandidate = (candidate) {
        if (candidate.candidate != null) {
          print('📤 Sending ICE candidate to admin');
          _socket.emit('ice-candidate', {
            'target': senderId,
            'candidate': {
              'candidate': candidate.candidate,
              'sdpMid': candidate.sdpMid,
              'sdpMLineIndex': candidate.sdpMLineIndex,
            },
          });
        }
      };

      // Handle incoming tracks (VIDEO!)
      _peerConnection!.onTrack = (event) {
        print('🎥 RECEIVED TRACK: ${event.track.kind}');
        print('📊 Track enabled: ${event.track.enabled}');
        print('📊 Streams count: ${event.streams.length}');
        
        if (event.track.kind == 'video' && event.streams.isNotEmpty) {
          print('✅ Setting video track to renderer!');
          print('📺 Stream ID: ${event.streams[0].id}');
          print('📺 Video tracks: ${event.streams[0].getVideoTracks().length}');
          
          if (mounted) {
            setState(() {
              _remoteRenderer.srcObject = event.streams[0];
              _isConnecting = false; // Stop loading indicator
              _isLive = true; // Mark as live when we receive video
            });
            print('✅ Video renderer updated and marked as LIVE!');
          }
        }
      };

      // Set remote description (offer)
      print('📥 Setting remote description...');
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(sdp['sdp'], sdp['type']),
      );
      print('✅ Remote description set');

      // Create answer
      print('📝 Creating answer...');
      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);
      print('✅ Local description set');

      // Send answer back
      print('📤 Sending answer to admin...');
      _socket.emit('answer', {
        'target': senderId,
        'sdp': answer.toMap(),
      });

      print('✅ Answer sent to admin - WebRTC handshake complete!');
    } catch (e) {
      print('❌ Error handling offer: $e');
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  void _closePeerConnection() {
    _peerConnection?.close();
    _peerConnection = null;
    _remoteRenderer.srcObject = null;
  }

  void _enterFullscreen() {
    // Set landscape orientation and hide system UI
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    setState(() => _isFullscreen = true);
  }

  void _exitFullscreen() {
    // Return to portrait and show system UI
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    setState(() => _isFullscreen = false);
  }

  void _sendMessage() {
    if (_chatController.text.trim().isEmpty) return;
    
    final user = ref.read(authStateProvider).value;
    _socket.emit('pooja-message', {
      'senderName': user?.displayName ?? 'User',
      'message': _chatController.text.trim(),
    });
    
    _chatController.clear();
  }

  void _showGiftSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true,
      builder: (context) {
        final gifts = [
          {'name': '🙏 Blessing', 'price': 11},
          {'name': '🌺 Flower', 'price': 21},
          {'name': '🪔 Diya', 'price': 51},
          {'name': '🔔 Bell', 'price': 101},
          {'name': '🕉️ Om', 'price': 151},
          {'name': '🌸 Lotus', 'price': 201},
          {'name': '🪷 Sacred Lotus', 'price': 251},
          {'name': '📿 Mala', 'price': 301},
          {'name': '🎋 Bamboo', 'price': 351},
          {'name': '🍃 Tulsi', 'price': 401},
          {'name': '⭐ Star', 'price': 501},
          {'name': '🌙 Moon', 'price': 551},
          {'name': '☀️ Sun', 'price': 701},
          {'name': '💎 Diamond', 'price': 851},
          {'name': '👑 Crown', 'price': 1001},
        ];

        return Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Send a Gift',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: gifts.map((gift) => ListTile(
                    leading: Text(
                      gift['name'].toString().split(' ')[0],
                      style: const TextStyle(fontSize: 32),
                    ),
                    title: Text(
                      gift['name'].toString().split(' ').sublist(1).join(' '),
                      style: GoogleFonts.outfit(color: Colors.white),
                    ),
                    trailing: Text(
                      '₹${gift['price']}',
                      style: GoogleFonts.outfit(
                        color: AppTheme.yellowPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      final user = ref.read(authStateProvider).value;
                      if (user == null) return;
                      
                      _socket.emit('send-gift', {
                        'userId': user.uid, // Add User ID for wallet deduction
                        'giftName': gift['name'],
                        'giftIcon': gift['name'].toString().split(' ')[0],
                        'senderName': user.displayName ?? 'User',
                        'amount': gift['price'],
                      });
                      Navigator.pop(context);
                    },
                  )).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    print('🚪 Leaving Live Pooja screen...');
    
    // Reset orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    _socket.emit('leave-pooja');
    _chatController.dispose();
    _giftAnimController.dispose();
    _socket.disconnect();
    _socket.dispose();
    _closePeerConnection();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isFullscreen) {
      return _buildFullscreenView();
    }
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Video Area
            Expanded(
              flex: 3,
              child: Container(
                color: Colors.black,
                child: _isConnecting
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : (_isLive || _remoteRenderer.srcObject != null)
                        ? Stack(
                            children: [
                              // VIDEO PLAYER
                              Builder(
                                builder: (context) {
                                  print('🎬 Rendering video: srcObject=${_remoteRenderer.srcObject != null}, isLive=$_isLive');
                                  return Center(
                                    child: RTCVideoView(
                                      _remoteRenderer,
                                      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                                      mirror: true,
                                    ),
                                  );
                                },
                              ),
                              /* LIVE Badge */
                              Positioned(
                                top: 16,
                                left: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'LIVE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              // Fullscreen button
                              Positioned(
                                top: 16,
                                right: 60,
                                child: IconButton(
                                  icon: const Icon(Icons.fullscreen, color: Colors.white),
                                  onPressed: _enterFullscreen,
                                ),
                              ),
                              // Close button
                              Positioned(
                                top: 16,
                                right: 16,
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white),
                                  onPressed: () => context.pop(),
                                ),
                              ),
                              // Gift Animation
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
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.videocam_off,
                                  size: 64,
                                  color: Colors.white54,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Waiting for Panditji...',
                                  style: GoogleFonts.outfit(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'The session will start shortly',
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
              ),
            ),
            
            // Chat Area
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    // Chat header
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.chat, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'Live Chat',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.card_giftcard, color: AppTheme.yellowPrimary),
                            onPressed: _showGiftSheet,
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Colors.white24),
                    
                    // Messages
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${msg['senderName']}: ',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.yellowPrimary,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    msg['message'],
                                    style: GoogleFonts.outfit(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Input
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        border: Border(
                          top: BorderSide(color: Colors.white24),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _chatController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Type a message...',
                                hintStyle: const TextStyle(color: Colors.white54),
                                filled: true,
                                fillColor: Colors.grey[800],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _sendMessage,
                            icon: const Icon(Icons.send, color: AppTheme.primaryOrange),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullscreenView() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fullscreen video
          Positioned.fill(
            child: RTCVideoView(
              _remoteRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              mirror: true,
            ),
          ),
          // LIVE badge
          Positioned(
            top: 50,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          // Exit fullscreen
          Positioned(
            top: 50,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
              onPressed: _exitFullscreen,
            ),
          ),
          // Gift animation in fullscreen
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
                        style: const TextStyle(fontSize: 150),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${_activeGift!['senderName']}',
                              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text(
                              'sent ${_activeGift!['giftName']}',
                              style: GoogleFonts.outfit(fontSize: 18, color: AppTheme.yellowPrimary),
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
}

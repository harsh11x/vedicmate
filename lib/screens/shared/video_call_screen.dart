import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class VideoCallScreen extends StatefulWidget {
  final String bookingId;

  const VideoCallScreen({super.key, required this.bookingId});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isSpeakerOn = true;
  Duration _callDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    // Start call timer
    _startCallTimer();
  }

  void _startCallTimer() {
    // Simulate call timer
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _callDuration = _callDuration + const Duration(seconds: 1);
        });
        _startCallTimer();
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Remote Video (Full Screen)
          Center(
            child: Container(
              color: Colors.grey[900],
              child: _isVideoOff
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: AppTheme.saffronPrimary,
                          child: Icon(Icons.person, size: 60, color: AppTheme.white),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Pandit Name',
                          style: TextStyle(color: AppTheme.white, fontSize: 20),
                        ),
                      ],
                    )
                  : const Icon(
                      Icons.videocam,
                      size: 100,
                      color: Colors.white54,
                    ),
            ),
          ),
          // Local Video (Picture in Picture)
          Positioned(
            top: 40,
            right: 16,
            child: Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.saffronPrimary, width: 2),
              ),
              child: _isVideoOff
                  ? const Center(
                      child: Icon(Icons.person, color: Colors.white54),
                    )
                  : const Center(
                      child: Icon(Icons.videocam, color: Colors.white54),
                    ),
            ),
          ),
          // Call Info
          Positioned(
            top: 40,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDuration(_callDuration),
                    style: const TextStyle(color: AppTheme.white),
                  ),
                ],
              ),
            ),
          ),
          // Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Participant Name
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Pandit Ravi Shankar',
                    style: TextStyle(color: AppTheme.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),
                // Control Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CallControlButton(
                      icon: _isMuted ? Icons.mic_off : Icons.mic,
                      onPressed: () => setState(() => _isMuted = !_isMuted),
                      backgroundColor: _isMuted ? Colors.red : Colors.white24,
                    ),
                    const SizedBox(width: 16),
                    _CallControlButton(
                      icon: _isVideoOff ? Icons.videocam_off : Icons.videocam,
                      onPressed: () => setState(() => _isVideoOff = !_isVideoOff),
                      backgroundColor: _isVideoOff ? Colors.red : Colors.white24,
                    ),
                    const SizedBox(width: 16),
                    _CallControlButton(
                      icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                      onPressed: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
                      backgroundColor: Colors.white24,
                    ),
                    const SizedBox(width: 16),
                    _CallControlButton(
                      icon: Icons.call_end,
                      onPressed: _endCall,
                      backgroundColor: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _endCall() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Call'),
        content: const Text('Are you sure you want to end the call?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('End Call'),
          ),
        ],
      ),
    );
  }
}

class _CallControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;

  const _CallControlButton({
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: AppTheme.white),
        onPressed: onPressed,
        iconSize: 28,
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/reels_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../core/config/env.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ReelsScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  final bool isReelsTabActive;

  const ReelsScreen({super.key, this.onBack, this.isReelsTabActive = true});

  @override
  ConsumerState<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends ConsumerState<ReelsScreen> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final reelsAsync = ref.watch(reelsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        onRefresh: () => ref.read(reelsProvider.notifier).refresh(),
        color: AppTheme.divineGold,
        child: reelsAsync.when(
          data: (reels) {
            if (reels.isEmpty) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 120,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.video_library_outlined, size: 64, color: Colors.white54),
                          const SizedBox(height: 16),
                          Text("No reels yet", style: GoogleFonts.outfit(color: Colors.white54, fontSize: 18)),
                          const SizedBox(height: 8),
                          Text(
                            "Upload reels via admin panel, then pull down to refresh",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: () => ref.read(reelsProvider.notifier).refresh(),
                            icon: const Icon(Icons.refresh, color: Colors.white54),
                            label: Text("Refresh", style: GoogleFonts.outfit(color: Colors.white54)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
            return PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: reels.length,
              itemBuilder: (context, index) {
                return ReelPlayerItem(
                  reel: reels[index],
                  isActive: widget.isReelsTabActive,
                  onBack: widget.onBack,
                );
              },
            );
          },
          loading: () => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 100,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: AppTheme.divineGold),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => ref.read(reelsProvider.notifier).refresh(),
                      child: Text("Retry", style: GoogleFonts.outfit(color: Colors.white54)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          error: (err, st) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 100,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: $err', style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () => ref.read(reelsProvider.notifier).refresh(),
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text('Retry', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ReelPlayerItem extends ConsumerStatefulWidget {
  final Reel reel;
  final bool isActive;
  final VoidCallback? onBack;

  const ReelPlayerItem({super.key, required this.reel, required this.isActive, this.onBack});

  @override
  ConsumerState<ReelPlayerItem> createState() => _ReelPlayerItemState();
}

class _ReelPlayerItemState extends ConsumerState<ReelPlayerItem> {
  VideoPlayerController? _videoController;
  bool _initialized = false;
  bool _loadFailed = false;
  bool _showHeart = false;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(ReelPlayerItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive && _videoController != null) {
      if (widget.isActive) {
        _videoController!.play();
      } else {
        _videoController!.pause();
      }
    }
  }

  List<String> _buildVideoUrls() {
    if (widget.reel.videoUrl.isEmpty) return [];
    final raw = widget.reel.videoUrl;
    final filename = raw.contains('/') ? raw.split('/').last : raw;
    final base = EnvConfig.apiBaseUrl.replaceAll('/api', '').replaceAll(RegExp(r'/+$'), '');
    final urls = <String>[];
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      urls.add(raw);
    } else {
      // Server path - try full path first
      urls.add('$base/${raw.startsWith('/') ? raw.substring(1) : raw}');
      urls.add('${ApiConfig.baseUrl}/reels/video/$filename');
      urls.add('$base/reels/videos/$filename');
      urls.add('$base/assets/videos/reels/$filename');
      urls.add('$base/api/reels/video/$filename');
    }
    return urls..removeWhere((u) => u.isEmpty);
  }

  Future<bool> _tryPlayUrl(String url) async {
    VideoPlayerController? c;
    try {
      c = VideoPlayerController.networkUrl(
        Uri.parse(url),
        httpHeaders: {'User-Agent': 'VedicMate/1.0', 'Accept': '*/*'},
      );
      await c.initialize().timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw Exception('Timeout'),
      );
      if (!mounted) {
        c.dispose();
        return false;
      }
      c.setLooping(true);
      c.setVolume(1.0);
      if (widget.isActive) c.play();
      _videoController?.dispose();
      _videoController = c;
      return true;
    } catch (e) {
      debugPrint('Video stream failed ($url): $e');
      c?.dispose();
      return false;
    }
  }

  Future<void> _initializeVideo() async {
    if (widget.reel.videoUrl.isEmpty) {
      if (mounted) setState(() => _loadFailed = true);
      return;
    }
    final urls = _buildVideoUrls();
    for (final url in urls) {
      if (await _tryPlayUrl(url)) {
        if (mounted) setState(() {
          _initialized = true;
          _loadFailed = false;
          _isRetrying = false;
        });
        return;
      }
    }
    if (mounted) setState(() {
      _loadFailed = true;
      _isRetrying = false;
    });
  }

  void _retryVideo() {
    if (_isRetrying) return;
    setState(() {
      _loadFailed = false;
      _initialized = false;
      _isRetrying = true;
    });
    _initializeVideo();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    if (_loadFailed) return;
    setState(() => _showHeart = true);
    ref.read(reelsProvider.notifier).toggleLike(widget.reel.id);
    // Hide heart after animation (soft fade-out finishes by ~900ms)
    Future.delayed(const Duration(milliseconds: 950), () {
      if (mounted) setState(() => _showHeart = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final isLiked = widget.reel.likes.any((l) => l.userId == user?.uid);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Video Player
        GestureDetector(
          onTap: () {
            if (_videoController != null) {
              _videoController!.value.isPlaying ? _videoController!.pause() : _videoController!.play();
            }
          },
          onDoubleTap: _handleDoubleTap,
          child: Container(
            color: Colors.black,
            child: _loadFailed || _isRetrying
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.videocam_off, size: 64, color: Colors.white38),
                          const SizedBox(height: 12),
                          Text(
                            _isRetrying ? 'Loading...' : 'Video unavailable',
                            style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14),
                          ),
                          if (widget.reel.description.isNotEmpty && !_isRetrying) ...[
                            const SizedBox(height: 8),
                            Text(widget.reel.description, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12), maxLines: 3, textAlign: TextAlign.center),
                          ],
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 44,
                            child: FilledButton.icon(
                              onPressed: _isRetrying ? null : _retryVideo,
                              icon: _isRetrying ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : const Icon(Icons.refresh, size: 18),
                              label: Text(_isRetrying ? 'Retrying...' : 'Retry'),
                              style: FilledButton.styleFrom(backgroundColor: AppTheme.divineGold, foregroundColor: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _initialized
                    ? Center(
                        child: AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        ),
                      )
                    : const Center(child: CircularProgressIndicator(color: Colors.white24)),
          ),
        ),

        // Double-tap heart (Instagram-style): soft white heart, smooth scale + fade
        if (_showHeart)
          Center(
            child: Icon(
              Icons.favorite,
              size: 88,
              color: Colors.white.withOpacity(0.95),
            )
                .animate()
                .scale(begin: const Offset(0.25, 0.25), end: const Offset(1.15, 1.15), duration: 360.ms, curve: Curves.easeOutCubic)
                .then()
                .scale(begin: const Offset(1.15, 1.15), end: const Offset(1.0, 1.0), duration: 180.ms, curve: Curves.easeInOutCubic)
                .fadeOut(delay: 320.ms, duration: 420.ms, curve: Curves.easeOutCubic),
          ),

        // Gradient Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.7, 1.0],
              ),
            ),
          ),
        ),

        // Right Side Actions (above bottom nav bar ~100px)
        Positioned(
          right: 16,
          bottom: 120,
          child: Column(
            children: [
              _buildActionBtn(
                icon: isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : Colors.white,
                label: '${widget.reel.likes.length}',
                onTap: () => ref.read(reelsProvider.notifier).toggleLike(widget.reel.id),
              ),
              const SizedBox(height: 20),
              _buildActionBtn(
                icon: Icons.comment_outlined,
                label: '${widget.reel.comments.length}',
                onTap: () => _showComments(context),
              ),
              const SizedBox(height: 20),
              _buildActionBtn(
                icon: Icons.share,
                label: 'Share',
                onTap: () {
                   Share.share('Check out this reel on Vedic Mate! \n\n${widget.reel.description}');
                },
              ),
            ],
          ),
        ),

        // Bottom Content (above bottom nav bar ~100px)
        Positioned(
          left: 16,
          bottom: 120,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User / Author Info (Mocked as Admin for now)
              Row(
                children: [
                  const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/logo.png'),
                    radius: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Vedic Mate Official',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.verified, color: Colors.blue, size: 16),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.reel.description,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (widget.reel.hashtags.isNotEmpty)
                Wrap(
                  spacing: 4,
                  children: widget.reel.hashtags.map((tag) => Text(
                    '#$tag',
                    style: GoogleFonts.outfit(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12),
                  )).toList(),
                ),
            ],
          ),
        ),
        
        // Back Button
        Positioned(
          top: 50,
          left: 16,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (widget.onBack != null) {
                widget.onBack!();
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionBtn({required IconData icon, required String label, required VoidCallback onTap, Color color = Colors.white}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: AppTheme.divineSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: AppTheme.divineGold.withOpacity(0.2)),
        ),
        child: CommentsSheet(reel: widget.reel),
      ),
    );
  }
}

class CommentsSheet extends ConsumerStatefulWidget {
  final Reel reel;
  const CommentsSheet({super.key, required this.reel});

  @override
  ConsumerState<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<CommentsSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Re-watch the specific reel to get updates
    final reel = ref.watch(reelsProvider).asData?.value.firstWhere((r) => r.id == widget.reel.id, orElse: () => widget.reel) ?? widget.reel;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10),
          width: 40,
          height: 4,
          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("Comments (${reel.comments.length})", style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.divineInk)),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: reel.comments.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final comment = reel.comments[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.divineGold.withOpacity(0.1),
                      child: Text(comment.name[0].toUpperCase(), style: const TextStyle(color: AppTheme.divineGold)),
                      radius: 16,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(comment.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.divineInk)),
                           Text(comment.text, style: GoogleFonts.outfit(color: AppTheme.textGrey, fontSize: 13)),
                           Text(
                             "${comment.timestamp.day}/${comment.timestamp.month}", 
                             style: TextStyle(color: Colors.grey, fontSize: 10)
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
        Divider(height: 1),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: AppTheme.divineInk),
                  decoration: InputDecoration(
                    hintText: "Add a comment...",
                    hintStyle: TextStyle(color: AppTheme.textGrey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: AppTheme.divineGold.withOpacity(0.3))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: AppTheme.divineGold.withOpacity(0.3))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: AppTheme.divineGold)),
                    filled: true,
                    fillColor: AppTheme.divineBackground,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  if (_controller.text.trim().isNotEmpty) {
                    ref.read(reelsProvider.notifier).addComment(widget.reel.id, _controller.text.trim());
                    _controller.clear();
                  }
                },
                icon: const Icon(Icons.send, color: AppTheme.divineGold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

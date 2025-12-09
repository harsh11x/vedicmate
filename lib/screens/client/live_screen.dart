import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../core/theme/app_theme.dart';
import '../../services/live_service.dart';
import '../../providers/api_providers.dart';
import '../../providers/wallet_provider.dart';

class LiveScreen extends ConsumerWidget {
  const LiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final future = ref.watch(_liveProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      body: future.when(
        data: (items) => _LiveReels(items: items),
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.yellowPrimary)),
        error: (e, _) => Center(child: Text('Failed to load live: $e', style: const TextStyle(color: Colors.white))),
      ),
    );
  }
}

final _liveProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final svc = ref.read(liveServiceProvider);
  return svc.fetchLive();
});

class _LiveReels extends StatefulWidget {
  const _LiveReels({required this.items});
  final List<Map<String, dynamic>> items;

  @override
  State<_LiveReels> createState() => _LiveReelsState();
}

class _LiveReelsState extends State<_LiveReels> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const Center(child: Text('No live sessions currently', style: TextStyle(color: Colors.white)));
    }

    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      // Infinite scrolling simulation
      itemBuilder: (context, index) {
        final itemIndex = index % widget.items.length;
        final it = widget.items[itemIndex];
        final name = '${it['title'] ?? 'Live Session'}';
        final viewers = (it['viewers'] ?? 0) as int? ?? 0;
        final panditName = it['panditName'] as String?;
        final panditId = it['panditId'] as String?;
        
        return _ReelItem(
          key: ValueKey('reel_$index'), // Unique key for each reel instance
          name: name,
          viewers: viewers,
          panditName: panditName,
          panditId: panditId,
        );
      },
    );
  }
}

class _ReelItem extends StatefulWidget {
  const _ReelItem({
    super.key,
    required this.name,
    required this.viewers,
    this.panditName,
    this.panditId,
  });
  final String name;
  final int viewers;
  final String? panditName;
  final String? panditId;

  @override
  State<_ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<_ReelItem> with SingleTickerProviderStateMixin {
  final List<Widget> _hearts = [];
  final math.Random _random = math.Random();
  late AnimationController _heartController;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _addHeart() {
    final double startX = _random.nextDouble() * 40 - 20; // Random horizontal start offset
    final double size = _random.nextDouble() * 20 + 20; // Random size
    final Color color = Colors.primaries[_random.nextInt(Colors.primaries.length)];

    setState(() {
      _hearts.add(
        _HeartAnimation(
          key: UniqueKey(),
          startX: startX,
          size: size,
          color: color,
          onComplete: () {
            // Remove heart when animation completes
            // Note: In a real app, we might want to manage this list more efficiently
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background / Video Placeholder
        GestureDetector(
          onDoubleTap: _addHeart,
          child: Container(
            color: Colors.black,
            width: double.infinity,
            height: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.yellowPrimary.withOpacity(0.2),
                    Colors.black,
                    AppTheme.primaryOrange.withOpacity(0.1),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: AppTheme.yellowPrimary.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.yellowPrimary.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.yellowPrimary.withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.videocam,
                        size: 80,
                        color: AppTheme.yellowPrimary.withOpacity(0.8),
                      ),
                    ),
                    if (widget.panditName != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        widget.panditName!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),

        // Floating Hearts Overlay
        Positioned(
          bottom: 100,
          right: 30,
          child: SizedBox(
            width: 100,
            height: 400,
            child: Stack(
              children: _hearts,
            ),
          ),
        ),

        // Top Controls
        Positioned(
          top: 50,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _BlinkingDot(),
                const SizedBox(width: 6),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        Positioned(
          top: 50,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.visibility, size: 14, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  '${widget.viewers}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom Controls
        Positioned(
          bottom: 80, // Added padding to avoid bottom nav bar overlap
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.9),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Swipe up for more live sessions',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ActionButton(
                      icon: Icons.favorite,
                      label: 'Like',
                      onTap: _addHeart,
                      color: Colors.pink,
                    ),
                    const SizedBox(height: 16),
                    _ActionButton(
                      icon: Icons.card_giftcard,
                      label: 'Gift',
                      onTap: () => _showLiveStreamDialog(context),
                      color: AppTheme.yellowPrimary,
                    ),
                    const SizedBox(height: 16),
                    _ActionButton(
                      icon: Icons.share,
                      label: 'Share',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sharing coming soon!'),
                            backgroundColor: AppTheme.infoBlue,
                          ),
                        );
                      },
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // Close Button
        Positioned(
          top: 50,
          right: 16 + 80, // Offset from viewer count
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
      ],
    );
  }

  void _showLiveStreamDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _LiveStreamView(),
    );
  }
}

class _BlinkingDot extends StatefulWidget {
  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _HeartAnimation extends StatefulWidget {
  final double startX;
  final double size;
  final Color color;
  final VoidCallback onComplete;

  const _HeartAnimation({
    super.key,
    required this.startX,
    required this.size,
    required this.color,
    required this.onComplete,
  });

  @override
  State<_HeartAnimation> createState() => _HeartAnimationState();
}

class _HeartAnimationState extends State<_HeartAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _yAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _yAnimation = Tween<double>(begin: 0, end: -300).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.7, 1.0)),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.2, curve: Curves.easeOutBack)),
    );

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          bottom: 0,
          right: 50 + widget.startX, // Center around the button
          child: Transform.translate(
            offset: Offset(
              math.sin(_controller.value * 2 * math.pi) * 20, // Wiggle effect
              _yAnimation.value,
            ),
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Icon(
                  Icons.favorite,
                  color: widget.color,
                  size: widget.size,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _LiveStreamView extends ConsumerStatefulWidget {
  const _LiveStreamView();

  @override
  ConsumerState<_LiveStreamView> createState() => _LiveStreamViewState();
}

class _LiveStreamViewState extends ConsumerState<_LiveStreamView> {
  @override
  Widget build(BuildContext context) {
    final walletBalanceAsync = ref.watch(walletBalanceProvider);
    final walletBalance = walletBalanceAsync.valueOrNull ?? 0.0;
    final walletNotifier = ref.read(walletNotifierProvider.notifier);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Send Gift',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.yellowPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.yellowPrimary.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet, size: 14, color: AppTheme.yellowPrimary),
                      const SizedBox(width: 6),
                      Text(
                        '₹${walletBalance.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppTheme.yellowPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _GiftItem(
                  icon: Icons.favorite,
                  name: 'Rose',
                  price: 10,
                  emoji: '🌹',
                  color: Colors.pink,
                  onTap: () => _sendGift(walletNotifier, 10, 'Rose Gift'),
                ),
                _GiftItem(
                  icon: Icons.star,
                  name: 'Star',
                  price: 50,
                  emoji: '⭐',
                  color: Colors.amber,
                  onTap: () => _sendGift(walletNotifier, 50, 'Star Gift'),
                ),
                _GiftItem(
                  icon: Icons.diamond,
                  name: 'Diamond',
                  price: 100,
                  emoji: '💎',
                  color: Colors.cyan,
                  onTap: () => _sendGift(walletNotifier, 100, 'Diamond Gift'),
                ),
                _GiftItem(
                  icon: Icons.celebration,
                  name: 'Crown',
                  price: 500,
                  emoji: '👑',
                  color: Colors.purple,
                  onTap: () => _sendGift(walletNotifier, 500, 'Crown Gift'),
                ),
                _GiftItem(
                  icon: Icons.local_fire_department,
                  name: 'Fire',
                  price: 1000,
                  emoji: '🔥',
                  color: Colors.orange,
                  onTap: () => _sendGift(walletNotifier, 1000, 'Fire Gift'),
                ),
                _GiftItem(
                  icon: Icons.auto_awesome,
                  name: 'Sparkle',
                  price: 250,
                  emoji: '✨',
                  color: Colors.yellow,
                  onTap: () => _sendGift(walletNotifier, 250, 'Sparkle Gift'),
                ),
                _GiftItem(
                  icon: Icons.wb_sunny,
                  name: 'Sun',
                  price: 200,
                  emoji: '☀️',
                  color: Colors.orange,
                  onTap: () => _sendGift(walletNotifier, 200, 'Sun Gift'),
                ),
                _GiftItem(
                  icon: Icons.emoji_events,
                  name: 'Trophy',
                  price: 2000,
                  emoji: '🏆',
                  color: Colors.amber,
                  onTap: () => _sendGift(walletNotifier, 2000, 'Trophy Gift'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendGift(WalletNotifier walletNotifier, double amount, String description) async {
    final success = await walletNotifier.deductMoney(amount, description);
    if (success) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Gift sent! ₹${amount.toStringAsFixed(0)}'),
              ],
            ),
            backgroundColor: AppTheme.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Insufficient wallet balance'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            action: SnackBarAction(
              label: 'Add Money',
              textColor: Colors.white,
              onPressed: () => context.push('/payment/wallet'),
            ),
          ),
        );
      }
    }
  }
}

class _GiftItem extends StatelessWidget {
  final IconData icon;
  final String name;
  final double price;
  final String emoji;
  final Color color;
  final VoidCallback onTap;

  const _GiftItem({
    required this.icon,
    required this.name,
    required this.price,
    required this.emoji,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.monetization_on, size: 10, color: AppTheme.yellowPrimary),
              const SizedBox(width: 2),
              Text(
                price.toStringAsFixed(0),
                style: const TextStyle(
                  color: AppTheme.yellowPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickTipButton extends StatelessWidget {
  final double amount;
  final VoidCallback onTap;

  const _QuickTipButton({
    required this.amount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Center(
          child: Text(
            '₹${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

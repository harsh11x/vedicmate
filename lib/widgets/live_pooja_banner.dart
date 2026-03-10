import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

class LivePoojaBanner extends StatefulWidget {
  final VoidCallback onTap;

  const LivePoojaBanner({super.key, required this.onTap});

  @override
  State<LivePoojaBanner> createState() => _LivePoojaBannerState();
}

class _LivePoojaBannerState extends State<LivePoojaBanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            // Removed internal margin as parent handles it
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.divineGold.withOpacity(0.2 + _pulseAnimation.value * 0.01),
                  blurRadius: 12 + _pulseAnimation.value * 0.5,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Image
                Image.asset(
                   'assets/images/services/live_pooja_box.png', 
                   fit: BoxFit.cover,
                   errorBuilder: (c,e,s) => Container(
                     decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFF512F), Color(0xFFDD2476)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                     ),
                   ),
                ),
                
                // Warm overlay for readability
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.75),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Builder(
                              builder: (context) {
                                final now = DateTime.now();
                                final isLive = now.hour >= 9 && now.hour < 13;
                                
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isLive ? AppTheme.divineGold.withOpacity(0.9) : Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isLive) ...[
                                        CircleAvatar(
                                          radius: 3,
                                          backgroundColor: Colors.white,
                                        ),
                                        const SizedBox(width: 6),
                                      ],
                                      Text(
                                        isLive ? 'LIVE NOW • 9 AM - 1 PM' : 'NEXT: 9 AM TOMORROW',
                                        style: GoogleFonts.outfit(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Live Daily\nPooja & Havan',
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.1,
                                shadows: [
                                  Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 2)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Join for blessings & donate',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Play Button
                      Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.divineGold.withOpacity(0.4),
                            border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.divineGold.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

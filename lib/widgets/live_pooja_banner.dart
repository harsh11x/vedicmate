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
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            height: 160,
            decoration: BoxDecoration(
              // Gradient as fallback or overlay
               color: Colors.black,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF512F).withOpacity(0.4),
                  blurRadius: 15 + _pulseAnimation.value,
                  spreadRadius: 1,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Image
                Image.asset(
                   'assets/images/cards/live_pooja_card_bg_1768067784488.png', 
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
                
                // Dark Overlay for readability
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.2), Colors.black.withOpacity(0.6)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

                // Background Pattern or Icon (Subtle)
                Positioned(
                  right: -30,
                  top: -30,
                  child: Icon(
                    Icons.fireplace_rounded,
                    size: 180,
                    color: Colors.white.withOpacity(0.1),
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.2)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 4,
                                    backgroundColor: Colors.redAccent,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'LIVE NOW • 9 AM - 1 PM',
                                    style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
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
                            color: Colors.white.withOpacity(0.2),
                            border: Border.all(color: Colors.white.withOpacity(0.5)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
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

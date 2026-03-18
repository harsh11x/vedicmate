import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import 'sketchy_painter.dart';

class ServiceInfoCards extends StatelessWidget {
  const ServiceInfoCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Astrology Services',
                      style: AppTheme.titleStyle.copyWith(
                            fontSize: 24,
                            color: AppTheme.textBlack,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Discover your cosmic path through AI guidance',
                      style: AppTheme.bodyStyle.copyWith(
                            color: AppTheme.textGrey,
                            fontSize: 14,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Row 1: Lal Kitab & Palm Reading
          Row(
            children: [
              Expanded(
                child: _ServiceCard(
                  icon: Icons.auto_stories,
                  title: 'Lal Kitab',
                  subtitle: 'Simple Remedies',
                  description: 'Ancient wisdom for modern life',
                  accentColor: const Color(0xFFEF4444),
                  iconGradient: const [Color(0xFFEF4444), Color(0xFFF87171)],
                  isComingSoon: true,
                  imagePath: 'assets/images/services/lal_kitab.png',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lal Kitab AI is not available yet.', style: TextStyle(color: Colors.white)),
                        backgroundColor: AppTheme.primaryOrange,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ServiceCard(
                  icon: Icons.back_hand,
                  title: 'Palm Reading',
                  subtitle: 'Hand Analysis',
                  description: 'Unlock your destiny',
                  accentColor: const Color(0xFFEC4899),
                  iconGradient: const [Color(0xFFEC4899), Color(0xFFF472B6)],
                  isComingSoon: true,
                  imagePath: 'assets/images/services/palm_reading.png',
                  onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(
                   content: Text('Palm Reading AI is not available yet.', style: TextStyle(color: Colors.white)),
                   backgroundColor: AppTheme.primaryOrange,
                   behavior: SnackBarBehavior.floating,
                 ),
               );
             },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

          // Row 2: Vedic Astrology & Numerology
          Row(
            children: [
              Expanded(
                child: _ServiceCard(
                  icon: Icons.stars,
                  title: 'Vedic Astrology',
                  subtitle: 'Life Predictions',
                  description: 'Ancient wisdom',
                  accentColor: const Color(0xFFF59E0B),
                  iconGradient: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                  featured: true,
                  imagePath: 'assets/images/services/vedic_astrology.png',
                  onTap: () => context.push('/birth-details?category=Vedic Astrology'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ServiceCard(
                  icon: Icons.calculate,
                  title: 'Numerology',
                  subtitle: 'Number Analysis',
                  description: 'Decode your numbers',
                  accentColor: const Color(0xFF6366F1),
                  iconGradient: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  imagePath: 'assets/images/services/numerology.png',
                  onTap: () => context.push('/birth-details?category=Numerology'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Row 3: Vastu Shastra (Full Width)
          _ServiceCard(
            icon: Icons.home_work,
            title: 'Vastu Shastra',
            subtitle: 'Space Harmony',
            description: 'Get expert guidance on architectural modifications to invite prosperity, health, and happiness into your home or office.',
            accentColor: const Color(0xFF10B981),
            iconGradient: const [Color(0xFF10B981), Color(0xFF34D399)],
            featured: false,
            isComingSoon: true,
            fullWidth: true,
            imagePath: 'assets/images/services/vastu_shastra.png',
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(
                   content: Text('Vastu AI is not available yet.', style: TextStyle(color: Colors.white)),
                   backgroundColor: AppTheme.primaryOrange,
                   behavior: SnackBarBehavior.floating,
                 ),
               );
             },
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final Color accentColor;
  final List<Color> iconGradient;
  final bool featured;
  final bool isComingSoon;
  final bool fullWidth;
  final String? imagePath;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.accentColor,
    required this.iconGradient,
    this.featured = false,
    this.isComingSoon = false,
    this.fullWidth = false,
    this.imagePath,
    required this.onTap,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine card dimensions
    final double cardHeight = widget.fullWidth ? 180.0 : 250.0;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
      scale: _scaleAnimation.value,
      child: SizedBox(
        height: cardHeight,
        child: SketchyContainer(
        backgroundColor: AppTheme.divineSurface,
        borderColor: AppTheme.textBlack,
        borderRadius: 24,
        padding: 0,
        child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: widget.fullWidth 
                  ? _buildFullWidthLayout(context)
                  : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Section: Image Area - Full Bleed
                    Expanded(
                      flex: 4,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (widget.imagePath != null)
                             // Image with Overlay Gradient
                            Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  widget.imagePath!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                                // Gradient Overlay for text readability
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.05),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            Container(
                              color: widget.accentColor.withOpacity(0.05),
                              child: Center(
                                child: Icon(
                                  widget.icon,
                                  color: widget.accentColor,
                                  size: 48,
                                ),
                              ),
                            ),
                            
                          // Featured Tag (Overlay)
                          if (widget.featured)
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star, size: 10, color: widget.accentColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Popular',
                                      style: TextStyle(
                                        color: widget.accentColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // Unavailable Tag (Overlay)
                          if (widget.isComingSoon)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                                ),
                                child: const Text(
                                  'Not available',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Bottom Section: Text Content
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center, // Centered vertically in available space
                          children: [
                              Text(
                                widget.title,
                                style: AppTheme.titleStyle.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textBlack,
                                  fontSize: 18,
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.description, // Changed to description for more info
                                style: AppTheme.bodyStyle.copyWith(
                                  color: AppTheme.textGrey,
                                  fontSize: 13, // Smaller
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        },
      ),
    );
  }

  // Specialized layout for full-width card (Horizontal)
  Widget _buildFullWidthLayout(BuildContext context) {
    return Stack(
      children: [
        // Background Gradient
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.divineSurface,
            ),
          ),
        ),
        
        // Image on Right - Fits Top, Right, Bottom
        if (widget.imagePath != null)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: MediaQuery.of(context).size.width * 0.4, // Adjust width as needed
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ), // Actually clipped by parent, but good to be explicit/safe or if parent radius changes
              child: Image.asset(
                widget.imagePath!,
                fit: BoxFit.cover,
              ),
            ),
          ),

        // Text Content on Left
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          right: MediaQuery.of(context).size.width * 0.4, // Constrain width to avoid overlap
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(widget.icon, size: 14, color: widget.accentColor),
                      const SizedBox(width: 6),
                      Text(
                        'Recommended',
                        style: TextStyle(
                          color: widget.accentColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.neutralDark,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.description,
                  style: AppTheme.bodyStyle.copyWith(
                    color: AppTheme.neutralMedium,
                    height: 1.4,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

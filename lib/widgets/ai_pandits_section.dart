import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart';
import 'sketchy_painter.dart';
import '../models/ai_pandit_model.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/utils/animations.dart';

class AIPanditsSection extends StatefulWidget {
  final List<AIPanditModel>? pandits;
  final String title;
  final Color? backgroundColor;
  final TextStyle? titleStyle;
  
  const AIPanditsSection({
    super.key, 
    this.pandits,
    this.title = 'All Pandits',
    this.backgroundColor,
    this.titleStyle,
  });

  @override
  State<AIPanditsSection> createState() => _AIPanditsSectionState();
}

class _AIPanditsSectionState extends State<AIPanditsSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _headerAnimation = AppAnimations.fadeIn(
      controller: _controller,
      curve: AppAnimations.standardCurve,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aiPandits = widget.pandits ?? AIPandits.getAllPandits();
    
    return FadeTransition(
      opacity: _headerAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.yellowPrimary, AppTheme.goldAccent],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppTheme.goldGlowShadow,
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: AppTheme.textDark,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.title,
                      style: widget.titleStyle ?? AppTheme.titleStyle.copyWith(
                        fontSize: 24,
                        color: AppTheme.neutralDark,
                      ),
                    ),
                  ],
                ),
                AnimatedScaleWidget(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push('/ai-pandits/all');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primaryOrange.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'See all',
                          style: TextStyle(
                            color: AppTheme.primaryOrange,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: AppTheme.primaryOrange,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Chat with our AI-powered expert pandits anytime',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.neutralMedium,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220, // Increased height for bigger cards
            child: aiPandits.isEmpty 
              ? Center(child: Text("No pandits found matching criteria", style: TextStyle(color: AppTheme.neutralMedium)))
              : ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: aiPandits.length,
              itemBuilder: (context, index) {
                final pandit = aiPandits[index];
                return FadeInWidget(
                  delay: index * 0.05,
                  duration: const Duration(milliseconds: 400),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: _AIPanditItem(
                      pandit: pandit,
                      index: index,
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        context.push('/ai-pandit/profile/${pandit.id}');
                      },
                      backgroundColor: widget.backgroundColor,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AIPanditItem extends StatefulWidget {
  final AIPanditModel pandit;
  final int index;
  final VoidCallback onTap;
  final Color? backgroundColor;

  const _AIPanditItem({
    required this.pandit,
    required this.index,
    required this.onTap,
    this.backgroundColor,
  });

  @override
  State<_AIPanditItem> createState() => _AIPanditItemState();
}

class _AIPanditItemState extends State<_AIPanditItem>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _hoverController.forward(),
      onTapUp: (_) => _hoverController.reverse(),
      onTapCancel: () => _hoverController.reverse(),
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return SizedBox(
            width: 160,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: SketchyContainer(
                backgroundColor: widget.backgroundColor ?? AppTheme.divineSurface,
                borderColor: AppTheme.textBlack,
                borderRadius: 16,
                padding: 0,
                margin: const EdgeInsets.only(bottom: 8), // Added explicit margin
                child: Column(
                  children: [
                    // Image Section with Status
                    Expanded(
                      flex: 3,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: widget.pandit.profileImage.startsWith('http')
                                ? Image.network(
                                    widget.pandit.profileImage,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                                  )
                                : Image.asset(
                                    widget.pandit.profileImage,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                                  ),
                          ),
                          // Gradient Overlay
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.1),
                                    Colors.black.withOpacity(0.4),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Online Status
                          if (widget.pandit.isAvailable)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppTheme.successGreen,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.successGreen.withOpacity(0.5),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          // AI Badge (Mini)
                          Positioned(
                            top: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                shape: BoxShape.circle,
                                boxShadow: AppTheme.glowShadow,
                              ),
                              child: const Icon(Icons.auto_awesome, size: 8, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Info Section
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                widget.pandit.name,
                                style: AppTheme.bodyStyle.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.neutralDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '₹${widget.pandit.ratePerMinute.toInt()}/min',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                color: AppTheme.primaryOrange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.neutralSoft,
      child: const Center(
        child: Icon(Icons.person, color: AppTheme.neutralMedium, size: 30),
      ),
    );
  }
}

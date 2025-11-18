import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/pandit_model.dart';

class PanditCard extends StatefulWidget {
  final PanditModel pandit;
  final VoidCallback onTap;

  const PanditCard({
    super.key,
    required this.pandit,
    required this.onTap,
  });

  @override
  State<PanditCard> createState() => _PanditCardState();
}

class _PanditCardState extends State<PanditCard>
    with SingleTickerProviderStateMixin {
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
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
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: _isHovered ? AppTheme.strongShadow : AppTheme.mediumShadow,
            border: widget.pandit.isVerified
                ? Border.all(
                    color: AppTheme.primaryOrange.withOpacity(0.3),
                    width: 1.5,
                  )
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Enhanced Profile Image with Gradient Border
                        Stack(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: widget.pandit.isVerified
                                    ? AppTheme.primaryGradient
                                    : null,
                                color: widget.pandit.isVerified
                                    ? null
                                    : AppTheme.neutralLight.withOpacity(0.3),
                                boxShadow: widget.pandit.isVerified
                                    ? AppTheme.glowShadow
                                    : AppTheme.softShadow,
                              ),
                              padding: const EdgeInsets.all(3),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.white,
                                ),
                                child: ClipOval(
                                  child: widget.pandit.profileImage != null
                                      ? Image.network(
                                          widget.pandit.profileImage!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  _buildDefaultAvatar(),
                                        )
                                      : _buildDefaultAvatar(),
                                ),
                              ),
                            ),
                            if (widget.pandit.isAvailable)
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: AppTheme.successGreen,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.white,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.successGreen
                                            .withOpacity(0.5),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (widget.pandit.isVerified)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.goldGradient,
                                    shape: BoxShape.circle,
                                    boxShadow: AppTheme.goldGlowShadow,
                                  ),
                                  child: const Icon(
                                    Icons.verified,
                                    color: AppTheme.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        // Pandit Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.pandit.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (widget.pandit.rating > 0) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.goldGradient,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.accentGold
                                                .withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: AppTheme.white,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            widget.pandit.rating
                                                .toStringAsFixed(1),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: AppTheme.white,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 12,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.business_center,
                                    size: 14,
                                    color: AppTheme.neutralMedium,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.pandit.experienceYears} years experience',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppTheme.neutralMedium,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Enhanced Specializations
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: widget.pandit.specializations
                                    .take(2)
                                    .map((spec) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppTheme.primaryLight,
                                          AppTheme.primaryLight.withOpacity(0.6),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppTheme.primaryOrange
                                            .withOpacity(0.2),
                                      ),
                                    ),
                                    child: Text(
                                      spec,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppTheme.primaryOrange,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11,
                                          ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Enhanced Pricing and Actions
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primarySoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Starting from',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppTheme.neutralMedium,
                                        fontSize: 11,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      '₹${widget.pandit.servicePricing.values.first.toInt()}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            color: AppTheme.primaryOrange,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 20,
                                          ),
                                    ),
                                    Text(
                                      '/min',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppTheme.neutralMedium,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              _buildActionButton(
                                context,
                                icon: Icons.chat_bubble_outline,
                                label: 'Chat',
                                onTap: () => _handleChatTap(context),
                              ),
                              const SizedBox(width: 10),
                              _buildActionButton(
                                context,
                                icon: Icons.videocam,
                                label: 'Call',
                                onTap: () => _handleCallTap(context),
                                isPrimary: true,
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.primaryLight,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.person,
        color: AppTheme.primaryOrange,
        size: 32,
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.04,
          vertical: 12,
        ),
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width * 0.15,
        ),
        decoration: BoxDecoration(
          gradient: isPrimary ? AppTheme.primaryGradient : null,
          color: isPrimary ? null : AppTheme.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPrimary
                ? Colors.transparent
                : AppTheme.primaryOrange.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: isPrimary ? AppTheme.glowShadow : AppTheme.softShadow,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isPrimary ? AppTheme.white : AppTheme.primaryOrange,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isPrimary ? AppTheme.white : AppTheme.primaryOrange,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleChatTap(BuildContext context) {
    // Handle chat action
  }

  void _handleCallTap(BuildContext context) {
    // Handle call action
  }
}

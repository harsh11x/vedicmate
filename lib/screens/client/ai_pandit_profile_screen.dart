import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../models/ai_pandit_model.dart';
import 'dart:ui';

class AIPanditProfileScreen extends StatelessWidget {
  final String panditId;

  const AIPanditProfileScreen({
    super.key,
    required this.panditId,
  });

  @override
  Widget build(BuildContext context) {
    final pandit = AIPandits.getById(panditId);
    
    if (pandit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pandit Not Found')),
        body: const Center(child: Text('Pandit not found')),
      );
    }

    return SafeArea(
      top: true,
      bottom: false,
      child: Scaffold(
        backgroundColor: AppTheme.white,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 380,
              pinned: true,
              stretch: true,
              backgroundColor: AppTheme.white,
              elevation: 0,
              leading: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.arrow_back, color: Colors.black, size: 20), // Changed to black for visibility on white if image fails, or keep white if dark bg
                      ),
                    ),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    pandit.profileImage.startsWith('http')
                        ? Image.network(
                            pandit.profileImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(color: AppTheme.primaryOrange.withOpacity(0.1)),
                          )
                        : Image.asset(
                            pandit.profileImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(color: AppTheme.primaryOrange.withOpacity(0.1)),
                          ),
                    
                    // Cinematic Gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            AppTheme.neutralDark.withOpacity(0.8),
                            AppTheme.neutralDark,
                          ],
                          stops: const [0.0, 0.5, 0.85, 1.0],
                        ),
                      ),
                    ),
  // (Rest of the stack content remains the same)

                  // Title & Badge Over Content
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppTheme.accentGold,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.auto_awesome, size: 12, color: AppTheme.neutralDark),
                                  const SizedBox(width: 4),
                                  Text(
                                    'AI GUIDANCE',
                                    style: GoogleFonts.outfit(
                                      color: AppTheme.neutralDark,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            if (pandit.isAvailable)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppTheme.successGreen.withOpacity(0.2),
                                  border: Border.all(color: AppTheme.successGreen),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CircleAvatar(backgroundColor: AppTheme.successGreen, radius: 3),
                                    const SizedBox(width: 6),
                                    Text(
                                      'ONLINE',
                                      style: GoogleFonts.outfit(
                                        color: AppTheme.successGreen,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          pandit.name,
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                         Text(
                          pandit.specializations.join(" • "),
                          style: GoogleFonts.outfit(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Container(
              color: AppTheme.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Experience',
                          value: '${pandit.experienceYears}+ Years',
                          icon: Icons.history_edu_rounded,
                          color: AppTheme.primaryOrange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          label: 'Rating',
                          value: pandit.rating.toString(),
                          icon: Icons.star_rounded,
                          color: AppTheme.accentGold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Context Divider
                  Divider(color: AppTheme.forestBackground, thickness: 1),
                  const SizedBox(height: 32),

                  // Bio Section
                  Text(
                    'Biography',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.neutralDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    pandit.bio ?? 'An experienced AI guide dedicated to providing deep Vedic insights and spiritual direction.',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: AppTheme.neutralGrey,
                      height: 1.8,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.push('/ai-pandit/chat?panditId=${pandit.id}');
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    side: BorderSide(color: AppTheme.forestBackground, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    'Message',
                    style: GoogleFonts.outfit(
                      color: AppTheme.neutralDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                     context.push('/ai-pandit/voice-call?panditId=${pandit.id}');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: AppTheme.neutralDark,
                    foregroundColor: AppTheme.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.call, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Voice Call',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
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
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.forestBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.transparent),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.neutralDark,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: AppTheme.neutralMedium,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

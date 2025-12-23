import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceInfoCards extends StatelessWidget {
  const ServiceInfoCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'Cosmic Services',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Ancient Wisdom, Modern AI',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ],
        ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              _ServiceCard(
                icon: Icons.menu_book_rounded,
                title: 'Lal Kitab',
                subtitle: 'Ancient Remedies',
                gradient: const [Color(0xFFE11D48), Color(0xFFF43F5E)],
                onTap: () {},
              ),
              _ServiceCard(
                icon: Icons.front_hand_rounded,
                title: 'Palm Reading',
                subtitle: 'Future Lines',
                gradient: const [Color(0xFFD97706), Color(0xFFFBBF24)],
                onTap: () {},
              ),
              _ServiceCard(
                icon: Icons.auto_awesome_rounded,
                title: 'Vedic',
                subtitle: 'Traditional',
                gradient: const [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
                onTap: () {}, 
              ),
              _ServiceCard(
                icon: Icons.home_work_rounded,
                title: 'Vastu',
                subtitle: 'Living Harmony',
                gradient: const [Color(0xFF059669), Color(0xFF34D399)],
                onTap: () {},
              ),
              _ServiceCard(
                icon: Icons.looks_one_rounded,
                title: 'Numerology',
                subtitle: 'Number Power',
                gradient: const [Color(0xFF2563EB), Color(0xFF60A5FA)],
                onTap: () {},
              ),
            ],
          ),
        ],
        ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      decoration: BoxDecoration(
        color: AppTheme.celestialBlue.withOpacity(0.6), // Dark BG
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: gradient[0].withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.2),
               blurRadius: 10,
               offset: const Offset(0, 4),
             ),
          ],
          ),
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                        borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: gradient[0].withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                    color: Colors.white,
                  size: 24,
                  ),
                ),
                const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white, // White text
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                  ),
              const SizedBox(height: 4),
                      Text(
                subtitle,
                style: GoogleFonts.outfit(
                      color: Colors.white.withOpacity(0.5), // Dim white text
                      fontSize: 12,
                        ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
      ),
    );
  }
}

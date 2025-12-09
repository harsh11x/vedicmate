import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class ServiceInfoCards extends StatelessWidget {
  const ServiceInfoCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Explore Our Services',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: const [
              _ServiceInfoCard(
                title: 'Numerology',
                description: 'Discover your life path number and unlock the secrets of numbers that influence your destiny.',
                icon: Icons.numbers,
                gradient: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                image: '🔢',
              ),
              SizedBox(width: 16),
              _ServiceInfoCard(
                title: 'Horoscope',
                description: 'Get daily, weekly, and monthly predictions based on your zodiac sign and planetary positions.',
                icon: Icons.stars,
                gradient: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                image: '⭐',
              ),
              SizedBox(width: 16),
              _ServiceInfoCard(
                title: 'Astrology',
                description: 'Expert Vedic astrology consultations to understand your birth chart and planetary influences.',
                icon: Icons.auto_awesome,
                gradient: [Color(0xFF10B981), Color(0xFF059669)],
                image: '🌟',
              ),
              SizedBox(width: 16),
              _ServiceInfoCard(
                title: 'Vastu Shastra',
                description: 'Harmonize your living space with Vastu principles for prosperity, health, and positive energy.',
                icon: Icons.home,
                gradient: [Color(0xFFEC4899), Color(0xFFBE185D)],
                image: '🏠',
              ),
              SizedBox(width: 16),
              _ServiceInfoCard(
                title: 'Kundli',
                description: 'Generate your detailed birth chart (Kundli) with accurate planetary positions and predictions.',
                icon: Icons.account_tree,
                gradient: [Color(0xFFFF6B35), Color(0xFFE55A2B)],
                image: '📊',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ServiceInfoCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradient;
  final String image;

  const _ServiceInfoCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(24),
        border: AppTheme.softBorder,
      ),
      child: Stack(
        children: [
          // Decorative pattern
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon and emoji
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      image,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    height: 1.4,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Explore',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


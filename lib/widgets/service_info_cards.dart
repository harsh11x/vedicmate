import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';

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
              Text(
                'Our Services',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
              fontSize: 22,
                      color: AppTheme.neutralDark,
                      letterSpacing: -0.5,
            ),
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
                icon: Icons.auto_awesome_rounded,
                title: 'Kundli',
                subtitle: 'Birth Chart Analysis',
                gradient: const [Color(0xFFEC4899), Color(0xFFF472B6)],
                onTap: () => context.push('/kundli/generation'),
              ),
              _ServiceCard(
                icon: Icons.calendar_month_rounded,
                title: 'Horoscope',
                subtitle: 'Daily Predictions',
                gradient: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                onTap: () {},
              ),
              _ServiceCard(
                icon: Icons.home_work_rounded,
                title: 'Vastu',
                subtitle: 'Home Solutions',
                gradient: const [Color(0xFF10B981), Color(0xFF34D399)],
                onTap: () {},
              ),
              _ServiceCard(
                icon: Icons.numbers_rounded,
                title: 'Numerology',
                subtitle: 'Number Analysis',
                gradient: const [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
            colors: [
              gradient[0].withOpacity(0.1),
              gradient[1].withOpacity(0.05),
              Colors.white,
            ],
        ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: gradient[0].withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 6),
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
                padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                        borderRadius: BorderRadius.circular(16),
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
                  size: 32,
                  ),
                ),
                const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.neutralDark,
                      letterSpacing: -0.3,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                  ),
              const SizedBox(height: 6),
                      Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.neutralMedium,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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

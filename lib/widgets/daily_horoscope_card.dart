import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class DailyHoroscopeCard extends StatelessWidget {
  const DailyHoroscopeCard({super.key});

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
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6366F1), // Indigo
                      Color(0xFF8B5CF6), // Purple
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Daily Horoscope',
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
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF6366F1).withOpacity(0.1),
                  const Color(0xFF8B5CF6).withOpacity(0.05),
                  Colors.white,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF6366F1).withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      final signs = [
                        {'name': 'Aries', 'icon': Icons.auto_awesome_rounded, 'color': const Color(0xFFEF4444), 'gradient': [Color(0xFFFF6B6B), Color(0xFFEE5A6F)]},
                        {'name': 'Taurus', 'icon': Icons.eco_rounded, 'color': const Color(0xFF10B981), 'gradient': [Color(0xFF51CF66), Color(0xFF40C057)]},
                        {'name': 'Gemini', 'icon': Icons.people_rounded, 'color': const Color(0xFFF59E0B), 'gradient': [Color(0xFFFFD93D), Color(0xFFFFC947)]},
                        {'name': 'Cancer', 'icon': Icons.water_drop_rounded, 'color': const Color(0xFF3B82F6), 'gradient': [Color(0xFF4DABF7), Color(0xFF339AF0)]},
                        {'name': 'Leo', 'icon': Icons.local_fire_department_rounded, 'color': const Color(0xFFF97316), 'gradient': [Color(0xFFFF922B), Color(0xFFFF6B00)]},
                        {'name': 'Virgo', 'icon': Icons.forest_rounded, 'color': const Color(0xFF84CC16), 'gradient': [Color(0xFFA9E34B), Color(0xFF94D82D)]},
                        {'name': 'Libra', 'icon': Icons.balance_rounded, 'color': const Color(0xFFEC4899), 'gradient': [Color(0xFFFF6BCB), Color(0xFFF06292)]},
                        {'name': 'Scorpio', 'icon': Icons.bug_report_rounded, 'color': const Color(0xFF991B1B), 'gradient': [Color(0xFFC92A2A), Color(0xFFB91C1C)]},
                        {'name': 'Sagittarius', 'icon': Icons.arrow_forward_rounded, 'color': const Color(0xFF7C3AED), 'gradient': [Color(0xFF9775FA), Color(0xFF845EF7)]},
                        {'name': 'Capricorn', 'icon': Icons.landscape_rounded, 'color': const Color(0xFF6B7280), 'gradient': [Color(0xFF868E96), Color(0xFF74808A)]},
                        {'name': 'Aquarius', 'icon': Icons.water_drop_rounded, 'color': const Color(0xFF06B6D4), 'gradient': [Color(0xFF3BC9DB), Color(0xFF22B8CF)]},
                        {'name': 'Pisces', 'icon': Icons.set_meal_rounded, 'color': const Color(0xFF60A5FA), 'gradient': [Color(0xFF74C0FC), Color(0xFF4DABF7)]},
                      ];
                      final sign = signs[index];
                      return Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 14),
                        child: Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: sign['gradient'] as List<Color>,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (sign['color'] as Color).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                sign['icon'] as IconData,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              sign['name'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.neutralDark,
                                letterSpacing: 0.2,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        const Color(0xFF6366F1).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.insights_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today\'s Prediction',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppTheme.neutralDark,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'A day of new opportunities and positive energy. Trust your instincts and move forward with confidence.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.neutralMedium,
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
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

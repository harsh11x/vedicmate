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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryOrange,
                      AppTheme.accentGold,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryOrange.withOpacity(0.3),
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
                  AppTheme.primaryOrange.withOpacity(0.08),
                  AppTheme.accentGold.withOpacity(0.05),
                  AppTheme.white,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.primaryOrange.withOpacity(0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryOrange.withOpacity(0.1),
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
                        {'name': 'Aries', 'icon': Icons.auto_awesome_rounded, 'color': AppTheme.primaryOrange, 'gradient': [AppTheme.primaryOrange, AppTheme.primaryDeep]},
                        {'name': 'Taurus', 'icon': Icons.eco_rounded, 'color': AppTheme.successGreen, 'gradient': [AppTheme.successGreen, const Color(0xFF059669)]},
                        {'name': 'Gemini', 'icon': Icons.people_rounded, 'color': AppTheme.accentGold, 'gradient': [AppTheme.accentGold, const Color(0xFFFFD700)]},
                        {'name': 'Cancer', 'icon': Icons.water_drop_rounded, 'color': AppTheme.infoBlue, 'gradient': [AppTheme.infoBlue, const Color(0xFF2563EB)]},
                        {'name': 'Leo', 'icon': Icons.local_fire_department_rounded, 'color': AppTheme.warningAmber, 'gradient': [AppTheme.warningAmber, const Color(0xFFD97706)]},
                        {'name': 'Virgo', 'icon': Icons.forest_rounded, 'color': const Color(0xFF84CC16), 'gradient': [const Color(0xFF84CC16), const Color(0xFF65A30D)]},
                        {'name': 'Libra', 'icon': Icons.balance_rounded, 'color': const Color(0xFFEC4899), 'gradient': [const Color(0xFFEC4899), const Color(0xFFDB2777)]},
                        {'name': 'Scorpio', 'icon': Icons.bug_report_rounded, 'color': AppTheme.errorRed, 'gradient': [AppTheme.errorRed, const Color(0xFFDC2626)]},
                        {'name': 'Sagittarius', 'icon': Icons.arrow_forward_rounded, 'color': AppTheme.celestialPurple, 'gradient': [AppTheme.celestialPurple, const Color(0xFF7C3AED)]},
                        {'name': 'Capricorn', 'icon': Icons.landscape_rounded, 'color': AppTheme.neutralMedium, 'gradient': [AppTheme.neutralMedium, AppTheme.neutralDark]},
                        {'name': 'Aquarius', 'icon': Icons.water_drop_rounded, 'color': const Color(0xFF06B6D4), 'gradient': [const Color(0xFF06B6D4), const Color(0xFF0891B2)]},
                        {'name': 'Pisces', 'icon': Icons.set_meal_rounded, 'color': AppTheme.infoBlue, 'gradient': [AppTheme.infoBlue, const Color(0xFF2563EB)]},
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
                        AppTheme.white,
                        AppTheme.primaryOrange.withOpacity(0.03),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryOrange.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primaryOrange, AppTheme.accentGold],
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

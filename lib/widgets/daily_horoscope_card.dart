import 'package:flutter/material.dart';
import 'sketchy_painter.dart';
import '../core/theme/app_theme.dart';

class DailyHoroscopeCard extends StatelessWidget {
  const DailyHoroscopeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SketchyContainer(
      backgroundColor: AppTheme.divineSurface,
      borderColor: AppTheme.textBlack,
      borderRadius: 24,
      padding: 0,
      child: InkWell(
        onTap: () {}, // Detail view
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            _buildHeader(context),
            _buildHoroscopeSigns(context),
            _buildPrediction(context),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Horoscope',
                style: AppTheme.titleStyle.copyWith(
                  fontSize: 22,
                  color: AppTheme.textBlack,
                ),
              ),
              Text(
                'Sunday, Feb 22',
                style: AppTheme.bodyStyle.copyWith(
                  fontSize: 14,
                  color: AppTheme.textGrey,
                ),
              ),
            ],
          ),
          SketchyContainer(
            padding: 8,
            borderRadius: 12,
            backgroundColor: AppTheme.divineBackground,
            borderColor: AppTheme.textBlack,
            child: const Icon(Icons.calendar_today_outlined, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildHoroscopeSigns(BuildContext context) {
    final signs = [
      {'name': 'Aries', 'icon': Icons.auto_awesome_rounded},
      {'name': 'Taurus', 'icon': Icons.eco_rounded},
      {'name': 'Gemini', 'icon': Icons.people_rounded},
      {'name': 'Cancer', 'icon': Icons.water_drop_rounded},
      {'name': 'Leo', 'icon': Icons.local_fire_department_rounded},
      {'name': 'Virgo', 'icon': Icons.forest_rounded},
      {'name': 'Libra', 'icon': Icons.balance_rounded},
      {'name': 'Scorpio', 'icon': Icons.bug_report_rounded},
      {'name': 'Sagittarius', 'icon': Icons.arrow_forward_rounded},
      {'name': 'Capricorn', 'icon': Icons.landscape_rounded},
      {'name': 'Aquarius', 'icon': Icons.water_drop_rounded},
      {'name': 'Pisces', 'icon': Icons.set_meal_rounded},
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: signs.length,
        itemBuilder: (context, index) {
          final sign = signs[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                SketchyContainer(
                  padding: 8,
                  borderRadius: 25,
                  backgroundColor: index == 0 ? AppTheme.primaryOrange.withOpacity(0.1) : AppTheme.divineBackground,
                  borderColor: index == 0 ? AppTheme.primaryOrange : AppTheme.textBlack,
                  child: Icon(
                    sign['icon'] as IconData,
                    size: 24,
                    color: index == 0 ? AppTheme.primaryOrange : AppTheme.textBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  sign['name'] as String,
                  style: AppTheme.bodyStyle.copyWith(
                    fontSize: 12,
                    fontWeight: index == 0 ? FontWeight.bold : FontWeight.normal,
                    color: index == 0 ? AppTheme.primaryOrange : AppTheme.textBlack,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPrediction(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SketchyContainer(
        backgroundColor: AppTheme.divineBackground,
        borderColor: AppTheme.textBlack,
        borderRadius: 16,
        padding: 16,
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppTheme.primaryOrange),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Aries Prediction",
                    style: AppTheme.titleStyle.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "A day of new opportunities and positive energy. Trust your instincts and move forward with confidence.",
                    style: AppTheme.bodyStyle.copyWith(fontSize: 13, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Read Full Horoscope",
            style: AppTheme.bodyStyle.copyWith(
              color: AppTheme.primaryOrange,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward, size: 16, color: AppTheme.primaryOrange),
        ],
      ),
    );
  }
}

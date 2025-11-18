import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class AuspiciousTimingsWidget extends StatelessWidget {
  const AuspiciousTimingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final timings = [
      {'name': 'Abhijit Muhurat', 'time': '12:15 PM', 'icon': Icons.wb_sunny},
      {'name': 'Amrit Kaal', 'time': '06:30 AM', 'icon': Icons.brightness_high},
      {'name': 'Brahma Muhurat', 'time': '04:30 AM', 'icon': Icons.nightlight_round},
      {'name': 'Vijay Muhurat', 'time': '02:45 PM', 'icon': Icons.star},
    ];

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: (MediaQuery.of(context).size.width * 0.05).clamp(16.0, 24.0),
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.yellowPrimary.withOpacity(0.1),
            AppTheme.primarySoft,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.yellowPrimary.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.yellowPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.access_time,
                  color: AppTheme.yellowPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auspicious Timings',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.neutralDark,
                      ),
                    ),
                    Text(
                      'Today\'s Best Times',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.neutralMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...timings.map((timing) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Icon(
                    timing['icon'] as IconData,
                    size: 18,
                    color: AppTheme.yellowPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    timing['name'] as String,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.yellowPrimary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    timing['time'] as String,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.yellowPrimary,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}


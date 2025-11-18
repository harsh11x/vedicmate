import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class DailyHoroscopeCard extends StatelessWidget {
  final String zodiacSign;
  final String horoscopeText;
  final Color signColor;
  
  const DailyHoroscopeCard({
    super.key,
    this.zodiacSign = 'Aries',
    this.horoscopeText = 'Today brings new opportunities. Trust your instincts and embrace change.',
    this.signColor = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
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
            signColor.withOpacity(0.1),
            signColor.withOpacity(0.05),
            AppTheme.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: signColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: AppTheme.mediumShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: signColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: signColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Horoscope',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.neutralDark,
                      ),
                    ),
                    Text(
                      zodiacSign,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: signColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: signColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Today',
                  style: TextStyle(
                    color: signColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            horoscopeText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.neutralDark,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('Read Full'),
                style: TextButton.styleFrom(
                  foregroundColor: signColor,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.share_outlined, size: 20),
                color: AppTheme.neutralMedium,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}


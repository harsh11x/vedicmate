import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class NumerologyWidget extends StatelessWidget {
  const NumerologyWidget({super.key});

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
            Colors.purple.withOpacity(0.1),
            Colors.blue.withOpacity(0.05),
            AppTheme.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.purple.withOpacity(0.3),
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
                  color: Colors.purple.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.numbers,
                  color: Colors.purple,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Numerology',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.neutralDark,
                      ),
                    ),
                    Text(
                      'Discover your life path number',
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.purple.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NumberCard(number: '1', meaning: 'Leader'),
                    _NumberCard(number: '2', meaning: 'Diplomat'),
                    _NumberCard(number: '3', meaning: 'Creative'),
                    _NumberCard(number: '4', meaning: 'Builder'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NumberCard(number: '5', meaning: 'Adventurer'),
                    _NumberCard(number: '6', meaning: 'Nurturer'),
                    _NumberCard(number: '7', meaning: 'Seeker'),
                    _NumberCard(number: '8', meaning: 'Achiever'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _NumberCard(number: '9', meaning: 'Humanitarian'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Navigate to numerology screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              minimumSize: const Size(double.infinity, 0),
            ),
            child: const Text('Calculate My Number'),
          ),
        ],
      ),
    );
  }
}

class _NumberCard extends StatelessWidget {
  final String number;
  final String meaning;

  const _NumberCard({
    required this.number,
    required this.meaning,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.purple,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.purple,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          meaning,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 9,
            color: AppTheme.neutralMedium,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}


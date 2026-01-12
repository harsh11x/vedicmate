import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class QuickStatsWidget extends StatelessWidget {
  final double walletBalance;
  final int upcomingBookings;
  final int activeChats;
  
  const QuickStatsWidget({
    super.key,
    this.walletBalance = 0.0,
    this.upcomingBookings = 0,
    this.activeChats = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: (MediaQuery.of(context).size.width * 0.05).clamp(16.0, 24.0),
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.mediumShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.account_balance_wallet,
              label: 'Wallet',
              value: '₹${walletBalance.toStringAsFixed(0)}',
              color: AppTheme.successGreen,
              onTap: () {},
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.forestBackground.withOpacity(0.3),
          ),
          Expanded(
            child: _StatItem(
              icon: Icons.calendar_today,
              label: 'Bookings',
              value: '$upcomingBookings',
              color: AppTheme.infoBlue,
              onTap: () {},
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.forestBackground.withOpacity(0.3),
          ),
          Expanded(
            child: _StatItem(
              icon: Icons.chat_bubble,
              label: 'Chats',
              value: '$activeChats',
              color: AppTheme.primaryOrange,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.neutralDark,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.neutralMedium,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class AIPanditComingSoonScreen extends StatelessWidget {
  final String? feature; // 'chat' or 'voice-call' or null for both

  const AIPanditComingSoonScreen({super.key, this.feature});

  String get _title {
    switch (feature) {
      case 'chat':
        return 'AI Pandit Chat';
      case 'voice-call':
        return 'AI Pandit Voice Call';
      default:
        return 'AI Pandit Chat & Call';
    }
  }

  String get _subtitle {
    switch (feature) {
      case 'chat':
        return 'Chat with AI Pandits will be available soon.\nStay tuned!';
      case 'voice-call':
        return 'Voice call with AI Pandits will be available soon.\nStay tuned!';
      default:
        return 'Chat and voice call with AI Pandits will be available soon.\nStay tuned!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.divineBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textBlack),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryOrange.withOpacity(0.15),
                        AppTheme.yellowPrimary.withOpacity(0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    feature == 'voice-call' ? Icons.phone_in_talk : Icons.chat_bubble_outline,
                    size: 80,
                    color: AppTheme.divineGold,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neutralDark,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Coming Soon',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryOrange,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textGrey,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/ai_pandit_model.dart';
import 'package:go_router/go_router.dart';

class AIPanditsSection extends StatelessWidget {
  const AIPanditsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final aiPandits = AIPandits.getAllPandits();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.yellowPrimary, AppTheme.goldAccent],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: AppTheme.textDark,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Our AI Pandits',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => context.push('/ai-pandits/all'),
                child: const Text('See all'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Chat with our AI-powered expert pandits anytime',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.neutralMedium,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: aiPandits.length,
            itemBuilder: (context, index) {
              final pandit = aiPandits[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _AIPanditItem(
                  pandit: pandit,
                  onTap: () => context.push('/ai-pandit/chat?panditId=${pandit.id}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AIPanditItem extends StatelessWidget {
  final AIPanditModel pandit;
  final VoidCallback onTap;

  const _AIPanditItem({
    required this.pandit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppTheme.yellowPrimary, AppTheme.goldAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.yellowPrimary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: AppTheme.neutralSoft,
                      backgroundImage: NetworkImage(pandit.profileImage),
                      onBackgroundImageError: (_, __) {},
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.transparent,
                            width: 0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: pandit.isAvailable ? AppTheme.successGreen : AppTheme.neutralMedium,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      pandit.isAvailable ? Icons.check : Icons.schedule,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.yellowPrimary,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome, size: 8, color: AppTheme.textDark),
                        const SizedBox(width: 2),
                        Text(
                          'AI',
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              pandit.name.split(' ').first,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, size: 10, color: AppTheme.accentGold),
                const SizedBox(width: 2),
                Text(
                  '${pandit.rating}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.neutralMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


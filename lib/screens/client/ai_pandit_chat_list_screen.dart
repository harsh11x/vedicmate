import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../models/ai_pandit_model.dart';
class AIPanditChatListScreen extends StatelessWidget {
  const AIPanditChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pandits = AIPandits.getAllPandits();

    return Scaffold(
      backgroundColor: AppTheme.divineBackground,
      appBar: AppBar(
        title: Text(
          'AI Pandit Chat',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppTheme.textBlack,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textBlack),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: pandits.length,
        itemBuilder: (context, index) {
          final pandit = pandits[index];
          return PanditListTile(
            pandit: pandit,
            onChatTap: () => context.push('/ai-pandit/chat?panditId=${pandit.id}'),
            onCallTap: () => context.push('/ai-pandit/voice-call?panditId=${pandit.id}'),
          );
        },
      ),
    );
  }
}

class PanditListTile extends StatelessWidget {
  final AIPanditModel pandit;
  final VoidCallback onChatTap;
  final VoidCallback onCallTap;

  const PanditListTile({
    required this.pandit,
    required this.onChatTap,
    required this.onCallTap,
  });

  @override
  Widget build(BuildContext context) {
    final desc = pandit.bio != null && pandit.bio!.isNotEmpty
        ? (pandit.bio!.length > 120 ? '${pandit.bio!.substring(0, 120)}...' : pandit.bio!)
        : pandit.specializations.take(3).join(', ');
    final rate = pandit.ratePerMinute;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.white.withOpacity(0.08)
            : AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onChatTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Pic
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: pandit.profileImage.startsWith('assets')
                      ? Image.asset(
                          pandit.profileImage,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            width: 72,
                            height: 72,
                            color: AppTheme.primaryOrange.withOpacity(0.2),
                            child: const Icon(Icons.person, color: AppTheme.primaryOrange, size: 36),
                          ),
                        )
                      : Image.network(
                          pandit.profileImage,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            width: 72,
                            height: 72,
                            color: AppTheme.primaryOrange.withOpacity(0.2),
                            child: const Icon(Icons.person, color: AppTheme.primaryOrange, size: 36),
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                // Name, description, price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              pandit.name,
                              style: GoogleFonts.outfit(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textBlack,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGold.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, color: AppTheme.accentGold, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  pandit.rating.toStringAsFixed(1),
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textBlack,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pandit.category,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryOrange,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        desc,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: AppTheme.textGrey,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      // Price row
                      Row(
                        children: [
                          Icon(Icons.currency_rupee, size: 14, color: AppTheme.textGrey),
                          Text(
                            '${rate.toInt()}/min',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textBlack,
                            ),
                          ),
                          Text(
                            ' chat & call',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: AppTheme.textGrey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Chat & Call buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: onChatTap,
                              icon: const Icon(Icons.chat_bubble_outline, size: 18),
                              label: const Text('Chat'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryOrange,
                                side: const BorderSide(color: AppTheme.primaryOrange),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: onCallTap,
                              icon: const Icon(Icons.phone, size: 18),
                              label: const Text('Call'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryOrange,
                                side: const BorderSide(color: AppTheme.primaryOrange),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

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
          'Chat and Call',
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
            onProfileTap: () => context.push('/ai-pandit/profile/${pandit.id}'),
            onChatTap: () =>
                context.push('/ai-pandit/chat?panditId=${pandit.id}'),
            onCallTap: () =>
                context.push('/ai-pandit/voice-call?panditId=${pandit.id}'),
          );
        },
      ),
    );
  }
}

class PanditListTile extends StatelessWidget {
  final AIPanditModel pandit;
  final VoidCallback onProfileTap;
  final VoidCallback onChatTap;
  final VoidCallback onCallTap;

  const PanditListTile({
    required this.pandit,
    required this.onProfileTap,
    required this.onChatTap,
    required this.onCallTap,
  });

  @override
  Widget build(BuildContext context) {
    final desc = pandit.bio != null && pandit.bio!.isNotEmpty
        ? (pandit.publicBio.length > 116
            ? '${pandit.publicBio.substring(0, 116)}...'
            : pandit.publicBio)
        : pandit.publicSpecializations.take(3).join(', ');
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
          onTap: onProfileTap,
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
                            child: const Icon(Icons.person,
                                color: AppTheme.primaryOrange, size: 36),
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
                            child: const Icon(Icons.person,
                                color: AppTheme.primaryOrange, size: 36),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGold.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: AppTheme.accentGold, size: 14),
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
                        pandit.publicCategory,
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
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: onChatTap,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.chat_bubble_outline, size: 16),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Chat ₹${pandit.ratePerMinute.toStringAsFixed(0)}/min',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryOrange,
                                side: const BorderSide(
                                    color: AppTheme.primaryOrange),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: onCallTap,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.call_rounded, size: 16),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Call ₹${pandit.ratePerMinute.toStringAsFixed(0)}/min',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryOrange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
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

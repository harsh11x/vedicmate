import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../models/ai_pandit_model.dart';

class AIPanditSelectionScreen extends StatelessWidget {
  final String? astrologyType;
  
  const AIPanditSelectionScreen({super.key, this.astrologyType});

  @override
  Widget build(BuildContext context) {
    // Get astrology type from GoRouter state if not passed directly
    final String type = astrologyType ?? 
        (GoRouterState.of(context).extra as Map<String, dynamic>?)?['astrologyType'] ?? 
        'Vedic Astrology';

    // Filter pandits by the selected type
    final pandits = AIPandits.getBySpecialization(type);

    return Scaffold(
      backgroundColor: AppTheme.celestialVoid,
      appBar: AppBar(
        title: Text('Select $type Pandit', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.white)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
         children: [
            // Cosmic Background
           Positioned.fill(
             child: Container(
               decoration: const BoxDecoration(
                 gradient: LinearGradient(
                   begin: Alignment.topCenter,
                   end: Alignment.bottomCenter,
                   colors: [
                     Color(0xFF0B0B19), 
                     Color(0xFF2D1B4E), 
                   ],
                 ),
               ),
             ),
           ),
           
           SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Choose an AI Pandit to consult with',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: pandits.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final pandit = pandits[index];
                      return _AIPanditSelectionCard(pandit: pandit);
                    },
                  ),
                ),
              ],
            ),
          ),
         ]
      ),
    );
  }
}

class _AIPanditSelectionCard extends StatelessWidget {
  final AIPanditModel pandit;

  const _AIPanditSelectionCard({required this.pandit});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.celestialBlue.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [AppTheme.primaryOrange, AppTheme.celestialPurple]),
                    boxShadow: [
                      BoxShadow(color: AppTheme.primaryOrange.withOpacity(0.4), blurRadius: 10),
                    ]
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(pandit.profileImage),
                    backgroundColor: AppTheme.primaryOrange.withOpacity(0.1),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pandit.name,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        pandit.specializations.take(2).join(', '),
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.push('/ai-pandit/chat', extra: {'panditId': pandit.id});
                },
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                label: const Text('Start Chat'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.accentGold,
                  side: const BorderSide(color: AppTheme.accentGold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

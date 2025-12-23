import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/mandir_gate_animation.dart';

class AstrologyTypeSelectionScreen extends StatelessWidget {
  const AstrologyTypeSelectionScreen({super.key});

  final List<Map<String, dynamic>> _astrologyTypes = const [
    {
      'title': 'Lal Kitab',
      'icon': Icons.menu_book_rounded,
      'color': Color(0xFFE11D48),
      'description': 'Ancient remedy-based astrology',
    },
    {
      'title': 'Palm Reading',
      'icon': Icons.front_hand_rounded,
      'color': Color(0xFFD97706),
      'description': 'Future through your palm lines',
    },
    {
      'title': 'Vedic',
      'icon': Icons.auto_awesome_rounded,
      'color': Color(0xFF7C3AED),
      'description': 'Traditional Indian horoscope',
    },
    {
      'title': 'Vastu',
      'icon': Icons.house_rounded,
      'color': Color(0xFF059669),
      'description': 'Architecture & harmony',
    },
    {
      'title': 'Numerology',
      'icon': Icons.looks_one_rounded,
      'color': Color(0xFF2563EB),
      'description': 'Power of numbers',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B19), // Force Dark
      body: Stack(
        children: [
          // Background
           Positioned.fill(
             child: Container(
               decoration: const BoxDecoration(
                 gradient: LinearGradient(
                   begin: Alignment.topLeft,
                   end: Alignment.bottomRight,
                   colors: [Color(0xFF0B0B19), Color(0xFF1A103C)],
                 ),
               ),
             ),
           ),
           
           CustomScrollView(
             physics: const BouncingScrollPhysics(),
             slivers: [
               // Hero Section
               SliverToBoxAdapter(
                 child: SafeArea(
                   bottom: false,
                   child: Padding(
                     padding: const EdgeInsets.all(24.0),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text(
                                   'Cosmic Guidance',
                                   style: GoogleFonts.outfit(
                                     fontSize: 32, 
                                     fontWeight: FontWeight.bold,
                                     color: Colors.white,
                                   ),
                                 ),
                                 Text(
                                   'Choose your path to wisdom',
                                   style: GoogleFonts.outfit(
                                     fontSize: 16, 
                                     color: Colors.white60,
                                   ),
                                 ),
                               ],
                             ),
                             Container(
                               padding: const EdgeInsets.all(12),
                               decoration: BoxDecoration(
                                 color: AppTheme.celestialBlue,
                                 borderRadius: BorderRadius.circular(16),
                                 border: Border.all(color: Colors.white10),
                               ),
                               child: const Icon(Icons.stars_rounded, color: AppTheme.accentGold, size: 32),
                             ),
                           ],
                         ),
                         const SizedBox(height: 32),
                         // Featured/Hero Card (e.g. "Daily Insight")
                         Container(
                           width: double.infinity,
                           padding: const EdgeInsets.all(20),
                           decoration: BoxDecoration(
                             gradient: const LinearGradient(colors: [Color(0xFF6D28D9), Color(0xFF4C1D95)]),
                             borderRadius: BorderRadius.circular(24),
                             border: Border.all(color: Colors.white24),
                             boxShadow: [
                               BoxShadow(color: const Color(0xFF6D28D9).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))
                             ]
                           ),
                           child: Row(
                             children: [
                               Expanded(
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Container(
                                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                       decoration: BoxDecoration(
                                         color: Colors.white24,
                                         borderRadius: BorderRadius.circular(20)
                                       ),
                                       child: Text('RECOMMENDED', style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                     ),
                                     const SizedBox(height: 12),
                                     Text('Chart Your Destiny', style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                                     const SizedBox(height: 4),
                                     Text('Get a complete Vedic analysis of your life path.', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                                   ],
                                 ),
                               ),
                               const Icon(Icons.auto_awesome, color: Colors.white, size: 48),
                             ],
                           ),
                         ),
                         const SizedBox(height: 32),
                         Text('Browse Astrology Domains', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                         const SizedBox(height: 16),
                       ],
                     ),
                   ),
                 ),
               ),
               
               // Grid
               SliverPadding(
                 padding: const EdgeInsets.symmetric(horizontal: 24),
                 sliver: SliverGrid(
                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                     crossAxisCount: 2,
                     mainAxisSpacing: 16,
                     crossAxisSpacing: 16,
                     childAspectRatio: 0.75, // Taller cards
                   ),
                   delegate: SliverChildBuilderDelegate(
                     (context, index) {
                       final type = _astrologyTypes[index];
                       return _buildRichCard(context, type);
                     },
                     childCount: _astrologyTypes.length,
                   ),
                 ),
               ),
               
               const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
             ],
           ),
        ],
      ),
    );
  }

  Widget _buildRichCard(BuildContext context, Map<String, dynamic> type) {
    final color = type['color'] as Color;
    return GestureDetector(
      onTap: () {
        context.push(
          '/onboarding/birth-details',
          extra: {'astrologyType': type['title']},
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E).withOpacity(0.8), // Dark opaque glass
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
          ]
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
               // Subtle Gradient Background
               Positioned.fill(
                 child: Container(
                   decoration: BoxDecoration(
                     gradient: LinearGradient(
                       begin: Alignment.topRight,
                       end: Alignment.bottomLeft,
                       colors: [
                         color.withOpacity(0.1),
                         Colors.transparent,
                       ]
                     )
                   ),
                 )
               ),
               
               Padding(
                 padding: const EdgeInsets.all(16.0),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     // Icon & Popularity Badge
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Container(
                           padding: const EdgeInsets.all(10),
                           decoration: BoxDecoration(
                             color: color.withOpacity(0.2),
                             shape: BoxShape.circle,
                             border: Border.all(color: color.withOpacity(0.5)),
                           ),
                           child: Icon(type['icon'] as IconData, color: Colors.white, size: 24),
                         ),
                         if (type['title'] == 'Vedic Astrology' || type['title'] == 'Palmistry')
                           Container(
                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                             decoration: BoxDecoration(
                               color: AppTheme.accentGold,
                               borderRadius: BorderRadius.circular(10),
                             ),
                             child: Text('POPULAR', style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.black)),
                           ),
                       ],
                     ),
                     const Spacer(),
                     
                     Text(
                       type['title'] as String,
                       style: GoogleFonts.outfit(
                         fontSize: 18,
                         fontWeight: FontWeight.bold,
                         color: Colors.white,
                       ),
                       maxLines: 2,
                     ),
                     const SizedBox(height: 4),
                     Text(
                       type['description'] as String,
                       style: GoogleFonts.outfit(
                         fontSize: 12,
                         color: Colors.white60,
                         height: 1.3,
                       ),
                       maxLines: 3,
                       overflow: TextOverflow.ellipsis,
                     ),
                     const SizedBox(height: 12),
                     
                     // Tags
                     Wrap(
                       spacing: 4,
                       children: [
                          _buildTag('Career'),
                          _buildTag('Life'),
                       ],
                     )
                   ],
                 ),
               )
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: GoogleFonts.outfit(fontSize: 10, color: Colors.white70)),
    );
  }
}

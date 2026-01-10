import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';

class RelationshipResultScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const RelationshipResultScreen({super.key, required this.data});

  @override
  State<RelationshipResultScreen> createState() => _RelationshipResultScreenState();
}

class _RelationshipResultScreenState extends State<RelationshipResultScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scoreAnimation = Tween<double>(begin: 0, end: 85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.data['user'];
    final partner = widget.data['partner'];

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: Text(
          'Compatibility Report',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.neutralDark),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.neutralDark),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
             const SizedBox(height: 20),
             // Profiles
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               children: [
                 _buildProfile(user['name'], user['gender'], true),
                 const Icon(Icons.favorite_rounded, color: Colors.pink, size: 40),
                 _buildProfile(partner['name'], partner['gender'], false),
               ],
             ),
             
             const SizedBox(height: 40),

             // Score Circle
             AnimatedBuilder(
               animation: _controller,
               builder: (context, child) {
                 return Stack(
                   alignment: Alignment.center,
                   children: [
                     SizedBox(
                       width: 200,
                       height: 200,
                       child: CircularProgressIndicator(
                         value: _scoreAnimation.value / 100,
                         strokeWidth: 15,
                         backgroundColor: AppTheme.neutralLight,
                         color: _getScoreColor(_scoreAnimation.value),
                         strokeCap: StrokeCap.round,
                       ),
                     ),
                     Column(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         Text(
                           '${_scoreAnimation.value.toInt()}%',
                           style: GoogleFonts.outfit(
                             fontSize: 48,
                             fontWeight: FontWeight.bold,
                             color: AppTheme.neutralDark,
                           ),
                         ),
                         Text(
                           'Compatibility',
                           style: GoogleFonts.outfit(
                             fontSize: 16,
                             color: AppTheme.neutralMedium,
                           ),
                         ),
                       ],
                     ),
                   ],
                 );
               },
             ),

             const SizedBox(height: 40),

             // Analysis Cards
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 24),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   _buildAnalysisCard(
                     'Emotional Bond',
                     'Excellent',
                     'You both share a deep emotional connection and understand each other\'s feelings intuitively.',
                     Colors.purple,
                   ),
                   const SizedBox(height: 16),
                   _buildAnalysisCard(
                     'Communication',
                     'Good',
                     'Communication is generally good, but ensure you listen actively during disagreements.',
                     Colors.blue,
                   ),
                   const SizedBox(height: 16),
                   _buildAnalysisCard(
                     'Shared Values',
                     'High',
                     'Your life goals and moral values align perfectly, creating a strong foundation.',
                     Colors.green,
                   ),
                 ],
               ),
             ),
             
             const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile(String name, String gender, bool isLeft) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primaryOrange, width: 2),
          ),
          child: CircleAvatar(
            radius: 36,
            backgroundColor: AppTheme.neutralSoft,
            child: Text(
              name[0].toUpperCase(),
              style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryOrange),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.neutralDark),
        ),
        Text(
          gender, // Should be date, but showing gender for now
          style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.neutralMedium),
        ),
      ],
    );
  }

  Widget _buildAnalysisCard(String title, String rating, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.neutralDark),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  rating,
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 14, color: AppTheme.neutralMedium, height: 1.5),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return AppTheme.successGreen;
    if (score >= 60) return Colors.orange;
    return AppTheme.errorRed;
  }
}

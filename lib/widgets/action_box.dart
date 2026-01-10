import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

class ActionBox extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color accentColor;
  final VoidCallback onTap;
  final String? backgroundImage;

  const ActionBox({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.accentColor,
    required this.onTap,
    this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (backgroundImage != null)
              Image.asset(
                backgroundImage!,
                fit: BoxFit.cover,
              ),
            if (backgroundImage != null)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: backgroundImage != null ? Colors.white.withOpacity(0.2) : Colors.white,
                      shape: BoxShape.circle,
                      border: backgroundImage != null ? Border.all(color: Colors.white.withOpacity(0.3)) : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      icon, 
                      color: backgroundImage != null ? Colors.white : accentColor, 
                      size: 24
                    ),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: backgroundImage != null ? Colors.white : AppTheme.neutralDark,
                      height: 1.1,
                      shadows: backgroundImage != null ? [
                        Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 4, offset: const Offset(0, 2))
                      ] : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: backgroundImage != null ? Colors.white.withOpacity(0.9) : AppTheme.neutralMedium,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



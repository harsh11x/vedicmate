import 'package:flutter/material.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import '../models/timeline_event.dart';
import '../../../core/theme/app_theme.dart';
import '../../../../widgets/sketchy_painter.dart';

class TimelineCard extends StatelessWidget {
  final TimelineEvent event;
  final bool isLeftAligned;
  final VoidCallback onTap;

  const TimelineCard({
    Key? key,
    required this.event,
    required this.isLeftAligned,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        width: 320, 
        child: SketchyContainer(
          backgroundColor: AppTheme.divineSurface,
          borderColor: AppTheme.textBlack,
          borderRadius: 16,
          padding: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (event.imageUrl != null)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
                  child: event.imageUrl!.startsWith('/') 
                    ? Image.file(
                        File(event.imageUrl!),
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                      )
                    : Image.asset(
                        event.imageUrl!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                      ),
                ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        event.yearRange,
                        style: GoogleFonts.patrickHand(
                          color: AppTheme.primaryOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      event.title,
                      style: GoogleFonts.architectsDaughter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textBlack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.period,
                      style: GoogleFonts.patrickHand(
                        fontSize: 16,
                        color: AppTheme.neutralDark.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      event.description,
                      style: GoogleFonts.patrickHand(
                        fontSize: 16,
                        color: AppTheme.neutralDark,
                        height: 1.3,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 180,
      color: AppTheme.yellowPrimary.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.history_edu, 
          size: 60, 
          color: AppTheme.primaryOrange.withOpacity(0.5)
        ),
      ),
    );
  }
}

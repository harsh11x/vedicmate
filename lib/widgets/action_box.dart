import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'sketchy_painter.dart';

class ActionBox extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final VoidCallback onTap;

  const ActionBox({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SketchyContainer(
        backgroundColor: AppTheme.divineSurface,
        borderColor: AppTheme.textBlack,
        borderRadius: 20,
        padding: 16,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 60),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTheme.titleStyle.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTheme.bodyStyle.copyWith(fontSize: 14, color: AppTheme.textGrey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

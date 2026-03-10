import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vedic Library'),
        backgroundColor: AppTheme.primaryOrange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Core Scriptures'),
          _buildScriptureCard(
            context,
            title: 'Bhagavad Gita',
            subtitle: 'The Song of God',
            icon: Icons.auto_stories,
            onTap: () => _navigateToReader(context, 'gita', 'Bhagavad Gita', 1),
          ),
          _buildScriptureCard(
            context,
            title: 'Isha Upanishad',
            subtitle: 'Knowledge of the Self',
            icon: Icons.menu_book,
            onTap: () => _navigateToReader(context, 'isha_upanishad', 'Isha Upanishad', 0),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Vedic Hymns'),
           _buildScriptureCard(
            context,
            title: 'Purusha Suktam',
            subtitle: 'Cosmic Being Hymn',
            icon: Icons.music_note,
            onTap: () => _navigateToReader(context, 'purusha_suktam', 'Purusha Suktam', 0),
          ),
           _buildScriptureCard(
            context,
            title: 'Gayatri Mantra',
            subtitle: 'Hymn to the Sun',
            icon: Icons.wb_sunny,
            onTap: () => _navigateToReader(context, 'gayatri_mantra', 'Gayatri Mantra', 0),
          ),
           _buildScriptureCard(
            context,
            title: 'Maha Mrityunjaya',
            subtitle: 'Victory over Death',
            icon: Icons.shield,
            onTap: () => _navigateToReader(context, 'mrityunjaya', 'Maha Mrityunjaya', 0),
          ),
        ],
      ),
    );
  }

  void _navigateToReader(BuildContext context, String scriptureId, String title, int chapter) {
    context.push(
      Uri(
        path: '/education/reader/$scriptureId',
        queryParameters: {'title': title, 'chapter': chapter.toString()},
      ).toString(),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppTheme.textDark,
        ),
      ),
    );
  }

  Widget _buildScriptureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.yellowPrimary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primaryOrange),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

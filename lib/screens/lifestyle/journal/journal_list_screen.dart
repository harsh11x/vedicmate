import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
// import '../../../providers/journal_provider.dart';

class JournalListScreen extends ConsumerWidget {
  const JournalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock data
    final entries = [
      {
        'id': '1',
        'entry_date': '2025-05-20',
        'content_encrypted': 'Today was a peaceful day. I practiced meditation in the morning...',
        'mood_rating': 8,
      },
      {
        'id': '2',
        'entry_date': '2025-05-19',
        'content_encrypted': 'Felt a bit low energy today, but the evening walk helped.',
        'mood_rating': 5,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spiritual Journal'),
        backgroundColor: AppTheme.primaryOrange,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          final date = DateTime.parse(entry['entry_date'] as String);
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                DateFormat('MMM d, yyyy').format(date),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    entry['content_encrypted'] as String,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.mood, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text('${entry['mood_rating']}/10'),
                    ],
                  ),
                ],
              ),
              onTap: () {
                // Navigate to detail/edit view
                context.push('/lifestyle/journal/edit', extra: entry);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/lifestyle/journal/entry');
        },
        backgroundColor: AppTheme.primaryOrange,
        child: const Icon(Icons.edit),
      ),
    );
  }
}

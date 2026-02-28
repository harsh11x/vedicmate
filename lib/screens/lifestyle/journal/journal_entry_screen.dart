import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';

class JournalEntryScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? entry; // Null for new entry

  const JournalEntryScreen({super.key, this.entry});

  @override
  ConsumerState<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends ConsumerState<JournalEntryScreen> {
  final _contentController = TextEditingController();
  double _moodRating = 5;
  
  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _contentController.text = widget.entry!['content_encrypted'];
      _moodRating = (widget.entry!['mood_rating'] as num).toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? 'New Entry' : 'Edit Entry'),
        backgroundColor: AppTheme.primaryOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveEntry,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Mood Slider
            Row(
              children: [
                const Icon(Icons.mood_bad),
                Expanded(
                  child: Slider(
                    value: _moodRating,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: _moodRating.round().toString(),
                    activeColor: AppTheme.primaryOrange,
                    onChanged: (val) => setState(() => _moodRating = val),
                  ),
                ),
                const Icon(Icons.mood),
              ],
            ),
            const SizedBox(height: 16),
            
            // Content Area
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Write your thoughts...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveEntry() {
    // Save logic via provider
    Navigator.pop(context);
  }
}

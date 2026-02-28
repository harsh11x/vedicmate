import 'package:flutter/material.dart';
import '../models/timeline_event.dart';

class TimelineDetailScreen extends StatelessWidget {
  final TimelineEvent event;

  const TimelineDetailScreen({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: Text(event.title),
        backgroundColor: const Color(0xFF5D4037),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.imageUrl != null)
              Image.asset(
                event.imageUrl!,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.history_edu, size: 60, color: Colors.grey)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.yearRange,
                    style: TextStyle(
                      color: const Color(0xFF5D4037).withOpacity(0.8),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  const SizedBox(height: 16),
                   Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8D6E63),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event.period,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    event.detailedDescription,
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.6,
                      color: Color(0xFF4E342E),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (event.relatedScriptures.isNotEmpty) ...[
                    const Divider(color: Color(0xFF8D6E63)),
                    const SizedBox(height: 16),
                    const Text(
                      'Related Scriptures',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Serif',
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: event.relatedScriptures.map((scripture) {
                        return Chip(
                          label: Text(scripture),
                          backgroundColor: const Color(0xFFD7CCC8),
                          labelStyle: const TextStyle(color: Color(0xFF3E2723)),
                        );
                      }).toList(),
                    ),
                  ],
                  if (event.metadata != null && event.metadata!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Divider(color: Color(0xFF8D6E63)),
                    const SizedBox(height: 16),
                    const Text(
                      'Key Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Serif',
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...event.metadata!.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${entry.key.replaceAll('_', ' ').toUpperCase()}: ',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
                            ),
                            Expanded(
                              child: Text(
                                entry.value.toString(),
                                style: const TextStyle(color: Color(0xFF4E342E)),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

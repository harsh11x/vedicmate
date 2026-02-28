import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/timeline_event.dart';
import '../services/timeline_repository.dart';
import 'timeline_detail_screen.dart';
import '../widgets/timeline_card.dart';
import '../../../core/theme/app_theme.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({Key? key}) : super(key: key);

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  final TimelineRepository _repository = TimelineRepository();
  late Future<List<TimelineEvent>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _repository.getTimelineEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.divineBackground,
      appBar: AppBar(
        title: Text(
          'Vedic Timeline',
          style: GoogleFonts.architectsDaughter(
            fontWeight: FontWeight.bold,
            color: AppTheme.textBlack,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textBlack),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<TimelineEvent>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading timeline data: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No historical events found.'));
          }

          final events = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            itemCount: events.length,
            scrollDirection: Axis.horizontal, 
            itemBuilder: (context, index) {
              final event = events[index];
              return TimelineCard(
                event: event,
                isLeftAligned: index.isEven,
                onTap: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TimelineDetailScreen(event: event),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

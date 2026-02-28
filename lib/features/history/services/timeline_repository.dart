import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/timeline_event.dart';

class TimelineRepository {
  Future<List<TimelineEvent>> getTimelineEvents() async {
    try {
      final String response = await rootBundle.loadString('assets/data/history/timeline_data.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) => TimelineEvent.fromJson(json)).toList();
    } catch (e) {
      // Return empty list or throw error depending on needs
      return [];
    }
  }
}

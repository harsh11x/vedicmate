import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/scripture_model.dart';

class ScriptureRepository {
  Future<ScriptureChapter> getChapter(String scriptureId, int chapterNumber) async {
    // If chapterNumber is 0 or negative, it might be a single-chapter text or hymn
    final fileName = chapterNumber > 0 
        ? '${scriptureId}_ch$chapterNumber.json'
        : '$scriptureId.json';
        
    try {
      final String response = await rootBundle.loadString('assets/data/scriptures/$fileName');
      final Map<String, dynamic> data = json.decode(response);
      return ScriptureChapter.fromJson(data);
    } catch (e) {
      throw Exception('Failed to load $scriptureId (Chapter: $chapterNumber): $e');
    }
  }

  // Future expansion: get list of chapters, get specific verse, etc.
}

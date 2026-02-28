import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../models/yoga_pose_model.dart';

class YogaRepository {
  List<YogaPose>? _cachedPoses;

  Future<List<YogaPose>> getAllPoses() async {
    if (_cachedPoses != null) {
      return _cachedPoses!;
    }

    try {
      final String response = await rootBundle.loadString('assets/data/yoga/yoga_poses.json');
      final Map<String, dynamic> data = json.decode(response);
      final List<dynamic> posesJson = data['poses'] as List<dynamic>;
      
      _cachedPoses = posesJson.map((json) => YogaPose.fromJson(json)).toList();
      return _cachedPoses!;
    } catch (e) {
      throw Exception('Failed to load yoga poses: $e');
    }
  }

  Future<YogaPose?> getPoseById(String id) async {
    final poses = await getAllPoses();
    try {
      return poses.firstWhere((pose) => pose.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<YogaPose>> getPosesByCategory(String category) async {
    final poses = await getAllPoses();
    if (category.toLowerCase() == 'all') {
      return poses;
    }
    return poses.where((pose) => pose.category.toLowerCase() == category.toLowerCase()).toList();
  }

  Future<List<YogaPose>> getPosesByDifficulty(String difficulty) async {
    final poses = await getAllPoses();
    return poses.where((pose) => pose.difficulty.toLowerCase() == difficulty.toLowerCase()).toList();
  }

  Future<List<YogaPose>> searchPoses(String query) async {
    final poses = await getAllPoses();
    final lowerQuery = query.toLowerCase();
    return poses.where((pose) {
      return pose.nameEnglish.toLowerCase().contains(lowerQuery) ||
             pose.nameSanskrit.toLowerCase().contains(lowerQuery) ||
             pose.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<String> getCategories() {
    return [
      'All',
      'Standing',
      'Sitting',
      'Lying',
      'Balancing',
      'Twisting',
      'Inversion',
    ];
  }

  List<String> getDifficulties() {
    return ['Beginner', 'Intermediate', 'Advanced'];
  }
}

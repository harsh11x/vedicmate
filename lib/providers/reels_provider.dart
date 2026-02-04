import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_provider.dart';

// --- Models ---

class Reel {
  final String id;
  final String videoUrl;
  final String? thumbnailUrl;
  final String description;
  final List<String> hashtags;
  final List<ReelLike> likes;
  final List<ReelComment> comments;
  final DateTime createdAt;

  Reel({
    required this.id,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.description,
    required this.hashtags,
    required this.likes,
    required this.comments,
    required this.createdAt,
  });

  factory Reel.fromJson(Map<String, dynamic> json) {
    return Reel(
      id: json['id'],
      videoUrl: json['videoUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      description: json['description'] ?? '',
      hashtags: (json['hashtags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      likes: (json['likes'] as List?)?.map((e) => ReelLike.fromJson(e)).toList() ?? [],
      comments: (json['comments'] as List?)?.map((e) => ReelComment.fromJson(e)).toList() ?? [],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ReelLike {
  final String userId;
  final String name;

  ReelLike({required this.userId, required this.name});

  factory ReelLike.fromJson(Map<String, dynamic> json) {
    return ReelLike(userId: json['userId'], name: json['name'] ?? 'User');
  }
}

class ReelComment {
  final String id;
  final String userId;
  final String name;
  final String text;
  final DateTime timestamp;

  ReelComment({
    required this.id,
    required this.userId,
    required this.name,
    required this.text,
    required this.timestamp,
  });

  factory ReelComment.fromJson(Map<String, dynamic> json) {
    return ReelComment(
      id: json['id'],
      userId: json['userId'],
      name: json['name'] ?? 'User',
      text: json['text'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

// --- Providers ---

final reelsProvider = StateNotifierProvider<ReelsNotifier, AsyncValue<List<Reel>>>((ref) {
  return ReelsNotifier(ref);
});

class ReelsNotifier extends StateNotifier<AsyncValue<List<Reel>>> {
  final Ref ref;

  ReelsNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchReels();
  }

  /// Call to refresh reels (e.g. pull-to-refresh)
  Future<void> refresh() => fetchReels();

  Future<void> fetchReels() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/reels')).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> reelsJson = data['data'] as List;
          final reels = reelsJson.map((e) => Reel.fromJson(e as Map<String, dynamic>)).toList();
          state = AsyncValue.data(reels);
        } else {
          state = const AsyncValue.data([]);
        }
      } else {
        debugPrint('Reels API returned ${response.statusCode}');
        state = const AsyncValue.data([]);
      }
    } catch (e, st) {
      debugPrint('Error fetching reels: $e');
      state = const AsyncValue.data([]);
    }
  }

  Future<void> toggleLike(String reelId) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    // Optimistic Update
    state.whenData((reels) {
      final index = reels.indexWhere((r) => r.id == reelId);
      if (index != -1) {
        final reel = reels[index];
        final hasLiked = reel.likes.any((l) => l.userId == user.uid);
        final List<ReelLike> newLikes = List.from(reel.likes);

        if (hasLiked) {
          newLikes.removeWhere((l) => l.userId == user.uid);
        } else {
          newLikes.add(ReelLike(userId: user.uid, name: user.displayName ?? 'User'));
        }

        final updatedReel = Reel(
          id: reel.id,
          videoUrl: reel.videoUrl,
          thumbnailUrl: reel.thumbnailUrl,
          description: reel.description,
          hashtags: reel.hashtags,
          likes: newLikes,
          comments: reel.comments,
          createdAt: reel.createdAt,
        );
        
        final updatedList = List<Reel>.from(reels);
        updatedList[index] = updatedReel;
        state = AsyncValue.data(updatedList);
      }
    });

    try {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/reels/$reelId/like'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': user.uid,
          'email': user.email,
          'name': user.displayName,
        }),
      );
    } catch (e) {
      print('Error liking reel: $e');
    }
  }

  Future<void> addComment(String reelId, String text) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/reels/$reelId/comment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': user.uid,
          'email': user.email,
          'name': user.displayName,
          'text': text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          final newComment = ReelComment.fromJson(data['data']);
          
          state.whenData((reels) {
            final index = reels.indexWhere((r) => r.id == reelId);
            if (index != -1) {
              final reel = reels[index];
              final updatedComments = List<ReelComment>.from(reel.comments)..add(newComment);
              
              final updatedReel = Reel(
                id: reel.id,
                videoUrl: reel.videoUrl,
                thumbnailUrl: reel.thumbnailUrl,
                description: reel.description,
                hashtags: reel.hashtags,
                likes: reel.likes,
                comments: updatedComments,
                createdAt: reel.createdAt,
              );

              final updatedList = List<Reel>.from(reels);
              updatedList[index] = updatedReel;
              state = AsyncValue.data(updatedList);
            }
          });
        }
      }
    } catch (e) {
      print('Error commenting on reel: $e');
    }
  }
}


// Pandit Service
// This service handles all Pandit-related operations
// including search, filtering, and profile management

import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/pandit_model.dart';
import 'api_client.dart';

class PanditService {
  PanditService(this._api);
  final ApiClient _api;

  Future<List<PanditModel>> fetchPandits({String? query}) async {
    try {
      final Response res = await _api.get('/api/pandits', query: {
        if (query != null && query.isNotEmpty) 'q': query,
      });
      final data = res.data;
      if (data is List) {
        return data.map((e) => PanditModel.fromJson(Map<String, dynamic>.from(e))).toList();
      }
      return _getDemoPandits();
    } catch (e) {
      // Return demo data if API fails
      return _getDemoPandits();
    }
  }

  List<PanditModel> _getDemoPandits() {
    return [
      PanditModel(
        id: 'p1',
        name: 'Pandit Ravi Shankar',
        specializations: ['Vedic Astrology', 'Palmistry', 'Numerology'],
        experienceYears: 15,
        rating: 4.8,
        totalReviews: 2341,
        languages: ['Hindi', 'English', 'Sanskrit'],
        servicePricing: {'consultation': 25.0, 'video_call': 30.0, 'voice_call': 25.0, 'chat': 20.0},
        bio: 'Experienced Vedic astrologer with 15+ years of practice. Specialized in Vedic astrology, Palmistry, and Numerology.',
        certifications: ['Vedic Astrology Certification', 'Jyotish Expert'],
        isVerified: true,
        isAvailable: true,
      ),
      PanditModel(
        id: 'p2',
        name: 'Acharya Priya Sharma',
        specializations: ['Numerology', 'Tarot Reading', 'Vastu Shastra'],
        experienceYears: 12,
        rating: 4.9,
        totalReviews: 1890,
        languages: ['Hindi', 'English'],
        servicePricing: {'consultation': 30.0, 'video_call': 35.0, 'voice_call': 30.0, 'chat': 25.0},
        bio: 'Renowned numerologist and tarot reader with 12 years of experience. Expert in Vastu Shastra.',
        certifications: ['Numerology Master', 'Tarot Expert'],
        isVerified: true,
        isAvailable: true,
      ),
      PanditModel(
        id: 'p3',
        name: 'Guru Vikash Joshi',
        specializations: ['Vastu Shastra', 'Gemology', 'Remedies'],
        experienceYears: 20,
        rating: 4.7,
        totalReviews: 1567,
        languages: ['Hindi', 'English', 'Gujarati'],
        servicePricing: {'consultation': 35.0, 'video_call': 40.0, 'voice_call': 35.0, 'chat': 30.0},
        bio: 'Master in Vastu Shastra and Gemology with 20 years of expertise.',
        certifications: ['Vastu Expert', 'Gemologist'],
        isVerified: true,
        isAvailable: true,
      ),
      PanditModel(
        id: 'p4',
        name: 'Sidhi',
        specializations: ['Vedic', 'Vastu', 'Prashana'],
        experienceYears: 10,
        rating: 4.96,
        totalReviews: 212197,
        languages: ['English', 'Hindi'],
        servicePricing: {'consultation': 27.0, 'video_call': 32.0, 'voice_call': 27.0, 'chat': 22.0},
        bio: 'Sidhi is a Vedic astrologer in India. She loves to help her clients when they are in need. Her predictions are known for their accuracy.',
        certifications: ['Vedic Astrology Expert'],
        isVerified: true,
        isAvailable: true,
      ),
    ];
  }

    // Placeholder for creating/updating pandits through admin panel
  Future<PanditModel> createPandit(PanditModel p) async {
    final res = await _api.post('/api/pandits', data: p.toJson());
    return PanditModel.fromJson(Map<String, dynamic>.from(res.data));
  }
}


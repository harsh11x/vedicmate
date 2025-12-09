// Kundli AI Service
// Handles Kundli generation requests and provides detailed analysis using Gemini AI

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'gemini_service.dart';

class KundliAIService {
  final GeminiService _geminiService = GeminiService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Generate Kundli analysis using AI
  Future<String> generateKundliAnalysis({
    required String name,
    required DateTime dateOfBirth,
    required String placeOfBirth,
    required String timeOfBirth,
    List<Map<String, String>>? conversationHistory,
  }) async {
    try {
      // Format birth details for AI
      final birthDetails = '''
**BIRTH DETAILS FOR KUNDLI ANALYSIS:**
Name: $name
Date of Birth: ${dateOfBirth.day}/${dateOfBirth.month}/${dateOfBirth.year}
Time of Birth: $timeOfBirth
Place of Birth: $placeOfBirth

Please provide a complete Kundli analysis including:
1. Lagna (Ascendant) calculation and analysis
2. Rashi (Moon sign) and its characteristics
3. Nakshatra and its effects
4. Planetary positions in houses and signs
5. Analysis of all 12 houses (Bhavas)
6. Important Yogas and Doshas
7. Dasha periods and their effects
8. Future predictions based on the chart
9. Remedies and suggestions

Please be detailed and comprehensive in your analysis, speaking like an experienced pandit.
''';

      final history = conversationHistory ?? [];
      final response = await _geminiService.sendMessage(birthDetails, history);
      
      // Save Kundli analysis to Firestore
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).collection('kundlis').add({
          'name': name,
          'dateOfBirth': Timestamp.fromDate(dateOfBirth),
          'placeOfBirth': placeOfBirth,
          'timeOfBirth': timeOfBirth,
          'analysis': response,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      return response;
    } catch (e) {
      throw Exception('Failed to generate Kundli analysis: $e');
    }
  }

  // Get user's saved Kundli
  Future<Map<String, dynamic>?> getUserKundli() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final kundlis = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('kundlis')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (kundlis.docs.isNotEmpty) {
        final data = kundlis.docs.first.data();
        return {
          'id': kundlis.docs.first.id,
          ...data,
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Calculate numerology from name and date
  Future<String> calculateNumerology({
    required String name,
    required DateTime dateOfBirth,
    List<Map<String, String>>? conversationHistory,
  }) async {
    try {
      final lifePathNumber = GeminiService.calculateLifePathNumber(dateOfBirth);
      
      final numerologyRequest = '''
**NUMEROLOGY CALCULATION REQUEST:**
Name: $name
Date of Birth: ${dateOfBirth.day}/${dateOfBirth.month}/${dateOfBirth.year}
Calculated Life Path Number: $lifePathNumber

Please provide:
1. Detailed Life Path Number analysis
2. Name Numerology calculation and meaning
3. Destiny Number, Soul Number, Personality Number
4. Lucky numbers, colors, days
5. Numerology predictions
6. Compatibility analysis
7. Remedies based on numerology

Please calculate and explain everything in detail, speaking like an experienced numerologist.
''';

      final history = conversationHistory ?? [];
      return await _geminiService.sendMessage(numerologyRequest, history);
    } catch (e) {
      throw Exception('Failed to calculate numerology: $e');
    }
  }
}


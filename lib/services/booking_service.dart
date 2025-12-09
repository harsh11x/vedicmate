// Booking Service
// Real-time booking management using Firebase Firestore and API

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking_model.dart';
import 'api_client.dart';
import 'wallet_service.dart';
import 'settings_service.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiClient _api;
  final WalletService _walletService;
  final SettingsService _settingsService;

  BookingService(this._api, this._walletService, this._settingsService);

  // Create a new booking
  Future<BookingModel> createBooking({
    required String clientId,
    required String panditId,
    required String serviceType,
    required DateTime scheduledAt,
    required int duration,
    required String callType,
    required double servicePrice,
  }) async {
    try {
      // Get settings for platform fee and GST
      final settings = await _settingsService.getSettings();
      final platformFeePercent = settings.platformFeePercent;
      final gstRate = 18.0; // GST rate

      // Calculate amounts
      final platformFee = servicePrice * (platformFeePercent / 100);
      final gst = (servicePrice + platformFee) * (gstRate / 100);
      final totalAmount = servicePrice + platformFee + gst;

      // Check wallet balance
      final hasBalance = await _walletService.hasSufficientBalance(clientId, totalAmount);
      if (!hasBalance) {
        throw Exception('Insufficient wallet balance. Please recharge your wallet.');
      }

      // Create booking document in Firestore
      final bookingRef = _firestore.collection('bookings').doc();
      final bookingId = bookingRef.id;

      final bookingData = {
        'id': bookingId,
        'clientId': clientId,
        'panditId': panditId,
        'serviceType': serviceType,
        'scheduledAt': Timestamp.fromDate(scheduledAt),
        'duration': duration,
        'amount': servicePrice,
        'platformFee': platformFee,
        'gst': gst,
        'totalAmount': totalAmount,
        'status': 'pending',
        'callType': callType,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await bookingRef.set(bookingData);

      // Deduct amount from wallet
      final deducted = await _walletService.deductMoney(
        clientId,
        totalAmount,
        'Booking: $serviceType with Pandit',
        referenceId: bookingId,
      );

      if (!deducted) {
        // Rollback booking if payment fails
        await bookingRef.delete();
        throw Exception('Payment failed. Please try again.');
      }

      // Update booking status to confirmed after payment
      await bookingRef.update({
        'status': 'confirmed',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Try to sync with backend API if available
      try {
        await _api.post('/api/bookings', data: {
          'id': bookingId,
          'client_id': clientId,
          'pandit_id': panditId,
          'service_type': serviceType,
          'scheduled_at': scheduledAt.toIso8601String(),
          'duration': duration,
          'amount': servicePrice,
          'platform_fee': platformFee,
          'gst': gst,
          'total_amount': totalAmount,
          'status': 'confirmed',
          'call_type': callType,
        });
      } catch (e) {
        // API sync failed, but booking is created in Firestore
        print('Warning: Failed to sync booking to API: $e');
      }

      // Return booking model
      return BookingModel(
        id: bookingId,
        clientId: clientId,
        panditId: panditId,
        serviceType: serviceType,
        scheduledAt: scheduledAt,
        duration: duration,
        amount: servicePrice,
        platformFee: platformFee,
        gst: gst,
        totalAmount: totalAmount,
        status: BookingStatus.confirmed,
        callType: callType,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  // Get bookings for a user
  Stream<List<BookingModel>> getBookingsByUserStream(String userId, {BookingStatus? status}) {
    Query query = _firestore
        .collection('bookings')
        .where('clientId', isEqualTo: userId)
        .orderBy('scheduledAt', descending: true);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _bookingFromFirestore(doc.id, data);
      }).where((booking) {
        if (status != null) {
          return booking.status == status;
        }
        return true;
      }).toList();
    });
  }

  // Get bookings for a user (one-time fetch)
  Future<List<BookingModel>> getBookingsByUser(String userId, {BookingStatus? status}) async {
    try {
      Query query = _firestore
          .collection('bookings')
          .where('clientId', isEqualTo: userId)
          .orderBy('scheduledAt', descending: true);

      final snapshot = await query.get();
      final bookings = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _bookingFromFirestore(doc.id, data);
      }).toList();

      if (status != null) {
        return bookings.where((b) => b.status == status).toList();
      }
      return bookings;
    } catch (e) {
      // Fallback to API if Firestore fails
      try {
        final response = await _api.get('/api/bookings', query: {
          'userId': userId,
          if (status != null) 'status': status.toString().split('.').last,
        });
        if (response.data is List) {
          return (response.data as List)
              .map((e) => BookingModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      } catch (apiError) {
        print('Error fetching bookings: $apiError');
      }
      return [];
    }
  }

  // Get bookings for a pandit
  Stream<List<BookingModel>> getBookingsByPanditStream(String panditId, {BookingStatus? status}) {
    Query query = _firestore
        .collection('bookings')
        .where('panditId', isEqualTo: panditId)
        .orderBy('scheduledAt', descending: true);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _bookingFromFirestore(doc.id, data);
      }).where((booking) {
        if (status != null) {
          return booking.status == status;
        }
        return true;
      }).toList();
    });
  }

  // Cancel a booking
  Future<bool> cancelBooking(String bookingId) async {
    try {
      final bookingRef = _firestore.collection('bookings').doc(bookingId);
      final bookingDoc = await bookingRef.get();

      if (!bookingDoc.exists) {
        throw Exception('Booking not found');
      }

      final data = bookingDoc.data() as Map<String, dynamic>;
      final status = data['status'] as String?;
      final clientId = data['clientId'] as String?;
      final totalAmount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;

      if (status == 'completed' || status == 'cancelled') {
        throw Exception('Cannot cancel a $status booking');
      }

      // Update booking status
      await bookingRef.update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Refund to wallet if booking was confirmed
      if (status == 'confirmed' && clientId != null) {
        await _walletService.addMoney(
          clientId,
          totalAmount,
          'refund_$bookingId',
        );
      }

      // Try to sync with API
      try {
        await _api.put('/api/bookings/$bookingId', data: {
          'status': 'cancelled',
        });
      } catch (e) {
        print('Warning: Failed to sync cancellation to API: $e');
      }

      return true;
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  // Update booking status
  Future<bool> updateBookingStatus(String bookingId, BookingStatus status) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': status.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
        if (status == BookingStatus.completed)
          'completedAt': FieldValue.serverTimestamp(),
      });

      // Try to sync with API
      try {
        await _api.put('/api/bookings/$bookingId', data: {
          'status': status.toString().split('.').last,
        });
      } catch (e) {
        print('Warning: Failed to sync status update to API: $e');
      }

      return true;
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  // Helper to convert Firestore data to BookingModel
  BookingModel _bookingFromFirestore(String id, Map<String, dynamic> data) {
    return BookingModel(
      id: id,
      clientId: data['clientId'] ?? '',
      panditId: data['panditId'] ?? '',
      serviceType: data['serviceType'] ?? '',
      scheduledAt: (data['scheduledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      duration: data['duration'] ?? 30,
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      platformFee: (data['platformFee'] as num?)?.toDouble() ?? 0.0,
      gst: (data['gst'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: BookingStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (data['status'] ?? 'pending'),
        orElse: () => BookingStatus.pending,
      ),
      callType: data['callType'],
      meetingLink: data['meetingLink'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      notes: data['notes'],
    );
  }
}


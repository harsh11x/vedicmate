// Chat Service
// Real-time chat using Firebase Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatMessage {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final DateTime timestamp;
  final String? fileUrl;
  final String? fileName;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
    this.fileUrl,
    this.fileName,
    this.isRead = false,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      text: data['text'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? 'Unknown',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fileUrl: data['fileUrl'],
      fileName: data['fileName'],
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'timestamp': Timestamp.fromDate(timestamp),
      'fileUrl': fileUrl,
      'fileName': fileName,
      'isRead': isRead,
    };
  }
}

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get or create chat room between client and pandit
  Future<String> getOrCreateChatRoom(String panditId, String panditName) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    // Create a consistent chat room ID (sorted to ensure uniqueness)
    final participants = [userId, panditId]..sort();
    final chatRoomId = 'chat_${participants[0]}_${participants[1]}';

    // Check if chat room exists
    final chatRoomRef = _firestore.collection('chatRooms').doc(chatRoomId);
    final chatRoomDoc = await chatRoomRef.get();

    if (!chatRoomDoc.exists) {
      // Create new chat room
      await chatRoomRef.set({
        'id': chatRoomId,
        'participants': [userId, panditId],
        'participantNames': {
          userId: _auth.currentUser?.displayName ?? 'User',
          panditId: panditName,
        },
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    return chatRoomId;
  }

  // Get chat room ID from booking ID
  Future<String?> getChatRoomFromBooking(String bookingId) async {
    try {
      final bookingDoc = await _firestore.collection('bookings').doc(bookingId).get();
      if (!bookingDoc.exists) return null;
      
      final data = bookingDoc.data();
      final clientId = data?['clientId'] as String?;
      final panditId = data?['panditId'] as String?;
      
      if (clientId == null || panditId == null) return null;
      
      final participants = [clientId, panditId]..sort();
      return 'chat_${participants[0]}_${participants[1]}';
    } catch (e) {
      return null;
    }
  }

  // Send a message
  Future<void> sendMessage(String chatRoomId, String text, {String? fileUrl, String? fileName}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final userName = _auth.currentUser?.displayName ?? 'User';

    // Add message to messages subcollection
    await _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'text': text,
      'senderId': userId,
      'senderName': userName,
      'timestamp': FieldValue.serverTimestamp(),
      'fileUrl': fileUrl,
      'fileName': fileName,
      'isRead': false,
    });

    // Update chat room last message
    await _firestore.collection('chatRooms').doc(chatRoomId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Stream messages for a chat room
  Stream<List<ChatMessage>> getMessagesStream(String chatRoomId) {
    return _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList();
    });
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatRoomId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final messagesRef = _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages');

    // Get unread messages from other users
    final unreadMessages = await messagesRef
        .where('senderId', isNotEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    // Batch update
    final batch = _firestore.batch();
    for (var doc in unreadMessages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // Get all chat rooms for current user
  Stream<List<Map<String, dynamic>>> getUserChatRooms() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('chatRooms')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    });
  }

  // Get unread message count for a chat room
  Future<int> getUnreadCount(String chatRoomId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return 0;

    final snapshot = await _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('senderId', isNotEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    return snapshot.docs.length;
  }
}


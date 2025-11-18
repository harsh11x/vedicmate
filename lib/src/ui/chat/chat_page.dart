import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String chatId;
  const ChatPage({super.key, required this.chatId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _ctrl = TextEditingController();

  Future<void> _sendMessage() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    final uid = _auth.currentUser?.uid ?? 'anon';
    await _firestore.collection('chats').doc(widget.chatId).collection('messages').add({
      'senderId': uid,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat: ${widget.chatId}')),
      body: Column(children: [
        Expanded(child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('chats').doc(widget.chatId).collection('messages').orderBy('timestamp').snapshots(),
          builder: (context, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final docs = snap.data!.docs;
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: docs.length,
              itemBuilder: (ctx, i) {
                final d = docs[i].data() as Map<String, dynamic>;
                final sender = d['senderId'] ?? 'unknown';
                final text = d['text'] ?? '';
                final mine = sender == (_auth.currentUser?.uid ?? '');
                return Align(
                  alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: mine ? Colors.green[100] : Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                    child: Text(text),
                  ),
                );
              },
            );
          },
        )),
        SafeArea(child: Row(children: [
          Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: TextField(controller: _ctrl, decoration: const InputDecoration(hintText: 'Type a message')))),
          IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send))
        ]))
      ]),
    );
  }
}

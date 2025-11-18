import 'package:flutter/material.dart';
import '../call/call_page.dart';
import '../chat/chat_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VedicMate')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            Text('Namaste, Demo User 👋', style: TextStyle(fontSize: 22)),
            SizedBox(height: 12),
            Text('This is a minimal scaffold. Implement features per the product spec.'),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'call',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CallPage())),
            label: const Text('Call'),
            icon: const Icon(Icons.video_call),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'chat',
            onPressed: () {
              // For demo, use a fixed chat id
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatPage(chatId: 'demo_chat')));
            },
            label: const Text('Chat'),
            icon: const Icon(Icons.chat),
          ),
        ],
      ),
    );
  }
}

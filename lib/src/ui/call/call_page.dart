import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../services/call_service.dart';

class CallPage extends StatefulWidget {
  const CallPage({super.key});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final _callService = CallService();
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  String? _callId;
  bool _inCall = false;

  @override
  void initState() {
    super.initState();
    _initRenderers();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  Future<void> _startCall() async {
    final id = await _callService.createCall(video: true);
    setState(() {
      _callId = id;
      _inCall = true;
    });
    final localStream = _callService.localStream;
    if (localStream != null) _localRenderer.srcObject = localStream;
    // listen for remote stream and attach when available
    _callService.onRemoteStream.listen((s) {
      if (s != null) {
        setState(() {
          _remoteRenderer.srcObject = s;
        });
      }
    });
  }

  Future<void> _joinCall() async {
    final textCtl = TextEditingController();
    final callId = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Join Call'),
      content: TextField(controller: textCtl, decoration: const InputDecoration(labelText: 'Call ID')),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(ctx, textCtl.text.trim()), child: const Text('Join'))],
    ));
    if (callId == null || callId.isEmpty) return;
    await _callService.joinCall(callId, video: true);
    setState(() {
      _callId = callId;
      _inCall = true;
    });
    final localStream = _callService.localStream;
    if (localStream != null) _localRenderer.srcObject = localStream;
    _callService.onRemoteStream.listen((s) {
      if (s != null) {
        setState(() {
          _remoteRenderer.srcObject = s;
        });
      }
    });
  }

  Future<void> _hangUp() async {
    await _callService.hangUp(callId: _callId);
    setState(() {
      _callId = null;
      _inCall = false;
    });
    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Call (Demo)')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          if (!_inCall) Text('Logged in as: ${user?.phoneNumber ?? user?.uid ?? 'guest'}'),
          const SizedBox(height: 12),
          Expanded(
            child: Row(children: [
              Expanded(child: Container(color: Colors.black12, child: RTCVideoView(_localRenderer, mirror: true))),
              const SizedBox(width: 8),
              Expanded(child: Container(color: Colors.black26, child: RTCVideoView(_remoteRenderer))),
            ]),
          ),
          const SizedBox(height: 12),
          if (!_inCall) Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            ElevatedButton(onPressed: _startCall, child: const Text('Start Call')),
            ElevatedButton(onPressed: _joinCall, child: const Text('Join Call')),
          ]) else Row(mainAxisAlignment: MainAxisAlignment.center, children: [ElevatedButton(onPressed: _hangUp, child: const Text('Hang Up'))]),
          const SizedBox(height: 8),
          if (_callId != null) SelectableText('Call ID: $_callId')
        ]),
      ),
    );
  }
}

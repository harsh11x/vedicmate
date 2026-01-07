// Socket.IO Service for Real-time Updates
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../core/config/env.dart';
import 'dart:async';

class SocketService {
  IO.Socket? _socket;
  final String baseUrl;
  final Map<String, StreamController<dynamic>> _controllers = {};

  SocketService({String? customUrl})
      : baseUrl = customUrl ?? EnvConfig.apiBaseUrl;

  /// Connect to WebSocket server
  Future<void> connect() async {
    if (_socket?.connected == true) {
      return;
    }

    try {
      _socket = IO.io(
        baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .build(),
      );

      _socket!.onConnect((_) {
        print('✅ Socket connected');
      });

      _socket!.onDisconnect((_) {
        print('❌ Socket disconnected');
      });

      _socket!.onError((error) {
        print('❌ Socket error: $error');
      });

      // Listen for balance updates
      _socket!.on('balance-update', (data) {
        final userId = data['userId'] as String?;
        if (userId != null) {
          _emit('balance-$userId', data);
        }
      });

      // Listen for chat updates
      _socket!.on('chat-response', (data) {
        final sessionId = data['sessionId'] as String?;
        if (sessionId != null) {
          _emit('chat-$sessionId', data);
        }
      });

      _socket!.on('chat-update', (data) {
        final sessionId = data['sessionId'] as String?;
        if (sessionId != null) {
          _emit('chat-update-$sessionId', data);
        }
      });
    } catch (e) {
      print('❌ Socket connection error: $e');
    }
  }

  /// Disconnect from server
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _controllers.clear();
  }

  /// Join user room for personalized updates
  void joinUserRoom(String userId) {
    _socket?.emit('join-user-room', userId);
  }

  /// Request balance update
  void requestBalance(String userId) {
    _socket?.emit('request-balance', userId);
  }

  /// Send chat message via socket
  void sendChatMessage({
    required String sessionId,
    required String userId,
    required String panditId,
    required String message,
  }) {
    _socket?.emit('chat-message', {
      'sessionId': sessionId,
      'userId': userId,
      'panditId': panditId,
      'message': message,
    });
  }

  /// Stream for balance updates
  Stream<Map<String, dynamic>> watchBalance(String userId) {
    final key = 'balance-$userId';
    if (!_controllers.containsKey(key)) {
      _controllers[key] = StreamController<Map<String, dynamic>>.broadcast();
    }
    return _controllers[key]!.stream.cast<Map<String, dynamic>>();
  }

  /// Stream for chat responses
  Stream<Map<String, dynamic>> watchChat(String sessionId) {
    final key = 'chat-$sessionId';
    if (!_controllers.containsKey(key)) {
      _controllers[key] = StreamController<Map<String, dynamic>>.broadcast();
    }
    return _controllers[key]!.stream.cast<Map<String, dynamic>>();
  }

  /// Stream for chat updates
  Stream<Map<String, dynamic>> watchChatUpdate(String sessionId) {
    final key = 'chat-update-$sessionId';
    if (!_controllers.containsKey(key)) {
      _controllers[key] = StreamController<Map<String, dynamic>>.broadcast();
    }
    return _controllers[key]!.stream.cast<Map<String, dynamic>>();
  }

  void _emit(String key, dynamic data) {
    if (_controllers.containsKey(key)) {
      _controllers[key]!.add(data);
    }
  }

  bool get isConnected => _socket?.connected ?? false;
}


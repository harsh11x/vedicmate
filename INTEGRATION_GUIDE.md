# Backend Integration Guide

This guide explains how to integrate the Flutter app with the AWS backend server.

## 🔄 Service Architecture

The app now supports **two modes**:

1. **Local Mode** (Current) - Uses Firebase and local services
2. **Backend Mode** (New) - Uses AWS server for AI, wallet, and real-time updates

## 📦 New Services Added

### 1. BackendAIService
- Connects to `/api/ai/welcome` and `/api/ai/chat`
- Handles personality-based AI responses from server
- Falls back to CustomAIService if backend unavailable

### 2. BackendWalletService
- Connects to `/api/wallet/*` endpoints
- Manages wallet balance, transactions
- Real-time balance updates via WebSocket

### 3. SocketService
- WebSocket connection for real-time updates
- Balance updates
- Chat message delivery
- Session management

## 🔧 How to Switch to Backend Mode

### Step 1: Update Environment Config

Edit `lib/core/config/env.dart`:

```dart
static const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://YOUR_AWS_SERVER_IP:4000', // Change this
);
```

### Step 2: Update Providers

Edit `lib/providers/api_providers.dart` to add backend services:

```dart
import '../services/backend_ai_service.dart';
import '../services/backend_wallet_service.dart';
import '../services/socket_service.dart';

// Backend AI Service Provider
final backendAIServiceProvider = Provider<BackendAIService>((ref) {
  return BackendAIService();
});

// Backend Wallet Service Provider
final backendWalletServiceProvider = Provider<BackendWalletService>((ref) {
  return BackendWalletService();
});

// Socket Service Provider
final socketServiceProvider = Provider<SocketService>((ref) {
  final service = SocketService();
  service.connect(); // Auto-connect
  return service;
});
```

### Step 3: Update Chat Screen

The chat screen can be updated to use backend services. Add this logic:

```dart
// In ai_pandit_chat_screen.dart

// Try backend first, fallback to local
Future<String> _getAIResponse(String message) async {
  try {
    // Try backend AI
    final backendAI = ref.read(backendAIServiceProvider);
    if (await backendAI.isAvailable()) {
      return await backendAI.sendMessage(
        message,
        _getHistory(),
        panditId: widget.panditId,
      );
    }
  } catch (e) {
    print('Backend AI failed, using local: $e');
  }
  
  // Fallback to local AI
  final geminiService = ref.read(geminiServiceProvider);
  return await geminiService.sendMessage(
    message,
    _getHistory(),
    panditId: widget.panditId,
  );
}
```

### Step 4: Update Wallet Service

Update `lib/services/wallet_service.dart` to use backend:

```dart
class WalletService {
  final BackendWalletService? _backend;
  final bool _useBackend;

  WalletService({BackendWalletService? backend})
      : _backend = backend,
        _useBackend = backend != null;

  Future<double> getBalance(String userId) async {
    if (_useBackend && _backend != null) {
      return await _backend!.getBalance(userId);
    }
    // Fallback to Firebase/local
    // ... existing code
  }
}
```

## 🔌 WebSocket Integration

### Initialize Socket Connection

```dart
// In main.dart or app initialization
final socketService = ref.read(socketServiceProvider);

// Join user room
socketService.joinUserRoom(userId);

// Listen for balance updates
socketService.watchBalance(userId).listen((data) {
  final newBalance = data['balance'] as double;
  // Update UI
});
```

### Send Chat Message via Socket

```dart
final socketService = ref.read(socketServiceProvider);

socketService.sendChatMessage(
  sessionId: sessionId,
  userId: userId,
  panditId: panditId,
  message: message,
);

// Listen for response
socketService.watchChat(sessionId).listen((data) {
  final response = data['message'] as String;
  // Update chat UI
});
```

## 🎯 Feature Flags

Create a feature flag to switch between modes:

```dart
// lib/core/config/feature_flags.dart
class FeatureFlags {
  static const bool useBackendAI = true; // Set to false for local
  static const bool useBackendWallet = true; // Set to false for local
  static const bool useWebSocket = true; // Set to false to disable
}
```

Then use in services:

```dart
if (FeatureFlags.useBackendAI) {
  // Use backend
} else {
  // Use local
}
```

## 📱 Testing

### Test Backend Connection

```dart
// Test if backend is available
final backendAI = BackendAIService();
if (await backendAI.isAvailable()) {
  print('✅ Backend is available');
} else {
  print('❌ Backend is not available');
}
```

### Test Wallet

```dart
final walletService = BackendWalletService();
final balance = await walletService.getBalance('user123');
print('Balance: ₹$balance');
```

### Test WebSocket

```dart
final socket = SocketService();
await socket.connect();
socket.joinUserRoom('user123');
socket.watchBalance('user123').listen((data) {
  print('Balance updated: ${data['balance']}');
});
```

## 🔄 Migration Strategy

### Phase 1: Parallel Running
- Keep both local and backend services
- Use feature flags to switch
- Test thoroughly

### Phase 2: Gradual Migration
- Start with AI service
- Then wallet service
- Finally real-time features

### Phase 3: Full Backend
- Remove local services
- Use only backend
- Optimize performance

## 🐛 Troubleshooting

### Backend Not Connecting
1. Check server is running: `curl http://your-server:4000/api/health`
2. Check network connectivity
3. Verify IP address in `env.dart`
4. Check firewall rules

### WebSocket Not Working
1. Check server WebSocket is enabled
2. Verify CORS configuration
3. Check browser/device network
4. Review socket connection logs

### AI Not Responding
1. Check API keys in server `.env`
2. Verify API quota/limits
3. Check server logs
4. Test API directly with curl

## 📊 Monitoring

### Server Health
```bash
curl http://your-server:4000/api/health
```

### Check Services
```dart
final health = await http.get(Uri.parse('$baseUrl/api/health'));
print(health.body);
```

## ✅ Checklist

Before deploying:

- [ ] Server is running and accessible
- [ ] API keys configured in server `.env`
- [ ] Flutter app `env.dart` updated with server IP
- [ ] WebSocket connection tested
- [ ] Wallet endpoints tested
- [ ] AI endpoints tested
- [ ] Error handling implemented
- [ ] Fallback mechanisms in place
- [ ] Logging enabled
- [ ] Security configured

## 🚀 Next Steps

1. **Deploy Server** (See BACKEND_SETUP.md)
2. **Update Flutter App** (This guide)
3. **Test All Features**
4. **Monitor Performance**
5. **Optimize as Needed**

---

**Your app is now ready to use the AWS backend!** 🎉

For server setup, see `BACKEND_SETUP.md`
For AI setup, see `AI_SETUP.md`


import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import '../services/live_service.dart';
import '../services/settings_service.dart';
import '../services/booking_service.dart';
import '../services/chat_service.dart';
import '../services/wallet_service.dart';
import '../services/gemini_service.dart';
import '../services/notification_service.dart';
import '../services/kundli_ai_service.dart';
import '../services/horoscope_service.dart';
import '../services/astrology_service.dart';
import '../services/custom_ai_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final horoscopeServiceProvider = Provider<HoroscopeService>((ref) {
  return HoroscopeService();
});

final astrologyServiceProvider = Provider<AstrologyService>((ref) {
  return AstrologyService();
});

final liveServiceProvider = Provider<LiveService>((ref) {
  final api = ref.watch(apiClientProvider);
  return LiveService(api);
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  final api = ref.watch(apiClientProvider);
  return SettingsService(api);
});

final walletServiceProvider = Provider<WalletService>((ref) {
  return WalletService();
});

final bookingServiceProvider = Provider<BookingService>((ref) {
  final api = ref.watch(apiClientProvider);
  final walletService = ref.watch(walletServiceProvider);
  final settingsService = ref.watch(settingsServiceProvider);
  return BookingService(api, walletService, settingsService);
});

final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});

final kundliAIServiceProvider = Provider<KundliAIService>((ref) {
  return KundliAIService();
});

final customAIServiceProvider = Provider<CustomAIService>((ref) {
  return CustomAIService();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import '../services/pandit_service.dart';
import '../services/live_service.dart';
import '../services/settings_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final panditServiceProvider = Provider<PanditService>((ref) {
  final api = ref.watch(apiClientProvider);
  return PanditService(api);
});

final liveServiceProvider = Provider<LiveService>((ref) {
  final api = ref.watch(apiClientProvider);
  return LiveService(api);
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  final api = ref.watch(apiClientProvider);
  return SettingsService(api);
});

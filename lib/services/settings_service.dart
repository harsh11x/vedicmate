import 'api_client.dart';

class AppSettings {
  double get platformFeePercent => 5.0;
}

class SettingsService {
  final ApiClient api;
  SettingsService(this.api);
  
  Future<AppSettings> getSettings() async => AppSettings();
}

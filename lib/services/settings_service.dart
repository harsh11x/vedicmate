import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'api_client.dart';

class SettingsService {
  SettingsService(this._api);
  final ApiClient _api;

  Future<AppSettings> getSettings() async {
    final Response res = await _api.get('/api/settings');
    final data = Map<String, dynamic>.from(res.data as Map);
    return AppSettings(
      platformFeePercent: (data['platformFeePercent'] is num)
          ? (data['platformFeePercent'] as num).toDouble()
          : 35.0,
    );
  }
}

@immutable
class AppSettings {
  final double platformFeePercent;
  const AppSettings({required this.platformFeePercent});
}

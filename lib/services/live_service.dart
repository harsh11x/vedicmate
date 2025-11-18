import 'package:dio/dio.dart';
import 'api_client.dart';

class LiveService {
  LiveService(this._api);
  final ApiClient _api;

  Future<List<Map<String, dynamic>>> fetchLive() async {
    try {
      final Response res = await _api.get('/api/live');
      final data = res.data;
      if (data is List) {
        return data.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
      }
      return _getDemoLiveFeeds();
    } catch (e) {
      // Return demo data if API fails
      return _getDemoLiveFeeds();
    }
  }

  List<Map<String, dynamic>> _getDemoLiveFeeds() {
    return [
      {
        'id': 'l1',
        'title': 'Daily Horoscope Reading',
        'viewers': 1256,
        'panditName': 'Pandit Ravi Shankar',
        'panditId': 'p1',
        'thumbnail': null,
      },
      {
        'id': 'l2',
        'title': 'Marriage Compatibility Analysis',
        'viewers': 843,
        'panditName': 'Acharya Priya Sharma',
        'panditId': 'p2',
        'thumbnail': null,
      },
      {
        'id': 'l3',
        'title': 'Vastu Consultation Live',
        'viewers': 567,
        'panditName': 'Guru Vikash Joshi',
        'panditId': 'p3',
        'thumbnail': null,
      },
      {
        'id': 'l4',
        'title': 'Vedic Remedies Session',
        'viewers': 1234,
        'panditName': 'Sidhi',
        'panditId': 'p4',
        'thumbnail': null,
      },
      {
        'id': 'l5',
        'title': 'Numerology Reading',
        'viewers': 432,
        'panditName': 'Acharya Priya Sharma',
        'panditId': 'p2',
        'thumbnail': null,
      },
    ];
  }
}

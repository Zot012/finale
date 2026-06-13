import 'package:dio/dio.dart';
import '../models/game.dart';

class SteamSpyService {
  final Dio _dio;

  SteamSpyService([Dio? dio]) : _dio = dio ?? Dio();

  // Fetch top games from SteamSpy (example endpoint)
  Future<List<Game>> fetchTopGames({int limit = 50}) async {
    try {
      final res = await _dio.get('https://steamspy.com/api.php?request=top100in2weeks');
      if (res.statusCode == 200 && res.data is Map) {
        final data = res.data as Map<String, dynamic>;
        final List<Game> list = [];
        int count = 0;
        for (final entry in data.entries) {
          if (count >= limit) break;
          final v = entry.value as Map<String, dynamic>;
          final name = v['name'] as String? ?? entry.key;
          final appid = (v['appid'] is num) ? (v['appid'] as num).toInt() : 0;
          final headerImage = appid > 0
              ? 'https://cdn.cloudflare.steamstatic.com/steam/apps/$appid/header.jpg'
              : '';
          list.add(Game(
            name: name,
            appid: appid,
            headerImage: headerImage,
            price: 0.0,
            discountPercent: 0,
            rating: 0.0,
            released: '',
            description: '',
            players: (v['owners'] is String) ? 0 : (v['owners'] as num?)?.toInt() ?? 0,
          ));
          count++;
        }
        return list;
      }
    } catch (e) {
      // ignore: avoid_print
      print('SteamSpy error: $e');
    }
    return [];
  }
}

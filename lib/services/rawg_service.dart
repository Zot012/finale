import 'package:dio/dio.dart';

import '../utils/constants.dart';

class RawgService {
  final Dio _dio;

  RawgService([Dio? dio]) : _dio = dio ?? Dio();

  Future<List<Map<String, dynamic>>> searchGamesByName(String name, {int pageSize = 5}) async {
    if (Constants.rawgApiKey == '<RAWG_API_KEY_PLACEHOLDER>') return [];
    const url = 'https://api.rawg.io/api/games';
    try {
      final res = await _dio.get(url, queryParameters: {'key': Constants.rawgApiKey, 'search': name, 'page_size': pageSize});
      if (res.statusCode == 200 && res.data is Map) {
        final results = res.data['results'] as List<dynamic>? ?? [];
        return results.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      // Log and return empty list
      // ignore: avoid_print
      print('RAWG search error: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>?> getGameDetailsBySlug(String slug) async {
    if (Constants.rawgApiKey == '<RAWG_API_KEY_PLACEHOLDER>') return null;
    final url = 'https://api.rawg.io/api/games/$slug';
    try {
      final res = await _dio.get(url, queryParameters: {'key': Constants.rawgApiKey});
      if (res.statusCode == 200 && res.data is Map) {
        return res.data as Map<String, dynamic>;
      }
    } catch (e) {
      // ignore and return null
      // ignore: avoid_print
      print('RAWG details error: $e');
    }
    return null;
  }
}

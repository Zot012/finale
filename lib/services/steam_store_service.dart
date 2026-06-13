import 'package:dio/dio.dart';
import '../models/game.dart';

class SteamStoreService {
  static const _steamCountryCode = 'tw';
  static const _steamLanguage = 'tchinese';

  final Dio _dio;

  SteamStoreService([Dio? dio]) : _dio = dio ?? Dio() {
    // Some Steam store endpoints block non-browser clients; set a common browser UA by default.
    _dio.options.headers['User-Agent'] =
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0 Safari/537.36';
  }

  Map<String, dynamic> get _storeQueryParameters => const {
        'cc': _steamCountryCode,
        'l': _steamLanguage,
      };

  // Fetch featured / popular games - this uses the Steam store's featured categories endpoint when available
  Future<List<Game>> fetchFeatured() async {
    try {
      final res = await _dio.get(
        'https://store.steampowered.com/api/featuredcategories/',
        queryParameters: _storeQueryParameters,
      );
      if (res.statusCode == 200 && res.data is Map) {
        final data = res.data as Map<String, dynamic>;
        // This endpoint structure varies; try to extract any lists of apps
        final List<Game> list = [];
        data.forEach((k, v) {
          if (v is Map && v['items'] is List) {
            for (final item in v['items']) {
              if (item is! Map) continue;

              final name = (item['name'] as String?)?.toLowerCase() ?? '';

const excludedKeywords = [
  'supporter',
  'standard',
  'pack',
  'bundle',
  'dlc',
  'soundtrack',
  'edition',
  'pack',
  '組合包',
  '週末特價',
  '週中特價',
  '免費週末',
  'Free Weekend',
  'plug in',
];

if (excludedKeywords.any((keyword) => name.contains(keyword.toLowerCase()))) {
  continue;
}
                if(item['name'] != 'Free Weekend' ) {
                  list.add(_mapSteamItemToGame(item));
                }
            }
          }
        });
        // De-duplicate by `appid` when available, otherwise by lower-cased name
        final Map<String, Game> unique = {};
        for (final g in list) {
          final key = (g.appid > 0) ? 'id:${g.appid}' : 'name:${g.name.toLowerCase()}';
          unique.putIfAbsent(key, () => g);
        }
        return unique.values.toList();
      }
    } catch (e) {
      // ignore, let caller handle empty list
      // ignore: avoid_print
      print('Steam Store fetchFeatured error: $e');
    }
    return [];
  }

  // Fetch specials / discounts
  Future<List<Game>> fetchSpecials() async {
    try {
      final res = await _dio.get(
        'https://store.steampowered.com/api/featuredcategories/',
        queryParameters: _storeQueryParameters,
      );
      if (res.statusCode == 200 && res.data is Map) {
        final data = res.data as Map<String, dynamic>;
        final List<Game> list = [];
        data.forEach((k, v) {
          if (v is Map && v['items'] is List) {
            for (final item in v['items']) {
              if (item is! Map) continue;

              final name = (item['name'] as String?)?.toLowerCase() ?? '';

const excludedKeywords = [
  'supporter',
  'standard',
  'pack',
  'bundle',
  'dlc',
  'soundtrack',
  'edition',
  'pack',
  '組合包',
  '週末特價',
  '週中特價',
  '免費週末',
  'Free Weekend',
  'plug in',
];

if (excludedKeywords.any((keyword) => name.contains(keyword.toLowerCase()))) {
  continue;
}

          if ((item['discount_percent'] ?? 0) > 0) {
            list.add(_mapSteamItemToGame(item));
            }
            }   
          }
        });
        // De-duplicate by `appid` when available, otherwise by lower-cased name
        final Map<String, Game> unique = {};
        for (final g in list) {
          final key = (g.appid > 0) ? 'id:${g.appid}' : 'name:${g.name.toLowerCase()}';
          unique.putIfAbsent(key, () => g);
        }
        return unique.values.toList();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Steam Store fetchSpecials error: $e');
    }
    return [];
  }

  Future<Game?> fetchAppDetails(Game game) async {
    if (game.appid <= 0) return null;

    try {
      final reviewSummary = await fetchReviewSummary(game.appid);
      final res = await _dio.get(
        'https://store.steampowered.com/api/appdetails',
        queryParameters: {
          ..._storeQueryParameters,
          'appids': game.appid,
        },
      );

      if (res.statusCode != 200 || res.data is! Map) return null;

      final app = (res.data as Map)['${game.appid}'];
      if (app is! Map || app['success'] != true || app['data'] is! Map) return null;

      final data = app['data'] as Map;
      final platforms = data['platforms'] is Map ? data['platforms'] as Map : const {};
      final priceOverview = data['price_overview'] is Map ? data['price_overview'] as Map : const {};
      final screenshots = (data['screenshots'] as List<dynamic>?)
              ?.whereType<Map>()
              .map((e) => e['path_full'] as String? ?? '')
              .where((url) => url.isNotEmpty)
              .toList() ??
          game.screenshots;
      final genres = (data['genres'] as List<dynamic>?)
              ?.whereType<Map>()
              .map((e) => e['description'] as String? ?? '')
              .where((name) => name.isNotEmpty)
              .toList() ??
          game.genres;
      final developers = (data['developers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .where((name) => name.isNotEmpty)
              .toList() ??
          game.developers;
      final categories = (data['categories'] as List<dynamic>?)
              ?.whereType<Map>()
              .map((e) => e['description'] as String? ?? '')
              .where((name) => name.isNotEmpty)
              .toList() ??
          game.categories;
      final requiredAge = data['required_age'] is num
          ? (data['required_age'] as num).toInt()
          : int.tryParse(data['required_age']?.toString() ?? '') ?? game.requiredAge;

      return Game(
        name: data['name'] as String? ?? game.name,
        appid: game.appid,
        headerImage: data['header_image'] as String? ?? game.headerImage,
        largeCapsuleImage: game.largeCapsuleImage,
        smallCapsuleImage: game.smallCapsuleImage,
        price: game.price,
        discountPercent: (priceOverview['discount_percent'] as num?)?.toInt() ?? game.discountPercent,
        discounted: ((priceOverview['discount_percent'] as num?)?.toInt() ?? game.discountPercent) > 0,
        originalPrice: (priceOverview['initial'] is num) ? (priceOverview['initial'] as num).toDouble() / 100.0 : game.originalPrice,
        finalPrice: (priceOverview['final'] is num) ? (priceOverview['final'] as num).toDouble() / 100.0 : game.finalPrice,
        currency: priceOverview['currency'] as String? ?? game.currency,
        windowsAvailable: platforms['windows'] as bool? ?? game.windowsAvailable,
        macAvailable: platforms['mac'] as bool? ?? game.macAvailable,
        linuxAvailable: platforms['linux'] as bool? ?? game.linuxAvailable,
        streamingvideoAvailable: game.streamingvideoAvailable,
        rating: game.rating,
        released: data['release_date']?['date'] as String? ?? game.released,
        requiredAge: requiredAge,
        description: data['short_description'] as String? ?? game.description,
        screenshots: screenshots.cast<String>(),
        genres: genres.cast<String>(),
        developers: developers.cast<String>(),
        categories: categories.cast<String>(),
        reviewScoreDesc: reviewSummary.reviewScoreDesc.isNotEmpty ? reviewSummary.reviewScoreDesc : game.reviewScoreDesc,
        reviewTotal: reviewSummary.reviewTotal > 0 ? reviewSummary.reviewTotal : game.reviewTotal,
        reviewPositivePercent: reviewSummary.reviewPositivePercent > 0
            ? reviewSummary.reviewPositivePercent
            : game.reviewPositivePercent,
        players: game.players,
        steamUrl: game.steamUrl.isNotEmpty ? game.steamUrl : 'https://store.steampowered.com/app/${game.appid}',
      );
    } catch (e) {
      // ignore: avoid_print
      print('Steam Store fetchAppDetails error: $e');
    }

    return null;
  }

  Future<SteamReviewSummary> fetchReviewSummary(int appid) async {
    if (appid <= 0) return const SteamReviewSummary();

    try {
      final res = await _dio.get(
        'https://store.steampowered.com/appreviews/$appid',
        queryParameters: {
          ..._storeQueryParameters,
          'json': 1,
          'filter': 'summary',
          'purchase_type': 'all',
          'num_per_page': 0,
        },
      );

      if (res.statusCode != 200 || res.data is! Map) return const SteamReviewSummary();

      final data = res.data as Map;
      final summary = data['query_summary'] is Map ? data['query_summary'] as Map : const {};
      final totalPositive = (summary['total_positive'] as num?)?.toInt() ?? 0;
      final totalReviews = (summary['total_reviews'] as num?)?.toInt() ?? 0;
      final positivePercent = totalReviews > 0 ? ((totalPositive / totalReviews) * 100).round() : 0;

      return SteamReviewSummary(
        reviewScoreDesc: summary['review_score_desc'] as String? ?? '',
        reviewTotal: totalReviews,
        reviewPositivePercent: positivePercent,
      );
    } catch (e) {
      // ignore: avoid_print
      print('Steam Store fetchReviewSummary error: $e');
    }

    return const SteamReviewSummary();
  }

  // Fallback mapping from Steam store item structure to Game model
  Game _mapSteamItemToGame(Map item) {
    return Game(
      name: item['name'] as String? ?? '',
      appid: (item['id'] as num?)?.toInt() ?? (item['appid'] as num?)?.toInt() ?? 0,
      headerImage: item['header_image'] as String? ?? item['img'] as String? ?? '',
      price: (item['final_price'] is num) ? (item['final_price'] as num).toDouble() / 100.0 : 0.0,
      discountPercent: (item['discount_percent'] as num?)?.toInt() ?? 0,
      // Pricing details
      discounted: ((item['discount_percent'] as num?)?.toInt() ?? 0) > 0,
      originalPrice: (item['original_price'] is num) ? (item['original_price'] as num).toDouble() / 100.0 :
          // fallback: estimate original from final price and discount
          ((item['final_price'] is num && (item['discount_percent'] as num?) != null && (item['discount_percent'] as num?)! > 0)
              ? ((item['final_price'] as num).toDouble() / 100.0) / (1 - ((item['discount_percent'] as num).toDouble() / 100.0))
              : 0.0),
      finalPrice: (item['final_price'] is num) ? (item['final_price'] as num).toDouble() / 100.0 : 0.0,
      currency: item['currency'] as String? ?? '',
      // Platform availability if provided by the item
      windowsAvailable: (item['platforms'] is Map) ? (item['platforms']['windows'] as bool? ?? false) : false,
      macAvailable: (item['platforms'] is Map) ? (item['platforms']['mac'] as bool? ?? false) : false,
      linuxAvailable: (item['platforms'] is Map) ? (item['platforms']['linux'] as bool? ?? false) : false,
      streamingvideoAvailable: item['streamingvideo'] as bool? ?? false,
      rating: 0.0,
      released: item['release_date']?['date'] as String? ?? '',
      description: item['short_description'] as String? ?? '',
      screenshots: [],
      genres: [],
      players: 0,
      steamUrl: 'https://store.steampowered.com/app/${(item['id'] ?? item['appid'] ?? 0)}',
    );
  }
}

class SteamReviewSummary {
  final String reviewScoreDesc;
  final int reviewTotal;
  final int reviewPositivePercent;

  const SteamReviewSummary({
    this.reviewScoreDesc = '',
    this.reviewTotal = 0,
    this.reviewPositivePercent = 0,
  });
}

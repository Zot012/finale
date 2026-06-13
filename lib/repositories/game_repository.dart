import '../models/game.dart';
import '../services/steam_store_service.dart';
import '../services/steam_spy_service.dart';
import '../services/rawg_service.dart';

class GameRepository {
  final SteamStoreService _store;
  final SteamSpyService _spy;

  GameRepository([SteamStoreService? store, SteamSpyService? spy])
      : _store = store ?? SteamStoreService(),
        _spy = spy ?? SteamSpyService();

  final RawgService _rawg = RawgService();
  // Simple in-memory cache with TTL
  List<Game>? _cachedFeatured;
  DateTime? _cachedAt;
  final Duration cacheTTL = const Duration(minutes: 10);

  Future<List<Game>> getFeatured() => _store.fetchFeatured();

  Future<List<Game>> getSpecials() => _store.fetchSpecials();

  Future<List<Game>> getTopRated() async {
    // Use SteamSpy top list as a proxy for popularity/high rating
    if (_cachedFeatured != null && _cachedAt != null && DateTime.now().difference(_cachedAt!) < cacheTTL) {
      return _cachedFeatured!;
    }
    final list = await _spy.fetchTopGames();
    _cachedFeatured = list;
    _cachedAt = DateTime.now();
    return list;
  }

  /// Paginated access to cached topRated list. Ensure `getTopRated()` called first to populate cache.
  Future<List<Game>> getTopRatedPage(int page, {int pageSize = 20}) async {
    final all = await getTopRated();
    final start = page * pageSize;
    if (start >= all.length) return [];
    return all.sublist(start, (start + pageSize).clamp(0, all.length));
  }

  /// Try to enrich a [game] with RAWG data: screenshots, description, rating, released, genres.
  /// Strategy: search RAWG by name, take first match, fetch details by slug.
  Future<Game> getGameDetails(Game game) async {
    try {
      final steamDetails = await _store.fetchAppDetails(game);
      final baseGame = steamDetails ?? game;

      final results = await _rawg.searchGamesByName(baseGame.name, pageSize: 3);
      if (results.isEmpty) return baseGame;
      final first = results.first;
      final slug = first['slug'] as String?;
      if (slug == null) return baseGame;
      final details = await _rawg.getGameDetailsBySlug(slug);
      if (details == null) return baseGame;

      final screenshots = (details['short_screenshots'] as List<dynamic>?)?.map((e) => e['image'] as String).toList() ?? [];
      final description = details['description_raw'] as String? ?? baseGame.description;
      final released = details['released'] as String? ?? baseGame.released;
      final rating = (details['rating'] is num) ? (details['rating'] as num).toDouble() : baseGame.rating;
      final genres = (details['genres'] as List<dynamic>?)?.map((g) => g['name'] as String).toList() ?? baseGame.genres;

      return Game(
        name: baseGame.name,
        appid: baseGame.appid,
        headerImage: baseGame.headerImage.isNotEmpty ? baseGame.headerImage : (details['background_image'] as String? ?? ''),
        largeCapsuleImage: baseGame.largeCapsuleImage,
        smallCapsuleImage: baseGame.smallCapsuleImage,
        price: baseGame.price,
        discountPercent: baseGame.discountPercent,
        discounted: baseGame.discounted,
        originalPrice: baseGame.originalPrice,
        finalPrice: baseGame.finalPrice,
        currency: baseGame.currency,
        windowsAvailable: baseGame.windowsAvailable,
        macAvailable: baseGame.macAvailable,
        linuxAvailable: baseGame.linuxAvailable,
        streamingvideoAvailable: baseGame.streamingvideoAvailable,
        rating: rating,
        released: released,
        requiredAge: baseGame.requiredAge,
        description: description,
        screenshots: screenshots.isNotEmpty ? screenshots.cast<String>() : baseGame.screenshots,
        genres: genres.cast<String>(),
        developers: baseGame.developers,
        categories: baseGame.categories,
        reviewScoreDesc: baseGame.reviewScoreDesc,
        reviewTotal: baseGame.reviewTotal,
        reviewPositivePercent: baseGame.reviewPositivePercent,
        players: baseGame.players,
        steamUrl: baseGame.steamUrl,
      );
    } catch (e) {
      return game;
    }
  }
}

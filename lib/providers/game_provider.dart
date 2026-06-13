import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/game.dart';
import '../repositories/game_repository.dart';

class GameProvider extends ChangeNotifier {
  final GameRepository _repo = GameRepository();

  List<Game> featured = [];
  List<Game> specials = [];
  List<Game> topRated = [];
  int _topRatedPage = 0;
  final int _pageSize = 20;

  bool isLoading = false;
  String? error;

  Set<int> favorites = {};

  GameProvider() {
    loadFavorites();
    loadAll();
  }

  Future<void> loadAll() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final f = await _repo.getFeatured();
      final s = await _repo.getSpecials();
      featured = f;
      specials = s;
      // Load first page of topRated
      _topRatedPage = 0;
      topRated = await _repo.getTopRatedPage(_topRatedPage, pageSize: _pageSize);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async => loadAll();

  Future<void> loadMoreTopRated() async {
    if (isLoading) {
      return;
    }
    isLoading = true;
    notifyListeners();
    _topRatedPage += 1;
    try {
      final more = await _repo.getTopRatedPage(_topRatedPage, pageSize: _pageSize);
      if (more.isNotEmpty) {
        topRated.addAll(more);
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFavorites() async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList('favorites') ?? [];
    favorites = list.map((s) => int.tryParse(s) ?? 0).where((v) => v > 0).toSet();
    notifyListeners();
  }

  Future<void> toggleFavorite(int appid) async {
    if (favorites.contains(appid)) {
      favorites.remove(appid);
    } else {
      favorites.add(appid);
    }
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList('favorites', favorites.map((e) => e.toString()).toList());
    notifyListeners();
  }

  List<Game> search(String q) {
    final lower = q.toLowerCase();
    final merged = [...featured, ...specials, ...topRated];
    final seen = <int>{};
    final results = <Game>[];
    for (final g in merged) {
      if (seen.contains(g.appid)) continue;
      if (g.name.toLowerCase().contains(lower)) {
        results.add(g);
        seen.add(g.appid);
      }
    }
    return results;
  }
}

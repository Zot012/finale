import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../widgets/game_grid.dart';
import '../models/game.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    final all = [...gp.featured, ...gp.specials, ...gp.topRated];
    // Deduplicate games by appid to avoid duplicates appearing in multiple lists
    final seen = <int>{};
    final favs = <Game>[];
    for (final g in all) {
      if (!gp.favorites.contains(g.appid)) continue;
      if (seen.contains(g.appid)) continue;
      seen.add(g.appid);
      favs.add(g);
    }

    const darkBlue = Color(0xFF071A2B);
    const whiteText = Colors.white;

    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: darkBlue,
        textTheme: Theme.of(context).textTheme.apply(bodyColor: whiteText, displayColor: whiteText),
        colorScheme: Theme.of(context).colorScheme.copyWith(surface: darkBlue),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF071A2B), foregroundColor: Colors.white, elevation: 0),
      ),
      child: Scaffold(
        backgroundColor: darkBlue,
        appBar: AppBar(title: const Text('我的收藏')),
        body: favs.isEmpty
            ? const Center(child: Text('尚無收藏'))
            : GameGrid(title: '收藏', games: favs),
      ),
    );
  }
}

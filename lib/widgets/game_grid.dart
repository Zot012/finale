import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';

import '../models/game.dart';
import '../providers/game_provider.dart';
import 'game_card.dart';

class GameGrid extends StatefulWidget {
  final String title;
  final List<Game> games;

  const GameGrid({super.key, required this.title, required this.games});

  @override
  State<GameGrid> createState() => _GameGridState();
}

class _GameGridState extends State<GameGrid> {
  final ScrollController _sc = ScrollController();

  @override
  void initState() {
    super.initState();
    _sc.addListener(_onScroll);
  }

  void _onScroll() {
    if (_sc.position.pixels > _sc.position.maxScrollExtent - 200) {
      // near bottom
      context.read<GameProvider>().loadMoreTopRated();
    }
  }

  @override
  void dispose() {
    _sc.removeListener(_onScroll);
    _sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    final games = widget.games;

    if (games.isEmpty && gp.isLoading) {
      // skeleton list with shimmer placeholders (single column)
      return ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: 6,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, i) => const SizedBox(height: 220, child: GameCardPlaceholder()),
      );
    }

    if (games.isEmpty) return Center(child: Text('找不到遊戲：${widget.title}'));

    return ListView.separated(
      controller: _sc,
      padding: const EdgeInsets.all(8),
      itemCount: games.length + (gp.isLoading ? 2 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        if (i >= games.length) return const SizedBox(height: 220, child: GameCardPlaceholder());
        return SizedBox(height: 220, child: GameCard(game: games[i], index: i));
      },
    );
  }
}

class GameCardPlaceholder extends StatelessWidget {
  const GameCardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(color: Colors.grey[300]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(height: 12, width: 120, color: Colors.grey[300]),
                ),
                const SizedBox(height: 8),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(height: 12, width: 60, color: Colors.grey[300]),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

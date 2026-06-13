import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/game.dart';
import '../providers/game_provider.dart';
import '../repositories/game_repository.dart';

class DetailPage extends StatefulWidget {
  final Game game;
  final String? heroTag;

  const DetailPage({
    super.key,
    required this.game,
    this.heroTag,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final GameRepository _repo = GameRepository();

  bool _loading = false;
  Game? _enriched;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() => _loading = true);

    final enriched = await _repo.getGameDetails(widget.game);

    if (!mounted) return;

    setState(() {
      _enriched = enriched;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = _enriched ?? widget.game;
    // Local theme for detail page: deep blue background with white text
    const darkBlue = Color(0xFF071A2B);
    const whiteText = Colors.white70;

    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: darkBlue,
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: whiteText,
              displayColor: whiteText,
            ),
        colorScheme: Theme.of(context).colorScheme.copyWith(
              surface: darkBlue,
              primaryContainer: darkBlue,
            ),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF071A2B), foregroundColor: Colors.white, elevation: 0),
      ),
      child: Scaffold(
        backgroundColor: darkBlue,
        bottomNavigationBar: _BottomActionBar(game: game),
            body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : CustomScrollView(
              slivers: [
                _HeroBanner(
                  game: game,
                  heroTag: widget.heroTag,
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _GameHeader(game),

                        const SizedBox(height: 20),

                        _PriceCard(game),

                        const SizedBox(height: 16),

                        _InfoCard(game),

                        const SizedBox(height: 16),

                        if (game.reviewTotal > 0 ||
                            game.reviewScoreDesc.isNotEmpty)
                          _ReviewCard(game),

                        const SizedBox(height: 20),

                        if (game.screenshots.isNotEmpty)
                          _ScreenshotSection(game),

                        if (game.categories.isNotEmpty) ...[
                          const SizedBox(height: 24),

                          _TagSection(
                            title: 'Categories',
                            items: game.categories,
                          ),
                        ],

                        if (game.genres.isNotEmpty) ...[
                          const SizedBox(height: 24),

                          _TagSection(
                            title: 'Genres',
                            items: game.genres,
                          ),
                        ],

                        const SizedBox(height: 24),

                        Text(
                          'About This Game',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: whiteText
                              ),
                        ),

                        const SizedBox(height: 12),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: const Color.fromARGB(255, 10, 61, 87),
                          ),
                          child: Text(
                            game.description.isNotEmpty
                                ? game.description
                                : 'No description available.',
                            style: const TextStyle(
                              height: 1.6,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    ));
  }
}

String priceLabel(Game game) {
  if (game.finalPrice <= 0) {
    return 'FREE TO PLAY';
  }

  final decimals = game.currency == 'TWD' ? 0 : 2;

  return '${game.finalPrice.toStringAsFixed(decimals)} ${game.currency}';
}
class _HeroBanner extends StatelessWidget {
  final Game game;
  final String? heroTag;

  const _HeroBanner({
    required this.game,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final tag = heroTag ?? 'game-${game.appid}';

    return SliverAppBar(
      expandedHeight: 420,
      pinned: true,
      stretch: true,
      backgroundColor: const Color.fromARGB(0, 0, 0, 0),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: tag,
              child: CachedNetworkImage(
                imageUrl: game.headerImage,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => Container(
                  color: Colors.grey.shade900,
                  child: const Icon(
                    Icons.videogame_asset,
                    color: Color.fromARGB(255, 255, 255, 255),
                    size: 64,
                  ),
                ),
              ),
            ),

            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black87,
                  ],
                ),
              ),
            ),

            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (game.developers.isNotEmpty)
                    Text(
                      game.developers.join(', '),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _GameHeader extends StatelessWidget {
  final Game game;

  const _GameHeader(this.game);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.calendar_month,color: Colors.white70,),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            game.released.isNotEmpty
                ? game.released
                : 'Release Date Unknown',
          ),
        ),

        if (game.requiredAge > 0)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.red.shade700,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${game.requiredAge}+',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}
class _PriceCard extends StatelessWidget {
  final Game game;

  const _PriceCard(this.game);

  @override
  Widget build(BuildContext context) {
    final isFree = game.finalPrice <= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color.fromARGB(255, 10, 61, 87), // slightly darker card background
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PRICE',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            isFree ? 'FREE TO PLAY' : priceLabel(game),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (game.discountPercent > 0) ...[
            const SizedBox(height: 6),

            Text(
              '-${game.discountPercent}% OFF',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
class _InfoCard extends StatelessWidget {
  final Game game;

  const _InfoCard(this.game);

  Widget _platformChip(
    IconData icon,
    String text,
    bool enabled,
  ) {
    return Chip(
      avatar: Icon(
        icon,
        size: 18,
      ),
      label: Text(text),
      backgroundColor:
          // ignore: deprecated_member_use
          enabled ? null : Colors.grey.withOpacity(0.2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color.fromARGB(255, 10, 61, 87),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.people),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    game.players > 0
                        ? '${game.players} Active Players'
                        : 'Player Count Unknown',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _platformChip(
                  Icons.window,
                  'Windows',
                  game.windowsAvailable,
                ),

                _platformChip(
                  Icons.laptop_mac,
                  'macOS',
                  game.macAvailable,
                ),

                _platformChip(
                  Icons.terminal,
                  'Linux',
                  game.linuxAvailable,
                ),

                _platformChip(
                  Icons.cloud,
                  'Cloud',
                  game.streamingvideoAvailable,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
class _ReviewCard extends StatelessWidget {
  final Game game;

  const _ReviewCard(this.game);

  @override
  Widget build(BuildContext context) {
    final value =
        (game.reviewPositivePercent / 100).clamp(0.0, 1.0);

    return Card(
      elevation: 0,
      color: const Color.fromARGB(255, 10, 61, 87),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Steam Reviews',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            LinearProgressIndicator(
              value: value,
              minHeight: 12,
              borderRadius: BorderRadius.circular(20),
            ),

            const SizedBox(height: 16),

            Text(
              '${game.reviewPositivePercent}% Positive',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              game.reviewScoreDesc,
              style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    // ignore: deprecated_member_use
                    ?.withOpacity(.7),
              ),
            ),

            const SizedBox(height: 4),

            Text(
              '${game.reviewTotal} Reviews',
            ),
          ],
        ),
      ),
    );
  }
}
class _ScreenshotSection extends StatelessWidget {
  final Game game;

  const _ScreenshotSection(this.game);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Screenshots',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: game.screenshots.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final url = game.screenshots[index];

              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: url,
                  width: 320,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    width: 320,
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (_, _, _) => Container(
                    width: 320,
                    color: Colors.grey.shade300,
                    child: const Icon(
                      Icons.broken_image,
                      size: 50,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
class _TagSection extends StatelessWidget {
  final String title;
  final List<String> items;

  const _TagSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 10, 61, 87),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
          }).toList(),
        ),
      ],
    );
  }
}
class _BottomActionBar extends StatelessWidget {
  final Game game;

  const _BottomActionBar({
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    final isFavorite =
        context.watch<GameProvider>().favorites.contains(game.appid);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF071A2B),
          boxShadow: const [
            BoxShadow(
              blurRadius: 10,
              offset: Offset(0, -2),
              color: Colors.black12,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white12,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  await context
                      .read<GameProvider>()
                      .toggleFavorite(game.appid);
                },
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                label: Text(
                  isFavorite ? 'Favorited' : 'Favorite',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              flex: 2,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white12,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final url = game.steamUrl;

                  if (url.isEmpty) return;

                  final uri = Uri.tryParse(url);

                  if (uri == null) return;

                  final ok = await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );

                  if (!ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Could not open Steam page.',
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.open_in_new, color: Colors.white),
                label: const Text('Open Steam', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
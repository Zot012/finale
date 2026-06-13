import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../models/game.dart';
import '../pages/detail_page.dart';

class GameCard extends StatelessWidget {
  final Game game;
  final int? index;

  const GameCard({super.key, required this.game, this.index});

  @override
  Widget build(BuildContext context) {
    final heroTag = (index != null) ? 'game-${game.appid}-$index' : 'game-${game.appid}';
    final imageUrl = game.headerImage.isNotEmpty
        ? game.headerImage
        : (game.largeCapsuleImage.isNotEmpty
            ? game.largeCapsuleImage
            : game.smallCapsuleImage);
    final hasImage = imageUrl.isNotEmpty;
    final fallbackColor = const Color.fromARGB(255, 10, 61, 87);
    final textColor = hasImage ? null : const Color.fromARGB(255, 0, 0, 0);

    return GestureDetector(
      onTap: () => {Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailPage(game: game, heroTag: heroTag)),
      ),
      //print('Tapped on ${game.name}'),
      },
      child: Card(
        color: fallbackColor,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildImage(heroTag, imageUrl, hasImage, fallbackColor),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //children: [
                     // Text(
                      //  game.price > 0 ? '\$${game.price.toStringAsFixed(2)}' : 'Free',
                        //style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                      //),
                      //Row(
                        //children: [
                          //Icon(Icons.star, size: 14, color: textColor),
                          //const SizedBox(width: 4),
                          //Text(game.rating.toStringAsFixed(1), style: TextStyle(color: textColor)),
                        //],
                      //),
                    //],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String heroTag, String imageUrl, bool hasImage, Color fallbackColor) {
    final placeholder = Container(
      width: double.infinity,
      height: double.infinity,
      color: hasImage ? Colors.grey[300] : fallbackColor,
      child: Icon(Icons.videogame_asset, color: hasImage ? null : const Color.fromARGB(255, 88, 185, 140)),
    );

    if (imageUrl.isEmpty) {
      return game.appid > 0 ? Hero(tag: heroTag, child: placeholder) : placeholder;
    }

    final imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (c, _) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(color: Colors.grey[300]),
      ),
      errorWidget: (c, _, _) => placeholder,
    );

    return game.appid > 0 ? Hero(tag: heroTag, child: imageWidget) : imageWidget;
  }
}

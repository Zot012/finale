import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../widgets/game_grid.dart';
import 'search_page.dart';
import 'favorites_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();

    final tabs = [
      GameGrid(title: '熱門遊戲', games: gp.topRated),
      GameGrid(title: '特價遊戲', games: gp.specials),
      GameGrid(title: '高評價遊戲', games: gp.featured),
    ];

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
        appBar: AppBar(
        title: const Text('GameVault'),
        actions: [
          IconButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPage())),
              icon: const Icon(Icons.search, color: Colors.white)),
          IconButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesPage())),
              icon: const Icon(Icons.favorite, color: Colors.white)),
          IconButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())),
              icon: const Icon(Icons.person, color: Colors.white)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => gp.refresh(),
        child: gp.isLoading
            ? const Center(child: CircularProgressIndicator())
            : gp.error != null
                ? Center(child: Text('錯誤：${gp.error}'))
                : tabs[_index],
      ),
      bottomNavigationBar: NavigationBar(
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (states) {
            return const TextStyle(
            color: Colors.white,
          );
          },
        ),
        backgroundColor: darkBlue,
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.whatshot, color: Colors.white), label: '熱門'),
          NavigationDestination(icon: Icon(Icons.local_offer, color: Colors.white), label: '特價'),
          NavigationDestination(icon: Icon(Icons.thumb_up, color: Colors.white), label: '高評價'),
        ],
      ),
    ));
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../widgets/game_grid.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _ctrl = TextEditingController();
  List _results = [];

  void _onChange(String v) {
    final gp = context.read<GameProvider>();
    final r = gp.search(v);
    setState(() => _results = r);
  }

  @override
  Widget build(BuildContext context) {
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
        appBar: AppBar(title: const Text('搜尋遊戲')),
        body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _ctrl,
              onChanged: _onChange,
              cursorColor: Colors.white,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, color: whiteText),
                hintText: '輸入遊戲名稱',
                hintStyle: TextStyle(color: whiteText),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _results.isEmpty
                  ? const Center(child: Text('尚無搜尋結果'))
                  : GameGrid(title: '搜尋結果', games: List.from(_results)),
            )
          ],
        ),
      ),
    ));
  }
}

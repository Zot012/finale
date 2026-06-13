import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';

class ProfilePage extends StatelessWidget {
  String maskEmail(String email) {
  if (email.isEmpty) return '';
  final emailRegex = RegExp(r'^([^@]{2})([^@]+)([^@]{2})@(.+)$');
  
  return email.replaceAllMapped(emailRegex, (match) {
    String start = match.group(1)!;
    String middle = '*' * match.group(2)!.length;
    String end = match.group(3)!;
    String domain = match.group(4)!;
    
    return '$start$middle$end@$domain';
  });
}
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final gp = context.watch<GameProvider>();
    final user = auth.user;

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
        appBar: AppBar(title: const Text('個人資料')),
        body: Center(
  child: Padding(
    padding: const EdgeInsets.all(12),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 48,
          backgroundImage:
              user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
          child: user?.photoURL == null
              ? const Icon(Icons.person, size: 48)
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          user?.displayName ?? '訪客',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 8),
          Text(maskEmail(user?.email ?? ''), style: const TextStyle(fontSize: 14, color: Colors.white70)),
        const SizedBox(height: 16),
        //Text('收藏數量：${gp.favorites.length}'),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => auth.signOut(),
          icon: const Icon(Icons.logout),
          label: const Text('登出'),
        ),
      ],
    ),
  ),
),
    ));
  }
}

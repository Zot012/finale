import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _loading = false;
  String? _error;

  Future<void> _signIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<AuthProvider>().signInWithGoogle();
    } catch (e) {
      final message = e.toString();
      setState(() {
        if (message.contains('Account reauth failed')) {
          _error = 'Google 登入失敗。請先清除這個 App 的資料，或移除並重新加入裝置上的 Google 帳號後再試一次。';
        } else if (message.contains('GoogleSignInExceptionCode.canceled')) {
          _error = null;
        } else {
          _error = message;
        }
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
        appBar: AppBar(title: const Text('GameVault Login')),
        body: Center(
  child: Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/image/logo.png', width: 240, height: 240),
        const SizedBox(height: 24),
        const Text(
          '使用 Google 登入以繼續',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text('使用 Google 登入'),
          onPressed: _loading ? null : _signIn,
        ),
        if (_loading) const SizedBox(height: 16),
        if (_loading) const CircularProgressIndicator(),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ],
    ),
  ),
),
    ));
  }
}

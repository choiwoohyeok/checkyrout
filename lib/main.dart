import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';

import 'home.dart';
import 'providers/user_provider.dart';
import 'start.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MaterialApp(
        title: 'User Authority',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const InitialPage(),
      ),
    );
  }
}

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  _InitialPageState createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  Future<void> _checkLoginStatus() async {
    try {
      final token = await _storage.read(key: 'jwt');
      if (token != null) {
        // 토큰 유효성 검사 추가
        bool isTokenExpired = JwtDecoder.isExpired(token);
        if (isTokenExpired) {
          // 토큰이 만료된 경우 로그인 페이지로 이동
          _navigateToStartPage();
          return;
        }

        final membername = await _storage.read(key: 'membername');
        final email = await _storage.read(key: 'email');
        if (membername != null && email != null) {
          // Set user information in the provider
          Provider.of<UserProvider>(context, listen: false)
              .setUser(membername, email, token);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else {
          _navigateToStartPage();
        }
      } else {
        _navigateToStartPage();
      }
    } catch (e) {
      // 예외 처리
      print('Error during login check: $e');
      _navigateToStartPage();
    }
  }

  void _navigateToStartPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const StartPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

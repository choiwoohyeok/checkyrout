import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '/home.dart';
import '/providers/user_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _errorMessage = '';
  final _storage = const FlutterSecureStorage(); // JWT 저장을 위한 스토리지

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final response = await http.post(
        Uri.parse('http://spring-boot-server-url/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        // JWT를 성공적으로 받아왔을 때
        final responseData = json.decode(response.body);
        final jwtToken = responseData['token'];

        final response2 = await http.get(
          Uri.parse('http://spring-boot-server-url/member'),
          headers: {
            'Authorization': 'Bearer $jwtToken',
            'Content-Type': 'application/json'
          },
        );

        if (response2.statusCode == 200) {
          final responseName = json.decode(response2.body);
          final membername = responseName['membername'];
          final email = responseName['email'];
          // JWT를 안전하게 저장
          await _storage.write(key: 'membername', value: membername);
          await _storage.write(key: 'email', value: email);
          await _storage.write(key: 'jwt', value: jwtToken);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('로그인 성공')),
          );
          Provider.of<UserProvider>(context, listen: false)
              .setUser(membername, email, jwtToken);

          // 로그인 후 화면 전환 등 추가 작업
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return const HomePage();
          }));
        }
      } else {
        // 로그인 실패
        setState(() {
          _errorMessage = '로그인 실패. 사용자 이름 또는 비밀번호를 확인하세요.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log In'),
        centerTitle: true,
        elevation: 0.2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: '이메일',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일을 입력하세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력하세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: const Text('로그인'),
                    ),
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/providers/user_provider.dart';
import 'librarypage.dart';
import 'searchpage.dart';
import 'start.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomeContent(), // 홈 화면 내용 (AI 도서 추천 기능)
    SearchPage(), // 책 검색 페이지
    LibraryPage(), // 도서관 페이지
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final membername = userProvider.membername;
    final email = userProvider.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text('체키라웃'),
        centerTitle: true,
        elevation: 0.0,
      ),
      drawer: Drawer(
          child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(membername ?? '사용자 이름 없음'),
            accountEmail: Text(email ?? '이메일 없음'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                membername != null ? membername[0] : '?',
                style: const TextStyle(fontSize: 40.0, color: Colors.white),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('홈'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('로그아웃'),
            onTap: () {
              userProvider.clearUser();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const StartPage()));
            },
          ),
        ],
      )),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'AI 도서추천',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '도서 검색',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: '주변 도서관',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

//AI추천 기능 구현 필요!!
class _HomeContentState extends State<HomeContent> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('AI 도서 추천'),
    );
  }
}

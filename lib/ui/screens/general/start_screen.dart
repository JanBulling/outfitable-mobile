import 'package:flutter/material.dart';

import '../start_tabs/favorites_tab.dart';
import '../start_tabs/profile_tab.dart';
import '../tabs/closet.dart';
import '../tabs/home.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentTabIndex, children: const [
        HomeScreen(),
        ClosetScreen(),
        FavoritesTab(),
        ProfileTab(),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.redAccent,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (_currentTabIndex != index) {
            setState(() {
              _currentTabIndex = index;
            });
          }
        },
        currentIndex: _currentTabIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(label: "Home", icon: Icon(Icons.home)),
          BottomNavigationBarItem(label: "Closet", icon: Icon(Icons.king_bed)),
          BottomNavigationBarItem(label: "Favorites", icon: Icon(Icons.bookmark)),
          BottomNavigationBarItem(label: "Profile", icon: Icon(Icons.person)),
        ],
      ),
    );
  }
}

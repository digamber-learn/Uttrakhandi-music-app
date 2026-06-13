import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'genres_screen.dart';
import 'artists_screen.dart';
import 'search_screen.dart';
import '../widgets/mini_player.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    GenresScreen(),
    ArtistsScreen(),
    SearchScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1F0E),
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          NavigationBar(
            backgroundColor: const Color(0xFF080F09),
            indicatorColor: const Color(0xFF2E7D32),
            selectedIndex: _index,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.temple_hindu_outlined, color: Colors.white54),
                selectedIcon: Icon(Icons.temple_hindu, color: Color(0xFF81C784)),
                label: 'Devbhoomi',
              ),
              NavigationDestination(
                icon: Icon(Icons.album_outlined, color: Colors.white54),
                selectedIcon: Icon(Icons.album, color: Color(0xFF81C784)),
                label: 'Ragas',
              ),
              NavigationDestination(
                icon: Icon(Icons.mic_none, color: Colors.white54),
                selectedIcon: Icon(Icons.mic, color: Color(0xFF81C784)),
                label: 'Kalakar',
              ),
              NavigationDestination(
                icon: Icon(Icons.travel_explore, color: Colors.white54),
                selectedIcon: Icon(Icons.travel_explore, color: Color(0xFF81C784)),
                label: 'Khojo',
              ),
            ],
          ),
          // Copyright footer
          Container(
            width: double.infinity,
            color: const Color(0xFF050C05),
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: const Text(
              '©2026 Bot Intelligence LLC',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white24, fontSize: 11, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

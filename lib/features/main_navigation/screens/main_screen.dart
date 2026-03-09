import 'package:flutter/material.dart';
import 'package:malbit_frontend/features/home/screens/home_screen.dart';
import 'package:malbit_frontend/features/remaster/screens/remaster_screen.dart';
import 'package:malbit_frontend/features/template/screens/template_screen.dart';
import 'package:malbit_frontend/features/roleplay/screens/roleplay_list_screen.dart';
import 'package:malbit_frontend/features/profile/screens/profile_screen.dart';

import 'package:malbit_frontend/features/main_navigation/widgets/bottom_nav.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  int _currentIndex = 2;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = const [
      Center(child: Text("AI 화면 준비중")),
      Center(child: Text("추천 화면 준비중")),
      Center(child: Text("홈 화면 준비중")),
      Center(child: Text("학습 화면 준비중")),
      ProfileScreen(),
    ];
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
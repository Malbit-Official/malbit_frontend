import 'package:flutter/material.dart';
import 'package:malbit_frontend/features/home/screens/home_screen.dart';
import 'package:malbit_frontend/features/record/screens/record_screen.dart';
import 'package:malbit_frontend/features/remaster/screens/remaster_screen.dart';
import 'package:malbit_frontend/features/template/screens/template_screen.dart';
import 'package:malbit_frontend/features/roleplay/screens/roleplay_list_screen.dart';

import 'package:malbit_frontend/features/main_navigation/widgets/bottom_nav.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static _MainScreenState? mainScreenState;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    MainScreen.mainScreenState = this;
  }

  void setTabIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // 각 탭에 들어갈 화면들
  final List<Widget> _pages = [
    const RemasterScreen(),     // 0: AI
    const RoleplayListScreen(),     // 1: 추천
    const HomeScreen(),         // 2: 홈 (Scaffold에서 bottomNav가 제거된 버전)
    const TemplateScreen(), // 3: 학습
    const RecordScreen(),      // 4: 기록
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack이 모든 화면의 상태를 메모리에 유지해줍니다.
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // 탭 클릭 시 인덱스 변경 -> 화면 전환
          });
        },
      ),
    );
  }
}
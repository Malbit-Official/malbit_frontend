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

  // ← GlobalKey 추가
  final GlobalKey<RecordScreenState> _recordScreenKey =
  GlobalKey<RecordScreenState>();

  @override
  void initState() {
    super.initState();
    MainScreen.mainScreenState = this;
  }

  void setTabIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
    // ← 4번 탭 이동 시 RecordScreen 새로고침
    if (index == 4) {
      _recordScreenKey.currentState?.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const RemasterScreen(),
          const RoleplayListScreen(),
          const HomeScreen(),
          const TemplateScreen(),
          RecordScreen(key: _recordScreenKey), // ← key 연결
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // ← 탭 클릭으로 4번 이동할 때도 새로고침
          if (index == 4) {
            _recordScreenKey.currentState?.refresh();
          }
        },
      ),
    );
  }
}
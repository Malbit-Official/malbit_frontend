import 'package:flutter/material.dart';
import 'package:malbit_frontend/features/home/screens/home_screen.dart';
import 'package:malbit_frontend/features/record/screens/record_screen.dart';
import 'package:malbit_frontend/features/remaster/screens/remaster_screen.dart';
import 'package:malbit_frontend/features/template/screens/template_screen.dart';
import 'package:malbit_frontend/features/roleplay/screens/roleplay_list_screen.dart';
import 'package:malbit_frontend/features/main_navigation/widgets/bottom_nav.dart';

// 앱의 루트 화면, 하단 네비게이션 바로 5개 탭 관리
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static _MainScreenState? mainScreenState;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 2;

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
          RecordScreen(key: _recordScreenKey),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 4) {
            _recordScreenKey.currentState?.refresh();
          }
        },
      ),
    );
  }
}
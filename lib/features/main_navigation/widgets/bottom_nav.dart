import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem("assets/images/AI_icon.png", 0),
            _navItem("assets/images/Recommand_icon.png", 1),
            _navItem("assets/images/Home_icon.png", 2),
            _navItem("assets/images/Learn_icon.png", 3),
            _navItem("assets/images/Record_icon.png", 4),
          ],
        ),
      ),
    );
  }

  Widget _navItem(String icon, int index) {

    final bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () {
        print("탭 클릭됨: $index"); // 터미널(Debug Console)에 이 글자가 뜨는지 확인하세요!
        onTap(index);
      },
      behavior: HitTestBehavior.opaque, // 클릭 영역 확보
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            icon,
            width: 40,
            height: 40,
            color: isActive
                ? const Color(0xFF4882FD)
                : Colors.black54,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
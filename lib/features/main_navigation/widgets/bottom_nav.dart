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

    return Container(
      height: 70,
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

          _navItem("assets/images/AI_icon.png", "AI", 0),
          _navItem("assets/images/Recommand_icon.png", "추천", 1),
          _navItem("assets/images/Home_icon.png", "홈", 2),
          _navItem("assets/images/Learn_icon.png", "학습", 3),
          _navItem("assets/images/Record_icon.png", "기록", 4),
        ],
      ),
    );
  }

  Widget _navItem(String icon, String label, int index) {

    final bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Image.asset(
            icon,
            width: 26,
            height: 26,
            color: isActive
                ? const Color(0xFF4882FD)
                : Colors.black54,
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive
                  ? const Color(0xFF4882FD)
                  : Colors.black54,
            ),
          )
        ],
      ),
    );
  }
}
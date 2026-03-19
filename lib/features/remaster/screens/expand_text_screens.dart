import 'package:flutter/material.dart';

class ExpandTextScreens extends StatelessWidget {
  final String text;

  const ExpandTextScreens({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [

          // 중앙 텍스트
          Center(
            child: RotatedBox(
              quarterTurns: 1,
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // 닫기 버튼
          Positioned(
            right: 20,
            bottom: 20,
            child: IconButton(
              icon: Icon(Icons.close_rounded, size: 40, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
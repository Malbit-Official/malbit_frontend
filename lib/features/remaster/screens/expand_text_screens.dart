import 'package:flutter/material.dart';

// 교정된 문장을 가로로 회전된 대형 텍스트로 확대 표시하는 화면
class ExpandTextScreens extends StatelessWidget {
  final String text;

  const ExpandTextScreens({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Stack(
          children: [
            // 중앙 텍스트
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RotatedBox(
                  quarterTurns: 1,
                  child: Container(
                    padding: const EdgeInsets.all(50.0),
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                      softWrap: true,
                    ),
                  ),
                ),
              ),
            ),

            // 닫기 버튼
            Positioned(
              right: 20,
              bottom: 20,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, size: 40, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
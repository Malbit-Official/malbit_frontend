import 'package:flutter/material.dart';

class TemplateScreen extends StatelessWidget {
  const TemplateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("상황별 추천 템플릿 화면", style: TextStyle(fontSize: 20))),
    );
  }
}
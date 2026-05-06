import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:malbit_frontend/main.dart';

void main() {
  testWidgets('앱 실행 시 MainScreen이 뜬다', (WidgetTester tester) async {
    // ✅ initialRoute 전달
    await tester.pumpWidget(const MyApp(initialRoute: '/main'));

    await tester.pumpAndSettle();

    // MaterialApp 존재 확인
    expect(find.byType(MaterialApp), findsOneWidget);

    // Scaffold 확인 (메인 화면 구조)
    expect(find.byType(Scaffold), findsWidgets);
  });
}
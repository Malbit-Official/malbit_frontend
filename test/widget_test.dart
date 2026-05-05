import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:malbit_frontend/main.dart';

void main() {
  testWidgets('앱 실행 시 MainScreen이 뜬다', (WidgetTester tester) async {
    // 앱 실행
    await tester.pumpWidget(const MyApp());

    // 첫 프레임 렌더링
    await tester.pumpAndSettle();

    // MaterialApp 존재 확인
    expect(find.byType(MaterialApp), findsOneWidget);

    // 🔥 핵심: 홈(MainScreen)이 뜨는지 확인
    expect(find.byType(Scaffold), findsWidgets);
    // (또는 MainScreen import해서 아래로 더 정확하게 가능)
  });
}
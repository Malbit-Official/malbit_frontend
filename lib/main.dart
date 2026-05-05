import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:malbit_frontend/features/auth/screens/reset_password.dart';
import 'package:malbit_frontend/features/auth/screens/signup_screen.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'features/auth/screens/login_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/main_navigation/screens/main_screen.dart';
import 'features/profile/screens/profile_screen.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);

  KakaoSdk.init(
    nativeAppKey: 'f90beb4e45400ac7959f9e2929295180',
  );

  // 🔴 기존 로그인 체크 로직 (지금은 사용 안 함)
  /*
  final storage = const FlutterSecureStorage();
  final accessToken = await storage.read(key: 'accessToken');

  String initialRoute;

  if (accessToken != null) {
    log("이미 로그인 상태");
    initialRoute = '/main';
  } else {
    log("로그인 필요");
    initialRoute = '/login';
  }

  runApp(MyApp(initialRoute: initialRoute));
  */

  // 🟢 로그인 없이 바로 홈으로 이동
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Malbit',

      // 🔥 핵심: 무조건 홈으로 시작
      initialRoute: '/main',

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
      ],

      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/reset': (context) => const ResetPasswordScreen(),
        '/home': (context) => MainScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/main': (context) => const MainScreen(),
      },
    );
  }
}
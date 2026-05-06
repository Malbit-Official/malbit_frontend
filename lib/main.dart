import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:malbit_frontend/features/auth/screens/reset_password.dart';
import 'package:malbit_frontend/features/auth/screens/signup_screen.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'features/auth/screens/login_screen.dart';
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

  // ✅ 로그인 상태 확인 로직 복구
  final storage = const FlutterSecureStorage();
  final accessToken = await storage.read(key: 'accessToken');

  String initialRoute;

  if (accessToken != null && accessToken.isNotEmpty) {
    log("이미 로그인 상태");
    initialRoute = '/home';
  } else {
    log("로그인 필요");
    initialRoute = '/login';
  }

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Malbit',

      // ✅ 로그인 여부에 따라 시작 화면 결정
      initialRoute: initialRoute,

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
        '/home': (context) => const MainScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
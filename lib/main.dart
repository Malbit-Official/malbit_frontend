import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth/screens/login_screen.dart';
import 'auth/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = const FlutterSecureStorage();
  final accessToken = await storage.read(key: 'accessToken');

  String initialRoute = '/login';

  if (accessToken != null) {
    log("이미 로그인 상태");
    initialRoute = '/home';
  } else {
    log("로그인 필요");
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

      initialRoute: initialRoute,

      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
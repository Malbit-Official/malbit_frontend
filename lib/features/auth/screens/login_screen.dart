import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:malbit_frontend/core/services/storage.dart';
import 'package:malbit_frontend/features/auth/services/social_login_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storage = AppStorage.storage;
  final _socialLoginService = SocialLoginService();

  bool _isLoading = false;
  bool _obscureText = true;

  InputDecoration _getInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFC7C7C7), fontSize: 18),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Color(0xFFC7C7C7)),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Color(0xFFC7C7C7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Color(0xFF4882FD), width: 1.5),
      ),
    );
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('이메일과 비밀번호를 모두 입력해주세요.');
      return;
    }

    const apiUrl = 'http://3.37.239.105:8080/api/users/login';

    final loginData = {
      'email': _emailController.text,
      'password': _passwordController.text,
    };

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(loginData),
      );

      if (response.statusCode == 200) {

        final responseBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(responseBody);

        final accessToken = data['data']['accessToken'];
        final refreshToken = data['data']['refreshToken'];

        final name = data['name'];
        final email = data['email'];
        final disabilityType = data['disabilityType'];
        final cognitiveLevel = data['cognitiveLevel'];

        if (accessToken != null && refreshToken != null) {

          await _storage.write(key: 'tokenType', value: 'Bearer');
          await _storage.write(key: 'accessToken', value: accessToken);
          await _storage.write(key: 'refreshToken', value: refreshToken);

          // ✅ 사용자 정보 저장
          await _storage.write(key: 'name', value: name ?? "");
          await _storage.write(key: 'email', value: email ?? "");
          await _storage.write(key: 'disabilityType', value: disabilityType ?? "");
          await _storage.write(key: 'cognitiveLevel', value: cognitiveLevel ?? "");

          _showSnackBar('로그인 성공!');

          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/home');

        } else {
          _showSnackBar('토큰 정보가 없습니다. 서버 응답을 확인해주세요.');
        }

      } else {

        final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
        _showSnackBar(errorBody['message'] ?? '로그인 실패');

      }

    } catch (e) {

      print('로그인 오류: $e');
      _showSnackBar('서버와 통신할 수 없습니다.');

    } finally {

      setState(() => _isLoading = false);

    }
  }
  // 카카오 로그인
  Future<void> _handleKakaoLogin() async {
    setState(() => _isLoading = true);

    try {
      final result = await _socialLoginService.loginWithKakao();

      _showSnackBar(result['message']);

      if (result['success'] && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  // 구글 로그인
  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      final result = await _socialLoginService.loginWithGoogle();

      _showSnackBar(result['message']);

      if (result['success'] && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F6),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
            child: SizedBox(
              width: 322,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/main_logo.png',
                      width: 170,
                      height: 170,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // ✅ 이메일 필드
                  SizedBox(
                    height: 43,
                    child: TextField(
                      controller: _emailController,
                      decoration: _getInputDecoration("이메일"),
                    ),
                  ),
                  const SizedBox(height: 13),

                  // ✅ 비밀번호 필드
                  SizedBox(
                    height: 43,
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: _getInputDecoration("비밀번호").copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText ? Icons.visibility_off : Icons.visibility,
                            color: const Color(0xFFC7C7C7),
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscureText = !_obscureText),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // ✅ 로그인 버튼
                  SizedBox(
                    height: 43,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4882FD),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('로그인', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(height: 13),

                  // ✅ 회원가입 버튼
                  SizedBox(
                    height: 43,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4882FD),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                      ),
                      child: const Text('회원가입', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/reset'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                    child: const Text('새 비밀번호 만들기 >'),
                  ),

                  const SizedBox(height: 30),

                  // 소셜 로그인 영역
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _isLoading ? null : _handleKakaoLogin,
                        child: Image.asset('assets/images/kakao_logo.png', width: 80, height: 80),
                      ),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: _isLoading ? null : _handleGoogleLogin,
                        child: Image.asset('assets/images/google_logo.png', width: 80, height: 80),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
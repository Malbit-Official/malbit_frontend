import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF4882FD),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFF4882FD),
        ),
      ),
      home: const SignUpScreen(),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // 비밀번호 가시성 상태 변수
  bool _isObscured = true;
  bool _isConfirmObscured = true;

  // 공통 InputDecoration 설정
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F6),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 30),
                // 로고 (경로가 유효한지 확인 필요)
                Image.asset("assets/images/logo.png", height: 150, errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image, size: 150, color: Colors.grey);
                }),
                const SizedBox(height: 20),

                // 전체 너비 322로 고정
                SizedBox(
                  width: 322,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 이메일
                      const Text("이메일 *"),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 43,
                        child: TextField(decoration: _getInputDecoration("이메일")),
                      ),
                      const SizedBox(height: 7),

                      /// 인증코드 버튼
                      SizedBox(
                        width: 322,
                        height: 43,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4882FD),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                          child: const Text(
                            "이메일로 인증코드 받기",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      /// 인증코드 입력 Row
                      Row(
                        children: [
                          SizedBox(
                            width: 240,
                            height: 43,
                            child: TextField(decoration: _getInputDecoration("인증코드")),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SizedBox(
                              height: 43,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4882FD),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.zero,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                ),
                                child: const Text("확인", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),

                      /// 비밀번호
                      const Text("비밀번호 *"),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 43,
                        child: TextField(
                          obscureText: _isObscured, // 변수에 따라 가려짐 처리
                          decoration: _getInputDecoration("비밀번호").copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isObscured ? Icons.visibility_off : Icons.visibility,
                                color: const Color(0xFFC7C7C7),
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isObscured = !_isObscured; // 상태 반전
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),

                      /// 비밀번호 재입력
                      SizedBox(
                        height: 43,
                        child: TextField(
                          obscureText: _isConfirmObscured,
                          decoration: _getInputDecoration("비밀번호 재입력").copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmObscured ? Icons.visibility_off : Icons.visibility,
                                color: const Color(0xFFC7C7C7),
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmObscured = !_isConfirmObscured;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// 닉네임
                      const Text("닉네임 *"),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 43,
                        child: TextField(decoration: _getInputDecoration("닉네임")),
                      ),
                      const SizedBox(height: 20),

                      /// 직무 선택
                      const Text("직무분야 선택"),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 43,
                        child: DropdownButtonFormField<String>(
                          decoration: _getInputDecoration("선택"),
                          iconEnabledColor: const Color(0xFFC7C7C7),
                          items: const [
                            DropdownMenuItem(value: "office", child: Text("사무직")),
                            DropdownMenuItem(value: "sales", child: Text("영업 / 고객상담")),
                            DropdownMenuItem(value: "medical", child: Text("의료 / 간호")),
                            DropdownMenuItem(value: "edu", child: Text("교육 / 학교")),
                            DropdownMenuItem(value: "service", child: Text("서비스 / 매장")),
                            DropdownMenuItem(value: "etc", child: Text("기타")),
                          ],
                          onChanged: (value) {},
                        ),
                      ),
                      const SizedBox(height: 40),

                      /// 가입하기 버튼
                      SizedBox(
                        width: 322,
                        height: 43,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/home');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4882FD),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                          ),
                          child: const Text(
                            "가입하기",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
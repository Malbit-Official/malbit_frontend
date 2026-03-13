import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool _isObscured = true;
  bool _isConfirmObscured = true;

  // 공통 InputDecoration 설정
  InputDecoration _getInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFC7C7C7), fontSize: 18),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      enabledBorder: OutlineInputBorder(
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              // 1. 뒤로가기 버튼
              IconButton(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.arrow_back_ios_new, size: 30),
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
              ),
              const SizedBox(height: 30),

              // 2. 제목
              const Center(
                child: Text(
                  "새 비밀번호 만들기",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 60),

              // 3. 중앙 정렬된 폼 컨테이너
              Center(
                child: SizedBox(
                  width: 322,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("가입한 이메일을 입력하세요."),
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
                      const SizedBox(height: 40),

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
                      const SizedBox(height: 80),

                      // 비밀번호 재설정 영역
                      const Text("비밀번호 재설정"),
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
                      const SizedBox(height: 50),

                      // 최종 확인 버튼
                      SizedBox(
                        width: 322,
                        height: 43,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4882FD),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                          ),
                          child: const Text(
                            "확인",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Row 내부에 들어가는 작은 파란색 버튼 위젯
  Widget _smallBlueButton(String text) {
    return SizedBox(
      width: 70,
      height: 43,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4882FD),
          padding: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
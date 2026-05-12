import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  // 입력 제어 컨트롤러
  final _emailController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // 화면 상태 변수
  bool _isObscured = true;
  bool _isConfirmObscured = true;
  bool _isLoading = false;
  bool _isSendingEmail = false;
  bool _isEmailVerified = false;
  bool _isVerifyingCode = false;

  // 이메일 정규식 검사
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // 컨트롤러 해제 (메모리 누수 방지)
  @override
  void dispose() {
    _emailController.dispose();
    _verificationCodeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 공통 디자인 설정 (입력창 테두리, 여백, 힌트 스타일)
  InputDecoration _getInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFC7C7C7), fontSize: 18),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      enabledBorder: OutlineInputBorder( // 평상시
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Color(0xFFC7C7C7)),
      ),
      border: OutlineInputBorder( // 기본값
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Color(0xFFC7C7C7)),
      ),
      focusedBorder: OutlineInputBorder( // 입력 중
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Color(0xFF4882FD), width: 1.5),
      ),
    );
  }

  /// 주요 비즈니스 로직 (API 호출)
  // 이메일 인증코드 발송
  Future<void> _sendCode() async {
    setState(() => _isSendingEmail = true);
    final result = await AuthService.sendEmailCode(_emailController.text.trim());
    if (mounted) {
      setState(() => _isSendingEmail = false);
      _showSnackBar(result['message']);
    }
  }

  // 인증코드 일치 확인
  Future<void> _verifyCode() async {
    setState(() => _isVerifyingCode = true);
    final result = await AuthService.verifyEmailCode(
      _emailController.text.trim(),
      _verificationCodeController.text.trim(),
    );
    if (mounted) {
      setState(() => _isVerifyingCode = false);
      if (result['success']) {
        setState(() => _isEmailVerified = true);
        _showSnackBar("인증에 성공했습니다.");
      } else {
        _showSnackBar(result['message']);
      }
    }
  }

  // 비밀번호 재설정 최종 처리
  Future<void> _handleResetPassword() async {
    if (!_isEmailVerified) {
      _showSnackBar("이메일 인증을 먼저 완료해주세요.");
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar("비밀번호가 일치하지 않습니다.");
      return;
    }

    setState(() => _isLoading = true);
    
    final result = await AuthService.resetPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      passwordConfirm: _confirmPasswordController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success']) {
        _showSnackBar("비밀번호가 변경되었습니다. 다시 로그인해주세요.");
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        _showSnackBar(result['message']);
      }
    }
  }

  // 안내 문구 출력
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
              IconButton(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 30),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 25),

              const Center(
                child: Text(
                  "새 비밀번호 만들기",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 70),

              // 이메일 입력
              Center(
                child: SizedBox(
                  width: 322,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("   가입한 이메일을 입력하세요."),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 43,
                        child: TextField(
                          controller: _emailController,
                          enabled: !_isEmailVerified, // 인증 후에는 수정 불가
                          keyboardType: TextInputType.emailAddress,
                          decoration: _getInputDecoration("이메일").copyWith(
                            fillColor: _isEmailVerified ? Colors.grey[200] : Colors.transparent,
                            filled: _isEmailVerified,
                          ),
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(height: 7),

                      // 인증코드 받기 버튼
                      SizedBox(
                        width: 322,
                        height: 43,
                        child: ElevatedButton(
                          onPressed: (!_isEmailVerified && _isValidEmail(_emailController.text)) ? _sendCode : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (!_isEmailVerified && _isValidEmail(_emailController.text)) ? const Color(0xFF4882FD) : Colors.grey,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                          ),
                          child: _isSendingEmail
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(_isEmailVerified ? "인증 완료" : "이메일로 인증코드 받기", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      //인증코드 입력 및 확인 버튼
                      Row(
                        children: [
                          SizedBox(
                            width: 240,
                            height: 43,
                            child: TextField(
                              controller: _verificationCodeController,
                              enabled: !_isEmailVerified,
                              keyboardType: TextInputType.number,
                              decoration: _getInputDecoration("인증코드"),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SizedBox(
                              height: 43,
                              child: ElevatedButton(
                                onPressed: (_isEmailVerified || _isVerifyingCode) ? null : _verifyCode,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4882FD),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.zero,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                ),
                                child: _isVerifyingCode
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : Text(_isEmailVerified ? "완료" : "확인", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white)
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 80),

                      /// 비밀번호 재설정 영역
                      // 비밀번호
                      const Text("   비밀번호 재설정"),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 43,
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _isObscured,
                          decoration: _getInputDecoration("비밀번호").copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isObscured ? Icons.visibility_off : Icons.visibility,
                                color: const Color(0xFFC7C7C7),
                                size: 20,
                              ),
                              onPressed: () => setState(() => _isObscured = !_isObscured),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),

                      // 비밀번호 재입력
                      SizedBox(
                        height: 43,
                        child: TextField(
                          controller: _confirmPasswordController,
                          obscureText: _isConfirmObscured,
                          decoration: _getInputDecoration("비밀번호 재입력").copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmObscured ? Icons.visibility_off : Icons.visibility,
                                color: const Color(0xFFC7C7C7),
                                size: 20,
                              ),
                              onPressed: () => setState(() => _isConfirmObscured = !_isConfirmObscured),
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
                          onPressed: _isLoading ? null : _handleResetPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4882FD),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                              : const Text(
                            "확인",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
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
}
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // 입력 제어 컨트롤러
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _verificationCodeController = TextEditingController();

  // 화면 상태 변수
  bool _isObscured = true;
  bool _isConfirmObscured = true;
  bool _isLoading = false;
  bool _isSendingEmail = false;
  bool _isEmailVerified = false;
  bool _isVerifyingCode = false;

  // 서버 전송용 초기값
  String _selectedJobType = "OFFICE";
  String _disabilityType = "LANGUAGE";
  int _cognitiveLevel = 1;

  // 이메일 정규식 검사
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // 화면 집입 시 모든 상태값 초기화 (메모리 데이터 리셋)
  @override
  void initState() {
    super.initState();
    _isEmailVerified = false;
    _isLoading = false;
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _nameController.clear();
    _verificationCodeController.clear();

    _selectedJobType = "OFFICE";
    _disabilityType = "LANGUAGE";
    _cognitiveLevel = 3;
  }

  // 컨트롤러 해제 (메모리 누수 방지)
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
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
  Future<void> _handleSignUp() async {
    // 유효성 검사
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _nameController.text.isEmpty) {
      _showSnackBar("모든 항목을 입력해주세요.");
      return;
    }
    if (!_isEmailVerified) {
      _showSnackBar("이메일 인증을 완료해주세요.");
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar("비밀번호가 일치하지 않습니다.");
      return;
    }

    setState(() => _isLoading = true);

    // AuthService 호출
    final result = await AuthService.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      passwordConfirm: _confirmPasswordController.text.trim(),
      name: _nameController.text.trim(),
      jobType: _selectedJobType,
      disabilityType: _disabilityType,
      cognitiveLevel: _cognitiveLevel,
      code: _verificationCodeController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    // 결과 처리
    if (result['success']) {
      _showSnackBar("회원가입이 완료되었습니다!");
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      _showSnackBar(result['message']);
    }
  }

  // 안내 문구 출력
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

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
      setState(() => _isVerifyingCode = false); // 로딩 종료
      if (result['success']) {
        setState(() => _isEmailVerified = true);
        _showSnackBar("인증에 성공했습니다.");
      } else {
        _showSnackBar(result['message']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F6F6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 50),
                Image.asset("assets/images/logo.png", height: 150, errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image, size: 150, color: Colors.grey);
                }),
                const SizedBox(height: 30),

                SizedBox(
                  width: 322,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 이메일 및 인증 섹션
                      //이메일
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

                      // 인증코드 받기 버튼 (이메일 유효 시에만 활성화)
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
                      const SizedBox(height: 10),

                      // 인증코드 입력 및 확인 버튼
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
                      const SizedBox(height: 40),

                      /// 비밀번호 및 닉네임 섹션
                      // 비밀번호
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
                      const SizedBox(height: 40),

                      // 닉네임
                      SizedBox(
                        height: 43,
                        child: TextField(
                          controller: _nameController,
                          decoration: _getInputDecoration("닉네임"),
                        ),
                      ),
                      const SizedBox(height: 40),

                      /// 타입 선택 드롭다운 섹션
                      // 직무 분야 선택
                      const Text("   직무 분야 선택"),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 43,
                        child: DropdownButtonFormField<String>(
                          dropdownColor: const Color(0xFFF7F6F6),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                          decoration: _getInputDecoration("선택"),
                          iconEnabledColor: const Color(0xFFC7C7C7),
                          items: const [
                            DropdownMenuItem(value: "OFFICE", child: Text("사무직")),
                            DropdownMenuItem(value: "SALES", child: Text("영업 / 고객상담")),
                            DropdownMenuItem(value: "MEDICAL", child: Text("의료 / 간호")),
                            DropdownMenuItem(value: "EDUCATION", child: Text("교육 / 학교")),
                            DropdownMenuItem(value: "SERVICE", child: Text("서비스 / 매장")),
                            DropdownMenuItem(value: "ETC", child: Text("기타")),
                          ],
                          onChanged: (value) => setState(() => _selectedJobType = value!),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // 장애유형 선택
                      const Text("   장애유형 선택"),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 43,
                        child: DropdownButtonFormField<String>(
                          dropdownColor: const Color(0xFFF7F6F6),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                          decoration: _getInputDecoration("선택"),
                          iconEnabledColor: const Color(0xFFC7C7C7),
                          items: const [
                            DropdownMenuItem(value: "LANGUAGE", child: Text("언어장애")),
                            DropdownMenuItem(value: "CRANIAL_NERVE", child: Text("뇌신경장애")),
                            DropdownMenuItem(value: "HEARING", child: Text("청각장애")),
                            DropdownMenuItem(value: "ARTICULATION", child: Text("조음장애")),
                            DropdownMenuItem(value: "CONDUCTIVE_HEARING", child: Text("전음성 난청")),
                            DropdownMenuItem(value: "SENSORINEURAL_HEARING", child: Text("감음신경성 난청")),
                            DropdownMenuItem(value: "FUNCTIONAL_VOICE", child: Text("기능성 발성장애")),
                            DropdownMenuItem(value: "LARYNGEAL", child: Text("후두장애")),
                            DropdownMenuItem(value: "ORAL", child: Text("구강장애")),
                          ],
                          onChanged: (value) => setState(() => _disabilityType = value!),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // 인지 수준 선택
                      const Text("   인지 수준 선택"),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 43,
                        child: DropdownButtonFormField<int>(
                          dropdownColor: const Color(0xFFF7F6F6),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                          isExpanded: true,
                          decoration: _getInputDecoration("선택"),
                          iconEnabledColor: const Color(0xFFC7C7C7),
                          items: const [
                            DropdownMenuItem(value: 1, child: Text("1단계: 매우 낮음 (단어 위주 소통)")),
                            DropdownMenuItem(value: 2, child: Text("2단계: 낮음 (간단한 문장 이해)")),
                            DropdownMenuItem(value: 3, child: Text("3단계: 보통 (일상 대화 가능)")),
                            DropdownMenuItem(value: 4, child: Text("4단계: 높음 (추상/비유 이해)")),
                            DropdownMenuItem(value: 5, child: Text("5단계: 매우 높음 (정교한 소통)")),
                          ],
                          onChanged: (value) => setState(() => _cognitiveLevel = value!),
                        ),
                      ),
                      const SizedBox(height: 50),

                      // 가입하기 버튼
                      SizedBox(
                        width: 322,
                        height: 43,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSignUp,
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
                            "가입하기",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
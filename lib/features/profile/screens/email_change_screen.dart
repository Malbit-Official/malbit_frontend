import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:malbit_frontend/core/services/storage.dart';

// 이메일 변경 화면: 이메일 인증 코드 발송과 확인을 거쳐 새 이메일을 서버에 업데이트
class EmailChangeScreen extends StatefulWidget {
  final String currentEmail;

  const EmailChangeScreen({
    super.key,
    required this.currentEmail,
  });

  @override
  State<EmailChangeScreen> createState() => _EmailChangeScreenState();
}

class _EmailChangeScreenState extends State<EmailChangeScreen> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  bool isCodeSent = false;
  bool isVerified = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    emailController.text = widget.currentEmail;
  }

  /// 인증번호 발송
  Future<void> sendCode() async {
    final response = await http.post(
      Uri.parse('http://3.37.239.105:8080/api/auth/email/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": emailController.text,
      }),
    );

    final data = jsonDecode(response.body);

    if (data['status'] == 'SUCCESS') {
      setState(() {
        isCodeSent = true;
      });
      showSnackBar("인증번호 전송됨");
    } else {
      showSnackBar(data['message']);
    }
  }

  /// 인증 확인
  Future<void> verifyCode() async {
    final response = await http.post(
      Uri.parse('http://3.37.239.105:8080/api/auth/email/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": emailController.text,
        "code": codeController.text,
      }),
    );

    final data = jsonDecode(response.body);

    if (data['status'] == 'SUCCESS') {
      setState(() {
        isVerified = true;
      });
      showSnackBar("인증 완료");
    } else {
      showSnackBar("인증 실패");
    }
  }

  /// 이메일 변경
  Future<void> changeEmail() async {

    if (!isVerified) {
      showSnackBar("이메일 인증을 완료해주세요.");
      return;
    }

    setState(() => isLoading = true);

    final token = await AppStorage.storage.read(key: 'accessToken');

    final response = await http.patch(
      Uri.parse('http://3.37.239.105:8080/api/users/email'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "newEmail": emailController.text,
      }),
    );

    final data = jsonDecode(response.body);

    setState(() => isLoading = false);

    if (data['status'] == 'SUCCESS') {
      showSnackBar("이메일 변경 완료");

      Navigator.pop(context, emailController.text); // ⭐️ 결과 전달
    } else {
      showSnackBar(data['message']);
    }
  }

  void showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("이메일 변경")),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "새 이메일",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: sendCode,
              child: const Text("인증번호 받기"),
            ),

            if (isCodeSent) ...[
              const SizedBox(height: 10),

              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: "인증번호 입력",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: verifyCode,
                child: const Text("인증 확인"),
              ),
            ],

            if (isVerified)
              const Text("✅ 인증 완료", style: TextStyle(color: Colors.green)),

            const Spacer(),

            ElevatedButton(
              onPressed: isLoading ? null : changeEmail,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("이메일 변경"),
            ),
          ],
        ),
      ),
    );
  }
}
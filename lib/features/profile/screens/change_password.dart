import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:malbit_frontend/core/services/storage.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController currentPasswordController =
  TextEditingController();

  final TextEditingController newPasswordController =
  TextEditingController();

  final TextEditingController confirmPasswordController =
  TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  /// 비밀번호 변경
  void _handleChangePassword() async {

    if (!_formKey.currentState!.validate()) return;

    if (newPasswordController.text != confirmPasswordController.text) {
      _showSnackBar("새 비밀번호가 일치하지 않습니다.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final token = await AppStorage.storage.read(key: 'accessToken');

      final response = await http.patch(
        Uri.parse('http://10.0.2.2:8080/api/users/password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "oldPassword": currentPasswordController.text,
          "newPassword": newPasswordController.text,
        }),
      );

      final data = jsonDecode(response.body);
      print("비밀번호 변경 응답: $data");

      if (response.statusCode == 200 && data['status'] == 'SUCCESS') {

        _showSnackBar("비밀번호가 변경되었습니다.");

        Navigator.pop(context);

      } else {
        _showSnackBar(data['message'] ?? "변경 실패");
      }

    } catch (e) {
      _showSnackBar("서버 오류 발생");
      print("에러: $e");
    }

    setState(() {
      isLoading = false;
    });
  }
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),

      appBar: AppBar(
        title: const Text("비밀번호 변경"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              /// 현재 비밀번호
              TextFormField(
                controller: currentPasswordController,
                obscureText: true,

                decoration: const InputDecoration(
                  labelText: "현재 비밀번호",
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "현재 비밀번호를 입력해주세요";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              /// 새 비밀번호
              TextFormField(
                controller: newPasswordController,
                obscureText: true,

                decoration: const InputDecoration(
                  labelText: "새 비밀번호",
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null || value.length < 6) {
                    return "비밀번호는 6자 이상 입력해주세요";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              /// 새 비밀번호 확인
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,

                decoration: const InputDecoration(
                  labelText: "새 비밀번호 확인",
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "비밀번호 확인을 입력해주세요";
                  }
                  return null;
                },
              ),

              const Spacer(),

              /// 변경 버튼
              ElevatedButton(
                onPressed: isLoading ? null : _handleChangePassword,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[100],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),

                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "비밀번호 변경",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
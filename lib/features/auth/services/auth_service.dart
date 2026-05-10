import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "http://13.125.107.37:8080";

  static Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String passwordConfirm,
    required String name,
    required String jobType,
    required String disabilityType,
    required int cognitiveLevel,
    required String code,
  }) async {
    final url = Uri.parse('$baseUrl/api/users/join');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email,
          "password": password,
          "passwordConfirm": passwordConfirm,
          "nickname": name,
          "jobType": jobType.toUpperCase(),
          "disabilityType": disabilityType,
          "cognitiveLevel": cognitiveLevel,
          "code": code,
        }),
      );

      // 서버 응답 로그 확인 (디버깅용)
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${utf8.decode(response.bodyBytes)}");

      final responseBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200 || response.statusCode == 201) {

        try {
          final data = jsonDecode(responseBody);
          return {'success': true, 'message': data['message'] ?? '가입 성공'};
        } catch (e) {
          return {'success': true, 'message': responseBody};
        }
      } else {
        return {'success': false, 'message': '가입 실패: $responseBody'};
      }
    } catch (e) {
      print("Network Error: $e");
      return {'success': false, 'message': '서버 연결 실패. 네트워크 설정을 확인하세요.'};
    }
  }

  // 이메일 인증코드 발송
  static Future<Map<String, dynamic>> sendEmailCode(String email) async {
    final url = Uri.parse('$baseUrl/api/auth/email/send');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email}),
      );
      final data = jsonDecode(response.body);
      return {"success": response.statusCode == 200, "message": data['message']};
    } catch (e) {
      return {"success": false, "message": "네트워크 에러가 발생했습니다."};
    }
  }

  // 이메일 인증코드 검증
  static Future<Map<String, dynamic>> verifyEmailCode(String email, String code) async {
    final url = Uri.parse('$baseUrl/api/auth/email/verify');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email, "code": code}),
      );
      final data = jsonDecode(response.body);
      return {
        "success": data['success'] ?? (response.statusCode == 200),
        "message": data['message']
      };
    } catch (e) {
      return {"success": false, "message": "네트워크 에러가 발생했습니다."};
    }
  }

  // 비밀번호 재설정
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String password,
    required String passwordConfirm,
  }) async {
    final url = Uri.parse('$baseUrl/api/users/password/reset');

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email,
          "password": password,
          "passwordConfirm": passwordConfirm,
        }),
      );

      final responseBody = utf8.decode(response.bodyBytes);

      Map<String, dynamic> data = {};
      if (responseBody.isNotEmpty) {
        data = jsonDecode(responseBody);
      }

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? '비밀번호 변경 성공'
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? '변경 실패: $responseBody'
        };
      }
    } catch (e) {
      print("Network Error: $e");
      return {
        'success': false,
        'message': '서버 연결 실패'
      };
    }
  }
}
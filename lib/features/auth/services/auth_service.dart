// services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "http://10.0.2.2:8080";

  static Future<Map<String, dynamic>> signUp({
    // 추후 장애유형 등등 추가
    required String email,
    required String password,
    required String name,
    required String jobType,
  }) async {
    final url = Uri.parse('$baseUrl/api/users/join');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email,
          "password": password,
          "nickname": name,
          "jobType": jobType.toUpperCase(),
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
}
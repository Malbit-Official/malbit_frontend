import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:malbit_frontend/core/services/storage.dart';

const String baseUrl = 'http://3.37.239.105:8080';

// 상황극 기반 학습 세션의 시작, 종료를 서버에 요청하는 API 클라이언트
class TrainingApi {
  static Future<String?> _getToken() async {
    return await AppStorage.storage.read(key: 'accessToken');
  }

  static Future<int> startSession(int categoryId) async {
    final token = await _getToken();

    print('=== START 요청 ===');
    print('categoryId: $categoryId');
    print('token: $token');

    final res = await http.post(
      Uri.parse('$baseUrl/api/training/start'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'categoryId': categoryId}),
    );

    print('=== START 응답 ===');
    print('status: ${res.statusCode}');
    print('body: ${utf8.decode(res.bodyBytes)}');

    final decoded = jsonDecode(utf8.decode(res.bodyBytes));
    print('decoded: $decoded');
    print('data: ${decoded['data']}');

    return decoded['data']['sessionId'];
  }

  static Future<Map<String, dynamic>> finishSession(int sessionId) async {
    final token = await _getToken();
    final res = await http.post(
      Uri.parse('$baseUrl/api/training/finish/$sessionId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return jsonDecode(utf8.decode(res.bodyBytes));
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;

// 업무 기록의 목록 조회, 상세 조회, 생성, 메모 수정을 처리하는 API 클라이언트
class LogService {
  static const String baseUrl = "http://3.37.239.105:8080/api";

  static Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  // 업무 기록 목록 조회 API
  static Future<Map<String, dynamic>> getLogs({
    required String token,
    String? date,
  }) async {
    String url = '$baseUrl/logs';
    if (date != null) {
      url += '?date=$date';
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(token),
      );

      print("📡 [GET /logs] 응답 코드: ${response.statusCode}");
      print("📦 [GET /logs] 응답 내용: ${utf8.decode(response.bodyBytes)}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));

        if (jsonData['status'] == 'SUCCESS') {
          return {
            'success': true,
            'data': jsonData['data'] ?? [],
            'message': jsonData['message'],
          };
        } else {
          return {
            'success': false,
            'message': jsonData['message'] ?? '알 수 없는 오류',
          };
        }
      } else {
        return {
          'success': false,
          'message': '서버 에러: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ [GET /logs] 에러: $e");
      return {
        'success': false,
        'message': '서버 연결 실패: $e',
      };
    }
  }

  // 업무 기록 상세 조회
  static Future<Map<String, dynamic>> getLogDetail({
    required String token,
    required int logId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/logs/$logId'),
        headers: _getHeaders(token),
      );

      print("📡 [GET /logs/$logId] 응답 코드: ${response.statusCode}");
      print("📦 [GET /logs/$logId] 응답 내용: ${utf8.decode(response.bodyBytes)}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));

        if (jsonData['status'] == 'SUCCESS') {
          return {
            'success': true,
            'detail': jsonData['data'],
            'message': jsonData['message'],
          };
        } else {
          return {
            'success': false,
            'message': jsonData['message'] ?? '알 수 없는 오류',
          };
        }
      } else {
        return {
          'success': false,
          'message': '서버 에러: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ [GET /logs/$logId] 에러: $e");
      return {
        'success': false,
        'message': '서버 연결 실패: $e',
      };
    }
  }

  // 업무 기록 생성
  static Future<Map<String, dynamic>> createLog({
    required String token,
    required String title,
    required String rawContent,
    required String startTime,
    required String duration,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logs/summary'),
        headers: _getHeaders(token),
        body: jsonEncode({
          'title': title,
          'rawContent': rawContent,
          'startTime': startTime,
          'duration': duration,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonData['status'] == 'SUCCESS') {
          return {
            'success': true,
            'detail': jsonData['data'],
            'message': jsonData['message'],
          };
        }
      }
      return {'success': false, 'message': '생성 실패'};
    } catch (e) {
      return {'success': false, 'message': '서버 연결 실패: $e'};
    }
  }

  // 메모 추가 및 수정
  static Future<Map<String, dynamic>> updateMemo({
    required String token,
    required int logId,
    required String memo,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/logs/$logId/memo'),
        headers: _getHeaders(token),
        body: jsonEncode({'memo': memo}),
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        return {'success': true, 'message': jsonData['message']};
      }
      return {'success': false, 'message': '메모 수정 실패'};
    } catch (e) {
      return {'success': false, 'message': '연결 실패: $e'};
    }
  }
}
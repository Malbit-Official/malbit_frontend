import 'dart:convert';
import 'package:http/http.dart' as http;

class CalendarService {
  static const String baseUrl = "http://3.37.239.105:8080";

  static Map<String, String> _getHeaders(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // 1. 월간/주간 일정 조회 (GET /api/calendar?query_date=yyyy-MM-dd)
  static Future<Map<String, dynamic>> fetchMonthlyEvents({
    required String token,
    required String queryDate,
  }) async {
    final url = Uri.parse('$baseUrl/api/calendar?query_date=$queryDate');

    try {
      final response = await http.get(url, headers: _getHeaders(token));

      print("일정 조회 응답 코드: ${response.statusCode}");
      if (response.statusCode == 200) {
        final decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        return {
          'success': true,
          'data': decodedData['data'],
        };
      } else {
        return {'success': false, 'message': '서버 에러: ${response.statusCode}'};
      }
    } catch (e) {
      print("일정 조회 에러: $e");
      return {'success': false, 'message': '서버 연결 실패: $e'};
    }
  }

  // 2. 일정 수동 등록 (POST /api/calendar/manual)
  static Future<Map<String, dynamic>> addEvent({
    required String token,
    required String title,
    required String startAt,
    required String endAt,
    String category = "업무",
  }) async {
    final url = Uri.parse('$baseUrl/api/calendar/manual');
    final body = jsonEncode({
      'content': title,
      'start_at': startAt,
      'end_at': endAt,
      'category': category,
    });

    try {
      final response = await http.post(url, headers: _getHeaders(token), body: body);

      print("일정 등록 응답 코드: ${response.statusCode}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        return {
          'success': true,
          'taskId': decodedData['data']?['task_id'],
        };
      } else {
        return {'success': false, 'message': '서버 에러: ${response.statusCode}'};
      }
    } catch (e) {
      print("일정 등록 에러: $e");
      return {'success': false, 'message': '서버 연결 실패: $e'};
    }
  }

  // 3. 일정 수정 (PATCH /api/calendar/{taskId})
  static Future<Map<String, dynamic>> updateEvent({
    required String token,
    required int taskId,
    required String title,
    String? startAt,
    String? endAt,
    String? category,
  }) async {
    final url = Uri.parse('$baseUrl/api/calendar/$taskId');
    final body = jsonEncode({
      'content': title,
      if (startAt != null) 'start_at': startAt,
      if (endAt != null) 'end_at': endAt,
      if (category != null) 'category': category,
    });

    try {
      final response = await http.patch(url, headers: _getHeaders(token), body: body);

      print("일정 수정 응답 코드: ${response.statusCode}");
      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {'success': false, 'message': '서버 에러: ${response.statusCode}'};
      }
    } catch (e) {
      print("일정 수정 에러: $e");
      return {'success': false, 'message': '서버 연결 실패: $e'};
    }
  }

  // 4. 일정 삭제 (DELETE /api/calendar/{taskId})
  static Future<Map<String, dynamic>> deleteEvent({
    required String token,
    required int taskId,
  }) async {
    final url = Uri.parse('$baseUrl/api/calendar/$taskId');

    try {
      final response = await http.delete(url, headers: _getHeaders(token));

      print("일정 삭제 응답 코드: ${response.statusCode}");
      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {'success': false, 'message': '서버 에러: ${response.statusCode}'};
      }
    } catch (e) {
      print("일정 삭제 에러: $e");
      return {'success': false, 'message': '서버 연결 실패: $e'};
    }
  }

  // 5. 다가오는 일정 조회 (GET /api/calendar/upcoming)
  static Future<Map<String, dynamic>> fetchUpcomingEvents({
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/api/calendar/upcoming');

    try {
      final response = await http.get(url, headers: _getHeaders(token));

      print("다가오는 일정 조회 응답 코드: ${response.statusCode}");
      if (response.statusCode == 200) {
        final decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        return {
          'success': true,
          'upcomingTasks': decodedData['data']?['upcoming_tasks'] ?? [],
        };
      } else {
        return {'success': false, 'message': '서버 에러: ${response.statusCode}'};
      }
    } catch (e) {
      print("다가오는 일정 조회 에러: $e");
      return {'success': false, 'message': '서버 연결 실패: $e'};
    }
  }

  // 6. 일정 완료 상태 토글 (PATCH /api/calendar/{taskId}/toggle)
  static Future<Map<String, dynamic>> toggleEventStatus({
    required String token,
    required int taskId,
  }) async {
    final url = Uri.parse('$baseUrl/api/calendar/$taskId/completion');

    try {
      final response = await http.patch(url, headers: _getHeaders(token));

      print("일정 토글 요청 URL: $url");
      print("일정 토글 응답 코드: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        print("🔥 서버에서 온 실제 데이터: ${response.body}");
        return {
          'success': true,
          'data': decodedData['data'] as bool? ?? false,
        };
      } else {
        return {'success': false, 'message': '서버 에러: ${response.statusCode}'};
      }
    } catch (e) {
      print("일정 토글 에러: $e");
      return {'success': false, 'message': '서버 연결 실패: $e'};
    }
  }
}
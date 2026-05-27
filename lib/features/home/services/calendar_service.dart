import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CalendarService {
  static const String baseUrl = "http://3.37.239.105:8080";

  static Map<String, String> _getHeaders(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // 월간/주간 일정 조회
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
          'data': decodedData['data'] ?? [],
        };
      } else {
        return {'success': false, 'message': '서버 에러: ${response.statusCode}'};
      }
    } catch (e) {
      print("일정 조회 에러: $e");
      return {'success': false, 'message': '서버 연결 실패: $e'};
    }
  }

  // 일정 수동 등록
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
        final data = decodedData['data'];

        final taskId = (data is Map) ? data ['task_id'] : data;

        return {
          'success': true,
          'taskId': taskId,
        };
      } else {
        return {'success': false, 'message': '서버 에러: ${response.statusCode}'};
      }
    } catch (e) {
      print("일정 등록 에러: $e");
      return {'success': false, 'message': '서버 연결 실패: $e'};
    }
  }

  // 일정 수정
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

  // 일정 삭제
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

  // 다가오는 일정 조회
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

  // 일정 완료 상태 토글
  // 일정 완료 상태를 지정하여 백엔드로 전송 (Body 추가 버전)
  static Future<Map<String, dynamic>> toggleEventStatus({
    required String token,
    required int taskId,
    required bool isCompleted, // 💡 변경된 true/false 상태 주입받기
  }) async {
    final url = Uri.parse('$baseUrl/api/calendar/$taskId/completion');

    // 💡 백엔드 TaskCompletionRequest DTO 규격에 맞게 바디 생성
    final body = jsonEncode({
      'is_completed': isCompleted,
    });

    try {
      // 💡 body 파라미터 추가
      final response = await http.patch(url, headers: _getHeaders(token), body: body);

      print("일정 상태 변경 요청 URL: $url");
      print("일정 상태 변경 응답 코드: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        final rawData = decodedData['data'];
        bool parsedStatus = false;
        if (rawData is bool) {
          parsedStatus = rawData;
        } else if (rawData is String) {
          parsedStatus = rawData.toLowerCase() == 'true';
        }

        return {
          'success': true,
          'data': parsedStatus,
        };
      } else {
        return {'success': false, 'message': '서버 에러: ${response.statusCode}'};
      }
    } catch (e) {
      print("일정 상태 변경 에러: $e");
      return {'success': false, 'message': '서버 연결 실패: $e'};
    }
  }
}
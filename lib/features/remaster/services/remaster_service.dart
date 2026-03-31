import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class RemasterService {
  static const String baseUrl = "http://10.0.2.2:8080";

  static Future<Map<String, dynamic>> uploadAudio({
    required String filePath,
    required String token,
    String tone = "정중하게",
  }) async {
    final url = Uri.parse('$baseUrl/api/logs');
    var request = http.MultipartRequest('POST', url);

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json'
    });

    request.files.add(http.MultipartFile.fromString(
      'session_id',
      '102',
      contentType: MediaType('application', 'json'),
    ));

    request.files.add(http.MultipartFile.fromString(
      'preferred_tone',
      tone,
      contentType: MediaType('application', 'json'),
    ));

    request.files.add(await http.MultipartFile.fromPath(
      'audio_file',
      filePath,
      // 오디오 타입 명시 (서버 strict 체크 대비)
      contentType: MediaType('audio', 'mpeg'),
    ));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // 디버깅을 위해 로그 출력
      print("서버 응답 코드: ${response.statusCode}");
      print("서버 응답 내용: ${utf8.decode(response.bodyBytes)}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return {
          'success': true,
          'originalSpeech': data['original_speech'],
          'refinedText': data['refined_text'],
        };
      } else {
        return {
          'success': false,
          'message': '서버 에러: ${response.statusCode}'
        };
      }
    } catch (e) {
      print("네트워크 에러 상세: $e");
      return {'success': false, 'message': '서버 연결 실패: $e'};
    }
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class RemasterService {
  static const String baseUrl = "http://13.125.107.37:8080";

  static Future<Map<String, dynamic>> uploadAudio({
    required String filePath,
    required String token,
    String tone = "gentle", // 백엔드 예시값과 일치
  }) async {
    final url = Uri.parse('$baseUrl/api/remaster');
    var request = http.MultipartRequest('POST', url);

    // 1. 인증 헤더
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json'
    });

    // 2. 말투 설정 (백엔드 @RequestPart String 대응)
    // 일반 field가 아닌 application/json 타입을 가진 Part로 보냄 (500 에러 방지)
    request.files.add(http.MultipartFile.fromString(
      'preferred_tone',
      tone,
      contentType: MediaType('application', 'json'),
    ));

    // 3. 오디오 파일 전송 (WAV 형식 명시)
    request.files.add(await http.MultipartFile.fromPath(
      'audio_file',
      filePath,
      contentType: MediaType('audio', 'wav'),
    ));

    try {
      // 40초 타임아웃 설정
      final streamedResponse = await request.send().timeout(const Duration(seconds: 40));
      final response = await http.Response.fromStream(streamedResponse);

      print("서버 응답 코드: ${response.statusCode}");
      print("서버 응답 바디: ${utf8.decode(response.bodyBytes)}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        // 백엔드 ApiResponse<RemasteringLogResponse> 구조 파싱
        final resultData = data['data'];

        return {
          'success': true,
          'originalSpeech': resultData['original_speech'] ?? "인식 실패",
          'refinedText': resultData['refined_text'] ?? "교정 실패",
        };
      } else {
        return {
          'success': false,
          'message': '서버 오류: ${response.statusCode}'
        };
      }
    } catch (e) {
      print("전송 에러: $e");
      return {'success': false, 'message': '연결 실패'};
    }
  }
}
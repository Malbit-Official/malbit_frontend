import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class RemasterService {
  static const String baseUrl = "http://3.37.239.105:8080";

  static Future<Map<String, dynamic>> uploadAudio({
    required String filePath,
    required String token,
    String tone = "gentle",
  }) async {
    final url = Uri.parse('$baseUrl/api/remaster');
    var request = http.MultipartRequest('POST', url);

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json'
    });

    request.fields['preferred_tone'] = tone;

    request.files.add(await http.MultipartFile.fromPath(
      'audio_file',
      filePath,
      contentType: MediaType('audio', 'wav'),
    ));

    try {
      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final target = data.containsKey('data') ? data['data'] : data;

        return {
          'success': true,
          'original_speech': target['original_speech'] ?? "인식 실패",
          'refined_text': target['refined_text'] ?? "교정 실패",
        };
      } else {
        return {
          'success': false,
          'message': '서버 오류: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'success': false, 'message': '연결 실패'};
    }
  }
}
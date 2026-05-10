import 'dart:convert';
import 'package:http/http.dart' as http;

class HolidayService {
  static const String _serviceKey = "106404e685b32f9903d494fe31ec20e3d39bd4e564b174b8ed6b978b8b0d2f45";
  static const String _baseUrl = "http://apis.data.go.kr/B090041/openapi/service/SpcdeInfoService/getRestDeInfo";

  static Future<Map<DateTime, String>> fetchHolidays(int year, int month) async {
    String monthStr = month.toString().padLeft(2, '0');
    final url = Uri.parse("$_baseUrl?ServiceKey=$_serviceKey&solYear=$year&solMonth=$monthStr&_type=json");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final body = data['response']['body'];

        if (body['totalCount'] == 0) return {};

        var items = body['items']['item'];
        if (items is Map) items = [items];

        Map<DateTime, String> holidayMap = {};
        for (var item in items) {
          String locdate = item['locdate'].toString();
          DateTime date = DateTime.parse(locdate);
          String name = item['dateName'].toString();
          holidayMap[date] = name;
        }
        return holidayMap;
      }
    } catch (e) {
      print("공휴일 서비스 에러: $e");
    }
    return {};
  }
}
// 업무 기록 목록 화면에서 각 로그 아이템을 표현하는 데이터 모델
class Log {
  final int logId;
  final String title;
  final String time;
  final String duration;
  final String type;

  Log({
    required this.logId,
    required this.title,
    required this.time,
    required this.duration,
    required this.type,
  });

  factory Log.fromJson(Map<String, dynamic> json) {
    return Log(
      logId: json['logId'],
      title: json['title'],
      time: json['time'],
      duration: json['duration'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logId': logId,
      'title': title,
      'time': time,
      'duration': duration,
      'type': type,
    };
  }
}
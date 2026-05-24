class CalendarEvent {
  final int? taskId;
  String title;
  DateTime? startAt;
  DateTime? endAt;
  String? category;
  bool isDone;

  final int? dDay;
  final String? remainingTime;

  CalendarEvent({
    this.taskId,
    required this.title,
    this.startAt,
    this.endAt,
    this.category,
    this.isDone = false,
    this.dDay,
    this.remainingTime,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {

    final rawCompleted = json['is_completed'] ??
        json['isCompleted'] ??
        json['completed'] ??
        json['completedAt'] ??
        false;

    bool parsedIsDone = false;

    if (rawCompleted is bool) {
      parsedIsDone = rawCompleted;
    } else if (rawCompleted is int) {
      parsedIsDone = rawCompleted == 1;
    } else if (rawCompleted is String) {
      parsedIsDone = rawCompleted.toLowerCase() == 'true' || rawCompleted == '1';
    }

    return CalendarEvent(
      taskId: json['task_id'] ?? json['taskId'],
      title: json['content'] ?? json['title'] ?? '',
      isDone: parsedIsDone,
      startAt: json['start_at'] != null ? DateTime.parse(json['start_at']) : (json['start_time'] != null ? DateTime.parse(json['start_time']) : null),
      endAt: json['end_at'] != null ? DateTime.parse(json['end_at']) : (json['end_time'] != null ? DateTime.parse(json['end_time']) : null),
      category: json['category'],
      dDay: json['d_day'] ?? json['dday'],
      remainingTime: json['remaining_time'] ?? json['remainingTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': title,
      if (startAt != null) 'start_at': startAt!.toIso8601String(),
      if (endAt != null) 'end_at': endAt!.toIso8601String(),
      if (category != null) 'category': category,
    };
  }
}
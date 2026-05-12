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
    return CalendarEvent(
      taskId: json['task_id'],
      title: json['content'] ?? '',
      isDone: json['is_completed'] ?? json['isCompleted'] ?? json['completed'] ?? false,
      startAt: json['start_at'] != null ? DateTime.parse(json['start_at']) : null,
      endAt: json['end_at'] != null ? DateTime.parse(json['end_at']) : null,
      category: json['category'],
      dDay: json['d_day'],
      remainingTime: json['remaining_time'],
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
class LogDetail {
  final int logId;
  final String title;
  final String date;
  final String startTime;
  final String duration;
  final String? rawContent;
  final List<String> summaries;
  final List<String> decisions;
  final List<TodoItem> todos;

  LogDetail({
    required this.logId,
    required this.title,
    required this.date,
    required this.startTime,
    required this.duration,
    this.rawContent,
    required this.summaries,
    required this.decisions,
    required this.todos,
  });

  factory LogDetail.fromJson(Map<String, dynamic> json) {
    return LogDetail(
      logId: json['logId'],
      title: json['title'],
      date: json['date'],
      startTime: json['startTime'],
      duration: json['duration'],
      rawContent: json['rawContent'],
      summaries: List<String>.from(json['summaries'] ?? []),
      decisions: List<String>.from(json['decisions'] ?? []),
      todos: (json['todos'] as List?)
          ?.map((t) => TodoItem.fromJson(t))
          .toList() ??
          [],
    );
  }
}

class TodoItem {
  final String assignee;
  final String content;

  TodoItem({
    required this.assignee,
    required this.content,
  });

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      assignee: json['assignee'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assignee': assignee,
      'content': content,
    };
  }
}
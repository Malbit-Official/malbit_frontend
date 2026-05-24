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

    // summary와 summaries(리스트) 모두 대응 가능하도록 수정
    List<String> summaryList = [];
    if (json['summaries'] != null && json['summaries'] is List) {
      summaryList = List<String>.from(json['summaries']);
    } else {
      String aiSummary = json['summary'] ?? '';
      if (aiSummary.isNotEmpty) summaryList = [aiSummary];
    }

    return LogDetail(
      logId: json['logId'] ?? 0,
      title: json['title'] ?? '제목 없음',
      date: json['date'] ?? '',
      startTime: json['startTime'] ?? '',
      duration: json['duration'] ?? '',

      rawContent: json['rawText'] ?? json['raw_text'],

      summaries: summaryList,

      decisions: List<String>.from(json['checklist'] ?? json['checklists'] ?? []),

      todos: (json['schedules'] as List?)
          ?.map((t) => TodoItem.fromJson(t))
          .toList() ??
          [],
    );
  }
}

class TodoItem {
  final String assignee;
  final String content;
  final String? time;
  final String? importance;

  TodoItem({
    required this.assignee,
    required this.content,
    this.time,
    this.importance,
  });

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      assignee: json['category'] ?? '업무',
      content: json['title'] ?? '할 일 내용 없음',
      time: json['time'],
      importance: json['importance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assignee': assignee,
      'content': content,
      'time': time,
      'importance': importance,
    };
  }
}
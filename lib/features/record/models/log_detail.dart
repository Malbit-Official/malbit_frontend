import 'package:flutter/material.dart';

// 업무 기록 상세 화면에서 사용하는 상세 데이터 모델
// 회의 요약, 결정사항, 할 일 목록, 메모 포함
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
    List<String> summaryList = [];
    if (json['summaries'] != null && json['summaries'] is List) {
      summaryList = List<String>.from(json['summaries']);
    } else if (json['summary'] != null && json['summary'] is String) {
      final String aiSummary = json['summary'];
      if (aiSummary.isNotEmpty) summaryList = [aiSummary];
    }

    List<String> decisionList = [];
    final rawChecklist = json['decisions'] ?? json['checklists'] ?? json['checklist'] ?? [];
    if (rawChecklist is List) {
      decisionList = rawChecklist.map((item) => item.toString()).toList();
    }

    List<TodoItem> todoList = [];
    final rawTodos = json['todos'] ?? json['schedules'] ?? [];
    if (rawTodos is List) {
      try {
        todoList = rawTodos
            .map((t) => TodoItem.fromJson(t as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint("⚠️ todos (TodoItem) 파싱 실패: $e");
      }
    }

    return LogDetail(
      logId: json['logId'] ?? json['log_id'] ?? json['meetingId'] ?? 0,
      title: json['title'] ?? '제목 없음',
      date: json['date'] ?? '',
      startTime: json['startTime'] ?? json['start_time'] ?? '',
      duration: json['duration'] ?? '',
      rawContent: json['rawText'] ?? json['raw_text'],
      summaries: summaryList,
      decisions: decisionList,
      todos: todoList,
    );
  }
}

// 할 일 목록의 단일 항목을 나타내는 모델
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
      assignee: json['assignee'] ?? json['category'] ?? '업무',
      content: json['content'] ?? json['title'] ?? '할 일 내용 없음',
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
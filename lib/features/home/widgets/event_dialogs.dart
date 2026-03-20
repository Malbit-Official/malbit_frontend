import 'package:flutter/material.dart';
import '../models/calendar_event.dart';

class EventDialogs {
  // 1. 새 일정 등록 다이얼로그
  static void showAddDialog({
    required BuildContext context,
    required TextEditingController controller,
    required VoidCallback onSave,
  }) {
    controller.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("새 일정 등록", style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: "일정 내용을 입력하세요"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("취소")),
          ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff4882FD)),
            child: const Text("저장", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 2. 일정 관리 (수정/삭제) 다이얼로그
  static void showEditDeleteDialog({
    required BuildContext context,
    required TextEditingController controller,
    required CalendarEvent event,
    required VoidCallback onUpdate,
    required VoidCallback onDelete,
  }) {
    controller.text = event.title;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("일정 관리"),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: onDelete,
            child: const Text("삭제", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: onUpdate,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff4882FD)),
            child: const Text("수정 완료", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
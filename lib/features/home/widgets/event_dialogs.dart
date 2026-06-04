import 'package:flutter/material.dart';
import '../models/calendar_event.dart';

// 캘린더 일정 관리 다이얼로그 모음: 등록, 수정, 삭제 확인 다이얼로그 표시
class EventDialogs {
  static void _showEventBottomSheet({
    required BuildContext context,
    required TextEditingController controller,
    required String title,
    required String hintText,
    required VoidCallback onConfirm,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF7F6F6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: (MediaQuery.of(context).viewInsets.bottom > 0
                  ? MediaQuery.of(context).viewInsets.bottom + 15
                  : bottomPadding - 20).clamp(0.0, double.infinity),
              left: 20,
              right: 20,
              top: 15,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 17),
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 15),
                Theme(
                  data: Theme.of(context).copyWith(
                    textSelectionTheme: const TextSelectionThemeData(
                      cursorColor: Color(0xff4882FD),
                      selectionColor: Color(0xff4882FD),
                      selectionHandleColor: Color(0xff4882FD),
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: hintText,
                      hintStyle: const TextStyle(color: Colors.grey),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: IconButton(
                          icon: const Icon(Icons.send_rounded),
                          color: const Color(0xff4882FD),
                          onPressed: onConfirm,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    ),
                    onSubmitted: (_) => onConfirm(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 일정 등록 창
  static void showAddDialog({
    required BuildContext context,
    required TextEditingController controller,
    required VoidCallback onSave,
  }) {
    controller.clear();
    _showEventBottomSheet(
      context: context,
      controller: controller,
      title: "새 일정 등록",
      hintText: "일정 내용을 입력하세요.",
      onConfirm: onSave,
    );
  }

  // 일정 수정 창
  static void showEditDialog({
    required BuildContext context,
    required TextEditingController controller,
    required CalendarEvent event,
    required VoidCallback onUpdate,
  }) {
    controller.text = event.title;
    _showEventBottomSheet(
      context: context,
      controller: controller,
      title: "일정 수정",
      hintText: "수정할 내용을 입력하세요.",
      onConfirm: onUpdate,
    );
  }

  // 일정 삭제 확인 창
  static void showDeleteConfirmDialog({
    required BuildContext context,
    required VoidCallback onDelete,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF7F6F6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        content: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: const Text(
            "일정을 정말 삭제하시겠습니까?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          // 취소 버튼
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: Colors.grey,
                  ),
                  child: const Text(
                    "취소",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // 삭제 버튼
              Expanded(
                child: ElevatedButton(
                  onPressed: onDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    foregroundColor: Colors.red,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "삭제",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
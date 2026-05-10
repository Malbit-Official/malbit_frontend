import 'package:flutter/material.dart';
import '../models/calendar_event.dart';

class EventItemWidget extends StatelessWidget {
  final CalendarEvent event;
  final VoidCallback onLongPress;
  final VoidCallback onTap;
  final ValueChanged<bool?> onChanged;

  const EventItemWidget({
    super.key,
    required this.event,
    required this.onLongPress,
    required this.onTap,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        // 전체 카드 디자인
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F6F6),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            // 체크박스 디자인
            Transform.scale(
              scale: 1.0,
              child: Checkbox(
                value: event.isDone,
                onChanged: onChanged,
                activeColor: const Color(0xff4882FD),
                checkColor: Colors.white,
                side: BorderSide(
                  color: event.isDone ? const Color(0xff4882FD) : const Color(0xffD1D1D1),
                  width: 1.3,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            const SizedBox(width: 1),
            // 일정 텍스트 디자인
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: event.isDone ? Colors.grey : Colors.black,
                      decoration: event.isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
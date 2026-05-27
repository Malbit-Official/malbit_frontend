import 'package:flutter/material.dart';
import '../models/calendar_event.dart';

class EventItemWidget extends StatefulWidget {
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
  State<EventItemWidget> createState() => _EventItemWidgetState();
}

class _EventItemWidgetState extends State<EventItemWidget> {
  late bool _isDone;

  @override
  void initState() {
    super.initState();
    _isDone = widget.event.isDone;
  }

  // 부모에서 event.isDone이 바뀌면 로컬 상태도 동기화
  @override
  void didUpdateWidget(EventItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.event.isDone != widget.event.isDone) {
      _isDone = widget.event.isDone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: widget.onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F6F6),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Transform.scale(
              scale: 1.0,
              child: Checkbox(
                value: _isDone,
                onChanged: (val) {
                  setState(() => _isDone = val ?? _isDone); // 즉시 UI 반영
                  widget.onChanged(val);                    // 부모 API 호출
                },
                activeColor: const Color(0xff4882FD),
                checkColor: Colors.white,
                side: BorderSide(
                  color: _isDone ? const Color(0xff4882FD) : const Color(0xffD1D1D1),
                  width: 1.3,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            const SizedBox(width: 1),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    widget.event.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: _isDone ? Colors.grey : Colors.black,
                      decoration: _isDone ? TextDecoration.lineThrough : null,
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
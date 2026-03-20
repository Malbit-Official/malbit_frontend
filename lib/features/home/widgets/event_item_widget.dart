import 'package:flutter/material.dart';
import '../models/calendar_event.dart';

class EventItemWidget extends StatelessWidget {
  final CalendarEvent event;
  final VoidCallback onLongPress;
  final ValueChanged<bool?> onChanged;

  const EventItemWidget({
    super.key,
    required this.event,
    required this.onLongPress,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F6F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: CheckboxListTile(
          activeColor: const Color(0xff4882FD),
          checkboxShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          title: Text(
            event.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: event.isDone ? Colors.grey : Colors.black87,
              decoration: event.isDone ? TextDecoration.lineThrough : null,
            ),
          ),
          value: event.isDone,
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
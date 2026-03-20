import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

// 분리한 파일들 임포트
import '../models/calendar_event.dart';
import '../widgets/event_item_widget.dart';
import '../widgets/event_dialogs.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  final TextEditingController _eventController = TextEditingController();

  final Map<DateTime, List<CalendarEvent>> _events = {
    DateTime(2026, 3, 20): [
      CalendarEvent(title: '오전 주간 회의'),
      CalendarEvent(title: '기획안 피드백', isDone: true),
    ],
  };

  List<CalendarEvent> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _handleAddEvent() {
    EventDialogs.showAddDialog(
      context: context,
      controller: _eventController,
      onSave: () {
        if (_eventController.text.isEmpty) return;
        setState(() {
          final dateKey = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
          if (_events[dateKey] != null) {
            _events[dateKey]!.add(CalendarEvent(title: _eventController.text));
          } else {
            _events[dateKey] = [CalendarEvent(title: _eventController.text)];
          }
        });
        _eventController.clear();
        Navigator.pop(context);
      },
    );
  }

  void _handleEditEvent(CalendarEvent event, int index) {
    _eventController.text = event.title;
    EventDialogs.showEditDeleteDialog(
      context: context,
      controller: _eventController,
      event: event,
      onDelete: () {
        setState(() {
          final dateKey = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
          _events[dateKey]?.removeAt(index);
        });
        Navigator.pop(context);
      },
      onUpdate: () {
        if (_eventController.text.isEmpty) return;
        setState(() {
          event.title = _eventController.text;
        });
        _eventController.clear();
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      floatingActionButton: FloatingActionButton(
        onPressed: _handleAddEvent,
        backgroundColor: const Color(0xff4882FD),
        elevation: 2,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomHeader(),
            _buildCalendarSection(),
            Container(height: 1, color: Colors.grey.withOpacity(0.08)),
            _buildEventListSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 5),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Text(
            DateFormat('yyyy년 M월', 'ko_KR').format(_focusedDay),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TableCalendar(
        locale: 'ko_KR',
        firstDay: DateTime.now().subtract(const Duration(days: 365 * 5)),
        lastDay: DateTime.now().add(const Duration(days: 365 * 5)),
        focusedDay: _focusedDay,
        headerVisible: false,
        sixWeekMonthsEnforced: true,
        rowHeight: 46.0,
        daysOfWeekHeight: 38.0,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: _getEventsForDay,
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        calendarBuilders: _buildCalendarBuilders(),
        calendarStyle: const CalendarStyle(
          outsideDaysVisible: true,
          outsideTextStyle: TextStyle(fontSize: 13, color: Color(0xFFE0E0E0)),
          defaultTextStyle: TextStyle(fontSize: 13, color: Colors.black87),
          weekendTextStyle: TextStyle(fontSize: 13, color: Colors.redAccent), // 일요일용
          selectedTextStyle: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
          selectedDecoration: BoxDecoration(color: Color(0xff4882FD), shape: BoxShape.circle),
          todayTextStyle: TextStyle(fontSize: 13, color: Color(0xff4882FD), fontWeight: FontWeight.bold),
          todayDecoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.fromBorderSide(BorderSide(color: Color(0xff4882FD), width: 1.5)),
          ),
        ),
      ),
    );
  }

  CalendarBuilders _buildCalendarBuilders() {
    return CalendarBuilders(
      // [수정] 평일 중 토요일을 파란색으로 변경
      defaultBuilder: (context, day, focusedDay) {
        if (day.weekday == DateTime.saturday) {
          return Center(
            child: Text(
              '${day.day}',
              style: const TextStyle(color: Colors.blueAccent, fontSize: 13),
            ),
          );
        }
        return null; // 다른 평일은 기본 스타일 적용
      },
      dowBuilder: (context, day) {
        final text = const ['월', '화', '수', '목', '금', '토', '일'][day.weekday - 1];
        Color textColor = Colors.black54;
        if (day.weekday == DateTime.saturday) textColor = Colors.blueAccent;
        if (day.weekday == DateTime.sunday) textColor = Colors.redAccent;
        return Center(child: Text(text, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w500)));
      },
      // [수정] 이전/다음 달 토요일도 연한 파란색으로 표시
      outsideBuilder: (context, day, focusedDay) {
        Color textColor = const Color(0xFFE0E0E0);
        if (day.weekday == DateTime.sunday) textColor = const Color(0xFFFFEBEE);
        if (day.weekday == DateTime.saturday) textColor = const Color(0xFFE3F2FD);
        return Center(child: Text('${day.day}', style: TextStyle(color: textColor, fontSize: 13)));
      },
      markerBuilder: (context, date, events) {
        if (events.isNotEmpty) {
          return Positioned(
            bottom: 5,
            child: Container(
              width: 4.5,
              height: 4.5,
              decoration: const BoxDecoration(color: Color(0xFFEF5350), shape: BoxShape.circle),
            ),
          );
        }
        return null;
      },
    );
  }

  Widget _buildEventListSection() {
    final events = _getEventsForDay(_selectedDay!);

    return Expanded(
      child: Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMMM d일 (E)', 'ko_KR').format(_selectedDay!),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Expanded(
              child: events.isEmpty
                  ? const Center(child: Text("일정이 없습니다.", style: TextStyle(color: Colors.grey, fontSize: 14)))
                  : ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return EventItemWidget(
                    event: events[index],
                    onLongPress: () => _handleEditEvent(events[index], index),
                    onChanged: (val) => setState(() => events[index].isDone = val ?? false),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../../core/services/storage.dart';
import '../models/calendar_event.dart';
import '../services/calendar_service.dart';
import '../widgets/event_item_widget.dart';
import '../widgets/event_dialogs.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _storage = AppStorage.storage;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  final TextEditingController _eventController = TextEditingController();

  Map<DateTime, List<CalendarEvent>> _events = {};
  List<CalendarEvent> _upcomingEvents = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAllCalendarData();
  }

  Future<void> _loadAllCalendarData() async {
    setState(() => _isLoading = true);
    final token = await _storage.read(key: 'accessToken') ?? "";

    final queryDate = DateFormat('yyyy-MM-dd').format(_focusedDay);

    final monthlyResult = await CalendarService.fetchMonthlyEvents(
      token: token,
      queryDate: queryDate,
    );
    final upcomingResult = await CalendarService.fetchUpcomingEvents(token: token);

    if (monthlyResult['success']) {
      final List<dynamic> rawData = monthlyResult['data'] ?? [];
      Map<DateTime, List<CalendarEvent>> loadedEvents = {};

      for (var dayData in rawData) {
        DateTime parsedDate = DateTime.parse(dayData['date']);
        DateTime dateKey = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);

        List<CalendarEvent> dayEvents = (dayData['schedules'] as List)
            .map((task) => CalendarEvent.fromJson(task))
            .toList();

        loadedEvents[dateKey] = dayEvents;
      }

      setState(() {
        _events = loadedEvents;
      });
    } else {
      _showErrorSnackBar(monthlyResult['message'] ?? "일정을 불러오지 못했습니다.");
    }

    if (upcomingResult['success']) {
      final List<dynamic> rawUpcoming = upcomingResult['upcomingTasks'] ?? [];
      setState(() {
        _upcomingEvents = rawUpcoming.map((task) => CalendarEvent.fromJson(task)).toList();
      });
    } else {
      _showErrorSnackBar(upcomingResult['message'] ?? "다가오는 일정을 불러오지 못했습니다.");
    }

    setState(() => _isLoading = false);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  List<CalendarEvent> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _handleAddEvent() {
    EventDialogs.showAddDialog(
      context: context,
      controller: _eventController,
      onSave: () async {
        if (_eventController.text.isEmpty) return;

        final token = await _storage.read(key: 'accessToken') ?? "";
        final dateKey = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);

        final formattedStartAt = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateKey);
        final endDateTime = dateKey.add(const Duration(hours: 1));
        final formattedEndAt = DateFormat('yyyy-MM-dd HH:mm:ss').format(endDateTime);

        final result = await CalendarService.addEvent(
          token: token,
          title: _eventController.text,
          startAt: formattedStartAt,
          endAt: formattedEndAt,
          category: "업무",
        );

        if (result['success']) {
          setState(() {
            final newEvent = CalendarEvent(
              taskId: result['taskId'],
              title: _eventController.text,
              startAt: dateKey,
              endAt: endDateTime,
              category: "업무",
            );

            if (_events[dateKey] != null) {
              _events[dateKey]!.add(newEvent);
            } else {
              _events[dateKey] = [newEvent];
            }
          });
          _eventController.clear();
          Navigator.pop(context);

          _refreshUpcomingOnly(token);
        } else {
          _showErrorSnackBar(result['message']);
        }
      },
    );
  }

  void _handleEditEvent(CalendarEvent event, int index) {
    _eventController.text = event.title;
    EventDialogs.showEditDeleteDialog(
      context: context,
      controller: _eventController,
      event: event,
      onDelete: () async {
        if (event.taskId == null) return;

        final token = await _storage.read(key: 'accessToken') ?? "";
        final result = await CalendarService.deleteEvent(token: token, taskId: event.taskId!);

        if (result['success']) {
          setState(() {
            final dateKey = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
            _events[dateKey]?.removeAt(index);
          });
          Navigator.pop(context);
          _refreshUpcomingOnly(token);
        } else {
          _showErrorSnackBar(result['message']);
        }
      },
      onUpdate: () async {
        if (_eventController.text.isEmpty || event.taskId == null) return;

        final token = await _storage.read(key: 'accessToken') ?? "";

        String? formattedStartAt;
        if (event.startAt != null) {
          formattedStartAt = DateFormat('yyyy-MM-dd HH:mm:ss').format(event.startAt!);
        }

        String? formattedEndAt;
        if (event.endAt != null) {
          formattedEndAt = DateFormat('yyyy-MM-dd HH:mm:ss').format(event.endAt!);
        }

        final result = await CalendarService.updateEvent(
          token: token,
          taskId: event.taskId!,
          title: _eventController.text,
          startAt: formattedStartAt,
          endAt: formattedEndAt,
          category: event.category,
        );

        if (result['success']) {
          setState(() {
            event.title = _eventController.text;
          });
          _eventController.clear();
          Navigator.pop(context);
          _refreshUpcomingOnly(token);
        } else {
          _showErrorSnackBar(result['message']);
        }
      },
    );
  }

  Future<void> _refreshUpcomingOnly(String token) async {
    final upcomingResult = await CalendarService.fetchUpcomingEvents(token: token);
    if (upcomingResult['success']) {
      final List<dynamic> rawUpcoming = upcomingResult['upcomingTasks'] ?? [];
      setState(() {
        _upcomingEvents = rawUpcoming.map((task) => CalendarEvent.fromJson(task)).toList();
      });
    }
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xff4882FD)))
            : Column(
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
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Text(
            DateFormat('yyyy년 M월', 'ko_KR').format(_focusedDay),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
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
          _loadAllCalendarData();
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
          weekendTextStyle: TextStyle(fontSize: 13, color: Colors.redAccent),
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
      defaultBuilder: (context, day, focusedDay) {
        if (day.weekday == DateTime.saturday) {
          return Center(
            child: Text(
              '${day.day}',
              style: const TextStyle(
                color: Colors.blueAccent,
                fontSize: 13,
              ),
            ),
          );
        }
        return null;
      },
      dowBuilder: (context, day) {
        final text = const ['월', '화', '수', '목', '금', '토', '일'][day.weekday - 1];
        Color textColor = Colors.black54;

        if (day.weekday == DateTime.saturday) textColor = Colors.blueAccent;
        if (day.weekday == DateTime.sunday) textColor = Colors.redAccent;

        return Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
      outsideBuilder: (context, day, focusedDay) {
        Color textColor = const Color(0xFFE0E0E0);

        if (day.weekday == DateTime.sunday) textColor = const Color(0xFFFFEBEE);
        if (day.weekday == DateTime.saturday) textColor = const Color(0xFFE3F2FD);

        return Center(
          child: Text(
            '${day.day}',
            style: TextStyle(
              color: textColor,
              fontSize: 13,
            ),
          ),
        );
      },
      markerBuilder: (context, date, events) {
        if (events.isNotEmpty) {
          return Positioned(
            bottom: 5,
            child: Container(
              width: 4.5,
              height: 4.5,
              decoration: const BoxDecoration(
                color: Color(0xFFEF5350),
                shape: BoxShape.circle,
              ),
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
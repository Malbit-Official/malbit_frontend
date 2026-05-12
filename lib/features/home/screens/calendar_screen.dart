import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../../core/services/storage.dart';
import '../models/calendar_event.dart';
import '../services/calendar_service.dart';
import '../services/holiday_service.dart';
import '../widgets/event_item_widget.dart';
import '../widgets/event_dialogs.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _storage = AppStorage.storage;

  // 캘린더 상태 관리 변수
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  final TextEditingController _eventController = TextEditingController();

  // 데이터 리스트
  Map<DateTime, List<CalendarEvent>> _events = {};
  List<CalendarEvent> _upcomingEvents = [];
  Map<DateTime, String> _holidayMap = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAllCalendarData();
  }

  // 서버로부터 월별 및 다가오는 일정 데이터 불러옴
  Future<void> _loadAllCalendarData({bool isSilent = false}) async {
    if (!isSilent) setState(() => _isLoading = true);

    final token = await _storage.read(key: 'accessToken') ?? "";
    final queryDate = DateFormat('yyyy-MM-dd').format(_focusedDay);

    final results = await Future.wait([
      CalendarService.fetchMonthlyEvents(token: token, queryDate: queryDate),
      CalendarService.fetchUpcomingEvents(token: token),
      HolidayService.fetchHolidays(_focusedDay.year, _focusedDay.month),
    ]);

    final monthlyResult = results[0] as Map<String, dynamic>;
    final upcomingResult = results[1] as Map<String, dynamic>;
    final holidayData = results[2] as Map<DateTime, String>;

    // 월별 일정 데이터 가공 및 저장
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
      setState(() => _events = loadedEvents);
    } else {
      _showErrorSnackBar(monthlyResult['message'] ?? "일정을 불러오지 못했습니다.");
    }

    // 다가오는 일정 및 공휴일 데이터 상태 업데이트
    setState(() {
      if (upcomingResult['success']) {
        final List<dynamic> rawUpcoming = upcomingResult['upcomingTasks'] ?? [];
        _upcomingEvents = rawUpcoming.map((task) => CalendarEvent.fromJson(task)).toList();
      }

      _holidayMap = holidayData;

      if (!isSilent) _isLoading = false;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  List<CalendarEvent> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  // 플로팅 버튼 클릭 시 새 일정 등록 바텀시트 실행
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

  // 일정 제목 터치 시 수정 바텀시트 실행
  void _handleUpdateEvent(CalendarEvent event) {
    _eventController.text = event.title;
    EventDialogs.showEditDialog(
      context: context,
      controller: _eventController,
      event: event,
      onUpdate: () async {
        if (_eventController.text.isEmpty || event.taskId == null) return;

        final token = await _storage.read(key: 'accessToken') ?? "";
        String? formattedStartAt = event.startAt != null
            ? DateFormat('yyyy-MM-dd HH:mm:ss').format(event.startAt!) : null;
        String? formattedEndAt = event.endAt != null
            ? DateFormat('yyyy-MM-dd HH:mm:ss').format(event.endAt!) : null;

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

  // 일정 롱 프레스 시 중앙 삭제 확인 다이얼로그 실행
  void _handleDeleteEvent(CalendarEvent event, int index) {
    EventDialogs.showDeleteConfirmDialog(
      context: context,
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
    );
  }

  // 데이터 등록/수정/삭제 후 다가오는 일정만 별도로 최신화
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10.0, right: 10.0),
        child: SizedBox(
          width: 53,
          height: 53,
          child: FloatingActionButton(
            onPressed: _handleAddEvent,
            backgroundColor: const Color(0xff4882FD),
            elevation: 2,
            shape: const CircleBorder(),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 38),
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            _buildCustomHeader(),
            _isLoading
                ? const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xff4882FD))))
                : Expanded(
              child: Column(
                children: [
                  _buildCalendarSection(),
                  Container(height: 1.5, color: Colors.grey.withOpacity(0.08)),
                  _buildEventListSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 상단 연도/월 표시 및 월 이동(이전/다음) 버튼 영역
  Widget _buildCustomHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 이전달 버튼
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, color: Colors.black, size: 28),
            onPressed: () {
              final prevMonth = DateTime(_focusedDay.year, _focusedDay.month - 1);
              final now = DateTime.now();

              setState(() {
                _focusedDay = prevMonth;
                if (prevMonth.year == now.year && prevMonth.month == now.month) {
                  _selectedDay = now;
                } else {
                  _selectedDay = DateTime(prevMonth.year, prevMonth.month, 1);
                }
              });
              _loadAllCalendarData(isSilent: true);
            },
          ),

          Text(
            DateFormat('yyyy년 M월', 'ko_KR').format(_focusedDay),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black),
          ),

          // 다음달 버튼
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, color: Colors.black, size: 28),
            onPressed: () {
              final nextMonth = DateTime(_focusedDay.year, _focusedDay.month + 1);
              final now = DateTime.now();

              setState(() {
                _focusedDay = nextMonth;
                if (nextMonth.year == now.year && nextMonth.month == now.month) {
                  _selectedDay = now;
                } else {
                  _selectedDay = DateTime(nextMonth.year, nextMonth.month, 1);
                }
              });
              _loadAllCalendarData(isSilent: true);
            },
          ),
        ],
      ),
    );
  }

  // TableCalendar 위젯 설정 영역
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
          final now = DateTime.now();
          setState(() {
            _focusedDay = focusedDay;

            if (focusedDay.year == now.year && focusedDay.month == now.month) {
              _selectedDay = now;
            } else {
              _selectedDay = DateTime(focusedDay.year, focusedDay.month, 1);
            }
          });
          _loadAllCalendarData(isSilent: true);
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
          defaultTextStyle: TextStyle(fontSize: 13, color: Colors.black),
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

  // 달력의 각 셀(날짜, 요일, 마커) 디자인 커스텀
  CalendarBuilders _buildCalendarBuilders() {
    return CalendarBuilders(
      defaultBuilder: (context, day, focusedDay) {
        DateTime dayOnly = DateTime(day.year, day.month, day.day);
        bool isHoliday = _holidayMap.containsKey(dayOnly);

        // 공휴일이면 빨간색 표시
        if (isHoliday || day.weekday == DateTime.sunday) {
          return Center(
            child: Text(
              '${day.day}',
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          );
        }

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

  // 선택한 날짜의 일정 목록을 보여주는 하단 영역
  Widget _buildEventListSection() {
    final events = _getEventsForDay(_selectedDay!);

    DateTime selectedDayOnly = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    String? holidayName = _holidayMap[selectedDayOnly];

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
                const Icon(Icons.calendar_today, size: 15, color: Colors.grey),
                const SizedBox(width: 10),
                Text(
                  DateFormat('MMMM d일 (E)', 'ko_KR').format(_selectedDay!),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ],
            ),

            // [추가] 공휴일 안내 배너
            if (holidayName != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.celebration, size: 16, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Text(
                      "오늘은 $holidayName입니다.",
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 10),
            Expanded(
              child: events.isEmpty
                  ? const Center(child: Text("일정이 없습니다.", style: TextStyle(color: Colors.grey, fontSize: 15)))
                  : ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return EventItemWidget(
                    event: events[index],
                    onTap: () => _handleUpdateEvent(events[index]),
                    onLongPress: () => _handleDeleteEvent(events[index], index),
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
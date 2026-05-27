import 'package:flutter/material.dart';
import 'package:malbit_frontend/features/record/models/log.dart';
import 'package:malbit_frontend/features/record/screens/summary_screen.dart';
import '../../../core/services/storage.dart';
import '../services/log_service.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => RecordScreenState();
}

class RecordScreenState extends State<RecordScreen> {
  final _storage = AppStorage.storage;
  Future<Map<String, dynamic>>? _logsFuture;
  bool _isLoading = false;

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> refresh() async {
    await _fetchLogs();
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
    _fetchLogs();
  }

  String _formatDateForApi(DateTime date) {
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return "$year-$month-$day";
  }

  String _formatDateForUi(DateTime date) {
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return "$year.$month.$day";
  }

  Future<void> _fetchLogs() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await _storage.read(key: 'accessToken') ?? "";
      final formattedDate = _formatDateForApi(_selectedDate);
      debugPrint(" [목록 요청 날짜 체크]: $formattedDate");
      final futureResult = LogService.getLogs(token: token, date: formattedDate);
      await futureResult;

      if (mounted) {
        setState(() {
          _logsFuture = futureResult;
        });
      }
    } catch (e) {
      debugPrint(" 업무 기록 조회 실패: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 달력을 띄우고 날짜를 직접 선택하는 함수 추가
  Future<void> _selectDateViaCalendar(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4882FD),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF4882FD)),
            ),
          ),
          child: child!,
        );
      },
    );

    // 사용자가 취소를 누르지 않고 날짜를 정상적으로 선택했을 때만 상태 업데이트 및 재조회
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _fetchLogs(); // 캘린더로 바뀐 날짜의 데이터 요청
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday = _formatDateForApi(_selectedDate) == _formatDateForApi(now);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F6),
      body: RefreshIndicator(
        onRefresh: _fetchLogs,
        color: const Color(0xFF4882FD),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(25, 25, 25, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    isToday ? '오늘의 업무 기록' : '그날의 업무 기록',
                    style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 20),

                // 상단 날짜 선택 및 변경 바
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black54, size: 20),
                        onPressed: () => _changeDate(-1),
                      ),

                      InkWell(
                        onTap: () => _selectDateViaCalendar(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              Text(
                                _formatDateForUi(_selectedDate),
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.calendar_month_rounded, size: 18, color: Color(0xFF4882FD)), // 💡 달력 아이콘 힌트 추가
                            ],
                          ),
                        ),
                      ),

                      IconButton(
                        icon: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: isToday ? Colors.grey[300] : Colors.black54,
                            size: 20
                        ),
                        onPressed: isToday ? null : () => _changeDate(1),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text('이런 대화들이 있었어요', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black)),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF4882FD)))
                      : FutureBuilder<Map<String, dynamic>>(
                    future: _logsFuture,
                    builder: (context, snapshot) {
                      final List<Log> serverLogs = [];

                      if (snapshot.hasData && snapshot.data != null) {
                        final rawList = snapshot.data?['data'];

                        if (rawList != null && rawList is List) {
                          for (var jsonItem in rawList) {
                            try {
                              serverLogs.add(Log.fromJson(jsonItem));
                            } catch (e) {
                              debugPrint("⚠️ Log 파싱 중 에러 발생: $e, 데이터 원본: $jsonItem");
                            }
                          }
                        }
                      }

                      if (serverLogs.isEmpty) {
                        return const Center(
                          child: SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            child: Text('기록된 대화가 없습니다.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            margin: const EdgeInsets.only(bottom: 30),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: serverLogs.length,
                              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEEEEEE), indent: 16, endIndent: 16),
                              itemBuilder: (context, index) {
                                final item = serverLogs[index];

                                String displayTitle = item.title;
                                if (displayTitle.startsWith('202') && displayTitle.contains(' ')) {
                                  final parts = displayTitle.split(' ');
                                  if (parts.length > 1) {
                                    displayTitle = parts.sublist(1).join(' ');
                                  }
                                }

                                String formattedTime = item.time;
                                if (formattedTime.contains(':')) {
                                  final timeParts = formattedTime.split(':');
                                  if (timeParts.length >= 2) {
                                    formattedTime = "${timeParts[0]}:${timeParts[1]}";
                                  }
                                }

                                final currentSelectedDateStr = _formatDateForUi(_selectedDate);
                                final displayDateTime = "$currentSelectedDateStr $formattedTime";

                                return InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => SummaryScreen(
                                        logId: item.logId,
                                        meetingTitle: displayTitle,
                                        dateTimeText: displayDateTime,
                                        durationText: item.duration,
                                      ),
                                    ));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          displayTitle,
                                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              displayDateTime,
                                              style: const TextStyle(fontSize: 15, color: Color(0xFF868686), fontWeight: FontWeight.w400),
                                            ),
                                            const SizedBox(width: 8),
                                            const Text('-', style: TextStyle(color: Color(0xFF868686))),
                                            const SizedBox(width: 8),
                                            Text(
                                              item.duration,
                                              style: const TextStyle(fontSize: 15, color: Color(0xFF868686), fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
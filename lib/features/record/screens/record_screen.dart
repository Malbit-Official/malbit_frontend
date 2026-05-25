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

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> refresh() async {
    await _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await _storage.read(key: 'accessToken') ?? "";

      final now = DateTime.now();
      final year = now.year;
      final month = now.month.toString().padLeft(2, '0');
      final day = now.day.toString().padLeft(2, '0');
      final formattedDate = "$year-$month-$day";

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

  @override
  Widget build(BuildContext context) {
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
                const Center(
                  child: Text('오늘의 업무 기록', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black)),
                ),
                const SizedBox(height: 50),
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
                                return InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => SummaryScreen(
                                        logId: item.logId,
                                        meetingTitle: item.title,
                                        dateTimeText: item.time,
                                        durationText: item.duration,
                                      ),
                                    ));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black)),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Text(item.time, style: const TextStyle(fontSize: 15, color: Color(0xFF868686))),
                                            const SizedBox(width: 8),
                                            const Text('-', style: TextStyle(color: Color(0xFF868686))),
                                            const SizedBox(width: 8),
                                            Text(item.duration, style: const TextStyle(fontSize: 15, color: Color(0xFF868686))),
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
import 'package:flutter/material.dart';
import 'package:malbit_frontend/features/record/models/log.dart';
import 'package:malbit_frontend/features/record/screens/summary_screen.dart';
import '../../../core/services/storage.dart';
import '../services/log_service.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final _storage = AppStorage.storage;
  Future<Map<String, dynamic>>? _logsFuture;
  bool _isLoading = false; // [추가] 로딩 상태를 명확히 관리

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  // [수정] 로딩 상태가 UI에 반영되도록 수정
  Future<void> _fetchLogs() async {
    setState(() {
      _isLoading = true; // 로딩 시작
    });

    final token = await _storage.read(key: 'accessToken') ?? "";
    final now = DateTime.now();
    final formattedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    // 실제 데이터를 가져오는 Future 저장
    _logsFuture = LogService.getLogs(token: token, date: formattedDate);

    // 데이터 요청이 끝난 후 로딩 상태 해제
    await _logsFuture;

    if (mounted) {
      setState(() {
        _isLoading = false; // 로딩 종료
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    /* [목업 주석 처리]
    final List<Log> mockItems = [ ... ];
    */

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
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF4882FD))) // [수정] _isLoading이 true면 무조건 로딩바 표시
                      : FutureBuilder<Map<String, dynamic>>(
                    future: _logsFuture,
                    builder: (context, snapshot) {
                      // 서버 데이터 추출
                      final List<Log> serverLogs = [];
                      if (snapshot.hasData && snapshot.data?['logs'] != null) {
                        serverLogs.addAll(snapshot.data?['logs']);
                      }

                      if (serverLogs.isEmpty) {
                        return const Center(
                          child: SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            child: Text('기록된 대화가 없습니다.', style: TextStyle(color: Colors.grey)),
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
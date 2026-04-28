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

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  void _fetchLogs() async {
    final token = await _storage.read(key: 'accessToken') ?? "";
    final now = DateTime.now();
    final formattedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    setState(() {
      _logsFuture = LogService.getLogs(token: token, date: formattedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 서버 데이터가 없을 때 보여줄 가짜 데이터 리스트
    final List<Log> mockItems = [
      Log(logId: 1, title: '프로젝트 중간점검 회의', time: '2026.04.28 10:15', duration: '15분 29초', type: 'CONFERENCE'),
      Log(logId: 2, title: '보고서 작성 방법 및 마감 기한', time: '2026.04.28 13:28', duration: '10분 16초', type: 'CONFERENCE'),
      Log(logId: 3, title: '내일 오전 회의 준비', time: '2026.04.28 16:47', duration: '8분 3초', type: 'CONFERENCE'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F6),
      body: SafeArea(
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
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _logsFuture,
                  builder: (context, snapshot) {
                    if (_logsFuture == null || snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF4882FD)));
                    }

                    // 서버에서 온 데이터 추출 (에러나 데이터 없음 시 빈 리스트)
                    final List<Log> serverLogs = [];
                    if (snapshot.hasData && snapshot.data?['logs'] != null) {
                      serverLogs.addAll(snapshot.data?['logs']);
                    }

                    // 서버 데이터가 비어있으면 가짜 데이터를 사용
                    final displayLogs = serverLogs.isEmpty ? mockItems : serverLogs;

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
                            itemCount: displayLogs.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEEEEEE), indent: 16, endIndent: 16),
                            itemBuilder: (context, index) {
                              final item = displayLogs[index];
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
    );
  }
}
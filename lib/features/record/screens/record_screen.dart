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

                                // 💡 1. 타이틀 가공: '2026-05-25 업무 분석'에서 앞의 날짜를 떼어내고 순수 제목만 추출
                                String displayTitle = item.title;
                                if (displayTitle.startsWith('202') && displayTitle.contains(' ')) {
                                  // 공백을 기준으로 쪼갠 뒤 날짜를 제외한 나머지 문자열을 제목으로 사용
                                  final parts = displayTitle.split(' ');
                                  if (parts.length > 1) {
                                    displayTitle = parts.sublist(1).join(' '); // '업무 분석' 추출
                                  }
                                }

                                // 💡 2. 날짜 및 시간 포맷팅 가공 (두 번째 사진 스타일: yyyy.MM.dd HH:mm)
                                // 현재 item.time이 "17:55:25.617" 형태로 들어오므로 시:분까지만 잘라냅니다.
                                String formattedTime = item.time;
                                if (formattedTime.contains(':')) {
                                  final timeParts = formattedTime.split(':');
                                  if (timeParts.length >= 2) {
                                    formattedTime = "${timeParts[0]}:${timeParts[1]}"; // "17:55"
                                  }
                                }

                                // 오늘 날짜 구하기 (formattedDate와 맵핑하기 위해 포맷 가공)
                                final now = DateTime.now();
                                final year = now.year;
                                final month = now.month.toString().padLeft(2, '0');
                                final day = now.day.toString().padLeft(2, '0');
                                final todayStr = "$year.$month.$day"; // "2026.05.25"

                                final displayDateTime = "$todayStr $formattedTime"; // "2026.05.25 17:55"

                                return InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => SummaryScreen(
                                        logId: item.logId,
                                        meetingTitle: displayTitle, // 💡 가공된 깔끔한 제목 전달
                                        dateTimeText: displayDateTime, // 💡 가공된 날짜시간 전달
                                        durationText: item.duration,
                                      ),
                                    ));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18), // 패딩 조정으로 여백 확보
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // 📌 가공된 순수 회의 제목 노출
                                        Text(
                                          displayTitle,
                                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            // 📌 두 번째 사진 스타일: 날짜 시간 형식 출력 (2026.05.25 17:55)
                                            Text(
                                              displayDateTime,
                                              style: const TextStyle(fontSize: 15, color: Color(0xFF868686), fontWeight: FontWeight.w400),
                                            ),
                                            const SizedBox(width: 8),
                                            const Text('-', style: TextStyle(color: Color(0xFF868686))),
                                            const SizedBox(width: 8),
                                            // 📌 분석 소요 시간 혹은 상태 노출
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
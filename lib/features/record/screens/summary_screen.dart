import 'package:flutter/material.dart';

import '../../../core/services/storage.dart';
import '../models/log_detail.dart';
import '../services/log_service.dart';

class SummaryScreen extends StatefulWidget {
  final int logId;
  final String meetingTitle;
  final String dateTimeText;
  final String durationText;

  const SummaryScreen({
    super.key,
    required this.logId,
    required this.meetingTitle,
    required this.dateTimeText,
    required this.durationText,
  });

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final _storage = AppStorage.storage;
  Future<Map<String, dynamic>>? _logDetailFuture;
  List<String> userMemos = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final token = await _storage.read(key: 'accessToken') ?? "";
    setState(() {
      _logDetailFuture = LogService.getLogDetail(
        token: token,
        logId: widget.logId,
      );
    });
  }

  void _showMemoSheet(BuildContext context) {
    final TextEditingController memoController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('메모 추가', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              TextField(
                controller: memoController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: '내용을 입력해주세요...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFEBEBEB))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF4882FD), width: 2)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (memoController.text.trim().isNotEmpty) {
                      setState(() { userMemos.add(memoController.text.trim()); });
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4882FD), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: const Text('저장하기', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 공통 섹션 카드 위젯
  Widget _sectionCard({
    required String emoji,
    required String title,
    required List<String> bullets,
    Color? titleColor,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: titleColor ?? Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEBEBEB)),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            child: Column(
              children: bullets.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('· ', style: TextStyle(fontSize: 15, color: Colors.black)),
                    Expanded(
                      child: Text(
                        b,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F6),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _logDetailFuture,
        builder: (context, snapshot) {
          // 데이터 대기 중일 때만 로딩 표시
          if (_logDetailFuture == null || snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF4882FD)));
          }

          LogDetail detail;

          if (snapshot.hasData && snapshot.data?['success'] == true && snapshot.data?['detail'] != null) {
            try {
              // 맵 데이터를 팩토리 생성자에 태워 정상 파싱합니다.
              detail = LogDetail.fromJson(snapshot.data!['detail']);
            } catch (e) {
              debugPrint("❌ LogDetail 파싱 실패 에러: $e");
              detail = _buildFallbackDetail();
            }
          } else {
            detail = _buildFallbackDetail();
          }

          return SafeArea(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Column(
                    children: [
                      Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                              padding: const EdgeInsets.only(left: 10, top: 20),
                              child: IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(Icons.arrow_back_ios_new, size: 25, color: Colors.black)
                              )
                          )
                      ),
                      const SizedBox(height: 10),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(detail.title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black), textAlign: TextAlign.center)
                      ),
                      const SizedBox(height: 12),
                      Text('${detail.date} ${detail.startTime}  -  ${detail.duration}', style: const TextStyle(fontSize: 15, color: Color(0xFF868686))),
                    ],
                  ),
                ),
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFCECECE), width: 1.2))),
                    child: const Center(child: Text('요약', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)))
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                    child: Column(
                      children: [
                        _sectionCard(emoji: '📌', title: '회의에서 이런 이야기가 나왔어요', bullets: detail.summaries),
                        const SizedBox(height: 30),
                        _sectionCard(emoji: '✅', title: '회의에서 정한 내용이에요', bullets: detail.decisions),
                        const SizedBox(height: 30),
                        _sectionCard(emoji: '📝', title: '앞으로 해야 할 일이에요', bullets: detail.todos.map((t) => "[${t.assignee}] ${t.content}").toList()),
                        if (userMemos.isNotEmpty) ...[const SizedBox(height: 30), _sectionCard(emoji: '💡', title: '내가 추가한 메모', titleColor: const Color(0xFF4882FD), bullets: userMemos)],
                        const SizedBox(height: 30),
                        TextButton(onPressed: () => _showMemoSheet(context), child: const Text('메모하기', style: TextStyle(fontSize: 17, color: Color(0xFF4882FD)))),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 💡 데이터가 누락되거나 에러가 났을 때 작동하는 안전한 Fallback 데이터 생성기
  LogDetail _buildFallbackDetail() {
    final dateParts = widget.dateTimeText.split(' ');
    final fallbackDate = dateParts.isNotEmpty ? dateParts[0] : '';
    final fallbackTime = dateParts.length > 1 ? dateParts[1] : '';

    return LogDetail(
      logId: widget.logId,
      title: widget.meetingTitle,
      date: fallbackDate,
      startTime: fallbackTime,
      duration: widget.durationText,
      summaries: ['메인 페이지 및 로그인 UI 완료', '백엔드 API 기본 구조 완성', 'API 인증 로직 관련 지연 사항 논의'],
      decisions: ['이번 주 안으로 API 명세 확정', '디자인 피드백 반영 후 수정'],
      todos: [TodoItem(assignee: '참여자 3', content: 'API 응답 문서 정리')],
    );
  }
}
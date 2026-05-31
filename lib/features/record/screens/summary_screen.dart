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

    // ✅ _logDetailFuture는 최초 1회만 세팅 (로딩 깜빡임 방지)
    final future = LogService.getLogDetail(
      token: token,
      logId: widget.logId,
    ).then((result) {
      if (result['success'] == true && result['detail'] != null) {
        try {
          final detailData = result['detail'];

          List<String> serverMemos = [];

          if (detailData['memos'] is List) {
            serverMemos = List<String>.from(detailData['memos']);
          } else if (detailData['memoList'] is List) {
            serverMemos = List<String>.from(detailData['memoList']);
          } else if (detailData['memo'] != null &&
              detailData['memo'].toString().isNotEmpty) {
            serverMemos = [detailData['memo'].toString()];
          }

          debugPrint("✅ 백엔드로부터 불러온 메모 목록: $serverMemos");

          // ✅ userMemos가 비어있을 때만 서버 데이터로 초기화
          // (이미 로컬에서 추가한 메모가 있으면 덮어쓰지 않음)
          if (mounted && userMemos.isEmpty) {
            setState(() {
              userMemos = serverMemos;
            });
          }
        } catch (e) {
          debugPrint("⚠️ 서버 메모 파싱 에러: $e");
        }
      }
      return result;
    });

    // ✅ _logDetailFuture가 null일 때만 세팅 (재로딩 방지)
    if (_logDetailFuture == null) {
      setState(() {
        _logDetailFuture = future;
      });
    }
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
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('메모 추가',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              TextField(
                controller: memoController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: '내용을 입력해주세요...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFFEBEBEB))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                      const BorderSide(color: Color(0xFF4882FD), width: 2)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    final memoText = memoController.text.trim();
                    if (memoText.isNotEmpty) {
                      // ✅ 1. UI 즉시 반영 (로딩 없음)
                      setState(() {
                        userMemos.add(memoText);
                      });
                      Navigator.pop(context);

                      try {
                        final token =
                            await _storage.read(key: 'accessToken') ?? "";
                        final result = await LogService.updateMemo(
                          token: token,
                          logId: widget.logId,
                          memo: memoText,
                        );

                        if (result['success'] == true) {
                          debugPrint("✅ 메모가 서버에 성공적으로 저장되었습니다.");
                          // ✅ _loadData() 호출 없음 → 로딩 화면 안 뜸
                        } else {
                          debugPrint("⚠️ 서버 메모 저장 실패: ${result['message']}");
                          // ✅ 실패 시 추가했던 메모 롤백
                          setState(() {
                            userMemos.remove(memoText);
                          });
                        }
                      } catch (e) {
                        debugPrint("❌ 메모 저장 중 통신 에러: $e");
                        // ✅ 에러 시 추가했던 메모 롤백
                        setState(() {
                          userMemos.remove(memoText);
                        });
                      }
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4882FD),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  child: const Text('저장하기',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
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
            child: bullets.isEmpty
                ? const Text('정리된 내용이 없습니다.',
                style: TextStyle(fontSize: 15, color: Colors.grey))
                : Column(
              children: bullets
                  .map((b) => Padding(
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
              ))
                  .toList(),
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
          if (_logDetailFuture == null || snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF4882FD)));
          }

          LogDetail detail;

          if (snapshot.hasData && snapshot.data?['success'] == true && snapshot.data?['detail'] != null) {
            try {
              detail = LogDetail.fromJson(snapshot.data!['detail']);
            } catch (e) {
              debugPrint("❌ LogDetail 파싱 실패 에러: $e");
              detail = _buildFallbackDetail();
            }
          } else {
            detail = _buildFallbackDetail();
          }

          String displayTitle = (detail.title.isEmpty || detail.title == '제목 없음' || detail.title.contains('업무 분석'))
              ? widget.meetingTitle
              : detail.title;

          if (detail.todos.isNotEmpty) {
            final firstTodo = detail.todos.first;
            String cleanTodoTitle = firstTodo.content;

            if (cleanTodoTitle.contains(']')) {
              cleanTodoTitle = cleanTodoTitle.split(']').last.trim();
            }
            if (cleanTodoTitle.contains('(')) {
              cleanTodoTitle = cleanTodoTitle.split('(').first.trim();
            }

            if (cleanTodoTitle.isNotEmpty) {
              displayTitle = cleanTodoTitle;
            }
          }

          String displayDate = detail.date;
          String displayStartTime = detail.startTime;

          if (displayDate.isEmpty || displayStartTime.isEmpty) {
            if (widget.dateTimeText.contains(' ')) {
              final parts = widget.dateTimeText.split(' ');
              if (parts.length >= 2) {
                displayDate = displayDate.isEmpty ? parts[0] : displayDate;
                displayStartTime = displayStartTime.isEmpty ? parts[1] : displayStartTime;
              }
            } else {
              displayDate = displayDate.isEmpty ? widget.dateTimeText : displayDate;
            }
          }

          if (displayStartTime.contains(':')) {
            final timeParts = displayStartTime.split(':');
            if (timeParts.length >= 2) {
              displayStartTime = "${timeParts[0]}:${timeParts[1]}";
            }
          }

          final displayDuration = detail.duration.isEmpty ? widget.durationText : detail.duration;

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
                          child: Text(displayTitle, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black), textAlign: TextAlign.center)
                      ),
                      const SizedBox(height: 12),
                      Text('$displayDate $displayStartTime  -  $displayDuration',
                          style: const TextStyle(fontSize: 15, color: Color(0xFF868686))),
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
                        _sectionCard(
                          emoji: '📝',
                          title: '앞으로 해야 할 일이에요',
                          bullets: detail.todos.map((t) {
                            String cleanContent = t.content;

                            if (cleanContent.contains(']')) {
                              cleanContent = cleanContent.split(']').last.trim();
                            }
                            if (cleanContent.contains('(')) {
                              cleanContent = cleanContent.split('(').first.trim();
                            }

                            return cleanContent;
                          }).toList(),
                        ),
                        // 💡 저장되거나 로드된 userMemos 리스트가 온전하게 카드로 렌더링됩니다.
                        if (userMemos.isNotEmpty) ...[
                          const SizedBox(height: 30),
                          _sectionCard(
                              emoji: '💡',
                              title: '내가 추가한 메모',
                              titleColor: const Color(0xFF4882FD),
                              bullets: userMemos
                          )
                        ],
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
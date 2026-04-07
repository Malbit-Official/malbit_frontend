import 'package:flutter/material.dart';

class SummaryScreen extends StatefulWidget { // StatefulWidget으로 변경
  final String meetingTitle;
  final String dateTimeText;
  final String durationText;

  const SummaryScreen({
    super.key,
    required this.meetingTitle,
    required this.dateTimeText,
    required this.durationText,
  });

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  // 사용자가 입력한 메모들을 저장할 리스트 변수
  List<String> userMemos = [];

  // 메모 입력창(BottomSheet)을 띄우는 함수
  void _showMemoSheet(BuildContext context) {
    final TextEditingController memoController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
                const Text(
                  '메모 추가',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: memoController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: '내용을 입력해주세요...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFFEBEBEB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFF4882FD), width: 2),
                    ),
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
                        // 1. 상태 업데이트: 메모 리스트에 추가
                        setState(() {
                          userMemos.add(memoController.text);
                        });
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4882FD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text('저장하기', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 공통 섹션 카드 위젯
  Widget _sectionCard({
    required String emoji,
    required String title,
    required List<String> bullets,
    Color? titleColor, // 제목 색상 커스텀용
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
      body: SafeArea(
        child: Column(
          children: [
            // 상단 헤더 영역
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
                        icon: const Icon(Icons.arrow_back_ios_new, size: 25, color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      widget.meetingTitle,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${widget.dateTimeText}  -  ${widget.durationText}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF868686),
                    ),
                  ),
                ],
              ),
            ),

            // 요약 탭
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFCECECE), width: 1.2),
                ),
              ),
              child: const Center(
                child: Text(
                  '요약',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ),
            ),

            // --- 본문 스크롤 영역 ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                child: Column(
                  children: [
                    _sectionCard(
                      emoji: '📌',
                      title: '회의에서 이런 이야기가 나왔어요',
                      bullets: [
                        '메인 페이지 및 로그인 UI는 거의 완료',
                        '백엔드 API 기본 구조는 완성되었으나, 인증 로직 문제로 일정 일부 지연',
                        'API 응답 형식 미확정으로 프론트엔드 연동 작업이 부분적으로 지연',
                        '대시보드 디자인에서 그래프 표현 방식에 대한 추가 논의 필요',
                      ],
                    ),
                    const SizedBox(height: 30),
                    _sectionCard(
                      emoji: '✅',
                      title: '회의에서 정한 내용이에요',
                      bullets: [
                        '이번 주 안으로 백엔드 API 명세 확정',
                        '대시보드 디자인 수정 및 피드백 반영',
                        '다음 회의에서 실제 API 연동 화면 공유',
                      ],
                    ),
                    const SizedBox(height: 30),
                    _sectionCard(
                      emoji: '📝',
                      title: '앞으로 해야 할 일이에요',
                      bullets: [
                        '참여자 3: API 응답 형식 문서 정리 후 금요일까지 공유',
                        '참여자 2: API 명세 확정 후 연동 작업 진행',
                        '참여자 4: 대시보드 그래프 디자인 수정안 준비',
                      ],
                    ),

                    // 사용자 메모
                    if (userMemos.isNotEmpty) ...[
                      const SizedBox(height: 30),
                      _sectionCard(
                        emoji: '💡',
                        title: '내가 추가한 메모',
                        titleColor: const Color(0xFF4882FD),
                        bullets: userMemos,
                      ),
                    ],

                    const SizedBox(height: 30),

                    // 메모하기 버튼
                    TextButton(
                      onPressed: () => _showMemoSheet(context),
                      child: const Text(
                        '메모하기',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4882FD),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
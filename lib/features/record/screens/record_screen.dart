import 'package:flutter/material.dart';
import 'package:malbit_frontend/features/record/screens/summary_screen.dart';

class RecordScreen extends StatelessWidget {
  const RecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
      id: 'meeting-1',
      title: '프로젝트 중간점검 회의',
      time: '2026.02.06 10:15',
      duration: '15분 29초'
      ),
      (
      id: 'meeting-2',
      title: '보고서 작성 방법 및 마감 기한',
      time: '2026.02.06 13:28',
      duration: '10분 16초'
      ),
      (
      id: 'meeting-3',
      title: '내일 오전 회의 준비',
      time: '2026.02.06 16:47',
      duration: '8분 3초'
      ),
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
                child: Text(
                  '오늘의 업무 기록',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 50),

              // 1. 텍스트 위치 살짝 오른쪽으로 조정
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  '이런 대화들이 있었어요',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // 2. 카드 자체를 가로 중앙 정렬
              Center(
                child: Container(
                  // 카드의 가로 크기를 명시적으로 지정 (화면 너비의 90%)
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    // 카드가 더 돋보이게 그림자 추가 (선택 사항)
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      color: Color(0xFFEEEEEE),
                      indent: 16,
                      endIndent: 16,
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SummaryScreen(
                                meetingTitle: item.title,
                                dateTimeText: item.time,
                                durationText: item.duration,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 15,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 20, // 텍스트 크기 살짝 조정
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    item.time,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF868686),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    '-',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF868686),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    item.duration,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF868686),
                                    ),
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
            ],
          ),
        ),
      ),
    );
  }
}
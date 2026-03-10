import 'package:flutter/material.dart';

class JobEnvironmentScreen extends StatefulWidget {
  const JobEnvironmentScreen({super.key});

  @override
  State<JobEnvironmentScreen> createState() => _JobEnvironmentScreenState();
}

class _JobEnvironmentScreenState extends State<JobEnvironmentScreen> {

  String selectedJob = "사무직";

  final List<String> jobList = [
    "사무직",
    "영업 / 고객상담",
    "의료 / 간호",
    "교육 / 학교",
    "서비스 / 매장",
    "기타"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),

      appBar: AppBar(
        title: const Text("직무 환경 설정"),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.settings, color: Colors.black),
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "현재 직무 : 사무직",
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            const Text(
              "직무 분야를 선택해 주세요.",
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 16),

            /// 선택 카드
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),

              child: Column(
                children: [

                  ...jobList.map((job) {

                    return Column(
                      children: [

                        RadioListTile<String>(
                          title: Text(job),
                          value: job,
                          groupValue: selectedJob,

                          activeColor: const Color(0xFF4F7DF3),

                          onChanged: (value) {
                            setState(() {
                              selectedJob = value!;
                            });
                          },
                        ),

                        if (job != jobList.last)
                          const Divider(height: 1)

                      ],
                    );

                  }).toList(),

                  const SizedBox(height: 10),

                  /// 버튼 영역
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [

                        /// 취소
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(120, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("취소"),
                        ),

                        /// 확인
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            const Color(0xFFFFFFFF),
                            minimumSize: const Size(120, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {

                            /// TODO
                            /// 직무 저장 API 연결

                            Navigator.pop(context);
                          },
                          child: const Text("확인"),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:malbit_frontend/core/services/storage.dart';

class JobEnvironmentScreen extends StatefulWidget {

  final String currentJob;

  const JobEnvironmentScreen({
    super.key,
    required this.currentJob,
  });

  @override
  State<JobEnvironmentScreen> createState() => _JobEnvironmentScreenState();
}

class _JobEnvironmentScreenState extends State<JobEnvironmentScreen> {

  late String selectedJob;

  final List<String> jobList = [
    "사무직",
    "영업 / 고객상담",
    "의료 / 간호",
    "교육 / 학교",
    "서비스 / 매장",
    "기타"
  ];

  @override
  void initState() {
    super.initState();

    /// Profile에서 전달받은 현재 직무
    selectedJob = widget.currentJob;
  }

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

            /// 현재 직무 표시
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF4882FD),
                  width: 1.5,
                ),
              ),

              child: Row(
                children: [

                  const Icon(
                    Icons.work_outline,
                    color: Color(0xFF4882FD),
                  ),

                  const SizedBox(width: 10),

                  const Text(
                    "현재 직무",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Text(
                    selectedJob,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4882FD),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "직무 분야를 선택해 주세요.",
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 16),

            /// 직무 선택 카드
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

                          activeColor: const Color(0xFF4882FD),

                          onChanged: (value) {
                            setState(() {
                              selectedJob = value!;
                            });
                          },
                        ),

                        if (job != jobList.last)
                          const Divider(height: 1),

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

                        /// 취소 버튼
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

                        /// 확인 버튼
                        ElevatedButton(

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFFFFF),

                            minimumSize: const Size(120, 45),

                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(10),
                            ),
                          ),

                          onPressed: () {

                            /// 선택된 직무를 ProfileScreen으로 전달
                            Navigator.pop(context, selectedJob);

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
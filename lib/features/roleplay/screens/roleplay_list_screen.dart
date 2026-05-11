import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:malbit_frontend/core/services/storage.dart';

class RoleplayListScreen extends StatefulWidget {
  const RoleplayListScreen({super.key});

  @override
  State<RoleplayListScreen> createState() => _RoleplayListScreenState();
}

class _RoleplayListScreenState extends State<RoleplayListScreen> {
  String? selectedSituation;
  final TextEditingController _customController = TextEditingController();
  bool isLoading = false;
  List<String> recommendations = [];
  String situationSummary = "";

  final List<Map<String, String>> situations = [
    {'icon': '📦', 'label': '물건 받기/전달'},
    {'icon': '☎️', 'label': '전화 응대'},
    {'icon': '🤝', 'label': '첫 인사/소개'},
    {'icon': '💬', 'label': '회의 중 발언'},
    {'icon': '🛒', 'label': '주문/결제'},
    {'icon': '😰', 'label': '실수 사과'},
  ];

  Future<void> _getRecommendations(String situation) async {
    setState(() {
      isLoading = true;
      recommendations = [];
      situationSummary = situation;
    });

    try {
      final token = await AppStorage.storage.read(key: 'accessToken');

      final response = await http.post(
        Uri.parse('http://13.125.107.37:8080/api/roleplay/recommend'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'situation': situation}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          recommendations = List<String>.from(data['data']['recommendations']);
        });
      }
    } catch (e) {
      print('추천 API 오류: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Column(
                children: [
                  Text(
                    "상황별 발화 추천받기",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "지금 상황을 선택하거나 입력하면\nAI가 딱 맞는 말을 추천해드려요.",
                    style: TextStyle(fontSize: 17, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 상황 선택
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('지금 어떤 상황인가요?',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.4,
                    children: situations.map((s) {
                      final isSelected = selectedSituation == s['label'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedSituation = s['label'];
                            _customController.clear();
                          });
                          _getRecommendations(s['label']!);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF4882FD)
                                : const Color(0xFFF0F4FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF4882FD)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(s['icon']!, style: const TextStyle(fontSize: 20)),
                              const SizedBox(height: 4),
                              Text(
                                s['label']!,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected ? Colors.white : Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 직접 입력
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('직접 입력하기',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customController,
                          decoration: InputDecoration(
                            hintText: '예) 손님이 환불을 요청함',
                            hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              setState(() => selectedSituation = null);
                              _getRecommendations(value.trim());
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          final text = _customController.text.trim();
                          if (text.isNotEmpty) {
                            setState(() => selectedSituation = null);
                            _getRecommendations(text);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4882FD),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        child: const Text('추천받기'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 결과
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: Color(0xFF4882FD)),
                      SizedBox(height: 16),
                      Text('AI가 추천 발화를 생성 중이에요...',
                          style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
              )
            else if (recommendations.isNotEmpty)
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('💬 ',  style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: Text(
                            '"$situationSummary" 상황 추천 발화',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ...recommendations.map((rec) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '👉 $rec',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    )),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4882FD),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          // OrderScreen 연결
                        },
                        child: const Text(
                          '🎤 직접 말해보기',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
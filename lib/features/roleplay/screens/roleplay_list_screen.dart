import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:malbit_frontend/core/services/storage.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

// 상황별 발화 추천 화면: 상황 선택, 음성 입력, 직접 입력으로 AI 발화 추천 조회
class RoleplayListScreen extends StatefulWidget {
  const RoleplayListScreen({super.key});

  @override
  State<RoleplayListScreen> createState() => _RoleplayListScreenState();
}

class _RoleplayListScreenState extends State<RoleplayListScreen> {
  String? selectedSituation;
  final TextEditingController _customController = TextEditingController();
  bool isLoading = false;
  bool isListening = false;
  bool isAnalyzing = false;
  List<Map<String, String>> recommendations = [];
  String situationSummary = "";
  String recognizedText = "";

  late stt.SpeechToText _speech;
  Timer? _silenceTimer;

  final List<Map<String, String>> situations = [
    {'icon': '📦', 'label': '물건 받기/전달'},
    {'icon': '☎️', 'label': '전화 응대'},
    {'icon': '🤝', 'label': '첫 인사/소개'},
    {'icon': '💬', 'label': '회의 중 발언'},
    {'icon': '🛒', 'label': '주문/결제'},
    {'icon': '😰', 'label': '실수 사과'},
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _startAutoListen() async {
    final available = await _speech.initialize(
      onError: (error) {
        debugPrint('🎙 STT 에러: $error');
        if (!mounted) return;
        setState(() { isListening = false; isAnalyzing = false; });
      },
      onStatus: (status) {
        debugPrint('🎙 STT 상태: $status'); // ← 상태 변화 추적
        if (!mounted) return;
        if (status == 'done' || status == 'notListening') {
          debugPrint('🎙 녹음 종료 - 인식된 텍스트: "$recognizedText"');
          if (recognizedText.trim().isNotEmpty && !isLoading) {
            setState(() => isListening = false);
            _getRecommendations(null, recognizedText.trim());
          } else {
            debugPrint('🎙 텍스트 없음 - 추천 안 함');
            setState(() => isListening = false);
          }
        }
      },
    );

    debugPrint('🎙 STT 사용 가능: $available'); // ← 초기화 성공 여부

    if (!available) {
      debugPrint('🎙 STT 초기화 실패!');
      return;
    }

    setState(() { isListening = true; recognizedText = ""; });

    _speech.listen(
      onResult: (result) {
        debugPrint('🎙 인식 중: "${result.recognizedWords}" / final: ${result.finalResult}');
        setState(() { recognizedText = result.recognizedWords; });

        if (result.finalResult && recognizedText.trim().isNotEmpty) {
          _silenceTimer?.cancel();
          _silenceTimer = Timer(const Duration(seconds: 1), () {
            if (!isLoading && mounted) {
              _speech.stop();
              setState(() => isListening = false);
              _getRecommendations(null, recognizedText.trim());
            }
          });
        }
      },
      localeId: 'ko_KR',
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
    );
  }

  void _stopListening() {
    _silenceTimer?.cancel();
    _speech.stop();
    setState(() => isListening = false);
  }

  /// category: 상황 버튼 선택 시, userInput: 녹음/직접입력 시
  Future<void> _getRecommendations(String? category, String? userInput) async {
    if (category == null && (userInput == null || userInput.isEmpty)) return;

    setState(() {
      isLoading = true;
      isAnalyzing = userInput != null && category == null;
      recommendations = [];
      situationSummary = category ?? userInput ?? "";
    });

    try {
      final token = await AppStorage.storage.read(key: 'accessToken');
      debugPrint('🔑 토큰: $token');

      final body = {
        'category': category ?? '',
        'user_input': userInput ?? '',
      };

      debugPrint('📤 요청: $body'); // 요청 확인

      final response = await http.post(
        Uri.parse('http://3.37.239.105:8080/api/recommendations/suggest'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      debugPrint('📥 상태코드: ${response.statusCode}');
      debugPrint('📥 응답: ${utf8.decode(response.bodyBytes)}'); // 실제 응답 확인

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        // 응답 구조를 단계적으로 파싱
        List<Map<String, String>> parsed = [];

        try {
          // 케이스 1: data.data.data.recommendations
          final rawList = data['data']['data']['recommendations'] as List;
          parsed = rawList.map((item) => {
            'speech': item['speech']?.toString() ?? '',
            'tip': item['tip']?.toString() ?? '',
          }).toList();
        } catch (_) {
          try {
            // 케이스 2: data.data.recommendations
            final rawList = data['data']['recommendations'] as List;
            parsed = rawList.map((item) {
              if (item is String) {
                return {'speech': item, 'tip': ''};
              }
              return {
                'speech': item['speech']?.toString() ?? item.toString(),
                'tip': item['tip']?.toString() ?? '',
              };
            }).toList();
          } catch (e) {
            debugPrint('파싱 오류: $e');
          }
        }

        setState(() {
          recommendations = parsed;
        });

        debugPrint('✅ 추천 ${parsed.length}개 파싱 완료');
      } else {
        // 실패 시 사용자에게 알림
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('오류가 발생했어요 (${response.statusCode})')),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ API 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('네트워크 오류가 발생했어요')),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
        isAnalyzing = false;
      });
    }
  }

  @override
  void dispose() {
    _silenceTimer?.cancel();
    _speech.stop();
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

            // 🎙 자동 녹음 상태 카드
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🎙 상황을 말해보세요',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      if (isListening)
                        GestureDetector(
                          onTap: _stopListening,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.stop_circle,
                                    color: Colors.red, size: 16),
                                SizedBox(width: 4),
                                Text('중지',
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 13)),
                              ],
                            ),
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: _startAutoListen,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F0FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.mic,
                                    color: Color(0xFF4882FD), size: 16),
                                SizedBox(width: 4),
                                Text(recognizedText.isEmpty ? '녹음 시작' : '다시 녹음',
                                    style: TextStyle(
                                        color: Color(0xFF4882FD),
                                        fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isListening
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isListening
                            ? Colors.green.shade300
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (isListening)
                          const _PulsingDot()
                        else
                          const Icon(Icons.mic_off,
                              color: Colors.black26, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isListening
                                ? (recognizedText.isEmpty
                                ? '말씀해 주세요...'
                                : recognizedText)
                                : (recognizedText.isEmpty
                                ? '녹음이 중지되었어요.'
                                : recognizedText),
                            style: TextStyle(
                              fontSize: 14,
                              color: isListening
                                  ? Colors.black87
                                  : Colors.black45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isListening && recognizedText.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '말이 멈추면 3초 후 자동으로 분석해요',
                        style: TextStyle(
                            fontSize: 12, color: Colors.green.shade600),
                      ),
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
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
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
                          _stopListening();
                          setState(() {
                            selectedSituation = s['label'];
                            _customController.clear();
                          });
                          _getRecommendations(s['label'], null);
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
                              Text(s['icon']!,
                                  style: const TextStyle(fontSize: 20)),
                              const SizedBox(height: 4),
                              Text(
                                s['label']!,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
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
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customController,
                          decoration: InputDecoration(
                            hintText: '예) 손님이 환불을 요청함',
                            hintStyle: const TextStyle(
                                color: Colors.black38, fontSize: 14),
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
                              _stopListening();
                              setState(() => selectedSituation = null);
                              _getRecommendations(null, value.trim());
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          final text = _customController.text.trim();
                          debugPrint('버튼 눌림, 텍스트: $text'); // 버튼 클릭 확인
                          if (text.isNotEmpty) {
                            _stopListening();
                            setState(() => selectedSituation = null);
                            _getRecommendations(null, text);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('상황을 입력해주세요')),
                            );
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
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(
                          color: Color(0xFF4882FD)),
                      const SizedBox(height: 16),
                      Text(
                        isAnalyzing
                            ? 'AI가 상황을 분석 중이에요...'
                            : 'AI가 추천 발화를 생성 중이에요...',
                        style: const TextStyle(color: Colors.black54),
                      ),
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
                        const Text('💬 ', style: TextStyle(fontSize: 16)),
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
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '👉 ${rec['speech']}',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                            if (rec['tip']!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                '💡 ${rec['tip']}',
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )),

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

// 녹음 중 애니메이션 점
class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
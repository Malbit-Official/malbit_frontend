import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  int currentIndex = 0;
  bool showHint = false;
  bool isRecording = false;
  String recognizedText = "";
  List<double> scenarioScores = [];

  final stt.SpeechToText _speech = stt.SpeechToText();

  final List<Scenario> scenarios = [
    Scenario(
      situation: "매장에서 전화를 받는 상황",
      customerLine: "여기 ○○매장 맞나요?",
      hint: "네, ○○매장입니다. 무엇을 도와드릴까요?",
      guide: "전화 인사를 정중하게 해보세요!",
    ),
    Scenario(
      situation: "손님이 영업시간을 물어보는 상황",
      customerLine: "오늘 몇 시까지 영업하나요?",
      hint: "오늘은 오후 9시까지 영업합니다.",
      guide: "영업시간을 정확하게 안내해보세요!",
    ),
    Scenario(
      situation: "상품 재고를 문의하는 상황",
      customerLine: "이 가방 재고 있나요?",
      hint: "네, 현재 재고 있습니다.",
      guide: "재고 여부를 친절하게 안내해보세요!",
    ),
    Scenario(
      situation: "상품 위치를 물어보는 상황",
      customerLine: "매장 위치가 어디인가요?",
      hint: "○○역 2번 출구에서 도보 5분 거리입니다.",
      guide: "위치를 쉽게 이해할 수 있게 설명해보세요!",
    ),
    Scenario(
      situation: "예약 또는 방문 의사를 밝히는 상황",
      customerLine: "지금 방문해도 될까요?",
      hint: "네, 방문 가능합니다.",
      guide: "방문 가능 여부를 안내해보세요!",
    ),
    Scenario(
      situation: "통화를 마무리하는 상황",
      customerLine: "네, 감사합니다.",
      hint: "네, 감사합니다. 좋은 하루 되세요!",
      guide: "정중하게 통화를 마무리해보세요!",
    ),
  ];

  Scenario get current => scenarios[currentIndex];

  // 유사도 계산 (F1 Score)
  double _similarity(String input, String hint) {
    if (input.trim().isEmpty) return 0.0;

    String clean(String s) => s
        .replaceAll(RegExp(r'[^\uAC00-\uD7A3\u1100-\u11FF\u3130-\u318F\s\w]'), '')
        .trim();

    final inputWords = clean(input)
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toSet();

    final hintWords = clean(hint)
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toSet();

    if (hintWords.isEmpty || inputWords.isEmpty) return 0.0;

    final common = inputWords.intersection(hintWords);
    final recall = common.length / hintWords.length;
    final precision = common.length / inputWords.length;

    if (recall + precision == 0) return 0.0;
    return 2 * recall * precision / (recall + precision);
  }

  // 🎤 녹음 시작
  Future<void> onSpeak() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print("상태: $status");
        if (status == 'done' || status == 'notListening') {
          if (isRecording) {
            double score = _similarity(recognizedText, current.hint);
            scenarioScores.add(score);
            setState(() => isRecording = false);
            Future.delayed(const Duration(milliseconds: 500), () {
              nextStep();
            });
          }
        }
      },
      onError: (error) {
        print("에러: $error");
        setState(() => isRecording = false);
      },
    );

    if (available) {
      setState(() {
        isRecording = true;
        recognizedText = "";
      });

      await _speech.listen(
        localeId: 'ko_KR',
        onResult: (result) {
          print("인식됨: ${result.recognizedWords}");
          if (mounted) {
            setState(() {
              recognizedText = result.recognizedWords;
            });
          }
        },
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 5),
        cancelOnError: false,
      );
    }
  }

  void nextStep() {
    if (currentIndex < scenarios.length - 1) {
      setState(() {
        currentIndex++;
        showHint = false;
        recognizedText = "";
      });
    } else {
      _showFinishDialog();
    }
  }

  void _showFinishDialog() {
    double avgScore = scenarioScores.isEmpty
        ? 0
        : scenarioScores.reduce((a, b) => a + b) / scenarioScores.length;

    String emoji;
    String title;
    List<String> feedbacks;

    if (avgScore >= 0.7) {
      emoji = "🎉";
      title = "완벽해요!";
      feedbacks = [
        "✔ 전화 응대 매우 자연스러움",
        "✔ 핵심 표현을 정확히 사용했어요",
        "✔ 실전에서도 충분히 활용 가능해요",
      ];
    } else if (avgScore >= 0.4) {
      emoji = "👍";
      title = "잘 하고 있어요!";
      feedbacks = [
        "✔ 기본 응대는 잘 됐어요",
        "🔺 일부 표현을 더 다듬어보세요",
        "💡 힌트 문장을 참고해 다시 연습해봐요",
      ];
    } else {
      emoji = "🌱";
      title = "조금 더 연습해봐요!";
      feedbacks = [
        "💡 힌트 문장을 먼저 읽어보세요",
        "⭐️ 핵심 단어를 포함해서 말해봐요",
        "🔄 다시 연습하면 금방 늘 거예요",
      ];
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "$emoji $title",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "정확도 ${(avgScore * 100).toStringAsFixed(0)}%",
                  style: TextStyle(
                    fontSize: 16,
                    color: avgScore >= 0.7
                        ? Colors.green
                        : avgScore >= 0.4
                        ? Colors.orange
                        : Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: feedbacks
                      .map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(f,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500)),
                  ))
                      .toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        currentIndex = 0;
                        showHint = false;
                        recognizedText = "";
                        scenarioScores = [];
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B8DEF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("다시 연습하기",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE0E0E0),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("다음 연습으로",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: SingleChildScrollView(
            key: ValueKey(currentIndex),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6E8F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: const [
                      Text("전화 받기 📞",
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                      SizedBox(height: 6),
                      Text("손님의 문의를 전화로 정확하고 친절하게 응대해보세요.",
                          style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                _situationBox(),
                const SizedBox(height: 6),
                _character(),
                const SizedBox(height: 16),
                Text("\" ${current.guide} \"", style: const TextStyle(fontSize: 17)),
                const SizedBox(height: 12),
                _speakButton(),
                const SizedBox(height: 16),
                _hintBox(),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("뒤로 가기",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF5B8DEF)),
                      foregroundColor: const Color(0xFF5B8DEF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _situationBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.push_pin, size: 16, color: Colors.red),
              const SizedBox(width: 6),
              const Text("현재 상황",
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFFE6EEF7),
                    borderRadius: BorderRadius.circular(8)),
                child: const Text("# 전화 응대", style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(current.situation,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _character() {
    return Stack(
      children: [
        Image.asset('assets/images/call_girl.jpg',
            width: double.infinity, height: 220, fit: BoxFit.cover),
        Positioned(
          right: 10,
          top: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
            decoration: BoxDecoration(
                color: const Color(0xFFFFE8A3),
                borderRadius: BorderRadius.circular(16)),
            child: Text(current.customerLine,
                style: const TextStyle(fontSize: 18, height: 1.4)),
          ),
        ),
      ],
    );
  }

  Widget _speakButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: isRecording
          ? Column(
        children: [
          GestureDetector(
            onTap: () {
              _speech.stop();
              double score = _similarity(recognizedText, current.hint);
              scenarioScores.add(score);
              setState(() => isRecording = false);
              Future.delayed(const Duration(milliseconds: 300), () {
                nextStep();
              });
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                  color: Color(0xFFE53935), shape: BoxShape.circle),
              child: const Icon(Icons.mic, color: Colors.white, size: 36),
            ),
          ),
          const SizedBox(height: 10),
          const Text("말하는 중...",
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 60),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF5B8DEF)),
            ),
            child: Text(
              recognizedText.isEmpty ? "말해보세요..." : recognizedText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: recognizedText.isEmpty ? Colors.grey : Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text("버튼을 누르면 바로 다음으로 넘어가요",
              style: TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      )
          : ElevatedButton.icon(
        onPressed: onSpeak,
        icon: const Icon(Icons.mic),
        label: const Text("직접 말해보기",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5B8DEF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 17),
        ),
      ),
    );
  }

  Widget _hintBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      constraints: const BoxConstraints(minHeight: 80),
      decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => setState(() => showHint = !showHint),
            child: Row(
              children: [
                const Icon(Icons.lightbulb, size: 20, color: Colors.orange),
                const SizedBox(width: 8),
                const Text("힌트 보기",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const Spacer(),
                Icon(showHint ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
              ],
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState:
            showHint ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox(),
            secondChild: Column(
              children: [
                const SizedBox(height: 16),
                Text(current.hint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Scenario {
  final String situation;
  final String customerLine;
  final String hint;
  final String guide;

  Scenario({
    required this.situation,
    required this.customerLine,
    required this.hint,
    required this.guide,
  });
}
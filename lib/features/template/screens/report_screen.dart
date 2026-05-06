import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../core/services/training_api.dart';

class ReportScreen extends StatefulWidget {
  final int categoryId;
  const ReportScreen({super.key, required this.categoryId});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int currentIndex = 0;
  bool showHint = false;
  bool isRecording = false;
  bool isLoading = true;
  bool _isProcessing = false;
  String recognizedText = "";
  List<double> scenarioScores = [];
  int? sessionId;

  final stt.SpeechToText _speech = stt.SpeechToText();

  final List<Map<String, String>> scenarios = [
    {
      'situation': "상사에게 오늘 업무를 보고하는 상황",
      'customerLine': "오늘 진행 상황 어떻게 됐나요?",
      'hint': "오늘은 데이터 정리 작업을 완료했습니다.",
      'guide': "업무 진행 상황을 간단하고 명확하게 보고해보세요!",
    },
    {
      'situation': "업무 진행 중 문제를 보고하는 상황",
      'customerLine': "문제는 없었나요?",
      'hint': "데이터 오류가 있었지만 수정 완료했습니다.",
      'guide': "문제 상황과 해결 과정을 함께 설명해보세요!",
    },
    {
      'situation': "업무 완료 보고 상황",
      'customerLine': "업무 다 끝났나요?",
      'hint': "네, 요청하신 작업 모두 완료했습니다.",
      'guide': "업무 완료 여부를 정확하게 전달해보세요!",
    },
    {
      'situation': "추가 업무를 요청받는 상황",
      'customerLine': "이 작업도 추가로 가능할까요?",
      'hint': "네, 일정 확인 후 진행하겠습니다.",
      'guide': "가능 여부를 정중하게 답변해보세요!",
    },
    {
      'situation': "업무 일정 보고 상황",
      'customerLine': "언제까지 가능할까요?",
      'hint': "내일까지 완료 예정입니다.",
      'guide': "업무 일정을 명확하게 전달해보세요!",
    },
    {
      'situation': "업무 결과를 설명하는 상황",
      'customerLine': "결과가 어떻게 나왔나요?",
      'hint': "예상보다 좋은 결과가 나왔습니다.",
      'guide': "결과를 간단하게 요약해서 설명해보세요!",
    },
  ];

  Map<String, String> get current => scenarios[currentIndex];

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  Future<void> _startSession() async {
    try {
      final id = await TrainingApi.startSession(widget.categoryId);
      setState(() {
        sessionId = id;
        isLoading = false;
      });
    } catch (e) {
      print('startSession 에러: $e');
      setState(() => isLoading = false);
    }
  }

  // 유사도 계산 (F1 Score)
  double _similarity(String input, String hint) {
    if (input
        .trim()
        .isEmpty) return 0.0;
    String clean(String s) =>
        s
            .replaceAll(
            RegExp(
                r'[^\uAC00-\uD7A3\u1100-\u11FF\u3130-\u318F\s\w]'),
            '')
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

  Future<void> onSpeak() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print('=== STT 상태: $status, isRecording: $isRecording ===');
        if ((status == 'done' || status == 'notListening') && isRecording) {
          double score = _similarity(recognizedText, current['hint']!);
          scenarioScores.add(score);
          setState(() => isRecording = false);
          Future.delayed(const Duration(milliseconds: 500), _nextStep);
        }
      },
      onError: (error) {
        print('STT 에러: $error');
        setState(() => isRecording = false);
      },
    );

    if (available) {
      setState(() {
        isRecording = true;
        recognizedText = "";
        _isProcessing = false;
      });
      await _speech.listen(
        localeId: 'ko_KR',
        onResult: (result) {
          if (mounted) setState(() => recognizedText = result.recognizedWords);
        },
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 5),
        cancelOnError: false,
      );
    }
  }

  void _nextStep() {
    if (_isProcessing) {
      print('중복 호출 방지');
      return;
    }
    _isProcessing = true;

    print('=== NEXT STEP ===');
    print('currentIndex: $currentIndex');
    print('scenarios.length: ${scenarios.length}');

    if (currentIndex < scenarios.length - 1) {
      print('다음 단계로 이동');
      setState(() {
        currentIndex++;
        showHint = false;
        recognizedText = "";
        _isProcessing = false;
      });
    } else {
      print('마지막 단계 → finish 호출');
      _finishSession();
    }
  }

  Future<void> _finishSession() async {
    print('=== FINISH 호출 ===');
    print('sessionId: $sessionId');

    if (sessionId == null) {
      print('sessionId null → 로컬 결과로 다이얼로그');
      _showFinishDialogLocal();
      return;
    }

    try {
      final res = await TrainingApi.finishSession(sessionId!);
      print('=== FINISH 응답 ===');
      print('body: $res');

      final data = res['data'];
      _showFinishDialog(
        totalScore: data['totalScore'] ?? 0,
        averageAccuracy: data['averageAccuracy'] ?? 0,
        totalTime: data['totalTime'] ?? '00:00',
        evaluation: data['evaluation'] ?? '',
      );
    } catch (e) {
      print('=== FINISH 에러: $e ===');
      _showFinishDialogLocal();
    }
  }

  void _showFinishDialogLocal() {
    double avg = scenarioScores.isEmpty
        ? 0
        : scenarioScores.reduce((a, b) => a + b) / scenarioScores.length;
    _showFinishDialog(
      totalScore: (avg * 100).toInt(),
      averageAccuracy: (avg * 100).toInt(),
      totalTime: '00:00',
      evaluation: '',
    );
  }

  void _showFinishDialog({
    required int totalScore,
    required int averageAccuracy,
    required String totalTime,
    required String evaluation,
  }) {
    String emoji = averageAccuracy >= 80 ? '🎉' : averageAccuracy >= 50 ? '👍' : '🌱';
    String title = averageAccuracy >= 80 ? '연습 완료!' : averageAccuracy >= 50 ? '잘 하고 있어요!' : '조금 더 연습해봐요!';

    List<String> feedbacks = averageAccuracy >= 80
        ? ['✔ 주문 응대 성공', '✔ 옵션 확인 자연스러움', '✔ 결제 안내 적절함']
        : averageAccuracy >= 50
        ? ['✔ 기본 응대는 잘 됐어요', '🔺 일부 표현을 더 다듬어보세요', '💡 힌트 문장을 참고해보세요']
        : ['💡 힌트 문장을 먼저 읽어보세요', '🔺 핵심 단어를 포함해서 말해봐요', '🔄 다시 연습하면 금방 늘 거예요'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 제목
              Text(
                '$emoji $title',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // 정확도
              Text(
                '정확도 $averageAccuracy%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: averageAccuracy >= 80
                      ? Colors.green
                      : averageAccuracy >= 50
                      ? Colors.orange
                      : Colors.redAccent,
                ),
              ),
              const SizedBox(height: 16),

              // 피드백 리스트
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: feedbacks
                    .map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    f,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ))
                    .toList(),
              ),
              const SizedBox(height: 20),

              // 다시 연습하기 버튼
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
                      _isProcessing = false;
                      isLoading = true;
                    });
                    _startSession();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B8DEF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('다시 연습하기',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),

              // 다음 연습으로 버튼
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
                  child: const Text('다음 연습으로',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: SingleChildScrollView(
            key: ValueKey(currentIndex),
            child: Column(
              children: [
                _header('업무 보고하기 📑', '상사에게 업무 내용을 정확하고 간결하게 보고해보세요.'),
                _situationBox('# 업무 보고'),
                const SizedBox(height: 6),
                _character('assets/images/report_girl.jpg'),
                const SizedBox(height: 16),
                Text('" ${current['guide']!} "',
                    style: const TextStyle(fontSize: 17)),
                const SizedBox(height: 4),
                Text('${currentIndex + 1} / ${scenarios.length} 단계',
                    style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 12),
                _speakButton(),
                const SizedBox(height: 16),
                _hintBox(),
                const SizedBox(height: 20),
                _backButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _header(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      decoration: BoxDecoration(
        color: const Color(0xFFD6E8F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 25, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _situationBox(String tag) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.push_pin, size: 16, color: Colors.red),
              const SizedBox(width: 6),
              const Text('현재 상황',
                  style: TextStyle(
                      fontWeight: FontWeight.normal, fontSize: 18)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFFE6EEF7),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(tag,
                    style: const TextStyle(fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(current['situation']!,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _character(String imagePath) {
    return Stack(
      children: [
        Image.asset(imagePath,
            width: double.infinity, height: 220, fit: BoxFit.cover),
        Positioned(
          right: 10,
          top: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 25),
            decoration: BoxDecoration(
                color: const Color(0xFFFFE8A3),
                borderRadius: BorderRadius.circular(16)),
            child: Text(current['customerLine']!,
                style:
                const TextStyle(fontSize: 18, height: 1.4)),
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
            onTap: () async {
              await _speech.stop();
              if (!isRecording) return;
              double score =
              _similarity(recognizedText, current['hint']!);
              scenarioScores.add(score);
              setState(() => isRecording = false);
              Future.delayed(
                  const Duration(milliseconds: 300), _nextStep);
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                  color: Color(0xFFE53935),
                  shape: BoxShape.circle),
              child: const Icon(Icons.mic,
                  color: Colors.white, size: 36),
            ),
          ),
          const SizedBox(height: 10),
          const Text('말하는 중...',
              style: TextStyle(
                  fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 8),
          Container(
            margin:
            const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            constraints:
            const BoxConstraints(minHeight: 60),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFF5B8DEF)),
            ),
            child: Text(
              recognizedText.isEmpty
                  ? '말해보세요...'
                  : recognizedText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: recognizedText.isEmpty
                    ? Colors.grey
                    : Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text('버튼을 누르면 바로 다음으로 넘어가요',
              style: TextStyle(
                  fontSize: 13, color: Colors.grey)),
        ],
      )
          : ElevatedButton.icon(
        onPressed: onSpeak,
        icon: const Icon(Icons.mic),
        label: const Text('직접 말해보기',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5B8DEF),
          foregroundColor: Colors.white,
          padding:
          const EdgeInsets.symmetric(vertical: 17),
        ),
      ),
    );
  }

  Widget _hintBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 20),
      constraints: const BoxConstraints(minHeight: 80),
      decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          GestureDetector(
            onTap: () =>
                setState(() => showHint = !showHint),
            child: Row(
              children: [
                const Icon(Icons.lightbulb,
                    size: 20, color: Colors.orange),
                const SizedBox(width: 8),
                const Text('힌트 보기',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                const Spacer(),
                Icon(showHint
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down),
              ],
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: showHint
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                current['hint']!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _backButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back),
        label: const Text('뒤로 가기',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: Color(0xFF5B8DEF)),
          foregroundColor: const Color(0xFF5B8DEF),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
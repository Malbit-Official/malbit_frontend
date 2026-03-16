import 'package:flutter/material.dart';

class VoiceRegisterScreen extends StatefulWidget {
  const VoiceRegisterScreen({super.key});

  @override
  State<VoiceRegisterScreen> createState() => _VoiceRegisterScreenState();
}

class _VoiceRegisterScreenState extends State<VoiceRegisterScreen> {

  bool isRecording = false;
  int currentIndex = 0;

  final List<String> sentences = [
    "나는 오늘 기차를 타고 광주에 갑니다.",
    "달콤한 빵과 따뜻한 차를 함께 마셨습니다.",
    "읽고 쓰는 연습을 꾸준히 했습니다.",
    "국물이 맛있어서 밥을 많이 먹었습니다.",
    "서울에서 부산까지 KTX를 탔습니다.",
    "저는 또박또박 정확하게 말하려고 노력하고 있습니다.",
  ];

  void toggleRecording() {
    setState(() {
      isRecording = !isRecording;
    });
  }

  void nextSentence() {

    if (currentIndex < sentences.length - 1) {
      setState(() {
        currentIndex++;
        isRecording = false;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),

      appBar: AppBar(
        title: const Text("음성 재등록"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            const SizedBox(height: 10),

            const Text(
              "준비된 문장을 또박또박 따라 읽어 녹음하고\n사용자의 음성 프로필을 AI에게 학습시켜 보세요.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "문장 ${currentIndex + 1} / ${sentences.length}",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "아래 문장을 읽어 주세요",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            /// 문장 카드
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),

              child: Text(
                sentences[currentIndex],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 40),

            /// 녹음 버튼
            GestureDetector(
              onTap: toggleRecording,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: isRecording
                      ? Colors.red
                      : const Color(0xFF4882FD),
                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.mic,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              isRecording ? "녹음 중..." : "녹음 시작",
              style: const TextStyle(fontSize: 18),
            ),

            const Spacer(),

            /// 다음 문장 / 완료 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4882FD),
                  foregroundColor: Colors.white, // 글자색
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),

                onPressed: nextSentence,

                child: Text(
                  currentIndex == sentences.length - 1
                      ? "등록 완료"
                      : "다음 문장",
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
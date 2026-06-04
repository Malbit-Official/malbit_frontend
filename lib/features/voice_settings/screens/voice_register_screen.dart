import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:malbit_frontend/core/services/storage.dart';
import 'dart:io';

class VoiceRegisterScreen extends StatefulWidget {
  const VoiceRegisterScreen({super.key});

  @override
  State<VoiceRegisterScreen> createState() => _VoiceRegisterScreenState();
}

class _VoiceRegisterScreenState extends State<VoiceRegisterScreen> {
  bool isRecording = false;
  int currentIndex = 0;
  final AudioRecorder _recorder = AudioRecorder();
  final List<String> recordedFilePaths = [];
  String? currentFilePath;

  final List<String> sentences = [
    "나는 오늘 기차를 타고 광주에 갑니다.",
    "달콤한 빵과 따뜻한 차를 함께 마셨습니다.",
    "읽고 쓰는 연습을 꾸준히 했습니다.",
    "국물이 맛있어서 밥을 많이 먹었습니다.",
    "서울에서 부산까지 KTX를 탔습니다.",
    "저는 또박또박 정확하게 말하려고 노력하고 있습니다.",
  ];

  Future<void> toggleRecording() async {
    if (isRecording) {
      final path = await _recorder.stop();
      if (path != null) {
        currentFilePath = path;
        print('녹음 완료: $path');
      }
      setState(() => isRecording = false);
    } else {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) return;

      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/voice_$currentIndex.wav';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: filePath,
      );
      setState(() {
        isRecording = true;
        currentFilePath = null;
      });
    }
  }

  Future<void> nextSentence() async {
    // 녹음 중이면 먼저 정지
    if (isRecording) {
      final path = await _recorder.stop();
      if (path != null) currentFilePath = path;
      setState(() => isRecording = false);
    }

    // 녹음된 파일 없으면 경고
    if (currentFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('먼저 문장을 녹음해주세요.')),
      );
      return;
    }

    recordedFilePaths.add(currentFilePath!);

    if (currentIndex < sentences.length - 1) {
      setState(() {
        currentIndex++;
        currentFilePath = null;
      });
    } else {
      await _uploadVoices();
    }
  }

  Future<void> _uploadVoices() async {
    try {
      final token = await AppStorage.storage.read(key: 'accessToken');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://3.37.239.105:8080/api/users/voice/re-register'),
      );
      request.headers['Authorization'] = 'Bearer $token';

      for (final path in recordedFilePaths) {
        request.files.add(
          await http.MultipartFile.fromPath('voiceFiles', path),
        );
      }

      final response = await request.send();
      final body = await response.stream.bytesToString();
      print('음성 재등록 응답: ${response.statusCode} / $body');

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('음성이 성공적으로 등록되었습니다.')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('음성 등록에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    } catch (e) {
      print('음성 업로드 오류: $e');
    }
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
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
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            Text(
              "문장 ${currentIndex + 1} / ${sentences.length}",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            const Text(
              "아래 문장을 읽어 주세요",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                sentences[currentIndex],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: toggleRecording,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: isRecording ? Colors.red : const Color(0xFF4882FD),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mic, color: Colors.white, size: 40),
              ),
            ),
            const SizedBox(height: 20),

            // 녹음 상태 표시
            Text(
              isRecording
                  ? "녹음 중..."
                  : currentFilePath != null
                  ? "✅ 녹음 완료"
                  : "녹음 시작",
              style: const TextStyle(fontSize: 18),
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4882FD),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: nextSentence,
                child: Text(
                  currentIndex == sentences.length - 1 ? "등록 완료" : "다음 문장",
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
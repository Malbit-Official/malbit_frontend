import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../core/services/storage.dart';
import '../services/remaster_service.dart';
import 'expand_text_screens.dart';

class RemasterScreen extends StatefulWidget {
  const RemasterScreen({super.key});

  @override
  State<RemasterScreen> createState() => _RemasterScreenState();
}

class _RemasterScreenState extends State<RemasterScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final FlutterTts _tts = FlutterTts();
  final _storage = AppStorage.storage;

  bool _isRecording = false;
  bool _isLoading = false;
  String _originalText = "마이크를 눌러 말을 시작해보세요.";
  String _refinedText = "...";

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  // TTS 엔진 초기 설정
  Future<void> _initTts() async {
    await _tts.setLanguage("ko-KR");
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _tts.stop();
    super.dispose();
  }

  // 보정된 텍스트 음성 출력 핸들러
  Future<void> _handlePlayAction() async {
    if (_refinedText != "..." && _refinedText.isNotEmpty) {
      await _tts.speak(_refinedText);
    }
  }

  // 녹음 시작 및 중단 제어: 권한 확인 후 로컬 파일 경로에 WAV 포맷으로 저장
  Future<void> _handleMicAction() async {
    if (_isRecording) {
      final path = await _audioRecorder.stop();
      setState(() => _isRecording = false);
      if (path != null) _sendAudio(path);
    } else {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final path = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.wav';

        await _audioRecorder.start(
            const RecordConfig(
              encoder: AudioEncoder.wav,
              sampleRate: 16000,
              bitRate: 128000,
            ),
            path: path
        );

        setState(() => _isRecording = true);
      }
    }
  }

  // 녹음된 파일 서버 전송 후 결과 받아 화면 UI 갱신
  Future<void> _sendAudio(String path) async {
    setState(() => _isLoading = true);

    final token = await _storage.read(key: 'accessToken') ?? "";
    final result = await RemasterService.uploadAudio(filePath: path, token: token);

    if (result['success'] == true) {
      setState(() {
        _originalText = result['original_speech'];
        _refinedText = result['refined_text'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? "오류가 발생했습니다."))
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F6),
      body: SafeArea(
        child: Column(
          children: [
            // 고정 영역: 상단 제목 및 가이드
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const SizedBox(height: 55),
                  const Text(
                    'AI 문장 교정',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '더 정확하고 자연스러운 표현으로 바꿔드릴게요.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 15),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),

            // 스크롤 영역: 본문 결과 박스 및 인터랙션 버튼
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      // 잘못된 문장 섹션
                      _sectionTitle('이렇게 들려요.', Icons.hearing_rounded, Colors.black),
                      const SizedBox(height: 12),
                      _messageBox(context, _originalText, isHighlighted: false),

                      const SizedBox(height: 35),

                      _sectionTitle('이렇게 말해보세요!', Icons.auto_awesome, const Color(0xFF4882FD)),
                      const SizedBox(height: 12),
                      _messageBox(
                        context,
                        _refinedText,
                        isHighlighted: true,
                        showActions: true,
                      ),

                      const SizedBox(height: 40),

                      // 실시간 녹음 시작/중지 마이크 버튼
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _handleMicAction,
                              child: Container(
                                width: 70, height: 70,
                                decoration: BoxDecoration(
                                  color: _isRecording ? Colors.redAccent : const Color(0xFF4882FD),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_isRecording ? Colors.redAccent : const Color(0xFF4882FD)).withOpacity(0.3),
                                      blurRadius: 15, offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                    _isRecording ? Icons.stop_rounded : Icons.mic_none_rounded,
                                    color: Colors.white, size: 45
                                ),
                              ),
                            ),
                            const SizedBox(height: 35),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 섹션 제목 디자인
  Widget _sectionTitle(String text, IconData icon, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // 메시지 박스 디자인
  Widget _messageBox(BuildContext context, String text, {required bool isHighlighted, bool showActions = false}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.white : Colors.grey[200],
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(24),
          bottomLeft: const Radius.circular(24),
          bottomRight: const Radius.circular(24),
        ),
        border: isHighlighted
            ? Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 1.5)
            : null,
        boxShadow: isHighlighted
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ]
            : [],
      ),
      child: Column(
        children: [
          // 텍스트 영역
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 40, 25, 40),
            child: _isLoading
                ? const SizedBox(
              height: 32,
              width: 32,
              child: CircularProgressIndicator(
                color: Color(0xFF4882FD),
                strokeWidth: 3,
              ),
            )
                : Text(
              text,
              style: TextStyle(
                fontSize: 18,
                height: 1.6,
                fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
                color: isHighlighted ? Colors.black : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // 하단 액션 버튼
          if (showActions) ...[
            const Divider(height: 1, thickness: 0.5, indent: 20, endIndent: 20),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(Icons.volume_up_rounded, '재생', onTap: _handlePlayAction),
                  _ActionButton(
                    Icons.zoom_out_map,
                    '확대',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExpandTextScreens(text: text),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// 하단 아이콘 버튼 컴포넌트
class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton(this.icon, this.label, {this.onTap});

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final activeColor = _isPressed ? Colors.black : Colors.black54;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true), // 눌렀을 때
      onTapUp: (_) => setState(() => _isPressed = false), // 뗐을 때
      onTapCancel: () => setState(() => _isPressed = false), // 이탈
      onTap: widget.onTap,

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon,
              size: 20,
              color: activeColor,
            ),
            const SizedBox(width: 4),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 14,
                color: activeColor,
                fontWeight: _isPressed ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
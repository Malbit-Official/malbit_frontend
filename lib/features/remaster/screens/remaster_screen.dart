import 'package:flutter/material.dart';

import 'expand_text_screens.dart';

void main() {
  runApp(const MaterialApp(
    home: RemasterScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class RemasterScreen extends StatelessWidget {
  const RemasterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 85),

              // 제목
              const Text(
                'AI 문장 교정',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),

              // 부제목
              Text(
                '더 정확하고 자연스러운 표현으로 바꿔드릴게요.',
                style: TextStyle(color: Colors.grey[600], fontSize: 15),
              ),
              const SizedBox(height: 55),

              // 잘못된 문장 섹션
              _sectionTitle('이렇게 들려요.', Icons.hearing_rounded, Colors.black),
              const SizedBox(height: 12),
              _messageBox(
                context,
                '주임니... 이 더류.. 복사 ㅏ ...',
                isHighlighted: false,
              ),
              const SizedBox(height: 35),

              // AI 교정 문장 섹션
              _sectionTitle('이렇게 말해보세요!', Icons.auto_awesome, const Color(0xFF4882FD)),
              const SizedBox(height: 12),
              _messageBox(
                context,
                '주임님, 요청하신 서류\n복사 완료했습니다.',
                isHighlighted: true,
                showActions: true,
              ),
              const SizedBox(height: 50),

              // 마이크 버튼 레이아웃
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4882FD),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4882FD).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.mic_none_rounded, color: Colors.white, size: 45),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
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
            fontSize: 14,
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
            padding: EdgeInsets.fromLTRB(25, 40, 25, showActions ? 40 : 35),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 20,
                height: 1.6,
                fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
                color: isHighlighted ? Colors.black : Colors.grey[600],
              ),
            ),
          ),

          // 하단 액션 버튼 (showActions가 true일 때만 표시)
          if (showActions) ...[
            const Divider(height: 1, thickness: 0.5, indent: 20, endIndent: 20), // 구분선
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(Icons.volume_up_rounded, '재생'),
                  _ActionButton(Icons.bookmark_outline_rounded, '저장'),
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

// AI 하단 아이콘 버튼 컴포넌트
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
              size: 22,
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
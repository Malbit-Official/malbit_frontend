import 'package:flutter/material.dart';

class RoleplayListScreen extends StatelessWidget {
  const RoleplayListScreen({super.key});

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

            /// 상단 설명
            const Text(
              "👜 매장 직원 | 상황 : 상품 안내 중",
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),

            const SizedBox(height: 15),

            /// 현재 상황 카드
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("📌 현재 상황 요약",
                      style: TextStyle(fontSize: 15)),
                  Divider(),
                  Text("• 고객이 상품 재고를 문의함",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("• 색상 관련 질문 가능성 있음",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 상품 카드
            _card(
              child: Column(
                children: [
                  Image.asset(
                    "assets/images/product.png", // 이미지 맞게 수정
                    height: 120,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "이 상품은 현재 재고가 있습니다.",
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _tag("# 재고  # 안내"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 추천 문장 카드
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text("💬 다음으로 이렇게 말해볼 수 있어요",
                      style: TextStyle(fontWeight: FontWeight.bold)),

                  const SizedBox(height: 15),

                  _exampleBox("👉 다른 색상도 보여드릴까요?"),
                  const SizedBox(height: 10),
                  _exampleBox("👉 가격은 00원입니다."),

                  const SizedBox(height: 20),

                  /// 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff4882FD),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // 👉 여기서 음성/roleplay 시작 연결
                      },
                      child: const Text(
                        "🎤 직접 말해보기",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
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

  /// 공통 카드
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

  /// 태그
  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xffE3F2FD),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
  Widget _exampleBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffE3F2FD),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "# 재고  # 안내",
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'order_screen.dart';
import 'product_screen.dart';
import 'report_screen.dart';
import 'call_screen.dart';

class TemplateScreen extends StatelessWidget {
  const TemplateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            /// 🔹 상단 제목
            const Text(
              "직무 상황으로 말해보기",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "실제 업무에서 쓰는 말, 미리 연습하고 편하게 말해요.",
              style: TextStyle(
                fontSize: 17,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 10),

            /// 🔹 카드 리스트
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children:  [
                  _TemplateCard(
                    title: "주문 받기 ☕️",
                    hashtags: "# 주문 # 추천",
                    imagePath: "assets/images/order.png",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) =>  OrderScreen()),
                      );
                    },
                  ),
                  _TemplateCard(
                    title: "상품 안내하기 👜",
                    hashtags: "# 재고 # 가격 # 안내",
                    imagePath: "assets/images/product.png",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProductScreen()),
                      );
                    },
                  ),
                  _TemplateCard(
                    title: "업무 보고하기 📑",
                    hashtags: "# 보고 # 진행상황",
                    imagePath: "assets/images/report.png",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReportScreen()),
                      );
                    },
                  ),
                  _TemplateCard(
                    title: "전화 받기 📞",
                    hashtags: "# 응대 # 첫인사 # 문의",
                    imagePath: "assets/images/call.png",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CallScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔥 카드 위젯
class _TemplateCard extends StatelessWidget {
  final String title;
  final String hashtags;
  final String imagePath;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.title,
    required this.hashtags,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔥 이미지 (핵심)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: Image.asset(
              imagePath,
              width: double.infinity,
              height: 140, // 👉 여기 키우면 더 커짐
              fit: BoxFit.cover,
            ),
          ),

          /// 🔹 텍스트 영역
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),

                /// 🔥 오른쪽 아래 정렬
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: 6,
                    children: hashtags
                        .split("#")
                        .where((e) => e.trim().isNotEmpty)
                        .map((e) => _hashtagChip("#${e.trim()}"))
                        .toList(),
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
}
Widget _hashtagChip(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFE6F0FA),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        color: Colors.black87,
      ),
    ),
  );
}
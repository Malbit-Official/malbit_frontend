import 'package:flutter/material.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int currentIndex = 0;
  bool showHint = false;

  final List<Scenario> scenarios = [
    Scenario(
      situation: "손님이 매장 안에서 상품을 들고 고민하는 상황",
      customerLine: "이 가방은 어떤 스타일로 \n 쓰기 좋아요?",
      hint: "수납공간이 넉넉해서 출퇴근용으로 좋아요.",
      guide: "손님 질문에 맞게 상품을 안내해보세요!",
    ),
    Scenario(
      situation: "손님이 매장 안에서 상품을 들고 고민하는 상황",
      customerLine: "가격은 얼마예요?",
      hint: "이 제품은 59,000원입니다. \n 현재 할인 적용된 가격입니다.",
      guide: "상품 가격을 차분하고 정확하게 안내해보세요!",
    ),
    Scenario(
      situation: "손님이 다른 제품을 찾는 상황",
      customerLine: "조금 더 저렴한 제품도 있나요?",
      hint: "비슷한 디자인으로 이 제품이 있습니다.",
      guide: "다른 상품을 안내해주세요!",
    ),
    Scenario(
      situation: "손님이 비슷한 상품을 비교하려는 상황",
      customerLine: "이거랑 저거랑 뭐가 달라요?",
      hint: "이 제품은 가볍고, 저 제품은 수납공간이 더 넓어요.",
      guide: "상품 차이를 비교해서 설명해보세요!",
    ),
    Scenario(
      situation: "손님이 상품의 세부 정보를 궁금해하는 상황",
      customerLine: "이거 소재가 뭐예요?",
      hint: "생활 방수가 가능한 나일론 소재입니다.",
      guide: "상품 정보를 자세히 설명해보세요!",
    ),
    Scenario(
      situation: "손님이 구매를 망설이는 상황",
      customerLine: "좀 고민해볼게요.",
      hint: "지금 할인 중이라 좋은 기회입니다.",
      guide: "부담 없이 구매를 유도해보세요!",
    ),
    Scenario(
      situation: "손님이 구매를 결정한 상황",
      customerLine: "이걸로 할게요.",
      hint: "선택해주셔서 감사합니다.",
      guide: "구매를 확인하고 다음 단계로 안내하세요!",
    ),
    Scenario(
      situation: "결제를 진행해야 하는 상황",
      customerLine: "카드로 결제할게요.",
      hint: "총 금액은 59,000원입니다.",
      guide: "결제를 안내해보세요!",
    ),
  ];

  Scenario get current => scenarios[currentIndex];
  void _showFinishDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 바깥 터치 방지
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 제목
                const Text(
                  "🎉 연습 완료!",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                /// 피드백 리스트
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "✔ 주문 응대 성공",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),

                    Text(
                      "✔ 옵션 확인 자연스러움",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),

                    Text(
                      "✔ 결제 안내 적절함",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                /// 다시 연습 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // 팝업 닫기
                      setState(() {
                        currentIndex = 0;
                        showHint = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B8DEF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "다시 연습하기",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// 다음으로 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context); // 👉 이전 화면으로 이동
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE0E0E0),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "다음 연습으로",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void nextStep() {
    if (currentIndex < scenarios.length - 1) {
      setState(() {
        currentIndex++;
        showHint = false;
      });
    }  else {
      // 마지막 팝업팡
      _showFinishDialog();
    }
  }

  void onSpeak() {
    nextStep();
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

                /// 🔥 헤더 (여기 안으로 들어옴)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  margin:
                  const EdgeInsets.fromLTRB(16, 16, 16, 6),
                  // 🔥 간격 핵심
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6E8F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: const [
                      Text(
                        "상품 안내하기 👜",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "손님에게 상품 정보를 정확하고 친절하게 안내해보세요.",
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),

                /// 🔥 현재 상황 (바로 붙음)
                _situationBox(),

                const SizedBox(height: 6),

                /// 캐릭터
                _character(),

                const SizedBox(height: 16),

                /// 안내
                Text(
                  "“ ${current.guide} ”",
                  style: const TextStyle(fontSize: 17),
                ),
                const SizedBox(height: 12),

                /// 버튼
                _speakButton(),

                const SizedBox(height: 16),

                /// 힌트
                _hintBox(),

                const SizedBox(height: 20),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text(
                      "뒤로 가기",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF5B8DEF)),
                      foregroundColor: const Color(0xFF5B8DEF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ================= UI =================

  Widget _situationBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.push_pin, size: 16, color: Colors.red),
              const SizedBox(width: 6),
              const Text(
                "현재 상황",
                style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 18),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6EEF7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "# 기본 응대",
                  style: TextStyle(fontSize: 13),
                ),
              )
            ],
          ),

          const SizedBox(height: 10),

          Text(
            current.situation,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _character() {
    return Stack(
      children: [
        Image.asset(
          'assets/images/shopping_girl.png',
          width: double.infinity,
          height: 220,
          fit: BoxFit.cover,
        ),
        Positioned(
          right: 10,
          top: 10,
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8A3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              current.customerLine,
              style: const TextStyle(
                fontSize: 18,
                height: 1.4,
              ),),
          ),
        )
      ],
    );
  }

  Widget _speakButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onSpeak,
        icon: const Icon(Icons.mic),
        label: const Text(
          "직접 말해보기",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      constraints: const BoxConstraints(
        minHeight: 80, // 🔥 줄여야 접힌 상태 자연스러움
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          /// 🔥 클릭 영역
          GestureDetector(
            onTap: () {
              setState(() {
                showHint = !showHint;
              });
            },
            child: Row(
              children: [
                const Icon(Icons.lightbulb, size: 20, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  "힌트 보기",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),

                /// 🔥 화살표 추가
                Icon(
                  showHint
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ],
            ),
          ),

          /// 🔥 펼쳐지는 영역
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: showHint
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(),
            secondChild: Column(
              children: [
                const SizedBox(height: 16),

                Text(
                  current.hint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
/// 데이터 모델
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
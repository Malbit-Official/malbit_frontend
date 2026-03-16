import 'package:flutter/material.dart';
import '../../main_navigation/widgets/bottom_nav.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _participantCount = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F6),
      // 1. 상단 AppBar를 없애야 카드가 맨 위로 붙습니다.
      appBar: null,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// 2. 상단 통합 카드 (가로 꽉 차고 위로 밀착)
              Container(
                width: double.infinity,
                // 내부 여백: 좌우 25, 위 20, 아래 30 (시안에 맞춰 조절)
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  //boxShadow: [
                  //  BoxShadow(
                  //    color: Colors.black.withOpacity(0.05),
                  //    blurRadius: 10,
                  //    offset: const Offset(0, 5),
                  //  ),
                  //],
                ),
                child: Column(
                  children: [
                    // 로고 및 설정 버튼 Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          "assets/images/logo2.png", // 본인의 로고 파일 경로
                          height: 30,               // 시안에 맞춰 높이 조절 (텍스트 26 정도면 30~35가 적당함)
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Text(
                            "말빛", // 이미지가 없을 때 대비한 백업 텍스트
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.settings, color: Colors.black, size: 28),
                          onPressed: () => Navigator.pushNamed(context, '/profile'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    // 하늘색 메인 배너
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xffC9E9FF),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "지금 말하면,\n더 자연스럽게 바꿔줘요",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      height: 1.3),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "부정확한 발화를 정확한 문장으로!",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          Image.asset(
                            "assets/images/banner.png",
                            width: 75,
                            height: 75,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.face, size: 70, color: Colors.blueAccent),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /// 3. 하단 콘텐츠 영역 (여기서부터는 좌우 여백 적용)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                child: Column(
                  children: [
                    /// 캘린더 영역
                    _buildSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("잊지 말고 챙겨야 해요",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              day("9", true), day("10", false), day("11", false),
                              day("12", false), day("13", false), day("14", false),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 추천 버튼
                    Container(
                      width: double.infinity,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff4882FD),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () {},
                        child: const Text(
                          "상황별 발화 추천받기\nclick!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 오늘의 업무 기록 카드
                    _buildSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("오늘의 업무 기록하기",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("참여자 수", style: TextStyle(color: Colors.black87)),
                              Text("${_participantCount.toInt()}명",
                                  style: const TextStyle(color: Color(0xff4882FD), fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Slider(
                            value: _participantCount,
                            min: 0, max: 5, divisions: 5,
                            activeColor: const Color(0xff4882FD),
                            onChanged: (v) => setState(() => _participantCount = v),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: GestureDetector(
                              onTap: () => print("녹음 버튼 클릭"),
                              child: const CircleAvatar(
                                radius: 30,
                                backgroundColor: Color(0xffF25D50),
                                child: Text("REC",
                                    style: TextStyle(
                                        color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {},
      ),
    );
  }

  // 반복되는 흰색 카드 스타일을 위한 공통 위젯
  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  // 날짜 아이템 위젯
  Widget day(String text, bool highlight) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: highlight ? const Color(0xff4882FD) : const Color(0xffF0F0F0),
      child: Text(text,
          style: TextStyle(
              color: highlight ? Colors.white : Colors.black,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal
          )),
    );
  }
}
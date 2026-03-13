import 'package:flutter/material.dart';

import '../../main_navigation/widgets/bottom_nav.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "말빛",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [

            /// 상단 안내 카드
            Container(
              width: 370,
              height: 160,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xffC9E9FF),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "지금 말하면,\n더 자연스럽게 바꿔줘요",
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "부정확한 발화를 정확한 문장으로!",
                            style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 50,
                    margin: EdgeInsets.only(left: 16),
                    child: Image.asset(
                      "assets/images/banner.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            /// 캘린더 영역
            Container(
              width: 350,
              height: 100,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "잊지 말고 챙겨야 해요",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      day("9", true),
                      day("10", false),
                      day("11", false),
                      day("12", false),
                      day("13", false),
                      day("14", false),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            /// 추천 버튼
            Container(
              width: 350,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3), // 아주 연한 검정색 (거의 회색빛)
                    blurRadius: 10,                        // 부드럽게 퍼지는 정도
                    offset: const Offset(0, 6),           // 아래로 살짝 내려온 위치
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff4882FD),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {},
                child: Text(
                  "상황별 발화 추천받기\nclick!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            /// 오늘의 업무 기록
            Container(
              width: 350,
              height: 200,
              padding: EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "오늘의 업무 기록하기",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600
                    ),
                  ),

                  SizedBox(height: 10),

                  Text("참여자 수"),

                  Slider(
                    value: 1,
                    min: 0,
                    max: 5,
                    divisions: 5,
                    onChanged: (v) {},
                  ),

                  Center(
                    child: GestureDetector(
                      onTap: () {
                        // 버튼 실행 시 동작
                        print("녹음 버튼이 클릭되었습니다!");
                      },
                      child: Image.asset(
                        "assets/images/Rec_Button.png",
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      // 하단 네비게이션
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {},
      ),
    );
  }

  Widget day(String text, bool highlight) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: highlight ? Colors.blue : Colors.grey.shade200,
      child: Text(
        text,
        style: TextStyle(
          color: highlight ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
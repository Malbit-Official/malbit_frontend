import 'package:flutter/material.dart';
import 'package:malbit_frontend/features/main_navigation/widgets/bottom_nav.dart';
import 'package:malbit_frontend/features/profile/screens/job_environment_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),

      appBar: AppBar(
        title: const Text('프로필 관리'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.settings, color: Colors.black),
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// 프로필 카드
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [

                  const CircleAvatar(
                    radius: 35,
                    backgroundImage:
                    AssetImage('assets/images/profile.png'),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "사용자 이름",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text("이메일 @ naver.com"),
                        Text("현재 직무 : 사무직"),
                      ],
                    ),
                  ),

                  OutlinedButton(
                    onPressed: () {},
                    child: const Text("프로필 사진 변경"),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 설정 메뉴
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: const [
                  _MenuTile(title: "프로필 관리"),
                  Divider(height: 1),
                  _MenuTile(title: "이메일 변경"),
                  Divider(height: 1),
                  _MenuTile(title: "로그아웃"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 직무 환경
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "직무 환경",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("사무직"),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const JobEnvironmentScreen(),
                            ),
                          );
                        },
                        child: const Text("직무 환경 변경"),
                      )
                    ],
                  ),

                  const Divider(),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                    children: const [
                      _SmallButton(text: "음성 재등록"),
                      _SmallButton(text: "음성 삭제"),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 기본 설정
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "기본 설정",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("글자 크기"),
                      Text("작게  보통  크게"),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("버튼 크게 보기"),
                      Switch(value: true, onChanged: null),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 사용 통계
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 3,
                children: const [
                  _StatTile(title: "총 보정 횟수", value: "30"),
                  _StatTile(title: "평균 보정 강도", value: "60%"),
                  _StatTile(title: "완료한 상황극", value: "7"),
                  _StatTile(title: "생성한 요약", value: "10"),
                ],
              ),
            ),
          ],
        ),
      ),

    );
  }
}

class _MenuTile extends StatelessWidget {
  final String title;
  const _MenuTile({required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final String text;
  const _SmallButton({required this.text});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
      child: Text(text),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final String value;

  const _StatTile({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
              fontWeight: FontWeight.bold),
        )
      ],
    );
  }
}
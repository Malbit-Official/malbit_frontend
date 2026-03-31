import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:malbit_frontend/features/main_navigation/widgets/bottom_nav.dart';
import 'package:malbit_frontend/features/profile/screens/job_environment_screen.dart';
import 'package:malbit_frontend/features/voice_settings/screens/voice_register_screen.dart';
import 'package:malbit_frontend/features/profile/screens/edit_profile_screen.dart';
import 'package:malbit_frontend/core/services/storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  String currentJob = "사무직";
  String userName = "사용자 이름";
  String email = "email@naver.com";
  String disabilityType = "";
  String cognitiveLevel = "";
  bool notificationEnabled = true;
  bool isLargeButton = false;
  String? profileImagePath;

  int totalCorrection = 0;
  int averageIntensity = 0;
  int completedRoleplays = 0;
  int generatedSummaries = 0;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadStatistics();
  }

  String convertJobToEnglish(String job) {
    switch (job) {
      case "사무직": return "OFFICE";
      case "영업 / 고객상담": return "SALES";
      case "의료 / 간호": return "MEDICAL";
      case "교육 / 학교": return "EDUCATION";
      case "서비스 / 매장": return "SERVICE";
      case "기타": return "ETC";
      default: return "OFFICE";
    }
  }

  Future<void> _loadUserInfo() async {
    try {
      final token = await AppStorage.storage.read(key: 'accessToken');

      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        setState(() {
          userName = data['data']['name'] ?? "";
          email = data['data']['email'] ?? "";
          currentJob = data['data']['jobType'] ?? "";
          disabilityType = data['data']['disabilityType'] ?? "";
          cognitiveLevel = data['data']['cognitiveLevel'] ?? "";
          profileImagePath = data['data']['profileImage'];

        });
      }

    } catch (e) {
      print("유저 정보 API 오류: $e");
    }
  }
  Future<void> uploadProfileImage(File image) async {
    final token = await AppStorage.storage.read(key: 'accessToken');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:8080/api/users/profile-image'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      await http.MultipartFile.fromPath('file', image.path),
    );

    var response = await request.send();

    print("이미지 업로드: ${response.statusCode}");
  }

  Future<void> _loadStatistics() async {
    try {
      final token = await AppStorage.storage.read(key: 'accessToken');

      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/users/statistics'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        setState(() {
          totalCorrection = data['data']['totalCorrectionCount'];
          averageIntensity = data['data']['averageCorrectionIntensity'];
          completedRoleplays = data['data']['completedRoleplays'];
          generatedSummaries = data['data']['generatedSummaries'];
        });
      }

    } catch (e) {
      print("통계 API 오류: $e");
    }
  }
  Future<void> _updateJob() async {
    final token = await AppStorage.storage.read(key: 'accessToken');

    final response = await http.patch(
      Uri.parse('http://10.0.2.2:8080/api/users/settings'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "jobType": convertJobToEnglish(currentJob),
      }),
    );

    print("직무 변경 응답: ${response.body}");
  }
  Future<void> _logout() async {
    final token = await AppStorage.storage.read(key: 'accessToken');

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/users/logout'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print("로그아웃 응답: ${response.body}");

    } catch (e) {
      print("로그아웃 오류: $e");
    }

    /// ⭐️ 로컬 토큰 삭제 (중요)
    await AppStorage.storage.deleteAll();

    /// 로그인 화면 이동
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
            (route) => false,
      );
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("음성 삭제"),
          content: const Text("등록된 음성을 정말 삭제하시겠습니까?"),
          actions: [

            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("취소"),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[100],
              ),
              onPressed: () {

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("음성이 삭제되었습니다."),
                  ),
                );
              },
              child: const Text("삭제"),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("로그아웃"),
          content: const Text("정말 로그아웃 하시겠습니까?"),
          actions: [

            /// 취소
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("취소"),
            ),

            /// 확인
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[100],),
              onPressed: () async {
                Navigator.pop(context); // 다이얼로그 닫기
                await _logout();        // ⭐️ 로그아웃 실행
              },
              child: const Text("확인"),
            ),
          ],
        );
      },
    );
  }

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

                  CircleAvatar(
                    radius: 35,
                    backgroundImage: profileImagePath != null
                        ? NetworkImage(profileImagePath!)
                        : const AssetImage('assets/images/profile.png') as ImageProvider,
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                          userName,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(email),
                        Text("현재 직무 : $currentJob"),
                      ],
                    ),
                  ),
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
                children:  [
                  _MenuTile(
                    title: "프로필 관리",
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(
                            name: userName,
                            email: email,
                            disabilityType: disabilityType,
                            cognitiveLevel: cognitiveLevel,
                          ),
                        ),
                      );

                      if (result != null) {
                        setState(() {
                          userName = result["name"];
                          email = result["email"];
                          disabilityType = result["disabilityType"];
                          cognitiveLevel = result["cognitiveLevel"];
                          profileImagePath = result["image"];
                        });

                        // ✅ 다시 저장 (중요)
                        await AppStorage.storage.write(key: 'name', value: userName);
                        await AppStorage.storage.write(key: 'email', value: email);
                        await AppStorage.storage.write(key: 'disabilityType', value: disabilityType);
                        await AppStorage.storage.write(key: 'cognitiveLevel', value: cognitiveLevel);
                      }
                    },
                  ),
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
                      Text(currentJob),

                      OutlinedButton(
                        onPressed: () async {

                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JobEnvironmentScreen(
                                currentJob: currentJob,
                              ),
                            ),
                          );

                          if (result != null) {
                            setState(() {
                              currentJob = result;
                            });
                            await _updateJob();
                          }

                        },
                        child: const Text("직무 환경 변경"),
                      )
                    ],
                  ),

                  const Divider(),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                    children:  [

                      _SmallButton(
                        text: "음성 재등록",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VoiceRegisterScreen(),
                            ),
                          );
                        },
                      ),

                      _SmallButton(
                        text: "음성 삭제",
                        onTap: () {
                          _showDeleteDialog(context);
                        },
                      ),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("버튼 크게 보기"),
                      Switch(
                        value: isLargeButton,
                        onChanged: (value) {
                          setState(() {
                            isLargeButton = value;
                          });
                        },
                      ),
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
                children: [
                  _StatTile(title: "총 보정 횟수", value: "$totalCorrection"),
                  _StatTile(title: "평균 보정 강도", value: "$averageIntensity%"),
                  _StatTile(title: "완료한 상황극", value: "$completedRoleplays"),
                  _StatTile(title: "생성한 요약", value: "$generatedSummaries"),
                ],
              ),
            ),
            const SizedBox(height: 20),

            /// 로그아웃
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: const Text(
                  "로그아웃",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showLogoutDialog(context);
                },
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
  final VoidCallback? onTap;

  const _MenuTile({
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

class _SmallButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const _SmallButton({
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
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
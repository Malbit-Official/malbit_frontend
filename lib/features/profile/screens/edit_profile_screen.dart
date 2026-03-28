import 'package:flutter/material.dart';
import 'package:malbit_frontend/features/profile/screens/change_password.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:malbit_frontend/core/services/storage.dart';
import 'package:malbit_frontend/features/profile/screens/email_change_screen.dart';

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String email;
  final String disabilityType;
  final String cognitiveLevel;


  const EditProfileScreen({
    super.key,
    required this.name,
    required this.email,
    required this.disabilityType,
    required this.cognitiveLevel,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  String nickname = "";
  String userName = "";
  String email = "";
  String currentJob = "";
  String disabilityType = "";
  String cognitiveLevel = "";
  bool notificationEnabled = true;
  String language = "한국어";

  @override
  void initState() {
    super.initState();
    userName = widget.name;
    email = widget.email;
    disabilityType = widget.disabilityType;
    cognitiveLevel = widget.cognitiveLevel;
  }
  String convertDisability(String value) {
    switch (value) {
      case "언어장애": return "LANGUAGE";
      case "뇌신경장애": return "CRANIAL_NERVE";
      case "청각장애": return "HEARING";
      case "조음장애": return "ARTICULATION";
      case "전음성 난청": return "CONDUCTIVE_HEARING";
      case "감음신경성 난청": return "SENSORINEURAL_HEARING";
      case "기능성 발성장애": return "FUNCTIONAL_VOICE";
      case "후두장애": return "LARYNGEAL";
      case "구강장애": return "ORAL";
      default: return "LANGUAGE";
    }
  }

  String convertJobToEnglish(String job) {
    switch (job) {
      case "사무직":
        return "OFFICE";
      case "영업 / 고객상담":
        return "SALES";
      case "의료 / 간호":
        return "MEDICAL";
      case "교육 / 학교":
        return "EDUCATION";
      case "서비스 / 매장":
        return "SERVICE";
      case "기타":
        return "ETC";
      default:
        return "OFFICE";
    }
  }
  String convertCognitive(String value) {
    if (value.startsWith("1")) return "LEVEL_1";
    if (value.startsWith("2")) return "LEVEL_2";
    if (value.startsWith("3")) return "LEVEL_3";
    if (value.startsWith("4")) return "LEVEL_4";
    if (value.startsWith("5")) return "LEVEL_5";
    return "LEVEL_1";
  }

  Future<void> _updateProfile() async {
    final token = await AppStorage.storage.read(key: 'accessToken');

    final response = await http.patch(
      Uri.parse('http://10.0.2.2:8080/api/users/settings'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "jobType": convertJobToEnglish(currentJob),
        "disabilityType": convertDisability(disabilityType),
        "cognitiveLevel": convertCognitive(cognitiveLevel),
      }),
    );

    print("수정 응답: ${response.body}");
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  Future<bool> _updateEmail() async {
    final token = await AppStorage.storage.read(key: 'accessToken');

    try {
      final response = await http.patch(
        Uri.parse('http://10.0.2.2:8080/api/users/email'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "newEmail": email,
        }),
      );

      final data = jsonDecode(response.body);
      print("이메일 변경 응답: $data");

      if (response.statusCode == 200 && data['status'] == 'SUCCESS') {
        return true;
      } else {
        _showSnackBar(data['message'] ?? "이메일 변경 실패");
        return false;
      }

    } catch (e) {
      _showSnackBar("이메일 변경 오류");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),

      appBar: AppBar(
        title: const Text("프로필 관리"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            /// 사용자 정보
            _sectionCard(
              title: "사용자 정보",
              children: [

                ListTile(
                  leading: const CircleAvatar(
                    radius: 20,
                    backgroundImage:
                    AssetImage('assets/images/profile.png'),
                  ),
                  title: const Text("프로필 사진 변경"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    /// TODO
                    /// 이미지 선택 기능
                  },
                ),

                const Divider(),

                ListTile(
                  title: const Text("이름 변경"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showEditDialog(
                      title: "이름 변경",
                      initialValue: userName,
                      onSave: (value) {
                        setState(() {
                          userName = value;
                        });
                      },
                    );
                  },
                ),

                const Divider(),

                ListTile(
                  title: const Text("닉네임 변경"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showEditDialog(
                      title: "닉네임 변경",
                      initialValue: nickname,
                      onSave: (value) {
                        setState(() {
                          nickname = value;
                        });
                      },
                    );
                  },
                ),
                const Divider(),

                ListTile(
                  title: const Text("장애 유형"),
                  trailing: Text(disabilityType),
                  onTap: () {
                    _showDisabilityDialog();
                  },
                ),

                const Divider(),

                ListTile(
                  title: const Text("인지 수준"),
                  trailing: Text(cognitiveLevel),
                  onTap: () {
                    _showCognitiveDialog();
                  },
                ),

              ],
            ),

            const SizedBox(height: 20),

            /// 계정 정보
            _sectionCard(
              title: "계정 정보",
              children: [

                ListTile(
                  title: const Text("이메일 변경"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {

                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmailChangeScreen(
                          currentEmail: email,
                        ),
                      ),
                    );

                    if (result != null) {
                      setState(() {
                        email = result;
                      });
                    }
                  },
                ),

                const Divider(),

                ListTile(
                  title: const Text("비밀번호 변경"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordScreen(),
                      ),
                    );
                  },
                )
              ],
            ),

            const SizedBox(height: 20),

            /// 알림 / 설정
            _sectionCard(
              title: "알림 / 설정",
              children: [

                SwitchListTile(
                  title: const Text("알림 설정"),
                  value: notificationEnabled,
                  onChanged: (value) {
                    setState(() {
                      notificationEnabled = value;
                    });
                  },
                ),

                const Divider(),

                ListTile(
                  title: const Text("언어 설정"),
                  trailing: Text(language),
                  onTap: () {
                    _showLanguageDialog();
                  },
                ),
                const SizedBox(height: 30),

                GestureDetector(
                  onTap: () async {

                    /// 2️⃣ 환경 설정 변경
                    await _updateProfile();

                    /// 3️⃣ 화면 반영
                    Navigator.pop(context, {
                      "name": userName,
                      "email": email,
                      "disabilityType": disabilityType,
                      "cognitiveLevel": cognitiveLevel,
                    });

                    _showSnackBar("프로필이 저장되었습니다.");
                  },

                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.black,
                      ),
                    ),

                    child: const Center(
                      child: Text(
                        "프로필 저장",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:Colors.red
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 카드 UI
  Widget _sectionCard({
    required String title,
    required List<Widget> children,
  }) {

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ...children
          ],
        ),
      ),
    );
  }

  /// 이름 / 닉네임 수정 다이얼로그
  void _showEditDialog({
    required String title,
    required String initialValue,
    required Function(String) onSave,
  }) {

    final controller = TextEditingController(text: initialValue);

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(
          title: Text(title),

          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("취소"),
            ),
            ElevatedButton(
              onPressed: () {

                onSave(controller.text);   // 값 업데이트

                Navigator.pop(context);    // 다이얼로그만 닫기

              },
              child: const Text("저장"),
            ),
          ],
        );
      },
    );
  }

  /// 언어 설정
  void _showLanguageDialog() {

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(
          title: const Text("언어 선택"),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              ListTile(
                title: const Text("한국어"),
                onTap: () {
                  setState(() {
                    language = "한국어";
                  });
                  Navigator.pop(context);
                },
              ),

              ListTile(
                title: const Text("English"),
                onTap: () {
                  setState(() {
                    language = "English";
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  void _showDisabilityDialog() {
    final options = [
      "언어장애",
      "뇌신경장애",
      "청각장애",
      "조음장애",
      "전음성 난청",
      "감음신경성 난청",
      "기능성 발성장애",
      "후두장애",
      "구강장애",
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("장애 유형 선택"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: options.map((e) {
                return ListTile(
                  title: Text(e),
                  trailing: disabilityType == e
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    setState(() {
                      disabilityType = e;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
  void _showCognitiveDialog() {
    final options = [
      "1단계: 매우 낮음 (단어 위주 소통)",
      "2단계: 낮음 (간단한 문장 이해)",
      "3단계: 보통 (일상 대화 가능)",
      "4단계: 높음 (추상/비유 이해)",
      "5단계: 매우 높음 (정교한 소통)",
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("인지 수준 선택"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: options.map((e) {
                return ListTile(
                  title: Text(e),
                  trailing: cognitiveLevel == e
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    setState(() {
                      cognitiveLevel = e;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

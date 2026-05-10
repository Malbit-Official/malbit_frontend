import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:malbit_frontend/features/main_navigation/screens/main_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/services/storage.dart';
import '../../main_navigation/widgets/bottom_nav.dart';
import '../../record/screens/record_screen.dart';
import 'calendar_screen.dart';
import 'package:malbit_frontend/features/roleplay/screens/roleplay_list_screen.dart';

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
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  // 녹음 및 상태 관리 변수
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _recordedFilePath;

  String _statusMessage = "";

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F6),
      appBar: null,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                decoration: const BoxDecoration(color: Colors.white),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          "assets/images/logo2.png",
                          height: 25,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Text(
                            "말빛",
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.settings, color: Colors.black, size: 32),
                          onPressed: () => Navigator.pushNamed(context, '/profile'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    Container(
                      height: 150,
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 20, 4, 0),
                      decoration: BoxDecoration(
                        color: const Color(0xffC9E9FF),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,

                      child: Stack(
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "지금 말하면,\n더 자연스럽게 바꿔줘요",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "부정확한 발화를 정확한 문장으로!",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            right: -10,
                            bottom: -18,
                            child: Image.asset(
                              "assets/images/banner.png",
                              width: 135,
                              height: 150,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.face, size: 80, color: Colors.blueAccent),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 3),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                child: Column(
                  children: [
                    _buildSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("잊지 말고 챙겨야 해요",
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const CalendarScreen()),
                                ),
                                child: const Icon(Icons.chevron_right, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TableCalendar(
                            locale: 'ko_KR',
                            firstDay: DateTime.utc(2020, 1, 1),
                            lastDay: DateTime.utc(2030, 12, 31),
                            focusedDay: _focusedDay,
                            calendarFormat: CalendarFormat.week,
                            headerVisible: false,
                            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                            },
                            daysOfWeekHeight: 20,
                            calendarBuilders: CalendarBuilders(
                              dowBuilder: (context, day) {
                                if (day.weekday == DateTime.saturday) {
                                  return const Center(
                                    child: Text(
                                      '토',
                                      style: TextStyle(color: Colors.blue, fontSize: 12),
                                    ),
                                  );
                                } else if (day.weekday == DateTime.sunday) {
                                  return const Center(
                                    child: Text(
                                      '일',
                                      style: TextStyle(color: Colors.redAccent, fontSize: 12),
                                    ),
                                  );
                                }
                                return null;
                              },
                            ),
                            calendarStyle: const CalendarStyle(
                              isTodayHighlighted: true,
                              todayDecoration: BoxDecoration(color: Color(0x804882FD), shape: BoxShape.circle),
                              selectedDecoration: BoxDecoration(color: Color(0xff4882FD), shape: BoxShape.circle),
                            ),
                            daysOfWeekStyle: const DaysOfWeekStyle(
                              weekdayStyle: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    Container(
                      width: double.infinity,
                      height: 80,
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RoleplayListScreen()),
                          );
                        },
                        child: const Text(
                          "상황별 발화 추천받기\nclick!",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

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
                              const Text("참여자 수", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87)),
                              Text(
                                _participantCount >= 5 ? "5명 이상" : "${_participantCount.toInt()}명",
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 2.3,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 15.0),
                              activeTrackColor: const Color(0xffEF5350),
                              inactiveTrackColor: const Color(0xffF0F0F0),
                              thumbColor: const Color(0xffEF5350),
                            ),
                            child: Slider(
                              value: _participantCount,
                              min: 0,
                              max: 5,
                              divisions: 5,
                              onChanged: (v) => setState(() => _participantCount = v),
                            ),
                          ),
                          const SizedBox(height: 10),

                          Center(
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    if (!_isRecording) {
                                      if (await _audioRecorder.hasPermission()) {
                                        final directory = await getApplicationDocumentsDirectory();
                                        _recordedFilePath = '${directory.path}/meeting_${DateTime.now().millisecondsSinceEpoch}.wav';
                                        await _audioRecorder.start(
                                            const RecordConfig(
                                              encoder: AudioEncoder.wav,
                                              sampleRate: 16000,
                                              bitRate: 128000,
                                            ),
                                            path: _recordedFilePath!);
                                        setState(() {
                                          _isRecording = true;
                                          _statusMessage = "녹음 중...";
                                        });
                                        print("WAV 녹음 시작: $_recordedFilePath");
                                      }
                                    } else {
                                      final path = await _audioRecorder.stop();
                                      setState(() {
                                        _isRecording = false;
                                        _statusMessage = "서버 연결 준비 중...";
                                      });

                                      if (path != null) {
                                        MainScreen.mainScreenState?.setTabIndex(4);

                                        try {
                                          final token = await AppStorage.storage.read(key: 'accessToken') ?? "";
                                          var request = http.MultipartRequest(
                                              'POST',
                                              Uri.parse('http://13.125.107.37:8080/api/remaster/analyze-meeting'));

                                          request.headers['Authorization'] = 'Bearer $token';
                                          request.fields['participantCount'] = _participantCount.toInt().toString();
                                          request.files.add(await http.MultipartFile.fromPath('file', path));

                                          setState(() => _statusMessage = "파일 업로드 중...");

                                          // [수정] 응답 시간을 5분으로 연장하여 타임아웃 방지
                                          var client = http.Client();
                                          var streamedResponse = await client.send(request).timeout(const Duration(minutes: 5));
                                          var response = await http.Response.fromStream(streamedResponse);

                                          if (response.statusCode == 200) {
                                            setState(() => _statusMessage = "분석 완료!");
                                            print("서버 분석 완료");
                                          } else {
                                            setState(() => _statusMessage = "에러: ${response.statusCode}");
                                            print("서버 응답 에러: ${response.statusCode}");
                                          }
                                        } catch (e) {
                                          setState(() => _statusMessage = "전송 실패: 연결 확인 필요");
                                          print("서버 전송 에러: $e");
                                        }
                                      }
                                    }
                                  },
                                  child: Image.asset(
                                    "assets/images/Rec_Button.png",
                                    width: 55,
                                    height: 55,
                                    fit: BoxFit.contain,
                                    color: _isRecording ? Colors.red.withOpacity(0.5) : null,
                                    colorBlendMode: _isRecording ? BlendMode.modulate : null,
                                  ),
                                ),
                                // [추가] 실시간 상태 메시지 UI (디자인 해치지 않는 작은 텍스트)
                                const SizedBox(height: 8),
                                Text(
                                  _statusMessage,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _statusMessage.contains("에러") || _statusMessage.contains("실패")
                                        ? Colors.red : Colors.blueAccent,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
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
    );
  }

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
}
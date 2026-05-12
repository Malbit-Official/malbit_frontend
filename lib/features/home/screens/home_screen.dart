import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/services/storage.dart';
import 'calendar_screen.dart';
import 'package:malbit_frontend/features/roleplay/screens/roleplay_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _participantCount = 0.0;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _recordedFilePath;

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F6),
      body: SafeArea(
        child: Column(
          children: [
            // [상단 고정 영역] 로고 및 메인 배너
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 25),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 1, offset: Offset(0, 1))
                ],
              ),
              child: Column(
                children: [
                  // 상단 바: 로고, 설정 버튼
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        "assets/images/main_logo.png",
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
                  const SizedBox(height: 5),
                  // 메인 배너
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
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.3),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "부정확한 발화를 정확한 문장으로!",
                              style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w600),
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
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // [하단 스크롤 영역] 캘린더, 버튼, 업무 기록
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Column(
                  children: [
                    // 주간 캘린더
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
                            daysOfWeekHeight: 20,
                            rowHeight: 40,
                            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                            },
                            calendarBuilders: CalendarBuilders(
                              defaultBuilder: (context, day, focusedDay) {
                                if (day.weekday == DateTime.sunday) {
                                  return Center(child: Text('${day.day}', style: const TextStyle(color: Colors.redAccent)));
                                } else if (day.weekday == DateTime.saturday) {
                                  return Center(child: Text('${day.day}', style: const TextStyle(color: Colors.blue)));
                                }
                                return null;
                              },
                              dowBuilder: (context, day) {
                                if (day.weekday == DateTime.sunday) {
                                  return const Center(child: Text('일', style: TextStyle(color: Colors.redAccent, fontSize: 12)));
                                } else if (day.weekday == DateTime.saturday) {
                                  return const Center(child: Text('토', style: TextStyle(color: Colors.blue, fontSize: 12)));
                                }
                                return null;
                              },
                            ),
                            calendarStyle: const CalendarStyle(
                              isTodayHighlighted: true,
                              todayDecoration: BoxDecoration(color: Color(0x804882FD), shape: BoxShape.circle),
                              selectedDecoration: BoxDecoration(color: Color(0xff4882FD), shape: BoxShape.circle),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 상황별 발화 추천 이동 버튼
                    _buildMainActionButton(),
                    const SizedBox(height: 20),

                    // 업무 기록 및 녹음
                    _buildSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("오늘의 업무 기록하기", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 15),
                          _buildParticipantCountRow(),
                          _buildParticipantSlider(),
                          const SizedBox(height: 5),
                          _buildRecordingButton(),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 공통 카드 UI 위젯
  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: child,
    );
  }

  // 파란 버튼 위젯
  Widget _buildMainActionButton() {
    return Container(
      width: double.infinity,
      height: 73,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff4882FD),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RoleplayListScreen())),
        child: const Text(
          "상황별 발화 추천받기\nclick!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
        ),
      ),
    );
  }

  // 참여자 수 표시
  Widget _buildParticipantCountRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("참여자 수", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87)),
        Text(
          _participantCount >= 5 ? "5명 이상" : "${_participantCount.toInt()}명",
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }

  // 참여자 수 조절 슬라이더
  Widget _buildParticipantSlider() {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 2.3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
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
    );
  }

  // 녹음 시작/중지 이미지 버튼
  Widget _buildRecordingButton() {
    return Center(
      child: GestureDetector(
        onTap: _handleRecording,
        child: Image.asset(
          "assets/images/Rec_Button.png",
          width: 55,
          height: 55,
          fit: BoxFit.contain,
          color: _isRecording ? Colors.red.withOpacity(0.5) : null,
          colorBlendMode: _isRecording ? BlendMode.modulate : null,
        ),
      ),
    );
  }

  // 녹음 및 서버 전송 핸들러
  Future<void> _handleRecording() async {
    if (!_isRecording) {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        _recordedFilePath = '${directory.path}/meeting_${DateTime.now().millisecondsSinceEpoch}.wav';
        await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.wav, sampleRate: 16000, bitRate: 128000),
            path: _recordedFilePath!);
        setState(() => _isRecording = true);
        debugPrint("🔴 녹음 시작: $_recordedFilePath");
      }
    } else {
      final path = await _audioRecorder.stop();
      setState(() => _isRecording = false);
      if (path != null) {
        try {
          final token = await AppStorage.storage.read(key: 'accessToken') ?? "";
          var request = http.MultipartRequest('POST', Uri.parse('http://3.37.239.105:8080/api/remaster/analyze-meeting'));
          request.headers.addAll({'Authorization': 'Bearer $token', 'Accept': 'application/json'});
          request.files.add(await http.MultipartFile.fromPath('audio_file', path));
          var response = await http.Response.fromStream(await request.send().timeout(const Duration(minutes: 5)));
          debugPrint(response.statusCode == 200 ? "✅ 분석 완료" : "❌ 에러: ${response.statusCode}");
        } catch (e) {
          debugPrint("⚠️ 실패: $e");
        }
      }
    }
  }
}
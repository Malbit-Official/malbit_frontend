import 'package:flutter/material.dart';
import '../../main_navigation/screens/main_screen.dart';

// 업무 기록 녹음본 분석 완료 팝업창
class AnalysisCompleteDialog extends StatelessWidget {
  const AnalysisCompleteDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AnalysisCompleteDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFF7F6F6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Color(0xff4882FD), size: 25),
              SizedBox(width: 8),
              Text(
                "분석 완료",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Icon(Icons.check_circle, color: Color(0xff4882FD), size: 25),
            ],
          ),
          SizedBox(height: 13),
          Text(
            "업무 녹음 분석이 완료됐어요!\n결과를 확인하러 갈까요?",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black87),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF7F6F6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("나중에", style: TextStyle(color: Colors.grey)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4882FD),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  MainScreen.mainScreenState?.setTabIndex(4);
                },
                child: const Text("결과 보기", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
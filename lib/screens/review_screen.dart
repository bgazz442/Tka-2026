import 'package:flutter/material.dart';
import '../models/exam_result.dart';
import '../models/question.dart';
import '../utils/constants.dart';
import '../widgets/question_card.dart';

class ReviewScreen extends StatefulWidget {
  final ExamResult result;

  const ReviewScreen({
    super.key,
    required this.result,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final breakdownList = widget.result.breakdown;
    if (breakdownList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review Jawaban')),
        body: const Center(child: Text('Data review tidak tersedia.')),
      );
    }

    final currentBreakdown = breakdownList[_currentIndex];

    // Reconstruct a Question object for QuestionCardWidget rendering
    final question = Question(
      id: currentBreakdown.id,
      stimulus: currentBreakdown.stimulus,
      question: currentBreakdown.question,
      options: currentBreakdown.options,
      correctAnswer: currentBreakdown.correctAnswer,
      explanation: currentBreakdown.explanation,
    );

    Color statusBgColor = const Color(0xFFF1F5F9);
    Color statusTextColor = const Color(0xFF64748B);
    String statusText = 'TIDAK DIJAWAB';
    IconData statusIcon = Icons.remove_circle_outline_rounded;

    if (currentBreakdown.status == 'correct') {
      statusBgColor = const Color(0xFFF0FDF4);
      statusTextColor = const Color(0xFF16A34A);
      statusText = 'BENAR';
      statusIcon = Icons.check_circle_rounded;
    } else if (currentBreakdown.status == 'wrong') {
      statusBgColor = const Color(0xFFFFF1F2);
      statusTextColor = const Color(0xFFDC2626);
      statusText = 'SALAH';
      statusIcon = Icons.cancel_rounded;
    }

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text('Review (${_currentIndex + 1}/${breakdownList.length})'),
      ),
      body: Column(
        children: [
          // Status indicator bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: statusBgColor,
            child: Row(
              children: [
                Icon(statusIcon, color: statusTextColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  'STATUS: $statusText',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusTextColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Text(
                  'Jawaban kamu: ${currentBreakdown.userAnswer ?? "-"} | Benar: ${currentBreakdown.correctAnswer}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),

          // Question Card
          Expanded(
            child: QuestionCardWidget(
              question: question,
              selectedAnswer: currentBreakdown.userAnswer,
              isReviewMode: true,
            ),
          ),
        ],
      ),

      // Bottom Navigation controls
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _currentIndex > 0
                    ? () => setState(() => _currentIndex--)
                    : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Sebelumnya'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _currentIndex < breakdownList.length - 1
                    ? () => setState(() => _currentIndex++)
                    : () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  _currentIndex < breakdownList.length - 1
                      ? 'Berikutnya'
                      : 'Selesai Review',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

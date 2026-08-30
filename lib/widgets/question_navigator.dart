import 'package:flutter/material.dart';
import '../models/question.dart';

class QuestionNavigatorWidget extends StatelessWidget {
  final List<Question> questions;
  final int currentIndex;
  final Map<int, String> answers;
  final Set<int> flaggedQuestions;
  final ValueChanged<int> onSelectQuestion;

  const QuestionNavigatorWidget({
    super.key,
    required this.questions,
    required this.currentIndex,
    required this.answers,
    required this.flaggedQuestions,
    required this.onSelectQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Navigasi Soal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
                color: const Color(0xFF64748B),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Status Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegend(const Color(0xFFF1F5F9), const Color(0xFF64748B),
                  'Belum dijawab'),
              _buildLegend(const Color(0xFF4F46E5), Colors.white, 'Dijawab'),
              _buildLegend(
                  const Color(0xFFFFFBEB), const Color(0xFFD97706), 'Ditandai',
                  borderColor: const Color(0xFFF59E0B)),
            ],
          ),
          const SizedBox(height: 20),

          // Grid of Question Numbers
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(questions.length, (index) {
                  final q = questions[index];
                  final isAnswered =
                      answers.containsKey(q.id) && answers[q.id]!.isNotEmpty;
                  final isFlagged = flaggedQuestions.contains(q.id);
                  final isActive = index == currentIndex;

                  Color itemBg = const Color(0xFFF1F5F9);
                  Color itemTextColor = const Color(0xFF475569);
                  Border? itemBorder;

                  if (isAnswered) {
                    itemBg = const Color(0xFF4F46E5);
                    itemTextColor = Colors.white;
                  }

                  if (isFlagged) {
                    itemBg = const Color(0xFFFFFBEB);
                    itemTextColor = const Color(0xFFD97706);
                    itemBorder =
                        Border.all(color: const Color(0xFFF59E0B), width: 2);
                  }

                  if (isActive) {
                    itemBorder =
                        Border.all(color: const Color(0xFF4F46E5), width: 2.5);
                  }

                  return GestureDetector(
                    onTap: () {
                      onSelectQuestion(index);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: itemBg,
                        borderRadius: BorderRadius.circular(12),
                        border: itemBorder,
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF4F46E5)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: itemTextColor,
                              ),
                            ),
                          ),
                          if (isFlagged)
                            const Positioned(
                              top: 4,
                              right: 4,
                              child: Icon(
                                Icons.bookmark_rounded,
                                size: 12,
                                color: Color(0xFFD97706),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLegend(Color bg, Color text, String label,
      {Color? borderColor}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(4),
            border: borderColor != null ? Border.all(color: borderColor) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
      ],
    );
  }
}

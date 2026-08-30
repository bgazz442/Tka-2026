import 'package:flutter/material.dart';
import '../models/question.dart';
import 'answer_option.dart';
import 'math_text.dart';

class QuestionCardWidget extends StatelessWidget {
  final Question question;
  final String? selectedAnswer;
  final ValueChanged<String>? onAnswerSelected;

  // Review mode properties
  final bool isReviewMode;

  const QuestionCardWidget({
    super.key,
    required this.question,
    this.selectedAnswer,
    this.onAnswerSelected,
    this.isReviewMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stimulus text if present
          if (question.stimulus != null &&
              question.stimulus!.trim().isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.menu_book_rounded,
                          size: 16, color: Color(0xFF4F46E5)),
                      SizedBox(width: 6),
                      Text(
                        'STIMULUS / TEKS BACAAN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4F46E5),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  MathText(
                    text: question.stimulus!,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Question Image if present
          if (question.imageUrl != null &&
              question.imageUrl!.trim().isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                question.imageUrl!,
                fit: BoxFit.contain,
                width: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 180,
                    color: const Color(0xFFF1F5F9),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.broken_image_rounded,
                          color: Color(0xFFEF4444)),
                      SizedBox(width: 8),
                      Text(
                        'Gambar tidak dapat dimuat.',
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFFDC2626)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Question prompt text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PERTANYAAN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                MathText(
                  text: question.question,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Options list
          const Text(
            'PILIH JAWABAN',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF94A3B8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),

          ...question.options.entries.map((entry) {
            final optionId = entry.key;
            final optionText = entry.value;

            final isSelected = selectedAnswer == optionId;
            final isCorrect = isReviewMode && question.correctAnswer == optionId;
            final isUser = isReviewMode && selectedAnswer == optionId;

            return AnswerOptionWidget(
              optionId: optionId,
              text: optionText,
              isSelected: isSelected,
              isReviewMode: isReviewMode,
              isCorrectAnswer: isCorrect,
              isUserAnswer: isUser,
              onTap: isReviewMode
                  ? null
                  : () {
                      if (onAnswerSelected != null) {
                        onAnswerSelected!(optionId);
                      }
                    },
            );
          }),

          // Review Pembahasan (if review mode)
          if (isReviewMode &&
              question.explanation != null &&
              question.explanation!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb_rounded,
                          color: Color(0xFF2563EB), size: 18),
                      SizedBox(width: 6),
                      Text(
                        'PEMBAHASAN',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D4ED8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  MathText(
                    text: question.explanation!,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

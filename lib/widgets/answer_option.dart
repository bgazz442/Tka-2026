import 'package:flutter/material.dart';
import 'math_text.dart';

class AnswerOptionWidget extends StatelessWidget {
  final String optionId;
  final String text;
  final bool isSelected;
  final VoidCallback? onTap;

  // Review mode properties
  final bool isReviewMode;
  final bool isCorrectAnswer;
  final bool isUserAnswer;

  const AnswerOptionWidget({
    super.key,
    required this.optionId,
    required this.text,
    this.isSelected = false,
    this.onTap,
    this.isReviewMode = false,
    this.isCorrectAnswer = false,
    this.isUserAnswer = false,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = const Color(0xFFE2E8F0);
    Color bgColor = Colors.white;
    Color circleColor = const Color(0xFFF1F5F9);
    Color circleTextColor = const Color(0xFF475569);

    if (isReviewMode) {
      if (isCorrectAnswer) {
        borderColor = const Color(0xFF22C55E);
        bgColor = const Color(0xFFF0FDF4);
        circleColor = const Color(0xFF22C55E);
        circleTextColor = Colors.white;
      } else if (isUserAnswer && !isCorrectAnswer) {
        borderColor = const Color(0xFFEF4444);
        bgColor = const Color(0xFFFFF1F2);
        circleColor = const Color(0xFFEF4444);
        circleTextColor = Colors.white;
      }
    } else {
      if (isSelected) {
        borderColor = const Color(0xFF4F46E5);
        bgColor = const Color(0xFFEEF2FF);
        circleColor = const Color(0xFF4F46E5);
        circleTextColor = Colors.white;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: isSelected || (isReviewMode && (isCorrectAnswer || isUserAnswer)) ? 2 : 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Option Circle (A, B, C, D, E)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: circleColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      optionId,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: circleTextColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Option Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: MathText(
                      text: text,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: isSelected
                            ? const Color(0xFF312E81)
                            : const Color(0xFF1E293B),
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),

                if (isReviewMode) ...[
                  const SizedBox(width: 8),
                  if (isCorrectAnswer)
                    const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF22C55E), size: 22)
                  else if (isUserAnswer && !isCorrectAnswer)
                    const Icon(Icons.cancel_rounded,
                        color: Color(0xFFEF4444), size: 22),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

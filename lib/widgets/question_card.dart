import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/question_type.dart';
import 'answer_option.dart';
import 'math_text.dart';

class QuestionCardWidget extends StatelessWidget {
  final Question question;

  /// For single-choice: the selected option key ('A', 'B', …)
  /// For multi-select: comma-separated keys ('A,C')
  /// For true/false: comma-separated "key:True/False" pairs
  final dynamic selectedAnswer;

  final ValueChanged<String>? onAnswerSelected;

  /// Called when a True/False sub-answer is changed.
  /// Params: statementKey, 'True'|'False'
  final void Function(String key, String value)? onTrueFalseSelected;

  final bool isReviewMode;

  const QuestionCardWidget({
    super.key,
    required this.question,
    this.selectedAnswer,
    this.onAnswerSelected,
    this.onTrueFalseSelected,
    this.isReviewMode = false,
  });

  // ─── Parse helpers ──────────────────────────────────────────────────────────

  Set<String> get _selectedSet {
    if (selectedAnswer == null) return {};
    if (selectedAnswer is String) {
      return selectedAnswer
          .toString()
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toSet();
    }
    if (selectedAnswer is List) {
      return (selectedAnswer as List).map((s) => s.toString()).toSet();
    }
    return {};
  }

  Map<String, String> get _tfAnswers {
    // e.g. "1:True,2:False,3:True"
    final result = <String, String>{};
    if (selectedAnswer == null) return result;
    for (final pair in selectedAnswer.toString().split(',')) {
      final parts = pair.split(':');
      if (parts.length == 2) result[parts[0].trim()] = parts[1].trim();
    }
    return result;
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStimulus(),
          _buildImage(),
          _buildQuestionText(),
          const SizedBox(height: 20),
          _buildAnswerSection(context),
          _buildExplanation(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Stimulus ───────────────────────────────────────────────────────────────

  Widget _buildStimulus() {
    if (question.stimulus == null || question.stimulus!.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
    );
  }

  // ─── Image ──────────────────────────────────────────────────────────────────

  Widget _buildImage() {
    if (question.imageUrl == null || question.imageUrl!.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            question.imageUrl!,
            fit: BoxFit.contain,
            width: double.infinity,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                height: 180,
                color: const Color(0xFFF1F5F9),
                child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2)),
              );
            },
            errorBuilder: (context, error, stack) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.broken_image_rounded, color: Color(0xFFEF4444)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ilustrasi soal tidak dapat dimuat.',
                      style:
                          TextStyle(fontSize: 12, color: Color(0xFFDC2626)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ─── Question text ──────────────────────────────────────────────────────────

  Widget _buildQuestionText() {
    return Container(
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
          Row(
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
              const SizedBox(width: 8),
              if (question.questionType != QuestionType.singleChoice)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    question.questionType.label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF4F46E5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          MathText(
            text: question.questionText,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.4,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Answer section dispatcher ──────────────────────────────────────────────

  Widget _buildAnswerSection(BuildContext context) {
    switch (question.questionType) {
      case QuestionType.trueOrFalse:
        return _buildTrueFalseOptions();
      case QuestionType.suitableOrNot:
        return _buildSuitableOrNotOptions();
      case QuestionType.multipleChoice:
      case QuestionType.complexChoice:
        return _buildMultiSelectOptions();
      default:
        return _buildSingleChoiceOptions();
    }
  }

  // ─── Single choice ──────────────────────────────────────────────────────────

  Widget _buildSingleChoiceOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          final isSelected = selectedAnswer == optionId;
          final isCorrect =
              isReviewMode && question.correctAnswers.contains(optionId);
          final isUser = isReviewMode && selectedAnswer == optionId;

          return AnswerOptionWidget(
            optionId: optionId,
            text: entry.value,
            isSelected: isSelected,
            isReviewMode: isReviewMode,
            isCorrectAnswer: isCorrect,
            isUserAnswer: isUser,
            onTap: isReviewMode
                ? null
                : () => onAnswerSelected?.call(optionId),
          );
        }),
      ],
    );
  }

  // ─── Multi-select (checkbox) ─────────────────────────────────────────────────

  Widget _buildMultiSelectOptions() {
    final selected = _selectedSet;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PILIH SEMUA JAWABAN YANG BENAR',
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
          final isSelected = selected.contains(optionId);
          final isCorrect =
              isReviewMode && question.correctAnswers.contains(optionId);
          final isUser = isReviewMode && selected.contains(optionId);

          return _MultiSelectOption(
            optionId: optionId,
            text: entry.value,
            isSelected: isSelected,
            isReviewMode: isReviewMode,
            isCorrectAnswer: isCorrect,
            isUserAnswer: isUser,
            onTap: isReviewMode
                ? null
                : () => onAnswerSelected?.call(optionId),
          );
        }),
      ],
    );
  }

  // ─── True / False ────────────────────────────────────────────────────────────

  Widget _buildTrueFalseOptions() {
    final tfAnswers = _tfAnswers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TENTUKAN BENAR / SALAH',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        ...question.options.entries.toList().asMap().entries.map((entry) {
          final idx = (entry.key + 1).toString();
          final optionId = entry.value.key;
          final text = entry.value.value;
          final userChoice = tfAnswers[optionId] ?? tfAnswers[idx];
          final correctChoice = isReviewMode &&
                  question.correctAnswers.length > entry.key
              ? question.correctAnswers[entry.key]
              : null;

          return _TrueFalseRow(
            statementKey: optionId,
            statementText: text,
            selectedValue: userChoice,
            correctValue: correctChoice,
            isReviewMode: isReviewMode,
            onSelect: isReviewMode
                ? null
                : (val) => onTrueFalseSelected?.call(optionId, val),
          );
        }),
      ],
    );
  }

  // ─── Sesuai / Tidak Sesuai ──────────────────────────────────────────────────

  Widget _buildSuitableOrNotOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SESUAI / TIDAK SESUAI',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        ...question.options.entries.toList().asMap().entries.map((entry) {
          final optionId = entry.value.key;
          final text = entry.value.value;
          final tfAnswers = _tfAnswers;
          final userChoice = tfAnswers[optionId];
          final correctChoice = isReviewMode &&
                  question.correctAnswers.length > entry.key
              ? question.correctAnswers[entry.key]
              : null;

          return _TrueFalseRow(
            statementKey: optionId,
            statementText: text,
            selectedValue: userChoice,
            correctValue: correctChoice,
            isReviewMode: isReviewMode,
            trueLabel: 'Sesuai',
            falseLabel: 'Tidak Sesuai',
            onSelect: isReviewMode
                ? null
                : (val) => onTrueFalseSelected?.call(optionId, val),
          );
        }),
      ],
    );
  }

  // ─── Explanation ────────────────────────────────────────────────────────────

  Widget _buildExplanation() {
    if (!isReviewMode) return const SizedBox.shrink();
    final exp = question.explanation;
    if (exp == null || exp.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
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
                text: exp,
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
    );
  }
}

// ─── Multi-select option widget ──────────────────────────────────────────────

class _MultiSelectOption extends StatelessWidget {
  final String optionId;
  final String text;
  final bool isSelected;
  final bool isReviewMode;
  final bool isCorrectAnswer;
  final bool isUserAnswer;
  final VoidCallback? onTap;

  const _MultiSelectOption({
    required this.optionId,
    required this.text,
    required this.isSelected,
    required this.isReviewMode,
    required this.isCorrectAnswer,
    required this.isUserAnswer,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = const Color(0xFFE2E8F0);
    Color bgColor = Colors.white;
    Color checkColor = const Color(0xFFF1F5F9);
    Color checkIconColor = const Color(0xFF94A3B8);

    if (isReviewMode) {
      if (isCorrectAnswer) {
        borderColor = const Color(0xFF22C55E);
        bgColor = const Color(0xFFF0FDF4);
        checkColor = const Color(0xFF22C55E);
        checkIconColor = Colors.white;
      } else if (isUserAnswer && !isCorrectAnswer) {
        borderColor = const Color(0xFFEF4444);
        bgColor = const Color(0xFFFFF1F2);
        checkColor = const Color(0xFFEF4444);
        checkIconColor = Colors.white;
      }
    } else if (isSelected) {
      borderColor = const Color(0xFF4F46E5);
      bgColor = const Color(0xFFEEF2FF);
      checkColor = const Color(0xFF4F46E5);
      checkIconColor = Colors.white;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox indicator
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: checkColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: isSelected || (isReviewMode && isCorrectAnswer)
                        ? Icon(Icons.check_rounded,
                            size: 18, color: checkIconColor)
                        : const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: MathText(
                      text: '$optionId. $text',
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

// ─── True/False row widget ──────────────────────────────────────────────────

class _TrueFalseRow extends StatelessWidget {
  final String statementKey;
  final String statementText;
  final String? selectedValue;
  final String? correctValue;
  final bool isReviewMode;
  final String trueLabel;
  final String falseLabel;
  final void Function(String value)? onSelect;

  const _TrueFalseRow({
    required this.statementKey,
    required this.statementText,
    this.selectedValue,
    this.correctValue,
    required this.isReviewMode,
    this.trueLabel = 'Benar',
    this.falseLabel = 'Salah',
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final trueSelected = selectedValue == trueLabel;
    final falseSelected = selectedValue == falseLabel;
    final isAnswered = selectedValue != null;

    Color rowBg = Colors.white;
    if (isReviewMode && correctValue != null) {
      final isRowCorrect = selectedValue == correctValue;
      rowBg = isRowCorrect
          ? const Color(0xFFF0FDF4)
          : (isAnswered ? const Color(0xFFFFF1F2) : const Color(0xFFFFFBEB));
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: rowBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MathText(
            text: statementText,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _TFButton(
                  label: trueLabel,
                  isSelected: trueSelected,
                  isCorrect: isReviewMode && correctValue == trueLabel,
                  isWrong: isReviewMode &&
                      trueSelected &&
                      correctValue != trueLabel,
                  isReviewMode: isReviewMode,
                  onTap: isReviewMode ? null : () => onSelect?.call(trueLabel),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TFButton(
                  label: falseLabel,
                  isSelected: falseSelected,
                  isCorrect: isReviewMode && correctValue == falseLabel,
                  isWrong: isReviewMode &&
                      falseSelected &&
                      correctValue != falseLabel,
                  isReviewMode: isReviewMode,
                  onTap: isReviewMode ? null : () => onSelect?.call(falseLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TFButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final bool isReviewMode;
  final VoidCallback? onTap;

  const _TFButton({
    required this.label,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.isReviewMode,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = const Color(0xFFF1F5F9);
    Color border = const Color(0xFFE2E8F0);
    Color text = const Color(0xFF64748B);

    if (isCorrect) {
      bg = const Color(0xFF22C55E);
      border = const Color(0xFF16A34A);
      text = Colors.white;
    } else if (isWrong) {
      bg = const Color(0xFFEF4444);
      border = const Color(0xFFDC2626);
      text = Colors.white;
    } else if (isSelected) {
      bg = const Color(0xFF4F46E5);
      border = const Color(0xFF4338CA);
      text = Colors.white;
    }

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

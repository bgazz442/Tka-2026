import '../models/question.dart';
import '../models/exam_result.dart';
import '../models/question_type.dart';

class ScoringService {
  /// Calculate the full exam result from questions + user answers.
  ///
  /// [answers] maps question.id (String) → user answer value.
  /// For single-choice that is the option letter ('A', 'B', …).
  /// For multi-select that is a comma-joined list ('A,C,E').
  static ExamResult calculate({
    required String uid,
    required String username,
    required String subjectId,
    required String packageId,
    required String packageName,
    required List<Question> questions,
    required Map<String, dynamic> answers,
    required List<String> flaggedQuestions,
    required int durationSeconds,
    required String startedAt,
    required int warningsCount,
    String? resultId,
    int scoreCorrect = 4,
    int scoreWrong = -1,
    int scoreEmpty = 0,
  }) {
    int correctCount = 0;
    int wrongCount = 0;
    int emptyCount = 0;
    int rawScore = 0;

    final breakdownList = <QuestionBreakdown>[];

    for (final q in questions) {
      // Normalise the stored answer value
      final rawAnswer = answers[q.id];
      dynamic userAnswer;
      if (rawAnswer == null || (rawAnswer is String && rawAnswer.trim().isEmpty)) {
        userAnswer = null;
      } else if (q.questionType.allowsMultipleAnswers && rawAnswer is String) {
        // Convert comma-separated back to list
        userAnswer = rawAnswer.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      } else {
        userAnswer = rawAnswer;
      }

      String status;
      int questionScore;

      if (userAnswer == null) {
        status = 'empty';
        emptyCount++;
        questionScore = scoreEmpty;
      } else if (q.isCorrect(userAnswer)) {
        status = 'correct';
        correctCount++;
        questionScore = scoreCorrect;
      } else {
        status = 'wrong';
        wrongCount++;
        questionScore = scoreWrong;
      }

      rawScore += questionScore;

      breakdownList.add(QuestionBreakdown(
        questionId: q.id,
        displayNumber: q.displayNumber,
        question: q.questionText,
        stimulus: q.stimulus,
        options: q.options,
        userAnswer: _formatAnswerForDisplay(userAnswer),
        correctAnswer: q.correctAnswers.join(', '),
        correctAnswers: q.correctAnswers,
        status: status,
        explanation: q.explanation ??
            'Pembahasan belum tersedia untuk soal ini.',
        questionType: q.questionType,
      ));
    }

    final int maxPossible = questions.length * scoreCorrect;
    final int clampedRaw = rawScore < 0 ? 0 : rawScore;
    final int finalScore =
        maxPossible > 0 ? ((clampedRaw / maxPossible) * 100).round() : 0;

    final finalResultId =
        resultId ?? '$packageId-${DateTime.now().millisecondsSinceEpoch}';

    // Normalise answers map to String→String for storage
    final Map<String, String> normAnswers = {};
    answers.forEach((k, v) {
      if (v != null) normAnswers[k] = v.toString();
    });

    return ExamResult(
      id: finalResultId,
      uid: uid,
      username: username,
      subjectId: subjectId,
      packageId: packageId,
      packageName: packageName,
      score: finalScore,
      correct: correctCount,
      wrong: wrongCount,
      empty: emptyCount,
      rawScore: rawScore,
      maxPossibleScore: maxPossible,
      durationSeconds: durationSeconds,
      startedAt: startedAt,
      completedAt: DateTime.now().toIso8601String(),
      answers: normAnswers,
      flaggedQuestions: flaggedQuestions,
      warningsCount: warningsCount,
      breakdown: breakdownList,
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  static String? _formatAnswerForDisplay(dynamic answer) {
    if (answer == null) return null;
    if (answer is List) return answer.join(', ');
    return answer.toString();
  }

  static String formatDurationText(int seconds) {
    if (seconds <= 0) return '0 detik';
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '$h jam $m menit $s detik';
    if (m > 0) return '$m menit $s detik';
    return '$s detik';
  }

  static String formatClock(int seconds) {
    if (seconds <= 0) return '00:00';
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    if (h > 0) return '${h.toString().padLeft(2, '0')}:$mm:$ss';
    return '$mm:$ss';
  }

  static double calculateAccuracy(int correct, int total) {
    if (total == 0) return 0.0;
    return (correct / total) * 100;
  }

  static String getPerformanceRating(int score) {
    if (score >= 90) return 'Sempurna';
    if (score >= 80) return 'Sangat Baik';
    if (score >= 70) return 'Baik';
    if (score >= 60) return 'Cukup';
    if (score >= 50) return 'Kurang';
    return 'Perlu Perbaikan';
  }
}

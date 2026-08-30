import '../models/question.dart';
import '../models/exam_result.dart';

class ScoringService {
  /// Calculate tryout result based on user answers and questions
  static ExamResult calculate({
    required String uid,
    required String username,
    required String subjectId,
    required String packageId,
    required String packageName,
    required List<Question> questions,
    required Map<int, String> answers,
    required List<int> flaggedQuestions,
    required int durationSeconds,
    required String startedAt,
    required int warningsCount,
    String? resultId, // Pre-generated unique ID from caller
    int scoreCorrect = 4,
    int scoreWrong = -1,
    int scoreEmpty = 0,
  }) {
    int correctCount = 0;
    int wrongCount = 0;
    int emptyCount = 0;
    int rawScore = 0;

    final List<QuestionBreakdown> breakdownList = [];

    for (final q in questions) {
      final userAnswer = answers[q.id];
      final correctAnswer = q.correctAnswer;

      String status;
      if (userAnswer == null || userAnswer.trim().isEmpty) {
        status = 'empty';
        emptyCount++;
        rawScore += scoreEmpty;
      } else if (userAnswer.trim().toUpperCase() ==
          correctAnswer.trim().toUpperCase()) {
        status = 'correct';
        correctCount++;
        rawScore += scoreCorrect;
      } else {
        status = 'wrong';
        wrongCount++;
        rawScore += scoreWrong;
      }

      breakdownList.add(QuestionBreakdown(
        id: q.id,
        question: q.question,
        stimulus: q.stimulus,
        options: q.options,
        userAnswer: userAnswer,
        correctAnswer: correctAnswer,
        status: status,
        explanation: q.explanation,
      ));
    }

    final int maxPossible = questions.length * scoreCorrect;
    final int clampedRaw = rawScore < 0 ? 0 : rawScore;
    final int finalScore = maxPossible > 0
        ? ((clampedRaw / maxPossible) * 100).round()
        : 0;

    final finalResultId =
        resultId ?? '$packageId-${DateTime.now().millisecondsSinceEpoch}';

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
      answers: answers,
      flaggedQuestions: flaggedQuestions,
      warningsCount: warningsCount,
      breakdown: breakdownList,
    );
  }

  /// Format duration seconds into human readable text (e.g. "68 menit 24 detik")
  static String formatDurationText(int seconds) {
    if (seconds <= 0) return '0 detik';
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;

    if (h > 0) {
      return '$h jam $m menit $s detik';
    } else if (m > 0) {
      return '$m menit $s detik';
    } else {
      return '$s detik';
    }
  }

  /// Format seconds into clock format (HH:MM:SS or MM:SS)
  static String formatClock(int seconds) {
    if (seconds <= 0) return '00:00';
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;

    final String mStr = m.toString().padLeft(2, '0');
    final String sStr = s.toString().padLeft(2, '0');

    if (h > 0) {
      final String hStr = h.toString().padLeft(2, '0');
      return '$hStr:$mStr:$sStr';
    }
    return '$mStr:$sStr';
  }
}

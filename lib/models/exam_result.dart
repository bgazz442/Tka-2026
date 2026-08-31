import 'question.dart';
import 'question_type.dart';

/// Per-question breakdown stored inside ExamResult.
class QuestionBreakdown {
  final String questionId;
  final int displayNumber;
  final String question;
  final String? stimulus;
  final Map<String, String> options;
  final String? userAnswer;
  final String correctAnswer; // comma-joined for multi-answer
  final String status; // 'correct' | 'wrong' | 'empty'
  final String? explanation;
  final QuestionType questionType;
  final List<String> correctAnswers;

  const QuestionBreakdown({
    required this.questionId,
    required this.displayNumber,
    required this.question,
    this.stimulus,
    required this.options,
    this.userAnswer,
    required this.correctAnswer,
    required this.status,
    this.explanation,
    this.questionType = QuestionType.singleChoice,
    this.correctAnswers = const [],
  });

  // ─── Legacy getter used in ReviewScreen ────────────────────────────────────
  /// Returns displayNumber for backward compat with old `id` references.
  int get id => displayNumber;

  // ─── Reconstruction into Question for ReviewScreen ─────────────────────────
  Question toQuestion() => Question(
        id: questionId,
        displayNumber: displayNumber,
        questionText: question,
        stimulus: stimulus,
        options: options,
        correctAnswers: correctAnswers.isNotEmpty
            ? correctAnswers
            : correctAnswer.split(',').map((s) => s.trim()).toList(),
        explanation: explanation,
        questionType: questionType,
      );

  // ─── Serialisation ─────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'displayNumber': displayNumber,
        'question': question,
        'stimulus': stimulus,
        'options': options,
        'userAnswer': userAnswer,
        'correctAnswer': correctAnswer,
        'status': status,
        'explanation': explanation,
        'questionType': questionType.toString(),
        'correctAnswers': correctAnswers,
      };

  factory QuestionBreakdown.fromJson(Map<String, dynamic> json) {
    final typeStr = json['questionType'] as String?;
    QuestionType qType = QuestionType.singleChoice;
    if (typeStr != null) {
      try {
        qType = QuestionType.values.firstWhere(
          (t) => t.toString() == typeStr,
          orElse: () => parseQuestionType(typeStr),
        );
      } catch (_) {
        qType = parseQuestionType(typeStr);
      }
    }

    // Support both old (id/int) and new (questionId/string) serialisation
    final rawId = json['questionId'] ?? json['id'];
    final questionId = rawId?.toString() ?? '';
    final displayNumber = json['displayNumber'] as int? ??
        (rawId is int ? rawId : int.tryParse(questionId) ?? 0);

    List<String> parsedCorrectAnswers;
    final raw = json['correctAnswers'];
    if (raw is List) {
      parsedCorrectAnswers = raw.cast<String>();
    } else {
      final single = json['correctAnswer'] as String? ?? '';
      parsedCorrectAnswers =
          single.isNotEmpty ? single.split(',').map((s) => s.trim()).toList() : [];
    }

    return QuestionBreakdown(
      questionId: questionId,
      displayNumber: displayNumber,
      question: json['question'] as String? ?? '',
      stimulus: json['stimulus'] as String?,
      options: Map<String, String>.from(json['options'] as Map? ?? {}),
      userAnswer: json['userAnswer'] as String?,
      correctAnswer: json['correctAnswer'] as String? ?? '',
      status: json['status'] as String? ?? 'empty',
      explanation: json['explanation'] as String?,
      questionType: qType,
      correctAnswers: parsedCorrectAnswers,
    );
  }
}

// ─── ExamResult ─────────────────────────────────────────────────────────────

class ExamResult {
  final String id;
  final String uid;
  final String username;
  final String subjectId;
  final String packageId;
  final String packageName;
  final int score;
  final int correct;
  final int wrong;
  final int empty;
  final int rawScore;
  final int maxPossibleScore;
  final int durationSeconds;
  final String startedAt;
  final String completedAt;

  /// Answers keyed by questionId (String) → answer value (String,
  /// comma-joined for multi-select).
  final Map<String, String> answers;
  final List<String> flaggedQuestions;
  final int warningsCount;
  final List<QuestionBreakdown> breakdown;

  const ExamResult({
    required this.id,
    required this.uid,
    required this.username,
    required this.subjectId,
    required this.packageId,
    required this.packageName,
    required this.score,
    required this.correct,
    required this.wrong,
    required this.empty,
    required this.rawScore,
    required this.maxPossibleScore,
    required this.durationSeconds,
    required this.startedAt,
    required this.completedAt,
    required this.answers,
    required this.flaggedQuestions,
    required this.warningsCount,
    required this.breakdown,
  });

  int get totalQuestions => correct + wrong + empty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'uid': uid,
        'username': username,
        'subjectId': subjectId,
        'packageId': packageId,
        'packageName': packageName,
        'score': score,
        'correct': correct,
        'wrong': wrong,
        'empty': empty,
        'rawScore': rawScore,
        'maxPossibleScore': maxPossibleScore,
        'durationSeconds': durationSeconds,
        'startedAt': startedAt,
        'completedAt': completedAt,
        'answers': answers,
        'flaggedQuestions': flaggedQuestions,
        'warningsCount': warningsCount,
        'breakdown': breakdown.map((b) => b.toJson()).toList(),
      };

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    // Answers: support both old (int key) and new (string key) formats
    final Map<String, String> parsedAnswers = {};
    if (json['answers'] != null) {
      (json['answers'] as Map).forEach((k, v) {
        parsedAnswers[k.toString()] = v.toString();
      });
    }

    // Flagged: support both old (int) and new (string) formats
    final List<String> parsedFlagged = [];
    if (json['flaggedQuestions'] != null) {
      for (final f in json['flaggedQuestions'] as List) {
        parsedFlagged.add(f.toString());
      }
    }

    return ExamResult(
      id: json['id'] as String,
      uid: json['uid'] as String? ?? '',
      username: json['username'] as String,
      subjectId: json['subjectId'] as String,
      packageId: json['packageId'] as String,
      packageName: json['packageName'] as String,
      score: json['score'] as int,
      correct: json['correct'] as int,
      wrong: json['wrong'] as int,
      empty: json['empty'] as int,
      rawScore: json['rawScore'] as int,
      maxPossibleScore: json['maxPossibleScore'] as int? ?? 100,
      durationSeconds: json['durationSeconds'] as int,
      startedAt: json['startedAt'] as String,
      completedAt: json['completedAt'] as String,
      answers: parsedAnswers,
      flaggedQuestions: parsedFlagged,
      warningsCount: json['warningsCount'] as int? ?? 0,
      breakdown: (json['breakdown'] as List?)
              ?.map((b) => QuestionBreakdown.fromJson(b as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

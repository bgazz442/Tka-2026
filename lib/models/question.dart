import 'question_type.dart';

class Question {
  /// Unique identifier for this question
  final String id;

  /// Reference to source question (for mapping back to source)
  final String? sourceId;
  final String? sourceUrl;
  final int? sourceQuestionNumber;

  /// Subject and package tracking
  final String subjectId;
  final String packageId;
  final String packageName;

  /// Question metadata
  final QuestionType questionType;
  final int displayNumber;

  /// Stimulus/passage shared across multiple questions
  final String? stimulus;
  final String? stimulusImageUrl;

  /// Main question content
  final String questionText;
  final String? imageUrl;
  final Map<String, String> options;

  /// Answer key(s) - List to support multiple/complex choice
  final List<String> correctAnswers;

  /// Explanation/pembahasan
  final String? explanation;

  /// Scoring configuration
  final int scoreCorrect;
  final int scoreWrong;
  final int scoreEmpty;

  /// Scoring rule for complex/multiple choice: 'exact', 'partial', 'any'
  final String scoringRule;

  /// Metadata
  final Map<String, dynamic>? metadata;

  const Question({
    required this.id,
    this.sourceId,
    this.sourceUrl,
    this.sourceQuestionNumber,
    this.subjectId = '',
    this.packageId = '',
    this.packageName = '',
    this.questionType = QuestionType.singleChoice,
    this.displayNumber = 0,
    this.stimulus,
    this.stimulusImageUrl,
    required this.questionText,
    this.imageUrl,
    required this.options,
    required this.correctAnswers,
    this.explanation,
    this.scoreCorrect = 4,
    this.scoreWrong = -1,
    this.scoreEmpty = 0,
    this.scoringRule = 'exact',
    this.metadata,
  });

  // ─── Legacy compatibility getter ───────────────────────────────────────────

  /// Legacy: first correct answer as a string
  String get correctAnswer =>
      correctAnswers.isNotEmpty ? correctAnswers.first : '';

  /// Legacy alias for questionText
  String get question => questionText;

  // ─── Core logic ────────────────────────────────────────────────────────────

  /// Checks whether the given userAnswer is correct.
  /// Supports String, List<String>, and null.
  bool isCorrect(dynamic userAnswer) {
    if (userAnswer == null) return false;

    if (questionType.allowsMultipleAnswers) {
      final List<String> userAnswers = userAnswer is List
          ? userAnswer.cast<String>()
          : [userAnswer.toString()];

      switch (scoringRule) {
        case 'exact':
          return _listEquals(
            userAnswers.map((a) => a.trim().toUpperCase()).toList(),
            correctAnswers.map((a) => a.trim().toUpperCase()).toList(),
          );
        case 'partial':
        case 'any':
          return userAnswers.any((a) => correctAnswers.any(
              (c) => a.trim().toUpperCase() == c.trim().toUpperCase()));
        default:
          return _listEquals(
            userAnswers.map((a) => a.trim().toUpperCase()).toList(),
            correctAnswers.map((a) => a.trim().toUpperCase()).toList(),
          );
      }
    }

    // Single / trueOrFalse / suitableOrNot
    final userStr = userAnswer.toString().trim().toUpperCase();
    return correctAnswers
        .any((c) => c.trim().toUpperCase() == userStr);
  }

  /// Partial credit fraction (0.0–1.0) for complex/multiple choice.
  double calculatePartialCredit(dynamic userAnswer) {
    if (userAnswer == null) return 0.0;
    if (!questionType.allowsMultipleAnswers) {
      return isCorrect(userAnswer) ? 1.0 : 0.0;
    }

    final List<String> userAnswers = userAnswer is List
        ? userAnswer.cast<String>()
        : [userAnswer.toString()];

    if (scoringRule == 'exact') {
      return isCorrect(userAnswer) ? 1.0 : 0.0;
    }

    if (scoringRule == 'partial' || scoringRule == 'any') {
      if (correctAnswers.isEmpty) return 0.0;
      final correctCount = userAnswers
          .where((a) => correctAnswers.any(
              (c) => a.trim().toUpperCase() == c.trim().toUpperCase()))
          .length;
      return correctCount / correctAnswers.length;
    }

    return 0.0;
  }

  /// Validates required fields. Returns list of error strings (empty = valid).
  List<String> validate() {
    final errors = <String>[];
    if (questionText.trim().isEmpty) errors.add('Question text is empty');
    if (options.isEmpty && !questionType.isTextInput) {
      errors.add('Question has no options');
    }
    if (correctAnswers.isEmpty ||
        (correctAnswers.length == 1 && correctAnswers.first.isEmpty)) {
      errors.add('No correct answer specified');
    }
    return errors;
  }

  // ─── Serialisation ─────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceId': sourceId,
        'sourceUrl': sourceUrl,
        'sourceQuestionNumber': sourceQuestionNumber,
        'subjectId': subjectId,
        'packageId': packageId,
        'packageName': packageName,
        'questionType': questionType.toString(),
        'displayNumber': displayNumber,
        'stimulus': stimulus,
        'stimulusImageUrl': stimulusImageUrl,
        'questionText': questionText,
        'imageUrl': imageUrl,
        'options': options,
        'correctAnswers': correctAnswers,
        'explanation': explanation,
        'scoreCorrect': scoreCorrect,
        'scoreWrong': scoreWrong,
        'scoreEmpty': scoreEmpty,
        'scoringRule': scoringRule,
        'metadata': metadata,
      };

  factory Question.fromJson(Map<String, dynamic> json) {
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

    List<String> parsedCorrectAnswers;
    final raw = json['correctAnswers'];
    if (raw is List) {
      parsedCorrectAnswers = raw.cast<String>();
    } else {
      final single =
          json['correctAnswer'] as String? ?? raw?.toString() ?? '';
      parsedCorrectAnswers = single.isNotEmpty ? [single] : [];
    }

    return Question(
      id: json['id']?.toString() ?? '',
      sourceId: json['sourceId'] as String?,
      sourceUrl: json['sourceUrl'] as String?,
      sourceQuestionNumber: json['sourceQuestionNumber'] as int?,
      subjectId: json['subjectId'] as String? ?? '',
      packageId: json['packageId'] as String? ?? '',
      packageName: json['packageName'] as String? ?? '',
      questionType: qType,
      displayNumber: json['displayNumber'] as int? ?? 0,
      stimulus: json['stimulus'] as String?,
      stimulusImageUrl: json['stimulusImageUrl'] as String?,
      questionText: json['questionText'] as String? ??
          json['question'] as String? ??
          '',
      imageUrl: json['imageUrl'] as String?,
      options: Map<String, String>.from(json['options'] as Map? ?? {}),
      correctAnswers: parsedCorrectAnswers,
      explanation: json['explanation'] as String?,
      scoreCorrect: json['scoreCorrect'] as int? ?? 4,
      scoreWrong: json['scoreWrong'] as int? ?? -1,
      scoreEmpty: json['scoreEmpty'] as int? ?? 0,
      scoringRule: json['scoringRule'] as String? ?? 'exact',
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  // ─── Internal helpers ───────────────────────────────────────────────────────

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    final sa = List<String>.from(a)..sort();
    final sb = List<String>.from(b)..sort();
    return sa.join(',') == sb.join(',');
  }
}

/// Groups of questions that share a common stimulus / passage.
class QuestionGroup {
  final String id;
  final String? stimulus;
  final String? imageUrl;
  final List<Question> questions;

  const QuestionGroup({
    required this.id,
    this.stimulus,
    this.imageUrl,
    required this.questions,
  });
}

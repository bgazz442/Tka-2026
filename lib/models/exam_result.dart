class QuestionBreakdown {
  final int id;
  final String question;
  final String? stimulus;
  final Map<String, String> options;
  final String? userAnswer;
  final String correctAnswer;
  final String status; // 'correct', 'wrong', 'empty'
  final String? explanation;

  const QuestionBreakdown({
    required this.id,
    required this.question,
    this.stimulus,
    required this.options,
    this.userAnswer,
    required this.correctAnswer,
    required this.status,
    this.explanation,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'stimulus': stimulus,
        'options': options,
        'userAnswer': userAnswer,
        'correctAnswer': correctAnswer,
        'status': status,
        'explanation': explanation,
      };

  factory QuestionBreakdown.fromJson(Map<String, dynamic> json) =>
      QuestionBreakdown(
        id: json['id'] as int,
        question: json['question'] as String,
        stimulus: json['stimulus'] as String?,
        options: Map<String, String>.from(json['options'] as Map),
        userAnswer: json['userAnswer'] as String?,
        correctAnswer: json['correctAnswer'] as String,
        status: json['status'] as String,
        explanation: json['explanation'] as String?,
      );
}

class ExamResult {
  final String id;
  final String uid; // Local account ID
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
  final Map<int, String> answers;
  final List<int> flaggedQuestions;
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
        'answers': answers.map((k, v) => MapEntry(k.toString(), v)),
        'flaggedQuestions': flaggedQuestions,
        'warningsCount': warningsCount,
        'breakdown': breakdown.map((b) => b.toJson()).toList(),
      };

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    Map<int, String> parsedAnswers = {};
    if (json['answers'] != null) {
      (json['answers'] as Map).forEach((k, v) {
        parsedAnswers[int.parse(k.toString())] = v.toString();
      });
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
      flaggedQuestions: json['flaggedQuestions'] != null
          ? List<int>.from(json['flaggedQuestions'])
          : [],
      warningsCount: json['warningsCount'] as int? ?? 0,
      breakdown: json['breakdown'] != null
          ? (json['breakdown'] as List)
              .map((b) => QuestionBreakdown.fromJson(b as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

}

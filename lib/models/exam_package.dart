import 'question.dart';

class ExamPackage {
  final String id;
  final String subjectId;
  final String title;
  final String? description;
  final String sourceName;
  final String sourceUrl;
  final List<Question> questions;
  final int defaultScoreCorrect;
  final int defaultScoreWrong;
  final int defaultScoreEmpty;

  const ExamPackage({
    required this.id,
    required this.subjectId,
    required this.title,
    this.description,
    required this.sourceName,
    required this.sourceUrl,
    required this.questions,
    this.defaultScoreCorrect = 4,
    this.defaultScoreWrong = -1,
    this.defaultScoreEmpty = 0,
  });

  /// Automatically calculate total questions count
  int get questionCount => questions.length;

  /// Automatically calculate time limit rules based on total questions count
  /// <= 20 questions = 60 mins
  /// 21-25 questions = 75 mins
  /// 26-30 questions = 90 mins
  /// > 30 questions = 90 mins
  int get durationMinutes {
    final count = questionCount;
    if (count <= 20) return 60;
    if (count <= 25) return 75;
    return 90;
  }

  int get durationSeconds => durationMinutes * 60;
}

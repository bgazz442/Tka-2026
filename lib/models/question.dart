
class Question {
  final int id;
  final String? type;
  final String? stimulus;
  final String question;
  final Map<String, String> options;
  final String correctAnswer;
  final String? explanation;
  final String? imageUrl;
  final int scoreCorrect;
  final int scoreWrong;
  final int scoreEmpty;

  const Question({
    required this.id,
    this.type = 'multiple_choice',
    this.stimulus,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    this.imageUrl,
    this.scoreCorrect = 4,
    this.scoreWrong = -1,
    this.scoreEmpty = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'stimulus': stimulus,
        'question': question,
        'options': options,
        'correctAnswer': correctAnswer,
        'explanation': explanation,
        'imageUrl': imageUrl,
        'scoreCorrect': scoreCorrect,
        'scoreWrong': scoreWrong,
        'scoreEmpty': scoreEmpty,
      };

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json['id'] as int,
        type: json['type'] as String?,
        stimulus: json['stimulus'] as String?,
        question: json['question'] as String,
        options: Map<String, String>.from(json['options'] as Map),
        correctAnswer: json['correctAnswer'] as String,
        explanation: json['explanation'] as String?,
        imageUrl: json['imageUrl'] as String?,
        scoreCorrect: json['scoreCorrect'] as int? ?? 4,
        scoreWrong: json['scoreWrong'] as int? ?? -1,
        scoreEmpty: json['scoreEmpty'] as int? ?? 0,
      );
}

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

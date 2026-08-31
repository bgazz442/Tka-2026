import 'dart:math';
import '../models/question.dart';

/// Service for creating and managing random TKA simulations
class RandomSimulationService {
  static const int defaultSimulationCount = 30;
  static const int minutesPerQuestion = 3;

  /// Create a random simulation from a question pool
  /// Returns questions with randomized order and unique display numbers
  static List<Question> createRandomSimulation({
    required List<Question> questionPool,
    int questionCount = defaultSimulationCount,
    int? seed,
  }) {
    if (questionPool.isEmpty) {
      throw StateError('Question pool is empty');
    }

    if (questionCount > questionPool.length) {
      throw StateError(
        'Cannot create simulation with $questionCount questions from pool of ${questionPool.length}',
      );
    }

    // Use provided seed or generate new one
    final random = Random(seed);

    // Shuffle and select
    final shuffled = List<Question>.from(questionPool)..shuffle(random);
    final selected = shuffled.take(questionCount).toList();

    // Reassign display numbers (1, 2, 3, ...)
    final result = <Question>[];
    for (var i = 0; i < selected.length; i++) {
      final q = selected[i];
      result.add(
        Question(
          id: q.id,
          sourceId: q.sourceId,
          sourceUrl: q.sourceUrl,
          sourceQuestionNumber: q.sourceQuestionNumber,
          subjectId: q.subjectId,
          packageId: q.packageId,
          packageName: q.packageName,
          questionType: q.questionType,
          displayNumber: i + 1, // Reassign display number
          stimulus: q.stimulus,
          stimulusImageUrl: q.stimulusImageUrl,
          questionText: q.questionText,
          imageUrl: q.imageUrl,
          options: q.options,
          correctAnswers: q.correctAnswers,
          explanation: q.explanation,
          scoreCorrect: q.scoreCorrect,
          scoreWrong: q.scoreWrong,
          scoreEmpty: q.scoreEmpty,
          scoringRule: q.scoringRule,
          metadata: q.metadata,
        ),
      );
    }

    return result;
  }

  /// Validate no duplicate questions in a simulation
  static bool validateNoDuplicates(List<Question> questions) {
    final ids = <String>{};
    for (final q in questions) {
      if (ids.contains(q.id)) {
        return false; // Duplicate found
      }
      ids.add(q.id);
    }
    return true; // No duplicates
  }

  /// Calculate timer duration for given question count
  static int calculateDurationSeconds(int questionCount) {
    if (questionCount <= 0) return 0;
    
    // Default: 3 minutes per question
    final minutes = questionCount * minutesPerQuestion;
    
    // But use common TKA timings if applicable
    if (questionCount <= 20) return 60 * 60; // 60 minutes
    if (questionCount <= 25) return 75 * 60; // 75 minutes
    if (questionCount <= 30) return 90 * 60; // 90 minutes
    
    return minutes * 60;
  }

  /// Create simulation metadata for tracking
  static Map<String, dynamic> createSimulationMetadata({
    required String simulationId,
    required int seed,
    required int questionCount,
    required List<String> sourcePackageIds,
  }) {
    return {
      'simulationId': simulationId,
      'seed': seed,
      'questionCount': questionCount,
      'sourcePackageIds': sourcePackageIds,
      'createdAt': DateTime.now().toIso8601String(),
      'isSimulation': true,
    };
  }

  /// Distribute question selection evenly across sources
  /// Tries to select proportional questions from each source
  static List<Question> createBalancedRandomSimulation({
    required Map<String, List<Question>> questionPoolByPackage,
    int questionCount = defaultSimulationCount,
    int? seed,
  }) {
    if (questionPoolByPackage.isEmpty) {
      throw StateError('Question pool map is empty');
    }

    final random = Random(seed);
    final result = <Question>[];
    final packageIds = questionPoolByPackage.keys.toList()..shuffle(random);

    // Calculate target questions per package
    final packagesCount = packageIds.length;
    final targetPerPackage = (questionCount / packagesCount).ceil();

    // Collect questions with distribution
    for (var i = 0; i < packageIds.length; i++) {
      final packageId = packageIds[i];
      final pool = questionPoolByPackage[packageId] ?? [];
      
      // Shuffle this package's questions
      final shuffledPool = List<Question>.from(pool)..shuffle(random);
      
      // Take up to target, but don't exceed total needed
      final needed = questionCount - result.length;
      final take = min(targetPerPackage, min(needed, shuffledPool.length));
      
      result.addAll(shuffledPool.take(take));

      // Early exit if we have enough
      if (result.length >= questionCount) {
        break;
      }
    }

    // Reassign display numbers
    final finalResult = <Question>[];
    for (var i = 0; i < result.length; i++) {
      final q = result[i];
      finalResult.add(
        Question(
          id: q.id,
          sourceId: q.sourceId,
          sourceUrl: q.sourceUrl,
          sourceQuestionNumber: q.sourceQuestionNumber,
          subjectId: q.subjectId,
          packageId: q.packageId,
          packageName: q.packageName,
          questionType: q.questionType,
          displayNumber: i + 1,
          stimulus: q.stimulus,
          stimulusImageUrl: q.stimulusImageUrl,
          questionText: q.questionText,
          imageUrl: q.imageUrl,
          options: q.options,
          correctAnswers: q.correctAnswers,
          explanation: q.explanation,
          scoreCorrect: q.scoreCorrect,
          scoreWrong: q.scoreWrong,
          scoreEmpty: q.scoreEmpty,
          scoringRule: q.scoringRule,
          metadata: q.metadata,
        ),
      );
    }

    return finalResult.take(questionCount).toList();
  }
}

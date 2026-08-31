/// Question import validation report
class QuestionImportReport {
  final String subject;
  final String tryoutId;
  final String tryoutName;
  final String? sourceUrl;
  
  /// Expected count from source
  final int expectedCount;
  
  /// Actual questions parsed
  final int actualCount;
  
  /// Questions that failed to parse
  final List<QuestionImportError> importErrors;
  
  /// Missing questions (expected but not found)
  final List<int> missingQuestionNumbers;
  
  /// Questions missing answer keys
  final List<String> missingAnswerKeys;
  
  /// Questions missing explanations
  final List<String> missingExplanations;
  
  /// Image loading errors
  final List<String> imageErrors;
  
  final DateTime validatedAt;

  QuestionImportReport({
    required this.subject,
    required this.tryoutId,
    required this.tryoutName,
    this.sourceUrl,
    required this.expectedCount,
    required this.actualCount,
    this.importErrors = const [],
    this.missingQuestionNumbers = const [],
    this.missingAnswerKeys = const [],
    this.missingExplanations = const [],
    this.imageErrors = const [],
    DateTime? validatedAt,
  }) : validatedAt = validatedAt ?? DateTime.now();

  /// Overall validation status
  bool get isValid =>
      actualCount == expectedCount &&
      importErrors.isEmpty &&
      missingQuestionNumbers.isEmpty;

  /// Detailed status
  String get statusMessage {
    if (isValid) return 'VALID ✓';
    final issues = <String>[];
    if (actualCount != expectedCount) {
      issues.add('Count mismatch (expected: $expectedCount, got: $actualCount)');
    }
    if (importErrors.isNotEmpty) {
      issues.add('${importErrors.length} parse errors');
    }
    if (missingQuestionNumbers.isNotEmpty) {
      issues.add('${missingQuestionNumbers.length} questions missing');
    }
    return 'INVALID ✗\n${issues.join('\n')}';
  }

  Map<String, dynamic> toJson() => {
        'subject': subject,
        'tryoutId': tryoutId,
        'tryoutName': tryoutName,
        'sourceUrl': sourceUrl,
        'expectedCount': expectedCount,
        'actualCount': actualCount,
        'importErrors': importErrors.map((e) => e.toJson()).toList(),
        'missingQuestionNumbers': missingQuestionNumbers,
        'missingAnswerKeys': missingAnswerKeys,
        'missingExplanations': missingExplanations,
        'imageErrors': imageErrors,
        'validatedAt': validatedAt.toIso8601String(),
      };

  factory QuestionImportReport.fromJson(Map<String, dynamic> json) =>
      QuestionImportReport(
        subject: json['subject'] as String,
        tryoutId: json['tryoutId'] as String,
        tryoutName: json['tryoutName'] as String,
        sourceUrl: json['sourceUrl'] as String?,
        expectedCount: json['expectedCount'] as int,
        actualCount: json['actualCount'] as int,
        importErrors: (json['importErrors'] as List?)
                ?.map((e) => QuestionImportError.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        missingQuestionNumbers:
            List<int>.from(json['missingQuestionNumbers'] as List? ?? []),
        missingAnswerKeys: List<String>.from(json['missingAnswerKeys'] as List? ?? []),
        missingExplanations:
            List<String>.from(json['missingExplanations'] as List? ?? []),
        imageErrors: List<String>.from(json['imageErrors'] as List? ?? []),
        validatedAt: json['validatedAt'] != null
            ? DateTime.parse(json['validatedAt'] as String)
            : DateTime.now(),
      );
}

/// Individual question import error
class QuestionImportError {
  final int? questionNumber;
  final String reason;
  final String? rawContent;

  const QuestionImportError({
    this.questionNumber,
    required this.reason,
    this.rawContent,
  });

  Map<String, dynamic> toJson() => {
        'questionNumber': questionNumber,
        'reason': reason,
        'rawContent': rawContent,
      };

  factory QuestionImportError.fromJson(Map<String, dynamic> json) =>
      QuestionImportError(
        questionNumber: json['questionNumber'] as int?,
        reason: json['reason'] as String,
        rawContent: json['rawContent'] as String?,
      );

  @override
  String toString() =>
      'Question #$questionNumber: $reason${rawContent != null ? '\n$rawContent' : ''}';
}

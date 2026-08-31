/// Question type enumeration for supporting diverse question formats
enum QuestionType {
  singleChoice,        // Single correct answer from multiple options (A-E)
  multipleChoice,      // Multiple correct answers (user selects multiple)
  trueOrFalse,         // Boolean choice
  suitableOrNot,       // Sesuai/Tidak Sesuai choice
  matching,            // Matching pairs
  numericInput,        // User enters numeric value
  shortText,           // User enters short text answer
  imageBased,          // Image-based question with single choice
  tableBased,          // Table with single choice based on table data
  complexChoice,       // Complex multi-select with partial scoring rules
}

extension QuestionTypeExtension on QuestionType {
  String get label {
    switch (this) {
      case QuestionType.singleChoice:
        return 'Pilihan Ganda';
      case QuestionType.multipleChoice:
        return 'Pilihan Ganda Kompleks';
      case QuestionType.trueOrFalse:
        return 'Benar/Salah';
      case QuestionType.suitableOrNot:
        return 'Sesuai/Tidak Sesuai';
      case QuestionType.matching:
        return 'Pencocokan';
      case QuestionType.numericInput:
        return 'Input Angka';
      case QuestionType.shortText:
        return 'Uraian Singkat';
      case QuestionType.imageBased:
        return 'Soal Berbasis Gambar';
      case QuestionType.tableBased:
        return 'Soal Berbasis Tabel';
      case QuestionType.complexChoice:
        return 'Pilihan Kompleks';
    }
  }

  /// Determines if this question type allows multiple answer selection
  bool get allowsMultipleAnswers {
    return [
      QuestionType.multipleChoice,
      QuestionType.complexChoice,
      QuestionType.matching,
    ].contains(this);
  }

  /// Determines if user input is free-form text
  bool get isTextInput {
    return [
      QuestionType.numericInput,
      QuestionType.shortText,
    ].contains(this);
  }

  /// Determines if user must select from predefined options
  bool get hasOptions {
    return !isTextInput;
  }
}

/// Parses question type from string representation
QuestionType parseQuestionType(String? typeStr) {
  if (typeStr == null) return QuestionType.singleChoice;

  final normalized = typeStr.toLowerCase().trim();

  if (normalized.contains('multiple') || normalized.contains('kompleks')) {
    return QuestionType.multipleChoice;
  }
  if (normalized.contains('true') || normalized.contains('false') || normalized.contains('benar') || normalized.contains('salah')) {
    return QuestionType.trueOrFalse;
  }
  if (normalized.contains('sesuai')) {
    return QuestionType.suitableOrNot;
  }
  if (normalized.contains('match')) {
    return QuestionType.matching;
  }
  if (normalized.contains('numeric') || normalized.contains('angka')) {
    return QuestionType.numericInput;
  }
  if (normalized.contains('text') || normalized.contains('uraian')) {
    return QuestionType.shortText;
  }
  if (normalized.contains('image') || normalized.contains('gambar')) {
    return QuestionType.imageBased;
  }
  if (normalized.contains('table') || normalized.contains('tabel')) {
    return QuestionType.tableBased;
  }

  return QuestionType.singleChoice;
}

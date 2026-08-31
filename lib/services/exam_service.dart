import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/exam_package.dart';
import '../models/exam_result.dart';
import '../models/question.dart';
import '../models/question_type.dart';
import 'storage_service.dart';
import 'scoring_service.dart';
import 'timer_service.dart';
import 'anti_cheat_service.dart';

class ExamService extends ChangeNotifier {
  final ExamPackage package;
  final String uid;
  final String username;

  int _currentIndex = 0;

  /// Keyed by question.id (String).
  /// Value is String for single-choice, or comma-joined for multi-select.
  final Map<String, dynamic> _answers = {};

  final Set<String> _flaggedQuestions = {};
  int _warningsCount = 0;

  late DateTime _startedAt;
  late DateTime _endAt;
  Timer? _timer;
  int _remainingSeconds = 0;

  bool _isSubmitting = false;
  bool _submitGuard = false;
  ExamResult? _result;
  AntiCheatService? _antiCheatService;

  ExamService({
    required this.package,
    required this.uid,
    required this.username,
    Map<String, dynamic>? restoredSession,
  }) {
    if (restoredSession != null) {
      _restoreSession(restoredSession);
    } else {
      _initNewSession();
    }
    _initAntiCheat();
    _startTimer();
  }

  // ─── Getters ────────────────────────────────────────────────────────────────

  int get currentIndex => _currentIndex;
  Question get currentQuestion => package.questions[_currentIndex];
  int get totalQuestions => package.questions.length;

  Map<String, dynamic> get answers => Map.unmodifiable(_answers);
  Set<String> get flaggedQuestions => Set.unmodifiable(_flaggedQuestions);

  int get warningsCount => _warningsCount;
  int get remainingSeconds => _remainingSeconds;
  bool get isSubmitting => _isSubmitting;
  ExamResult? get result => _result;

  int get answeredCount => _answers.length;

  // ─── Session init ───────────────────────────────────────────────────────────

  void _initNewSession() {
    _startedAt = DateTime.now();
    _endAt = _startedAt.add(Duration(seconds: package.durationSeconds));
    _remainingSeconds = package.durationSeconds;
    _currentIndex = 0;
    _answers.clear();
    _flaggedQuestions.clear();
    _warningsCount = 0;
    _saveStateToStorage();
  }

  void _restoreSession(Map<String, dynamic> session) {
    _currentIndex = session['currentIndex'] as int? ?? 0;
    _warningsCount = session['warningsCount'] as int? ?? 0;

    _startedAt = session['startedAt'] != null
        ? DateTime.parse(session['startedAt'] as String)
        : DateTime.now();

    _endAt = session['endAt'] != null
        ? DateTime.parse(session['endAt'] as String)
        : _startedAt.add(Duration(seconds: package.durationSeconds));

    if (session['answers'] != null) {
      (session['answers'] as Map).forEach((k, v) {
        _answers[k.toString()] = v;
      });
    }

    if (session['flagged'] != null) {
      for (final id in (session['flagged'] as List)) {
        _flaggedQuestions.add(id.toString());
      }
    }

    _remainingSeconds = TimerService.getRemainingSeconds(_endAt);
  }

  // ─── Anti-cheat ─────────────────────────────────────────────────────────────

  void _initAntiCheat() {
    _antiCheatService = AntiCheatService(
      initialCount: _warningsCount,
      onViolation: (count) {
        _warningsCount = count;
        _saveStateToStorage();
        notifyListeners();
      },
      onMaxViolationExceeded: () {
        _warningsCount = AntiCheatService.maxViolations + 1;
        submitExam(forcedByAntiCheat: true);
      },
    );
    _antiCheatService?.startListening();
  }

  // ─── Timer ──────────────────────────────────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = TimerService.getRemainingSeconds(_endAt);

    if (_remainingSeconds <= 0) {
      submitExam(forcedByTimeout: true);
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      _remainingSeconds = TimerService.getRemainingSeconds(_endAt);
      if (_remainingSeconds <= 0) {
        t.cancel();
        submitExam(forcedByTimeout: true);
      } else {
        notifyListeners();
      }
    });
  }

  // ─── User actions ────────────────────────────────────────────────────────────

  /// Select or toggle a single answer option.
  void selectAnswer(String questionId, String optionId) {
    if (_isSubmitting) return;
    final q = _getQuestionById(questionId);
    if (q == null) return;

    if (q.questionType.allowsMultipleAnswers) {
      // Multi-select: toggle the option in a comma-separated list
      final current = _answers[questionId];
      List<String> selected = current != null && current is String && current.isNotEmpty
          ? current.split(',')
          : [];
      if (selected.contains(optionId)) {
        selected.remove(optionId);
      } else {
        selected.add(optionId);
      }
      if (selected.isEmpty) {
        _answers.remove(questionId);
      } else {
        _answers[questionId] = selected.join(',');
      }
    } else {
      // Single select
      _answers[questionId] = optionId;
    }
    _saveStateToStorage();
    notifyListeners();
  }

  /// For True/False type: select answer for a specific sub-statement key.
  void selectTrueFalseAnswer(String questionId, String statementKey, String value) {
    if (_isSubmitting) return;
    // Stored as JSON-like: "1:True,2:False,3:True"
    final current = _answers[questionId];
    final Map<String, String> stateMap = {};
    if (current != null && current is String && current.isNotEmpty) {
      for (final pair in current.split(',')) {
        final parts = pair.split(':');
        if (parts.length == 2) stateMap[parts[0]] = parts[1];
      }
    }
    stateMap[statementKey] = value;
    _answers[questionId] = stateMap.entries.map((e) => '${e.key}:${e.value}').join(',');
    _saveStateToStorage();
    notifyListeners();
  }

  void toggleFlag(String questionId) {
    if (_isSubmitting) return;
    if (_flaggedQuestions.contains(questionId)) {
      _flaggedQuestions.remove(questionId);
    } else {
      _flaggedQuestions.add(questionId);
    }
    _saveStateToStorage();
    notifyListeners();
  }

  void goToQuestion(int index) {
    if (index >= 0 && index < totalQuestions) {
      _currentIndex = index;
      _saveStateToStorage();
      notifyListeners();
    }
  }

  void nextQuestion() {
    if (_currentIndex < totalQuestions - 1) {
      _currentIndex++;
      _saveStateToStorage();
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _saveStateToStorage();
      notifyListeners();
    }
  }

  // ─── Submit ──────────────────────────────────────────────────────────────────

  Future<ExamResult?> submitExam({
    bool forcedByTimeout = false,
    bool forcedByAntiCheat = false,
  }) async {
    if (_isSubmitting || _submitGuard) return _result;
    _isSubmitting = true;
    _submitGuard = true;
    _timer?.cancel();
    _antiCheatService?.stopListening();
    notifyListeners();

    try {
      final int elapsed = TimerService.getElapsedSeconds(_startedAt);
      final resultId =
          '${uid}_${package.id}_${DateTime.now().millisecondsSinceEpoch}';

      _result = ScoringService.calculate(
        uid: uid,
        username: username,
        subjectId: package.subjectId,
        packageId: package.id,
        packageName: package.title,
        questions: package.questions,
        answers: _answers,
        flaggedQuestions: _flaggedQuestions.toList(),
        durationSeconds: elapsed,
        startedAt: _startedAt.toIso8601String(),
        warningsCount: _warningsCount,
        scoreCorrect: package.defaultScoreCorrect,
        scoreWrong: package.defaultScoreWrong,
        scoreEmpty: package.defaultScoreEmpty,
        resultId: resultId,
      );

      await StorageService.appendHistory(_result!);
      await StorageService.clearActiveExam();
    } catch (e) {
      debugPrint('[ExamService] submitExam error: $e');
      _isSubmitting = false;
      _submitGuard = false;
      notifyListeners();
      return null;
    }

    notifyListeners();
    return _result;
  }

  // ─── Persistence ─────────────────────────────────────────────────────────────

  void _saveStateToStorage() {
    if (_isSubmitting) return;
    final state = {
      'packageId': package.id,
      'subjectId': package.subjectId,
      'currentIndex': _currentIndex,
      'startedAt': _startedAt.toIso8601String(),
      'endAt': _endAt.toIso8601String(),
      'warningsCount': _warningsCount,
      'answers': Map<String, dynamic>.from(_answers),
      'flagged': _flaggedQuestions.toList(),
    };
    StorageService.saveActiveExam(state);
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  Question? _getQuestionById(String id) {
    try {
      return package.questions.firstWhere((q) => q.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _antiCheatService?.stopListening();
    super.dispose();
  }
}

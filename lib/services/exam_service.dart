import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/exam_package.dart';
import '../models/exam_result.dart';
import '../models/question.dart';
import 'storage_service.dart';
import 'scoring_service.dart';
import 'timer_service.dart';
import 'anti_cheat_service.dart';

class ExamService extends ChangeNotifier {
  final ExamPackage package;
  final String uid;
  final String username;

  int _currentIndex = 0;
  final Map<int, String> _answers = {};
  final Set<int> _flaggedQuestions = {};
  int _warningsCount = 0;

  late DateTime _startedAt;
  late DateTime _endAt;
  Timer? _timer;
  int _remainingSeconds = 0;

  bool _isSubmitting = false;
  bool _submitGuard = false; // Prevents duplicate submissions
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

  int get currentIndex => _currentIndex;
  Question get currentQuestion => package.questions[_currentIndex];
  int get totalQuestions => package.questions.length;

  Map<int, String> get answers => Map.unmodifiable(_answers);
  Set<int> get flaggedQuestions => Set.unmodifiable(_flaggedQuestions);

  int get warningsCount => _warningsCount;
  int get remainingSeconds => _remainingSeconds;
  bool get isSubmitting => _isSubmitting;
  ExamResult? get result => _result;

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

    if (session['startedAt'] != null) {
      _startedAt = DateTime.parse(session['startedAt'] as String);
    } else {
      _startedAt = DateTime.now();
    }

    if (session['endAt'] != null) {
      _endAt = DateTime.parse(session['endAt'] as String);
    } else {
      _endAt = _startedAt.add(Duration(seconds: package.durationSeconds));
    }

    if (session['answers'] != null) {
      (session['answers'] as Map).forEach((k, v) {
        _answers[int.parse(k.toString())] = v.toString();
      });
    }

    if (session['flagged'] != null) {
      for (final id in (session['flagged'] as List)) {
        _flaggedQuestions.add(int.parse(id.toString()));
      }
    }

    _remainingSeconds = TimerService.getRemainingSeconds(_endAt);
  }

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

  void selectAnswer(int questionId, String optionId) {
    if (_isSubmitting) return;
    _answers[questionId] = optionId;
    _saveStateToStorage();
    notifyListeners();
  }

  void toggleFlag(int questionId) {
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

  Future<ExamResult?> submitExam({
    bool forcedByTimeout = false,
    bool forcedByAntiCheat = false,
  }) async {
    // Duplicate submission guard
    if (_isSubmitting || _submitGuard) return _result;
    _isSubmitting = true;
    _submitGuard = true;
    _timer?.cancel();
    _antiCheatService?.stopListening();

    final int elapsed = TimerService.getElapsedSeconds(_startedAt);

    // Generate unique result ID using UID + packageId + timestamp
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

    notifyListeners();
    return _result;
  }

  void _saveStateToStorage() {
    if (_isSubmitting) return;
    final Map<String, dynamic> state = {
      'packageId': package.id,
      'subjectId': package.subjectId,
      'currentIndex': _currentIndex,
      'startedAt': _startedAt.toIso8601String(),
      'endAt': _endAt.toIso8601String(),
      'warningsCount': _warningsCount,
      'answers': _answers.map((k, v) => MapEntry(k.toString(), v)),
      'flagged': _flaggedQuestions.toList(),
    };
    StorageService.saveActiveExam(state);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _antiCheatService?.stopListening();
    super.dispose();
  }
}

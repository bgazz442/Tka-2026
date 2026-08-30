import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/exam_result.dart';

class StorageService {
  static const String _keyActiveExam = 'tka_active_exam';
  static const String _keySettings = 'tka_settings';
  static const String _keyUsername = 'tka_username';
  static const String _keyHistory = 'tka_history';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _requirePrefs {
    if (_prefs == null) {
      throw StateError('StorageService.init() must be called before use.');
    }
    return _prefs!;
  }

  static Map<String, dynamic>? getActiveExam() {
    final raw = _prefs?.getString(_keyActiveExam);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic>
          ? decoded
          : Map<String, dynamic>.from(decoded as Map);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveActiveExam(Map<String, dynamic> sessionData) async {
    await _requirePrefs.setString(_keyActiveExam, jsonEncode(sessionData));
  }

  static Future<void> clearActiveExam() async {
    await _requirePrefs.remove(_keyActiveExam);
  }

  static Map<String, dynamic> getSettings() {
    final raw = _prefs?.getString(_keySettings);
    if (raw == null) return {'antiCheat': true};
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic>
          ? decoded
          : Map<String, dynamic>.from(decoded as Map);
    } catch (_) {
      return {'antiCheat': true};
    }
  }

  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _requirePrefs.setString(_keySettings, jsonEncode(settings));
  }

  static Future<void> clearLocalSession() async {
    await _requirePrefs.remove(_keyActiveExam);
  }

  static String? getUsername() {
    return _prefs?.getString(_keyUsername);
  }

  static Future<void> setUsername(String username) async {
    final trimmed = username.trim();
    if (trimmed.isEmpty) return;
    await _requirePrefs.setString(_keyUsername, trimmed);
  }

  static List<ExamResult> getHistory() {
    final raw = _prefs?.getString(_keyHistory);
    if (raw == null || raw.isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .map((item) => ExamResult.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static Future<void> saveHistory(List<ExamResult> results) async {
    final payload = results.map((e) => e.toJson()).toList();
    await _requirePrefs.setString(_keyHistory, jsonEncode(payload));
  }

  static Future<void> appendHistory(ExamResult result) async {
    final items = getHistory();
    items.insert(0, result);
    await saveHistory(items);
  }

  static List<ExamResult> getHistoryBySubject(String subjectId) {
    return getHistory()
        .where((result) => result.subjectId == subjectId)
        .toList();
  }

  static List<ExamResult> getHistoryByPackage(String packageId) {
    return getHistory()
        .where((result) => result.packageId == packageId)
        .toList();
  }

  static Map<String, int> getBestScores() {
    final scores = <String, int>{};
    for (final result in getHistory()) {
      final existing = scores[result.packageId];
      if (existing == null || result.score > existing) {
        scores[result.packageId] = result.score;
      }
    }
    return scores;
  }

  static int? getBestScoreForPackage(String packageId) {
    final best = getHistoryByPackage(packageId)
        .map((e) => e.score)
        .fold<int?>(null, (previous, score) {
          if (previous == null || score > previous) return score;
          return previous;
        });
    return best;
  }

  static Map<String, dynamic>? getOverallStats() {
    final history = getHistory();
    if (history.isEmpty) return null;

    final totalTryouts = history.length;
    final avgScore = history.fold<int>(0, (sum, item) => sum + item.score) / totalTryouts;
    final bestScore = history.map((item) => item.score).reduce((a, b) => a > b ? a : b);

    return {
      'totalTryouts': totalTryouts,
      'avgScore': avgScore.round(),
      'bestScore': bestScore,
    };
  }

  static Map<String, dynamic>? getSubjectStats(String subjectId) {
    final history = getHistoryBySubject(subjectId);
    if (history.isEmpty) return null;

    final avgScore = history.fold<int>(0, (sum, item) => sum + item.score) /
        history.length;
    final bestScore = history.map((item) => item.score).reduce((a, b) => a > b ? a : b);

    return {
      'bestScore': bestScore,
      'avgScore': avgScore.round(),
      'totalTryouts': history.length,
    };
  }
}

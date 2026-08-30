import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/exam_result.dart';

class StorageService {
  static const String _keyProfile = 'local_profile';
  static const String _keyActiveExam = 'tka_active_exam';
  static const String _keySettings = 'tka_settings';
  static const String _keyHistory = 'tka_history';
  static const String _keySessionUid = 'tka_session_uid';
  static const String _keyUsername = 'tka_username';

  static late Box _profileBox;
  static late Box _settingsBox;
  static late Box _historyBox;
  static late Box _activeExamBox;

  static Future<void> init() async {
    _profileBox = await Hive.openBox('futureee_profile_box');
    _settingsBox = await Hive.openBox('futureee_settings_box');
    _historyBox = await Hive.openBox('futureee_history_box');
    _activeExamBox = await Hive.openBox('futureee_active_exam_box');
  }

  static Future<void> resetAll() async {
    await _profileBox.clear();
    await _settingsBox.clear();
    await _historyBox.clear();
    await _activeExamBox.clear();
  }

  static Map<String, dynamic>? getProfile() {
    final profile = _profileBox.get(_keyProfile);
    if (profile == null) return null;
    if (profile is Map) {
      return Map<String, dynamic>.from(profile);
    }
    return null;
  }

  static Future<void> saveProfile(Map<String, dynamic> profile) async {
    final normalized = <String, dynamic>{
      'profileId': profile['profileId'] ?? '',
      'username': (profile['username'] ?? '').toString().trim(),
      'email': (profile['email'] ?? '').toString().trim(),
      'createdAt': profile['createdAt'] ?? DateTime.now().toIso8601String(),
      'updatedAt': profile['updatedAt'] ?? DateTime.now().toIso8601String(),
    };
    await _profileBox.put(_keyProfile, normalized);
    if (normalized['profileId'] != null && normalized['profileId'].toString().isNotEmpty) {
      await setSessionUid(normalized['profileId'].toString());
    }
    if (normalized['username'] != null && normalized['username'].toString().isNotEmpty) {
      await setUsername(normalized['username'].toString());
    }
  }

  static bool hasProfile() => getProfile() != null;

  static Map<String, dynamic>? getActiveExam() {
    final raw = _activeExamBox.get(_keyActiveExam);
    if (raw == null) return null;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  static Future<void> saveActiveExam(Map<String, dynamic> sessionData) async {
    await _activeExamBox.put(_keyActiveExam, sessionData);
  }

  static Future<void> clearActiveExam() async {
    await _activeExamBox.delete(_keyActiveExam);
  }

  static Map<String, dynamic> getSettings() {
    final settings = _settingsBox.get(_keySettings);
    if (settings is Map) {
      return Map<String, dynamic>.from(settings);
    }
    return {'antiCheat': true, 'biometricEnabled': false};
  }

  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _settingsBox.put(_keySettings, settings);
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    final config = getSettings();
    config['biometricEnabled'] = enabled;
    await saveSettings(config);
  }

  static bool isBiometricEnabled() => getSettings()['biometricEnabled'] == true;

  static String? getUsername() {
    return _settingsBox.get(_keyUsername)?.toString();
  }

  static Future<void> setUsername(String username) async {
    final trimmed = username.trim();
    if (trimmed.isEmpty) return;
    await _settingsBox.put(_keyUsername, trimmed);
  }

  static List<Map<String, dynamic>> getAccounts() {
    final profile = getProfile();
    if (profile == null) return const [];
    return [Map<String, dynamic>.from(profile)];
  }

  static Map<String, dynamic>? getAccountByUid(String uid) {
    final profile = getProfile();
    if (profile == null || profile['profileId']?.toString() != uid) return null;
    return Map<String, dynamic>.from(profile);
  }

  static Map<String, dynamic>? getAccountByUsername(String username) {
    final profile = getProfile();
    if (profile == null) return null;
    final normalized = username.trim().toLowerCase();
    final current = profile['username']?.toString().trim().toLowerCase();
    if (current == normalized) return Map<String, dynamic>.from(profile);
    return null;
  }

  static Future<void> setSessionUid(String uid) async {
    await _settingsBox.put(_keySessionUid, uid);
  }

  static String? getSessionUid() => _settingsBox.get(_keySessionUid)?.toString();

  static Future<void> clearSession() async {
    await _settingsBox.delete(_keySessionUid);
  }

  static List<ExamResult> getHistory() {
    final data = _historyBox.get(_keyHistory);
    if (data is! List) return const [];
    return data
        .map((item) => ExamResult.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  static Future<void> saveHistory(List<ExamResult> results) async {
    final payload = results.map((e) => e.toJson()).toList();
    await _historyBox.put(_keyHistory, payload);
  }

  static Future<void> appendHistory(ExamResult result) async {
    final items = getHistory();
    items.insert(0, result);
    await saveHistory(items);
  }

  static List<ExamResult> getHistoryBySubject(String subjectId) {
    return getHistory().where((result) => result.subjectId == subjectId).toList();
  }

  static List<ExamResult> getHistoryByPackage(String packageId) {
    return getHistory().where((result) => result.packageId == packageId).toList();
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
    final values = getHistoryByPackage(packageId).map((e) => e.score);
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a > b ? a : b);
  }

  static Map<String, dynamic>? getOverallStats() {
    final history = getHistory();
    if (history.isEmpty) return null;

    final totalTryouts = history.length;
    final totalQuestions = history.fold<int>(0, (sum, item) => sum + item.totalQuestions);
    final avgScore = history.fold<int>(0, (sum, item) => sum + item.score) / totalTryouts;
    final bestScore = history.map((item) => item.score).reduce((a, b) => a > b ? a : b);
    final lowestScore = history.map((item) => item.score).reduce((a, b) => a < b ? a : b);

    return {
      'totalTryouts': totalTryouts,
      'totalQuestions': totalQuestions,
      'avgScore': avgScore.round(),
      'bestScore': bestScore,
      'lowestScore': lowestScore,
    };
  }

  static Map<String, dynamic>? getSubjectStats(String subjectId) {
    final history = getHistoryBySubject(subjectId);
    if (history.isEmpty) return null;

    final avgScore = history.fold<int>(0, (sum, item) => sum + item.score) / history.length;
    final bestScore = history.map((item) => item.score).reduce((a, b) => a > b ? a : b);
    final lowestScore = history.map((item) => item.score).reduce((a, b) => a < b ? a : b);

    return {
      'bestScore': bestScore,
      'lowestScore': lowestScore,
      'avgScore': avgScore.round(),
      'totalTryouts': history.length,
    };
  }

  static Future<void> clearLocalSession() async => clearActiveExam();
  static Future<void> saveAccounts(List<Map<String, dynamic>> accounts) async {
    final profile = accounts.isNotEmpty ? accounts.first : null;
    if (profile != null) await saveProfile(profile);
  }
}

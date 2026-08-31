import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:futureee/models/exam_result.dart';
import 'package:futureee/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    final tempDir = await Directory.systemTemp.createTemp('futureee_test_');
    Hive.init(tempDir.path);
    await StorageService.init();
    await StorageService.resetAll();
  });

  test('saves local profile and calculates overall stats from history', () async {
    final profile = {
      'profileId': 'profile-001',
      'username': 'Bagas',
      'email': 'bagas@email.com',
      'createdAt': DateTime(2026, 8, 30).toIso8601String(),
      'updatedAt': DateTime(2026, 8, 30).toIso8601String(),
    };

    await StorageService.saveProfile(profile);
    final savedProfile = StorageService.getProfile();

    expect(savedProfile, isNotNull);
    expect(savedProfile!['username'], 'Bagas');
    expect(savedProfile['email'], 'bagas@email.com');

    final r1 = ExamResult(
      id: 'attempt-1',
      uid: 'profile-001',
      username: 'Bagas',
      subjectId: 'mathematics',
      packageId: 'matematika-1',
      packageName: 'Paket 1',
      score: 80,
      correct: 20,
      wrong: 3,
      empty: 2,
      rawScore: 80,
      maxPossibleScore: 100,
      durationSeconds: 60,
      startedAt: DateTime(2026, 8, 30, 8).toIso8601String(),
      completedAt: DateTime(2026, 8, 30, 9).toIso8601String(),
      answers: {'1': 'A', '2': 'B'},
      flaggedQuestions: const [],
      warningsCount: 0,
      breakdown: const [],
    );

    final r2 = ExamResult(
      id: 'attempt-2',
      uid: 'profile-001',
      username: 'Bagas',
      subjectId: 'mathematics',
      packageId: 'matematika-2',
      packageName: 'Paket 2',
      score: 90,
      correct: 22,
      wrong: 2,
      empty: 1,
      rawScore: 90,
      maxPossibleScore: 100,
      durationSeconds: 70,
      startedAt: DateTime(2026, 8, 31, 8).toIso8601String(),
      completedAt: DateTime(2026, 8, 31, 9).toIso8601String(),
      answers: {'1': 'A', '2': 'B'},
      flaggedQuestions: const [],
      warningsCount: 0,
      breakdown: const [],
    );

    await StorageService.saveHistory([r1, r2]);

    final stats = StorageService.getOverallStats();
    expect(stats, isNotNull);
    expect(stats!['totalTryouts'], 2);
    expect(stats['avgScore'], 85);
    expect(stats['bestScore'], 90);
    expect(stats['lowestScore'], 80);
    expect(stats['totalQuestions'], 50);
  });
}

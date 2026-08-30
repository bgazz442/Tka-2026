import '../models/exam_result.dart';
import '../models/leaderboard_entry.dart';
import '../models/user_profile.dart';
import 'storage_service.dart';

/// Local data facade retained for existing screen compatibility.
/// Data is device-local and is not a global online leaderboard.
class FirestoreService {
  Future<bool> checkUsernameAvailable(String normalizedUsername) async {
    return StorageService.getAccountByUsername(normalizedUsername) == null;
  }

  Future<void> createUserProfile({
    required String uid,
    required String username,
    required String? name,
    required String? email,
    String? normalizedUsername,
  }) async {}

  Future<UserProfile?> ensureUserProfile({
    required String uid,
    required String name,
    required String email,
  }) async => getUserProfile(uid);

  Future<UserProfile?> getUserProfile(String uid) async {
    final account = StorageService.getAccountByUid(uid);
    if (account == null) return null;
    final createdAt = DateTime.tryParse(account['createdAt'] as String? ?? '') ??
        DateTime.now();
    return UserProfile(
      uid: uid,
      username: account['username'] as String,
      name: account['name'] as String? ?? account['username'] as String,
      email: '',
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Stream<UserProfile?> streamUserProfile(String uid) async* {
    yield await getUserProfile(uid);
  }

  Future<void> saveExamResult(ExamResult result) async {
    await StorageService.appendHistory(result);
  }

  Stream<List<ExamResult>> streamUserHistory(String uid) async* {
    yield StorageService.getHistory().where((item) => item.uid == uid).toList();
  }

  Future<List<ExamResult>> getUserHistoryBySubject(
      String uid, String subjectId) async {
    return StorageService.getHistory()
        .where((item) => item.uid == uid && item.subjectId == subjectId)
        .toList();
  }

  Stream<List<LeaderboardEntry>> streamLeaderboard(String subjectId) async* {
    final entries = <String, LeaderboardEntry>{};
    for (final result in StorageService.getHistoryBySubject(subjectId)) {
      final current = entries[result.uid];
      if (current == null || result.score > current.score ||
          (result.score == current.score &&
              result.durationSeconds < current.durationSeconds)) {
        entries[result.uid] = LeaderboardEntry(
          uid: result.uid,
          username: result.username,
          subjectId: subjectId,
          score: result.score,
          durationSeconds: result.durationSeconds,
          updatedAt: DateTime.tryParse(result.completedAt),
        );
      }
    }
    final sorted = entries.values.toList()
      ..sort((a, b) {
        final scoreOrder = b.score.compareTo(a.score);
        return scoreOrder != 0
            ? scoreOrder
            : a.durationSeconds.compareTo(b.durationSeconds);
      });
    yield [
      for (var index = 0; index < sorted.length; index++)
        sorted[index].copyWith(rank: index + 1),
    ];
  }

  Future<int?> getUserRank(String uid, String subjectId) async {
    final entries = await streamLeaderboard(subjectId).first;
    final index = entries.indexWhere((entry) => entry.uid == uid);
    return index < 0 ? null : index + 1;
  }

  Future<Map<String, int?>> getAllSubjectRanks(
      String uid, List<String> subjectIds) async {
    return {
      for (final subjectId in subjectIds)
        subjectId: await getUserRank(uid, subjectId),
    };
  }

  Future<Map<String, dynamic>?> getUserStats(String uid) async {
    final items = StorageService.getHistory().where((item) => item.uid == uid).toList();
    if (items.isEmpty) return null;
    return {
      'totalTryouts': items.length,
      'totalQuestions': items.fold<int>(0, (sum, item) => sum + item.totalQuestions),
      'overallBestScore': items.map((item) => item.score).reduce((a, b) => a > b ? a : b),
    };
  }

  Future<Map<String, dynamic>?> getSubjectStats(
      String uid, String subjectId) async {
    final items = StorageService.getHistory()
        .where((item) => item.uid == uid && item.subjectId == subjectId)
        .toList();
    if (items.isEmpty) return null;
    final best = items.map((item) => item.score).reduce((a, b) => a > b ? a : b);
    final bestDuration = items.where((item) => item.score == best)
        .map((item) => item.durationSeconds)
        .reduce((a, b) => a < b ? a : b);
    return {'bestScore': best, 'bestDurationSeconds': bestDuration};
  }
}
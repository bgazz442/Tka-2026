import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../models/exam_result.dart';
import '../models/leaderboard_entry.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _users => _db.collection('users');
  CollectionReference get _usernames => _db.collection('usernames');
  CollectionReference get _examResults => _db.collection('examResults');
  CollectionReference _leaderboardEntries(String subjectId) =>
      _db.collection('leaderboard').doc(subjectId).collection('entries');

  Future<bool> checkUsernameAvailable(String normalizedUsername) async {
    final doc = await _usernames.doc(normalizedUsername).get();
    return !doc.exists;
  }

  Future<void> createUserProfile({
    required String uid,
    required String username,
    required String? name,
    required String? email,
    String? normalizedUsername,
  }) async {
    final now = Timestamp.now();
    final resolvedName = (name ?? username).trim();
    final resolvedUsername = (username.trim().isNotEmpty
            ? username.trim()
            : resolvedName)
        .trim();
    final batch = _db.batch();

    batch.set(_users.doc(uid), {
      'uid': uid,
      'username': resolvedUsername,
      'name': resolvedName,
      'email': (email ?? '').trim(),
      'createdAt': now,
      'updatedAt': now,
    }, SetOptions(merge: true));

    if (normalizedUsername != null && normalizedUsername.isNotEmpty) {
      batch.set(_usernames.doc(normalizedUsername), {
        'uid': uid,
        'reservedAt': now,
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  Future<UserProfile?> ensureUserProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    final doc = await _users.doc(uid).get();
    final now = Timestamp.now();
    final resolvedName = name.trim().isNotEmpty ? name.trim() : 'User';
    final resolvedEmail = email.trim();

    if (!doc.exists) {
      final profile = UserProfile(
        uid: uid,
        username: resolvedName,
        name: resolvedName,
        email: resolvedEmail,
        createdAt: now.toDate(),
        updatedAt: now.toDate(),
      );
      await _users.doc(uid).set(profile.toJson(), SetOptions(merge: true));
      return profile;
    }

    final data = doc.data() as Map<String, dynamic>;
    final existingName = (data['name'] as String?) ??
        (data['username'] as String?) ??
        resolvedName;
    final existingEmail = (data['email'] as String?) ?? resolvedEmail;

    final updated = {
      'uid': uid,
      'username': existingName,
      'name': existingName,
      'email': existingEmail,
      'updatedAt': now,
    };

    await _users.doc(uid).set(updated, SetOptions(merge: true));
    return getUserProfile(uid);
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _users.doc(uid).get();
      if (!doc.exists) return null;
      return UserProfile.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// Stream user profile for realtime updates.
  Stream<UserProfile?> streamUserProfile(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromJson(doc.data() as Map<String, dynamic>);
    });
  }

  // ── Exam Results ───────────────────────────────────────────

  /// Save an exam result to Firestore.
  /// Also updates leaderboard best score.
  Future<void> saveExamResult(ExamResult result) async {
    // Save result document
    await _examResults.doc(result.id).set(result.toFirestore());

    // Update leaderboard
    await _updateLeaderboard(
      uid: result.uid,
      username: result.username,
      subjectId: result.subjectId,
      score: result.score,
      durationSeconds: result.durationSeconds,
    );

    // Update user stats in profile
    await _updateUserStats(uid: result.uid, result: result);
  }

  /// Stream user's exam history (most recent first, limit 100).
  Stream<List<ExamResult>> streamUserHistory(String uid) {
    return _examResults
        .where('uid', isEqualTo: uid)
        .orderBy('completedAtTimestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ExamResult.fromFirestore(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Get user history for a specific subject.
  Future<List<ExamResult>> getUserHistoryBySubject(
      String uid, String subjectId) async {
    final snapshot = await _examResults
        .where('uid', isEqualTo: uid)
        .where('subjectId', isEqualTo: subjectId)
        .orderBy('completedAtTimestamp', descending: true)
        .get();
    return snapshot.docs
        .map((doc) =>
            ExamResult.fromFirestore(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // ── Leaderboard ────────────────────────────────────────────

  /// Stream leaderboard for a subject (top 100, sorted by score DESC, duration ASC).
  Stream<List<LeaderboardEntry>> streamLeaderboard(String subjectId) {
    return _leaderboardEntries(subjectId)
        .orderBy('bestScore', descending: true)
        .orderBy('bestDurationSeconds', descending: false)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .asMap()
            .entries
            .map((entry) {
              final leaderboardEntry = LeaderboardEntry.fromFirestore(
                  entry.value, subjectId);
              return leaderboardEntry.copyWith(rank: entry.key + 1);
            })
            .toList());
  }

  /// Get user's rank in a subject leaderboard.
  Future<int?> getUserRank(String uid, String subjectId) async {
    try {
      // Get the user's best score first
      final userDoc =
          await _leaderboardEntries(subjectId).doc(uid).get();
      if (!userDoc.exists) return null;

      final userData = userDoc.data() as Map<String, dynamic>;
      final userScore = userData['bestScore'] as int? ?? 0;
      final userDuration = userData['bestDurationSeconds'] as int? ?? 0;

      // Count how many entries have a better score OR same score but better time
      final betterScoreQuery = await _leaderboardEntries(subjectId)
          .where('bestScore', isGreaterThan: userScore)
          .count()
          .get();

      final sameBetterTimeQuery = await _leaderboardEntries(subjectId)
          .where('bestScore', isEqualTo: userScore)
          .where('bestDurationSeconds', isLessThan: userDuration)
          .count()
          .get();

      final rank = (betterScoreQuery.count ?? 0) +
          (sameBetterTimeQuery.count ?? 0) +
          1;
      return rank;
    } catch (e) {
      return null;
    }
  }

  /// Get ranks for all subjects at once.
  Future<Map<String, int?>> getAllSubjectRanks(
      String uid, List<String> subjectIds) async {
    final Map<String, int?> ranks = {};
    for (final subjectId in subjectIds) {
      ranks[subjectId] = await getUserRank(uid, subjectId);
    }
    return ranks;
  }

  // ── Internal: Update Leaderboard ───────────────────────────

  Future<void> _updateLeaderboard({
    required String uid,
    required String username,
    required String subjectId,
    required int score,
    required int durationSeconds,
  }) async {
    final entryRef = _leaderboardEntries(subjectId).doc(uid);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(entryRef);

      if (!snapshot.exists) {
        // First entry for this user in this subject
        transaction.set(entryRef, {
          'uid': uid,
          'username': username,
          'bestScore': score,
          'bestDurationSeconds': durationSeconds,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        final data = snapshot.data() as Map<String, dynamic>;
        final currentBest = data['bestScore'] as int? ?? 0;
        final currentDuration = data['bestDurationSeconds'] as int? ?? 0;

        // Only update if new score is better, or same score with better time
        if (score > currentBest ||
            (score == currentBest && durationSeconds < currentDuration)) {
          transaction.update(entryRef, {
            'username': username, // update in case username changed
            'bestScore': score,
            'bestDurationSeconds': durationSeconds,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Still update username if it changed
          transaction.update(entryRef, {
            'username': username,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    });
  }

  // ── Internal: Update User Stats ────────────────────────────

  Future<void> _updateUserStats(
      {required String uid, required ExamResult result}) async {
    // Increment total tryouts using server-side transaction
    await _db.runTransaction((transaction) async {
      final userRef = _users.doc(uid);
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      final totalTryouts = (data['totalTryouts'] as int? ?? 0) + 1;
      final totalCorrect =
          (data['totalCorrect'] as int? ?? 0) + result.correct;
      final totalQuestions =
          (data['totalQuestions'] as int? ?? 0) + result.totalQuestions;
      final currentBest = data['overallBestScore'] as int? ?? 0;
      final newBest = result.score > currentBest ? result.score : currentBest;

      transaction.update(userRef, {
        'totalTryouts': totalTryouts,
        'totalCorrect': totalCorrect,
        'totalQuestions': totalQuestions,
        'overallBestScore': newBest,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // ── User Stats (aggregated) ────────────────────────────────

  /// Get aggregated user stats for home screen.
  Future<Map<String, dynamic>?> getUserStats(String uid) async {
    try {
      final doc = await _users.doc(uid).get();
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>;

      final totalTryouts = data['totalTryouts'] as int? ?? 0;
      if (totalTryouts == 0) return null;

      return {
        'totalTryouts': totalTryouts,
        'totalQuestions': data['totalQuestions'] as int? ?? 0,
        'overallBestScore': data['overallBestScore'] as int? ?? 0,
      };
    } catch (e) {
      return null;
    }
  }

  /// Get stats for a specific subject.
  Future<Map<String, dynamic>?> getSubjectStats(
      String uid, String subjectId) async {
    try {
      final snapshot = await _leaderboardEntries(subjectId).doc(uid).get();
      if (!snapshot.exists) return null;
      final data = snapshot.data() as Map<String, dynamic>;
      return {
        'bestScore': data['bestScore'] as int? ?? 0,
        'bestDurationSeconds': data['bestDurationSeconds'] as int? ?? 0,
      };
    } catch (e) {
      return null;
    }
  }
}

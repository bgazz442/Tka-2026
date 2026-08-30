import '../models/leaderboard_entry.dart';
import '../services/storage_service.dart';

class LeaderboardData {
  static const List<LeaderboardEntry> _rawMock = [
    // English
    LeaderboardEntry(
        username: 'Andi Pratama',
        subjectId: 'english',
        score: 96,
        durationSeconds: 3820),
    LeaderboardEntry(
        username: 'Sinta Dewi',
        subjectId: 'english',
        score: 92,
        durationSeconds: 4100),
    LeaderboardEntry(
        username: 'Raka Saputra',
        subjectId: 'english',
        score: 90,
        durationSeconds: 3950),
    LeaderboardEntry(
        username: 'Maya Lestari',
        subjectId: 'english',
        score: 88,
        durationSeconds: 4200),
    LeaderboardEntry(
        username: 'Dimas Fikri',
        subjectId: 'english',
        score: 86,
        durationSeconds: 4050),
    LeaderboardEntry(
        username: 'Nadia Putri',
        subjectId: 'english',
        score: 84,
        durationSeconds: 4300),

    // Mathematics
    LeaderboardEntry(
        username: 'Budi Santoso',
        subjectId: 'mathematics',
        score: 94,
        durationSeconds: 3600),
    LeaderboardEntry(
        username: 'Aldo Hidayat',
        subjectId: 'mathematics',
        score: 90,
        durationSeconds: 3900),
    LeaderboardEntry(
        username: 'Putri Rahayu',
        subjectId: 'mathematics',
        score: 88,
        durationSeconds: 4000),
    LeaderboardEntry(
        username: 'Gilang Nugroho',
        subjectId: 'mathematics',
        score: 84,
        durationSeconds: 4200),

    // Indonesian
    LeaderboardEntry(
        username: 'Wulandari',
        subjectId: 'indonesian',
        score: 95,
        durationSeconds: 3700),
    LeaderboardEntry(
        username: 'Fadhil Akbar',
        subjectId: 'indonesian',
        score: 91,
        durationSeconds: 3900),
    LeaderboardEntry(
        username: 'Retno Sari',
        subjectId: 'indonesian',
        score: 88,
        durationSeconds: 4000),
    LeaderboardEntry(
        username: 'Eka Prasetya',
        subjectId: 'indonesian',
        score: 85,
        durationSeconds: 4100),

    // Entrepreneurship
    LeaderboardEntry(
        username: 'Dewi Kartika',
        subjectId: 'entrepreneurship',
        score: 92,
        durationSeconds: 3600),
    LeaderboardEntry(
        username: 'Hamdan Arief',
        subjectId: 'entrepreneurship',
        score: 88,
        durationSeconds: 3800),
  ];

  static List<LeaderboardEntry> getForSubject(String subjectId) {
    final username = StorageService.getUsername() ?? 'YOU';
    final userHistory = StorageService.getHistoryBySubject(subjectId);

    final List<LeaderboardEntry> list =
        _rawMock.where((e) => e.subjectId == subjectId).toList();

    if (userHistory.isNotEmpty) {
      final bestScoreResult = userHistory.reduce((a, b) =>
          (a.score > b.score) ||
                  (a.score == b.score && a.durationSeconds < b.durationSeconds)
              ? a
              : b);

      list.removeWhere((e) => e.username.toUpperCase() == username.toUpperCase());
      list.add(LeaderboardEntry(
        username: username,
        subjectId: subjectId,
        score: bestScoreResult.score,
        durationSeconds: bestScoreResult.durationSeconds,
        isUser: true,
      ));
    }

    // Sort score DESC, duration ASC
    list.sort((a, b) {
      if (b.score != a.score) return b.score.compareTo(a.score);
      return a.durationSeconds.compareTo(b.durationSeconds);
    });

    return list.asMap().entries.map((entry) {
      final idx = entry.key;
      final val = entry.value;
      return val.copyWith(rank: idx + 1);
    }).toList();
  }

  static int? getUserRank(String subjectId) {
    final list = getForSubject(subjectId);
    try {
      return list.firstWhere((e) => e.isUser).rank;
    } catch (_) {
      return null;
    }
  }
}

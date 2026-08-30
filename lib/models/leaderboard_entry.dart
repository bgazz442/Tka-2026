class LeaderboardEntry {
  final String uid;
  final String username;
  final String subjectId;
  final int score;
  final int durationSeconds;
  final bool isUser;
  final int? rank;
  final DateTime? updatedAt;

  const LeaderboardEntry({
    this.uid = '',
    required this.username,
    required this.subjectId,
    required this.score,
    required this.durationSeconds,
    this.isUser = false,
    this.rank,
    this.updatedAt,
  });

  LeaderboardEntry copyWith({
    String? uid,
    String? username,
    String? subjectId,
    int? score,
    int? durationSeconds,
    bool? isUser,
    int? rank,
    DateTime? updatedAt,
  }) {
    return LeaderboardEntry(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      subjectId: subjectId ?? this.subjectId,
      score: score ?? this.score,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isUser: isUser ?? this.isUser,
      rank: rank ?? this.rank,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
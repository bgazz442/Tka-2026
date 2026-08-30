import 'package:cloud_firestore/cloud_firestore.dart';

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

  /// Create from Firestore document
  factory LeaderboardEntry.fromFirestore(
      DocumentSnapshot doc, String subjectId) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime? updatedAt;
    if (data['updatedAt'] is Timestamp) {
      updatedAt = (data['updatedAt'] as Timestamp).toDate();
    }
    return LeaderboardEntry(
      uid: doc.id,
      username: data['username'] as String? ?? 'Unknown',
      subjectId: subjectId,
      score: data['bestScore'] as int? ?? 0,
      durationSeconds: data['bestDurationSeconds'] as int? ?? 0,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'username': username,
        'bestScore': score,
        'bestDurationSeconds': durationSeconds,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

import 'package:flutter/material.dart';
import '../models/leaderboard_entry.dart';
import '../services/scoring_service.dart';

class LeaderboardCardWidget extends StatelessWidget {
  final LeaderboardEntry entry;

  const LeaderboardCardWidget({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    Color rankColor = const Color(0xFF64748B);
    Color rankBg = const Color(0xFFF1F5F9);
    IconData? medalIcon;

    if (entry.rank == 1) {
      rankColor = const Color(0xFFD97706);
      rankBg = const Color(0xFFFEF3C7);
      medalIcon = Icons.workspace_premium_rounded;
    } else if (entry.rank == 2) {
      rankColor = const Color(0xFF475569);
      rankBg = const Color(0xFFE2E8F0);
      medalIcon = Icons.military_tech_rounded;
    } else if (entry.rank == 3) {
      rankColor = const Color(0xFFB45309);
      rankBg = const Color(0xFFFFEDD5);
      medalIcon = Icons.military_tech_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: entry.isUser ? const Color(0xFFEEF2FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: entry.isUser
              ? const Color(0xFF6366F1)
              : const Color(0xFFE2E8F0),
          width: entry.isUser ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: rankBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: medalIcon != null
                  ? Icon(medalIcon, color: rankColor, size: 20)
                  : Text(
                      '#${entry.rank}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: rankColor,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),

          // Username & Tag
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              entry.isUser ? FontWeight.bold : FontWeight.w600,
                          color: entry.isUser
                              ? const Color(0xFF312E81)
                              : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    if (entry.isUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (entry.durationSeconds > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Waktu: ${ScoringService.formatDurationText(entry.durationSeconds)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Score
          Text(
            '${entry.score}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: entry.isUser
                  ? const Color(0xFF4F46E5)
                  : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

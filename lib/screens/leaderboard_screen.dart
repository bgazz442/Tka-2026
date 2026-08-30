import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/subjects_data.dart';
import '../models/leaderboard_entry.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../services/scoring_service.dart';
import '../utils/constants.dart';

class LeaderboardScreen extends StatefulWidget {
  final String? initialSubjectId;

  const LeaderboardScreen({
    super.key,
    this.initialSubjectId,
  });

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();

    int initialIndex = 0;
    if (widget.initialSubjectId != null) {
      initialIndex = SubjectsData.list
          .indexWhere((s) => s.id == widget.initialSubjectId);
      if (initialIndex < 0) initialIndex = 0;
    }

    _tabController = TabController(
      length: SubjectsData.list.length,
      vsync: this,
      initialIndex: initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = context.read<AuthProvider>().uid;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('🏆 Leaderboard'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppConstants.primaryColor,
          unselectedLabelColor: AppConstants.textSecondary,
          indicatorColor: AppConstants.primaryColor,
          tabs: SubjectsData.list.map((s) {
            return Tab(
              child: Row(
                children: [
                  Text(s.icon),
                  const SizedBox(width: 6),
                  Text(s.title),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: SubjectsData.list.map((subject) {
          return _LeaderboardTab(
            subjectId: subject.id,
            currentUid: currentUid,
            firestoreService: _firestoreService,
          );
        }).toList(),
      ),
    );
  }
}

class _LeaderboardTab extends StatelessWidget {
  final String subjectId;
  final String currentUid;
  final FirestoreService firestoreService;

  const _LeaderboardTab({
    required this.subjectId,
    required this.currentUid,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LeaderboardEntry>>(
      stream: firestoreService.streamLeaderboard(subjectId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off_rounded,
                      size: 48, color: AppConstants.textMuted),
                  const SizedBox(height: 16),
                  const Text(
                    'Gagal memuat leaderboard',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Periksa koneksi internet kamu.',
                    style: TextStyle(
                        fontSize: 13, color: AppConstants.textSecondary),
                  ),
                ],
              ),
            ),
          );
        }

        final list = snapshot.data ?? [];

        if (list.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events_rounded,
                      size: 64, color: Color(0xFFE2E8F0)),
                  SizedBox(height: 16),
                  Text(
                    'Leaderboard Kosong',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Jadilah yang pertama mengerjakan tryout mapel ini!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14, color: AppConstants.textSecondary),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final entry = list[index];
            final isCurrentUser = entry.uid == currentUid;
            return _LeaderboardCard(
              entry: entry,
              isCurrentUser: isCurrentUser,
            );
          },
        );
      },
    );
  }
}

class _LeaderboardCard extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  const _LeaderboardCard({
    required this.entry,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final rank = entry.rank ?? 0;

    Widget rankBadge;
    if (rank == 1) {
      rankBadge = const Text('🥇', style: TextStyle(fontSize: 24));
    } else if (rank == 2) {
      rankBadge = const Text('🥈', style: TextStyle(fontSize: 24));
    } else if (rank == 3) {
      rankBadge = const Text('🥉', style: TextStyle(fontSize: 24));
    } else {
      rankBadge = Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isCurrentUser
              ? AppConstants.primaryLightColor
              : const Color(0xFFF1F5F9),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '#$rank',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isCurrentUser
                  ? AppConstants.primaryColor
                  : AppConstants.textSecondary,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppConstants.primaryLightColor
            : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
        border: Border.all(
          color: isCurrentUser
              ? AppConstants.primaryColor.withValues(alpha: 0.3)
              : const Color(0xFFE2E8F0),
          width: isCurrentUser ? 1.5 : 1,
        ),
        boxShadow: isCurrentUser
            ? [
                BoxShadow(
                  color: AppConstants.primaryColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Rank badge
          SizedBox(width: 40, child: Center(child: rankBadge)),
          const SizedBox(width: 12),

          // Avatar circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? AppConstants.primaryColor
                  : const Color(0xFFE2E8F0),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                entry.username.isNotEmpty
                    ? entry.username[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isCurrentUser
                      ? Colors.white
                      : AppConstants.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Username & YOU badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.username,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isCurrentUser
                              ? AppConstants.primaryColor
                              : AppConstants.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor,
                          borderRadius: BorderRadius.circular(6),
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
                const SizedBox(height: 2),
                Text(
                  ScoringService.formatClock(entry.durationSeconds),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppConstants.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.score}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isCurrentUser
                      ? AppConstants.primaryColor
                      : _scoreColor(entry.score),
                ),
              ),
              const Text(
                'poin',
                style: TextStyle(
                  fontSize: 10,
                  color: AppConstants.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _scoreColor(int score) {
    if (score >= 85) return AppConstants.successColor;
    if (score >= 70) return AppConstants.warningColor;
    return AppConstants.textSecondary;
  }
}

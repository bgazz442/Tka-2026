import 'package:flutter/material.dart';
import '../data/subjects_data.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../widgets/subject_card.dart';
import 'package_screen.dart';
import 'subject_screen.dart';
import 'progress_screen.dart';
import 'history_screen.dart';
import 'leaderboard_screen.dart';
import 'settings_screen.dart';
import '../data/leaderboard_data.dart';
import 'package_detail_screen.dart';
import '../data/english/english_packages.dart';
import '../data/mathematics/mathematics_packages.dart';
import '../data/indonesian/indonesian_packages.dart';
import '../models/exam_package.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentBottomNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentBottomNavIndex,
        children: const [
          _DashboardView(),
          SubjectScreen(),
          ProgressScreen(),
          HistoryScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (idx) => setState(() => _currentBottomNavIndex = idx),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: const Color(0xFF94A3B8),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: 'Mapel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights_rounded),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  ExamPackage? _findPackageById(String packageId) {
    for (final p in EnglishPackages.list) {
      if (p.id == packageId) return p;
    }
    for (final p in MathematicsPackages.list) {
      if (p.id == packageId) return p;
    }
    for (final p in IndonesianPackages.list) {
      if (p.id == packageId) return p;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final username = StorageService.getUsername() ?? 'Siswa';
    final overallStats = StorageService.getOverallStats();
    final activeExam = StorageService.getActiveExam();

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'TKA',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(AppConstants.appName),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_rounded,
                color: Color(0xFFD97706)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
              );
            },
            tooltip: 'Leaderboard',
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            tooltip: 'Pengaturan',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Banner
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selamat datang kembali,',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          '$username 👋',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Terus tingkatkan kemampuanmu untuk menghadapi TKA.',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 20),

              // Resume Banner (If tryout is currently in progress)
              if (activeExam != null) ...[
                Builder(builder: (context) {
                  final pkgId = activeExam['packageId'] as String;
                  final pkg = _findPackageById(pkgId);
                  if (pkg == null) return const SizedBox.shrink();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF59E0B)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.play_circle_fill_rounded,
                            color: Color(0xFFD97706), size: 36),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tryout sebelumnya belum selesai',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD97706),
                                ),
                              ),
                              Text(
                                pkg.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PackageDetailScreen(package: pkg),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD97706),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                          ),
                          child: const Text('Lanjutkan',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  );
                }),
              ],

              // Quick Statistics Section
              if (overallStats != null) ...[
                const Text(
                  '📊 STATISTIK KAMU',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildDashboardStatCard(
                        'Total Tryout',
                        '${overallStats['totalTryouts']}',
                        const Color(0xFF4F46E5),
                        const Color(0xFFEEF2FF),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDashboardStatCard(
                        'Total Soal',
                        '${overallStats['totalQuestions']}',
                        const Color(0xFF0EA5E9),
                        const Color(0xFFE0F2FE),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDashboardStatCard(
                        'Rata-rata',
                        '${overallStats['avgScore']}',
                        const Color(0xFFD97706),
                        const Color(0xFFFFFBEB),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDashboardStatCard(
                        'Terbaik',
                        '${overallStats['bestScore']}',
                        const Color(0xFF16A34A),
                        const Color(0xFFF0FDF4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // Leaderboard Rank Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.emoji_events_rounded,
                            color: Color(0xFFD97706), size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Peringkat Saya',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LeaderboardScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Lihat Semua',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: SubjectsData.list.map((subj) {
                        final rank = LeaderboardData.getUserRank(subj.id);
                        return Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LeaderboardScreen(
                                      initialSubjectId: subj.id),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: subj.backgroundColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Text(subj.icon,
                                      style: const TextStyle(fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text(
                                    rank != null ? '#$rank' : '-',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: subj.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Subject List Section
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PILIH MATA PELAJARAN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ...SubjectsData.list.map((subject) {
                return SubjectCard(
                  subject: subject,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PackageScreen(subject: subject),
                      ),
                    );
                  },
                );
              }),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardStatCard(
      String label, String value, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

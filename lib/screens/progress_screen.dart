import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/subjects_data.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../data/english/english_packages.dart';
import '../data/mathematics/mathematics_packages.dart';
import '../data/indonesian/indonesian_packages.dart';
import '../data/entrepreneurship/entrepreneurship_packages.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  int _getTotalPackages(String subjectId) {
    switch (subjectId) {
      case 'english':
        return EnglishPackages.list.length;
      case 'mathematics':
        return MathematicsPackages.list.length;
      case 'indonesian':
        return IndonesianPackages.list.length;
      case 'entrepreneurship':
        return EntrepreneurshipPackages.list.length;
      default:
        return 0;
    }
  }

  List<String> _getPackageIds(String subjectId) {
    switch (subjectId) {
      case 'english':
        return EnglishPackages.list.map((e) => e.id).toList();
      case 'mathematics':
        return MathematicsPackages.list.map((e) => e.id).toList();
      case 'indonesian':
        return IndonesianPackages.list.map((e) => e.id).toList();
      case 'entrepreneurship':
        return EntrepreneurshipPackages.list.map((e) => e.id).toList();
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final overallStats = StorageService.getOverallStats();
    final allHistory = StorageService.getHistory();
    final bestScores = StorageService.getBestScores();

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Perkembangan Belajar'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Stats Header Cards
            if (overallStats != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatHeaderItem(
                      'Total Tryout',
                      '${overallStats['totalTryouts']}',
                    ),
                    _buildStatHeaderItem(
                      'Rata-rata',
                      '${overallStats['avgScore']}',
                    ),
                    _buildStatHeaderItem(
                      'Nilai Terbaik',
                      '${overallStats['bestScore']}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Line Chart: Perkembangan Nilai
            const Text(
              '📈 GRAFIK PERKEMBANGAN NILAI',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              height: 220,
              padding: const EdgeInsets.fromLTRB(16, 20, 20, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: allHistory.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada data tryout.\nKerjakan tryout untuk melihat grafik!',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: true, drawVerticalLine: false),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (val, meta) {
                                final idx = val.toInt();
                                if (idx >= 0 && idx < allHistory.reversed.length) {
                                  return Text('T${idx + 1}',
                                      style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)));
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minY: 0,
                        maxY: 100,
                        lineBarsData: [
                          LineChartBarData(
                            spots: allHistory.reversed
                                .toList()
                                .asMap()
                                .entries
                                .map((e) => FlSpot(e.key.toDouble(), e.value.score.toDouble()))
                                .toList(),
                            isCurved: true,
                            color: AppConstants.primaryColor,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppConstants.primaryColor.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 28),

            // Subject Breakdown Cards
            const Text(
              '📚 PROGRESS MATA PELAJARAN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            ...SubjectsData.list.map((subject) {
              final total = _getTotalPackages(subject.id);
              final pkgIds = _getPackageIds(subject.id);
              final completed =
                  pkgIds.where((id) => bestScores.containsKey(id)).length;
              final subjectStats = StorageService.getSubjectStats(subject.id);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
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
                        Text(subject.icon,
                            style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Text(
                          subject.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$completed / $total paket',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: subject.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: total > 0 ? completed / total : 0,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            subject.primaryColor),
                        minHeight: 6,
                      ),
                    ),
                    if (subjectStats != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Terbaik: ${subjectStats['bestScore']}',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF16A34A)),
                          ),
                          Text(
                            'Rata-rata: ${subjectStats['avgScore']}',
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF475569)),
                          ),
                          Text(
                            'Tryout: ${subjectStats['totalTryouts']}x',
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF475569)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatHeaderItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

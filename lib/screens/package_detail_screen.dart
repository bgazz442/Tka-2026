import 'package:flutter/material.dart';
import '../models/exam_package.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'exam_screen.dart';

class PackageDetailScreen extends StatefulWidget {
  final ExamPackage package;

  const PackageDetailScreen({
    super.key,
    required this.package,
  });

  @override
  State<PackageDetailScreen> createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends State<PackageDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final package = widget.package;
    final historyList = StorageService.getHistoryByPackage(package.id);
    final bestScore = StorageService.getBestScoreForPackage(package.id);
    final activeExam = StorageService.getActiveExam();

    final isCurrentlyOngoing =
        activeExam != null && activeExam['packageId'] == package.id;

    final lastAttempt = historyList.isNotEmpty ? historyList.first : null;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(package.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isCurrentlyOngoing
                          ? 'DAPAT DILANJUTKAN'
                          : (historyList.isNotEmpty
                              ? 'SUDAH SELESAI'
                              : 'BELUM DIKERJAKAN'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    package.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  if (package.description != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      package.description!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Package Specifications
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildSpecRow(
                    Icons.help_outline_rounded,
                    'Jumlah Soal',
                    '${package.questionCount} Soal',
                  ),
                  const Divider(height: 24, color: Color(0xFFF1F5F9)),
                  _buildSpecRow(
                    Icons.timer_outlined,
                    'Durasi Pengerjaan',
                    '${package.durationMinutes} Menit',
                  ),
                  const Divider(height: 24, color: Color(0xFFF1F5F9)),
                  _buildSpecRow(
                    Icons.rule_rounded,
                    'Sistem Penilaian',
                    'Benar +4, Salah -1, Kosong 0',
                  ),
                  const Divider(height: 24, color: Color(0xFFF1F5F9)),
                  _buildSpecRow(
                    Icons.link_rounded,
                    'Sumber Latihan',
                    package.sourceName,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // History & Best Score Card (if available)
            if (lastAttempt != null || bestScore != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'STATISTIK PAKET INI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatTile('Nilai Terbaik',
                              '${bestScore ?? lastAttempt?.score}',
                              color: const Color(0xFF16A34A)),
                        ),
                        Expanded(
                          child: _buildStatTile('Nilai Terakhir',
                              '${lastAttempt?.score ?? "-"}'),
                        ),
                        Expanded(
                          child: _buildStatTile(
                              'Percobaan', '${historyList.length}x'),
                        ),
                      ],
                    ),
                    if (lastAttempt != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Terakhir mengerjakan: ${AppHelpers.formatDateTime(lastAttempt.completedAt)}',
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Start / Resume Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExamScreen(package: package),
                    ),
                  );
                },
                icon: Icon(
                  isCurrentlyOngoing
                      ? Icons.play_arrow_rounded
                      : Icons.assignment_turned_in_rounded,
                ),
                label: Text(
                  isCurrentlyOngoing
                      ? 'Lanjutkan Tryout'
                      : (historyList.isNotEmpty
                          ? 'Ulangi Tryout'
                          : 'Mulai Tryout'),
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: isCurrentlyOngoing
                      ? const Color(0xFFD97706)
                      : AppConstants.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF4F46E5)),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color ?? const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

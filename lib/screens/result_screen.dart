import 'package:flutter/material.dart';
import '../models/exam_result.dart';
import '../services/scoring_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import 'review_screen.dart';

class ResultScreen extends StatelessWidget {
  final ExamResult result;

  const ResultScreen({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final history = StorageService.getHistoryByPackage(result.packageId);

    // Calculate score comparison if there's a previous attempt
    int? diff;
    if (history.length > 1) {
      final previousAttempt = history[1]; // index 0 is current attempt
      diff = result.score - previousAttempt.score;
    }

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Hasil Tryout'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Celebratory Banner Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'TRYOUT SELESAI 🎉',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppConstants.primaryColor,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.username,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    result.packageName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Giant Score Circle
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: result.score >= 75
                            ? [const Color(0xFF16A34A), const Color(0xFF22C55E)]
                            : [const Color(0xFF4F46E5), const Color(0xFF6366F1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (result.score >= 75
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFF4F46E5))
                              .withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${result.score}',
                            style: const TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'SKOR AKHIR',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Score Comparison badge if previous exists
                  if (diff != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: diff > 0
                            ? const Color(0xFFF0FDF4)
                            : (diff < 0
                                ? const Color(0xFFFFF1F2)
                                : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: diff > 0
                              ? const Color(0xFFBBF7D0)
                              : (diff < 0
                                  ? const Color(0xFFFECDD3)
                                  : const Color(0xFFCBD5E1)),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            diff > 0
                                ? Icons.trending_up_rounded
                                : (diff < 0
                                    ? Icons.trending_down_rounded
                                    : Icons.trending_flat_rounded),
                            size: 16,
                            color: diff > 0
                                ? const Color(0xFF16A34A)
                                : (diff < 0
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF64748B)),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            diff > 0
                                ? 'Naik $diff poin dari percobaan sebelumnya'
                                : (diff < 0
                                    ? 'Turun ${diff.abs()} poin dari percobaan sebelumnya'
                                    : 'Sama dengan percobaan sebelumnya'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: diff > 0
                                  ? const Color(0xFF15803D)
                                  : (diff < 0
                                      ? const Color(0xFFB91C1C)
                                      : const Color(0xFF475569)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Statistics Grid (Benar, Salah, Kosong, Waktu)
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Benar',
                    '${result.correct}',
                    Icons.check_circle_rounded,
                    const Color(0xFF16A34A),
                    const Color(0xFFF0FDF4),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatCard(
                    'Salah',
                    '${result.wrong}',
                    Icons.cancel_rounded,
                    const Color(0xFFDC2626),
                    const Color(0xFFFFF1F2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatCard(
                    'Kosong',
                    '${result.empty}',
                    Icons.remove_circle_outline_rounded,
                    const Color(0xFF64748B),
                    const Color(0xFFF1F5F9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Duration Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, color: Color(0xFF4F46E5)),
                  const SizedBox(width: 12),
                  const Text(
                    'Waktu Pengerjaan',
                    style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  ),
                  const Spacer(),
                  Text(
                    ScoringService.formatDurationText(result.durationSeconds),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons: Review, Retry, Return to Home
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewScreen(result: result),
                    ),
                  );
                },
                icon: const Icon(Icons.menu_book_rounded),
                label: const Text('Review Jawaban & Pembahasan'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.home_rounded),
                label: const Text('Kembali ke Dashboard'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

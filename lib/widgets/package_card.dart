import 'package:flutter/material.dart';
import '../models/exam_package.dart';
import '../services/storage_service.dart';
import '../utils/helpers.dart';

class PackageCard extends StatelessWidget {
  final ExamPackage package;
  final VoidCallback onTap;

  const PackageCard({
    super.key,
    required this.package,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final historyList = StorageService.getHistoryByPackage(package.id);
    final bestScore = StorageService.getBestScoreForPackage(package.id);
    final activeExam = StorageService.getActiveExam();

    final isCurrentlyOngoing =
        activeExam != null && activeExam['packageId'] == package.id;

    String statusText;
    Color statusColor;
    Color statusBgColor;

    if (isCurrentlyOngoing) {
      statusText = 'Sedang dikerjakan';
      statusColor = const Color(0xFFD97706);
      statusBgColor = const Color(0xFFFFFBEB);
    } else if (historyList.isNotEmpty) {
      statusText = 'Selesai';
      statusColor = const Color(0xFF16A34A);
      statusBgColor = const Color(0xFFF0FDF4);
    } else {
      statusText = 'Belum dikerjakan';
      statusColor = const Color(0xFF64748B);
      statusBgColor = const Color(0xFFF1F5F9);
    }

    final lastAttempt = historyList.isNotEmpty ? historyList.first : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentlyOngoing
              ? const Color(0xFFF59E0B)
              : const Color(0xFFE2E8F0),
          width: isCurrentlyOngoing ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: Title & Badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        package.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Specs: Question count & Time limit
                Row(
                  children: [
                    const Icon(Icons.help_outline_rounded,
                        size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(
                      '${package.questionCount} Soal',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.timer_outlined,
                        size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(
                      '${package.durationMinutes} Menit',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                if (lastAttempt != null) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 12),

                  // History stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nilai Terakhir',
                            style: TextStyle(
                                fontSize: 11, color: Color(0xFF94A3B8)),
                          ),
                          Text(
                            '${lastAttempt.score}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nilai Terbaik',
                            style: TextStyle(
                                fontSize: 11, color: Color(0xFF94A3B8)),
                          ),
                          Text(
                            '${bestScore ?? lastAttempt.score}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Terakhir Dikerjakan',
                            style: TextStyle(
                                fontSize: 11, color: Color(0xFF94A3B8)),
                          ),
                          Text(
                            AppHelpers.formatDate(lastAttempt.completedAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

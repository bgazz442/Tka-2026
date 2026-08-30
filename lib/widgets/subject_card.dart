import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../services/storage_service.dart';
import '../data/english/english_packages.dart';
import '../data/mathematics/mathematics_packages.dart';
import '../data/indonesian/indonesian_packages.dart';
import '../data/entrepreneurship/entrepreneurship_packages.dart';

class SubjectCard extends StatelessWidget {
  final Subject subject;
  final VoidCallback onTap;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.onTap,
  });

  int _getTotalPackages() {
    switch (subject.id) {
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

  List<String> _getPackageIds() {
    switch (subject.id) {
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
    final totalPackages = _getTotalPackages();
    final packageIds = _getPackageIds();

    final bestScores = StorageService.getBestScores();
    final completedCount =
        packageIds.where((id) => bestScores.containsKey(id)).length;

    final double progress =
        totalPackages > 0 ? (completedCount / totalPackages) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
            child: Row(
              children: [
                // Subject Icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: subject.backgroundColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      subject.icon,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Title & Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subject.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Progress bar
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: const Color(0xFFF1F5F9),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    subject.primaryColor),
                                minHeight: 6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '$completedCount/$totalPackages paket',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: subject.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Arrow
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

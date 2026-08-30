import 'package:flutter/material.dart';
import '../data/english/english_packages.dart';
import '../data/mathematics/mathematics_packages.dart';
import '../data/indonesian/indonesian_packages.dart';
import '../data/entrepreneurship/entrepreneurship_packages.dart';
import '../models/exam_package.dart';
import '../models/subject.dart';
import '../utils/constants.dart';
import '../widgets/package_card.dart';
import 'package_detail_screen.dart';

class PackageScreen extends StatelessWidget {
  final Subject subject;

  const PackageScreen({
    super.key,
    required this.subject,
  });

  List<ExamPackage> _getPackages() {
    switch (subject.id) {
      case 'english':
        return EnglishPackages.list;
      case 'mathematics':
        return MathematicsPackages.list;
      case 'indonesian':
        return IndonesianPackages.list;
      case 'entrepreneurship':
        return EntrepreneurshipPackages.list;
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final packages = _getPackages();

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text('Daftar Paket — ${subject.title}'),
      ),
      body: packages.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: subject.backgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          subject.icon,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${subject.title} belum memiliki paket soal.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Paket soal untuk mata pelajaran ini akan segera tersedia.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: packages.length,
              itemBuilder: (context, index) {
                final package = packages[index];
                return PackageCard(
                  package: package,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PackageDetailScreen(package: package),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

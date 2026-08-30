import 'package:flutter/material.dart';
import '../data/subjects_data.dart';
import '../utils/constants.dart';
import '../widgets/subject_card.dart';
import 'package_screen.dart';

class SubjectScreen extends StatelessWidget {
  const SubjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Pilih Mata Pelajaran'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: SubjectsData.list.length,
        itemBuilder: (context, index) {
          final subject = SubjectsData.list[index];
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
        },
      ),
    );
  }
}

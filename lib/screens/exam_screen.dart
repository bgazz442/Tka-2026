import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exam_package.dart';
import '../providers/auth_provider.dart';
import '../services/exam_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../widgets/timer_widget.dart';
import '../widgets/question_card.dart';
import '../widgets/question_navigator.dart';
import '../widgets/warning_dialog.dart';
import 'result_screen.dart';

class ExamScreen extends StatelessWidget {
  final ExamPackage package;

  const ExamScreen({
    super.key,
    required this.package,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final username = StorageService.getUsername() ?? auth.username;
    final activeExamData = StorageService.getActiveExam();

    Map<String, dynamic>? restoredSession;
    if (activeExamData != null && activeExamData['packageId'] == package.id) {
      restoredSession = activeExamData;
    }

    return ChangeNotifierProvider(
      create: (_) => ExamService(
        package: package,
        uid: auth.uid,
        username: username,
        restoredSession: restoredSession,
      ),
      child: const _ExamContent(),
    );
  }
}

class _ExamContent extends StatefulWidget {
  const _ExamContent();

  @override
  State<_ExamContent> createState() => _ExamContentState();
}

class _ExamContentState extends State<_ExamContent> {
  int _lastWarningCount = 0;

  @override
  Widget build(BuildContext context) {
    final exam = Provider.of<ExamService>(context);

    // Monitor Anti-cheat warnings & navigate to result if submitted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (exam.warningsCount > _lastWarningCount &&
          exam.warningsCount <= 5) {
        _lastWarningCount = exam.warningsCount;
        _showViolationWarningDialog(context, exam.warningsCount);
      }

      if (exam.result != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ResultScreen(result: exam.result!),
          ),
        );
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final shouldExit = await _showExitConfirmationDialog(context);
        if (shouldExit == true && mounted) {
          navigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 16,
          title: Row(
            children: [
              // Exit button
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final shouldExit = await _showExitConfirmationDialog(context);
                  if (shouldExit == true && mounted) {
                    navigator.pop();
                  }
                },
              ),
              const SizedBox(width: 4),

              // Question progress counter
              Text(
                'Soal ${exam.currentIndex + 1} dari ${exam.totalQuestions}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const Spacer(),

              // Timer widget
              TimerWidget(remainingSeconds: exam.remainingSeconds),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: (exam.currentIndex + 1) / exam.totalQuestions,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
              minHeight: 4,
            ),
          ),
        ),
        body: Column(
          children: [
            // Warning bar if violations exist
            if (exam.warningsCount > 0)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                color: const Color(0xFFFFF1F2),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Color(0xFFDC2626), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Pelanggaran: ${exam.warningsCount}/5',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Jangan tinggalkan halaman tryout',
                      style: TextStyle(fontSize: 11, color: Color(0xFFB91C1C)),
                    ),
                  ],
                ),
              ),

            // Question Card Body
            Expanded(
              child: QuestionCardWidget(
                question: exam.currentQuestion,
                selectedAnswer: exam.answers[exam.currentQuestion.id],
                onAnswerSelected: (optionId) {
                  exam.selectAnswer(exam.currentQuestion.id, optionId);
                },
              ),
            ),
          ],
        ),

        // Bottom Controls: Mark, Navigator Sheet, Prev / Next
        bottomNavigationBar: Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).padding.bottom + 12,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            children: [
              // Mark / Flag Button
              IconButton.filledTonal(
                onPressed: () {
                  exam.toggleFlag(exam.currentQuestion.id);
                },
                icon: Icon(
                  exam.flaggedQuestions.contains(exam.currentQuestion.id)
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: exam.flaggedQuestions
                          .contains(exam.currentQuestion.id)
                      ? const Color(0xFFFFFBEB)
                      : const Color(0xFFF1F5F9),
                  foregroundColor: exam.flaggedQuestions
                          .contains(exam.currentQuestion.id)
                      ? const Color(0xFFD97706)
                      : const Color(0xFF64748B),
                ),
                tooltip: 'Tandai Soal',
              ),
              const SizedBox(width: 8),

              // Question Navigator Sheet Opener
              OutlinedButton.icon(
                onPressed: () {
                  _showNavigatorSheet(context, exam);
                },
                icon: const Icon(Icons.grid_view_rounded, size: 18),
                label: Text('${exam.currentIndex + 1}'),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
              ),
              const SizedBox(width: 12),

              // Previous Button
              Expanded(
                child: OutlinedButton(
                  onPressed:
                      exam.currentIndex > 0 ? () => exam.previousQuestion() : null,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Sebelumnya'),
                ),
              ),
              const SizedBox(width: 8),

              // Next / Submit Button
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (exam.currentIndex < exam.totalQuestions - 1) {
                      exam.nextQuestion();
                    } else {
                      _showSubmitConfirmationDialog(context, exam);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: exam.currentIndex == exam.totalQuestions - 1
                        ? const Color(0xFF16A34A)
                        : AppConstants.primaryColor,
                  ),
                  child: Text(
                    exam.currentIndex == exam.totalQuestions - 1
                        ? 'Periksa Jawaban'
                        : 'Berikutnya',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNavigatorSheet(BuildContext context, ExamService exam) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuestionNavigatorWidget(
        questions: exam.package.questions,
        currentIndex: exam.currentIndex,
        answers: exam.answers,
        flaggedQuestions: exam.flaggedQuestions,
        onSelectQuestion: (index) => exam.goToQuestion(index),
      ),
    );
  }

  void _showViolationWarningDialog(BuildContext context, int count) {
    showDialog(
      context: context,
      builder: (ctx) => WarningDialog(
        title: 'Perhatian! (Pelanggaran $count/5)',
        message:
            'Kamu meninggalkan halaman tryout.\nJangan berpindah aplikasi atau tab selama pengerjaan.',
        primaryButtonText: 'Saya Mengerti',
        isDanger: true,
        onPrimaryPressed: () => Navigator.pop(ctx),
      ),
    );
  }

  Future<bool?> _showExitConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => WarningDialog(
        title: 'Keluar dari Tryout?',
        message:
            'Progress jawaban dan sisa waktu kamu akan disimpan.\nKamu dapat melanjutkannya nanti.',
        primaryButtonText: 'Keluar',
        secondaryButtonText: 'Batal',
        onPrimaryPressed: () => Navigator.pop(ctx, true),
        onSecondaryPressed: () => Navigator.pop(ctx, false),
      ),
    );
  }

  void _showSubmitConfirmationDialog(BuildContext context, ExamService exam) {
    final int total = exam.totalQuestions;
    final int answered = exam.answers.length;
    final int empty = total - answered;
    final int flagged = exam.flaggedQuestions.length;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Konfirmasi Submit',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Apakah kamu yakin ingin mengakhiri tryout ini?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 20),

              // Summary Stats Table
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(
                        'Sudah Dijawab', '$answered', const Color(0xFF16A34A)),
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                        'Belum Dijawab', '$empty', const Color(0xFFDC2626)),
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                        'Ditandai', '$flagged', const Color(0xFFD97706)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Kembali'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        exam.submitExam();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

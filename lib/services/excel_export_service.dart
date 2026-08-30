import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/exam_result.dart';
import 'storage_service.dart';

class ExcelExportService {
  static Future<({String filePath, String fileName, int sizeBytes})?> exportTryoutResults() async {
    final profile = StorageService.getProfile();
    final username = (profile?['username'] ?? StorageService.getUsername() ?? 'User').toString();
    final history = StorageService.getHistory();

    if (history.isEmpty) {
      throw StateError('Belum ada hasil tryout yang dapat diekspor.');
    }

    final safeUsername = _sanitizeFileName(username);
    final workbook = Excel.createExcel();

    final dataSheet = workbook['Data Tryout'];
    final summarySheet = workbook['Ringkasan'];
    final progressSheet = workbook['Perkembangan'];

    dataSheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('No');
    dataSheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('Tanggal');
    dataSheet.cell(CellIndex.indexByString('C1')).value = TextCellValue('Nama');
    dataSheet.cell(CellIndex.indexByString('D1')).value = TextCellValue('Mapel');
    dataSheet.cell(CellIndex.indexByString('E1')).value = TextCellValue('Tryout');
    dataSheet.cell(CellIndex.indexByString('F1')).value = TextCellValue('Jumlah Soal');
    dataSheet.cell(CellIndex.indexByString('G1')).value = TextCellValue('Benar');
    dataSheet.cell(CellIndex.indexByString('H1')).value = TextCellValue('Salah');
    dataSheet.cell(CellIndex.indexByString('I1')).value = TextCellValue('Tidak Dijawab');
    dataSheet.cell(CellIndex.indexByString('J1')).value = TextCellValue('Nilai');
    dataSheet.cell(CellIndex.indexByString('K1')).value = TextCellValue('Durasi');

    for (var i = 0; i < history.length; i++) {
      final item = history[i];
      final row = i + 2;
      final date = DateTime.tryParse(item.completedAt)?.toLocal() ?? DateTime.now();
      dataSheet.cell(CellIndex.indexByString('A$row')).value = IntCellValue(i + 1);
      dataSheet.cell(CellIndex.indexByString('B$row')).value = TextCellValue(_formatDate(date));
      dataSheet.cell(CellIndex.indexByString('C$row')).value = TextCellValue(item.username);
      dataSheet.cell(CellIndex.indexByString('D$row')).value = TextCellValue(_subjectLabel(item.subjectId));
      dataSheet.cell(CellIndex.indexByString('E$row')).value = TextCellValue(item.packageName);
      dataSheet.cell(CellIndex.indexByString('F$row')).value = IntCellValue(item.totalQuestions);
      dataSheet.cell(CellIndex.indexByString('G$row')).value = IntCellValue(item.correct);
      dataSheet.cell(CellIndex.indexByString('H$row')).value = IntCellValue(item.wrong);
      dataSheet.cell(CellIndex.indexByString('I$row')).value = IntCellValue(item.empty);
      dataSheet.cell(CellIndex.indexByString('J$row')).value = IntCellValue(item.score);
      dataSheet.cell(CellIndex.indexByString('K$row')).value = TextCellValue(_formatDuration(item.durationSeconds));
    }

    summarySheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Nama Peserta');
    summarySheet.cell(CellIndex.indexByString('B1')).value = TextCellValue(username);
    summarySheet.cell(CellIndex.indexByString('A2')).value = TextCellValue('Email');
    summarySheet.cell(CellIndex.indexByString('B2')).value = TextCellValue(profile?['email']?.toString() ?? '-');
    summarySheet.cell(CellIndex.indexByString('A3')).value = TextCellValue('Tanggal Export');
    summarySheet.cell(CellIndex.indexByString('B3')).value = TextCellValue(_formatDate(DateTime.now()));
    summarySheet.cell(CellIndex.indexByString('A5')).value = TextCellValue('Total Tryout');
    summarySheet.cell(CellIndex.indexByString('B5')).value = IntCellValue(history.length);
    summarySheet.cell(CellIndex.indexByString('A6')).value = TextCellValue('Total Soal');
    summarySheet.cell(CellIndex.indexByString('B6')).value = IntCellValue(history.fold<int>(0, (sum, item) => sum + item.totalQuestions));
    summarySheet.cell(CellIndex.indexByString('A7')).value = TextCellValue('Total Benar');
    summarySheet.cell(CellIndex.indexByString('B7')).value = IntCellValue(history.fold<int>(0, (sum, item) => sum + item.correct));
    summarySheet.cell(CellIndex.indexByString('A8')).value = TextCellValue('Total Salah');
    summarySheet.cell(CellIndex.indexByString('B8')).value = IntCellValue(history.fold<int>(0, (sum, item) => sum + item.wrong));
    summarySheet.cell(CellIndex.indexByString('A10')).value = TextCellValue('Rata-rata Nilai');
    summarySheet.cell(CellIndex.indexByString('B10')).value = IntCellValue(_averageScore(history));
    summarySheet.cell(CellIndex.indexByString('A11')).value = TextCellValue('Nilai Tertinggi');
    summarySheet.cell(CellIndex.indexByString('B11')).value = IntCellValue(history.map((e) => e.score).reduce((a, b) => a > b ? a : b));
    summarySheet.cell(CellIndex.indexByString('A12')).value = TextCellValue('Nilai Terendah');
    summarySheet.cell(CellIndex.indexByString('B12')).value = IntCellValue(history.map((e) => e.score).reduce((a, b) => a < b ? a : b));

    final subjectRows = [
      ['Mapel', 'Jumlah Tryout', 'Rata-rata', 'Nilai Tertinggi', 'Nilai Terendah'],
      ['Bahasa Inggris', 0, 0, 0, 0],
      ['Matematika', 0, 0, 0, 0],
      ['Bahasa Indonesia', 0, 0, 0, 0],
      ['Kewirausahaan', 0, 0, 0, 0],
    ];

    final subjectIds = ['english', 'mathematics', 'indonesian', 'entrepreneurship'];
    for (var i = 0; i < subjectIds.length; i++) {
      final subjectId = subjectIds[i];
      final subjectHistory = history.where((item) => item.subjectId == subjectId).toList();
      final rowIndex = i + 1;
      subjectRows[rowIndex][1] = subjectHistory.length;
      if (subjectHistory.isNotEmpty) {
        final scores = subjectHistory.map((item) => item.score).toList();
        subjectRows[rowIndex][2] = _average(scores);
        subjectRows[rowIndex][3] = scores.reduce((a, b) => a > b ? a : b);
        subjectRows[rowIndex][4] = scores.reduce((a, b) => a < b ? a : b);
      }
    }

    final tableStartRow = 15;
    final tableHeaders = ['Mapel', 'Jumlah Tryout', 'Rata-rata', 'Nilai Tertinggi', 'Nilai Terendah'];
    for (var col = 0; col < tableHeaders.length; col++) {
      summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: tableStartRow)).value = TextCellValue(tableHeaders[col]);
    }
    for (var row = 0; row < subjectRows.length - 1; row++) {
      final data = subjectRows[row + 1];
      for (var col = 0; col < 5; col++) {
        final cell = summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: tableStartRow + row + 1));
        if (col == 0) {
          cell.value = TextCellValue(data[col].toString());
        } else {
          cell.value = IntCellValue(int.tryParse(data[col].toString()) ?? 0);
        }
      }
    }

    progressSheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Urutan');
    progressSheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('Tanggal');
    progressSheet.cell(CellIndex.indexByString('C1')).value = TextCellValue('Mapel');
    progressSheet.cell(CellIndex.indexByString('D1')).value = TextCellValue('Tryout');
    progressSheet.cell(CellIndex.indexByString('E1')).value = TextCellValue('Nilai');

    for (var i = 0; i < history.length; i++) {
      final item = history[i];
      final row = i + 2;
      final date = DateTime.tryParse(item.completedAt)?.toLocal() ?? DateTime.now();
      progressSheet.cell(CellIndex.indexByString('A$row')).value = IntCellValue(i + 1);
      progressSheet.cell(CellIndex.indexByString('B$row')).value = TextCellValue(_formatDate(date));
      progressSheet.cell(CellIndex.indexByString('C$row')).value = TextCellValue(_subjectLabel(item.subjectId));
      progressSheet.cell(CellIndex.indexByString('D$row')).value = TextCellValue(item.packageName);
      progressSheet.cell(CellIndex.indexByString('E$row')).value = IntCellValue(item.score);
    }

    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'TKA_Study_Hasil_$safeUsername.xlsx';
    final path = '${directory.path}/$fileName';
    final bytes = workbook.save();
    final file = File(path);
    await file.writeAsBytes(bytes!);

    return (
      filePath: path,
      fileName: fileName,
      sizeBytes: file.lengthSync()
    );
  }

  static Future<ShareResult> shareExport(String filePath) async {
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [XFile(filePath)],
        text: 'Laporan hasil belajar TKA Study',
      ),
    );

    if (result.status == ShareResultStatus.dismissed) {
      throw StateError('Share dibatalkan pengguna.');
    }

    if (result.status == ShareResultStatus.unavailable) {
      throw StateError('Fitur bagikan file tidak tersedia pada perangkat ini.');
    }

    return result;
  }

  static String _sanitizeFileName(String input) {
    final sanitized = input
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
    return sanitized.isEmpty ? 'User' : sanitized;
  }

  static String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  static String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  static String _subjectLabel(String subjectId) {
    switch (subjectId) {
      case 'english':
        return 'Bahasa Inggris';
      case 'mathematics':
        return 'Matematika';
      case 'indonesian':
        return 'Bahasa Indonesia';
      case 'entrepreneurship':
        return 'Kewirausahaan';
      default:
        return subjectId;
    }
  }

  static int _averageScore(List<ExamResult> items) {
    if (items.isEmpty) return 0;
    final total = items.fold<int>(0, (sum, item) => sum + item.score);
    return (total / items.length).round();
  }

  static int _average(List<int> values) {
    if (values.isEmpty) return 0;
    return (values.reduce((a, b) => a + b) / values.length).round();
  }
}

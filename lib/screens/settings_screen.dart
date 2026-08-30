import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/excel_export_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import 'setup_profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final username = auth.username;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryLightColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      username.isNotEmpty ? username[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        StorageService.getProfile()?['email']?.toString() ?? 'Email belum diatur',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppConstants.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'DATA',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppConstants.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download_rounded, color: AppConstants.primaryColor),
                  title: const Text('Download Hasil ke Excel'),
                  subtitle: const Text('Ekspor seluruh history tryout lokal', style: TextStyle(fontSize: 12)),
                  onTap: () => _exportExcel(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: AppConstants.dangerColor),
                  title: const Text('Reset Semua Data', style: TextStyle(color: AppConstants.dangerColor, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Semua profile, progress, history, dan statistik akan dihapus.', style: TextStyle(fontSize: 12)),
                  onTap: () => _confirmReset(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'TENTANG APLIKASI',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppConstants.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusLg),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildInfoRow('Versi Aplikasi', '1.0.0'),
                const Divider(height: 20, color: Color(0xFFF1F5F9)),
                _buildInfoRow('Storage', 'Local Device Only'),
                const Divider(height: 20, color: Color(0xFFF1F5F9)),
                _buildInfoRow('Target OS', 'Android'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppConstants.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppConstants.textPrimary)),
      ],
    );
  }

  Future<void> _exportExcel(BuildContext context) async {
    try {
      final result = await ExcelExportService.exportTryoutResults();
      if (result == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Belum ada hasil tryout yang dapat diekspor.')));
        }
        return;
      }
      await ExcelExportService.shareExport(result.filePath);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Berhasil membuat laporan hasil belajar.\n${result.fileName} (${result.sizeBytes} bytes)')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengekspor data. Coba lagi nanti.')),
        );
      }
    }
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Semua Data?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Semua profile, progress, history, dan statistik akan dihapus.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await StorageService.resetAll();
              try {
                await context.read<AuthProvider>().logout();
              } catch (_) {}
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const SetupProfileScreen()),
                (route) => false,
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

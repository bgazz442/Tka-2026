import 'package:flutter/material.dart';

import '../services/biometric_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import 'home_screen.dart';

class BiometricSetupScreen extends StatelessWidget {
  const BiometricSetupScreen({super.key});

  Future<void> _enableBiometric(BuildContext context) async {
    final profile = StorageService.getProfile();
    final profileId = profile?['profileId']?.toString() ?? '';
    if (profileId.isEmpty) {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
      return;
    }

    final available = await BiometricService.isBiometricAvailable();
    if (!available) {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
      return;
    }

    final authenticated = await BiometricService.authenticate();
    if (!authenticated) {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
      return;
    }

    await BiometricService.enableForUid(profileId);
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  void _skipBiometric(BuildContext context) {
    StorageService.setBiometricEnabled(false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.fingerprint_rounded,
                  size: 76,
                  color: AppConstants.primaryColor,
                ),
                const SizedBox(height: 22),
                const Text(
                  'Gunakan keamanan perangkat untuk membuka aplikasi?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppConstants.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Fingerprint, face unlock, atau biometric yang didukung perangkatmu akan digunakan hanya untuk mengunci aplikasi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppConstants.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _enableBiometric(context),
                    icon: const Icon(Icons.lock_rounded),
                    label: const Text('Aktifkan Biometric'),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => _skipBiometric(context),
                    child: const Text('Lewati'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

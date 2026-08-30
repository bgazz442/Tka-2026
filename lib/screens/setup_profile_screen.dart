import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../services/storage_service.dart';
import '../utils/constants.dart';
import 'biometric_setup_screen.dart';

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final now = DateTime.now();
    final username = _nameController.text.trim();
    final email = _emailController.text.trim();
    final profileId = const Uuid().v4();

    await StorageService.saveProfile({
      'profileId': profileId,
      'username': username,
      'email': email,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    });

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const BiometricSetupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 18),
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppConstants.primaryLightColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 42,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Setup Profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppConstants.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Siapkan profil lokalmu untuk mulai belajar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppConstants.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nama / Username',
                      hintText: 'Contoh: Bagas',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) return 'Nama wajib diisi.';
                      if (text.length < 2) return 'Minimal 2 karakter.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'bagas@email.com',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) return 'Email wajib diisi.';
                      if (!text.contains('@')) return 'Format email tidak valid.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Mulai Belajar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

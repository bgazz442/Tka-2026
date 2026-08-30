import 'dart:async';
import 'package:flutter/material.dart';

import '../services/biometric_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import 'biometric_setup_screen.dart';
import 'home_screen.dart';
import 'setup_profile_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  Timer? _routeTimer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _animController.forward();
    _routeTimer = Timer(const Duration(milliseconds: 1600), _checkInitialRoute);
  }

  Future<void> _checkInitialRoute() async {
    if (!mounted) return;

    final hasProfile = StorageService.hasProfile();
    if (!mounted) return;

    if (!hasProfile) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SetupProfileScreen()),
      );
      return;
    }

    final biometricEnabled = StorageService.isBiometricEnabled();
    if (biometricEnabled) {
      final biometricAvailable = await BiometricService.isBiometricAvailable();
      if (biometricAvailable && mounted) {
        final authenticated = await BiometricService.authenticate();
        if (!mounted) return;
        if (authenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
          return;
        }
      }
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  void dispose() {
    _routeTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Center(
                        child: Text(
                          'TKA',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppConstants.primaryColor,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    AppConstants.appTagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                const CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

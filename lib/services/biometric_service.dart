import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import 'storage_service.dart';

class BiometricService {
  static const _secureStorage = FlutterSecureStorage();
  static const _biometricEnabledKey = 'biometric_enabled_uid';

  static final LocalAuthentication _localAuth = LocalAuthentication();

  static Future<bool> isBiometricAvailable() async {
    if (kIsWeb) return false;
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (e) {
      debugPrint('Biometric availability check failed: $e');
      return false;
    }
  }

  static Future<bool> authenticate() async {
    try {
      final available = await isBiometricAvailable();
      if (!available) return false;

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Lanjutkan dengan keamanan perangkat',
        biometricOnly: false,
        sensitiveTransaction: true,
        persistAcrossBackgrounding: false,
      );

      return authenticated;
    } catch (e) {
      debugPrint('Biometric authentication failed: $e');
      return false;
    }
  }

  static Future<void> enableForUid(String uid) async {
    await _secureStorage.write(key: _biometricEnabledKey, value: uid);
    await StorageService.setBiometricEnabled(true);
  }

  static Future<String?> getEnabledUid() async {
    final secureUid = await _secureStorage.read(key: _biometricEnabledKey);
    return secureUid ?? StorageService.getSessionUid();
  }

  static Future<void> disable() async {
    await _secureStorage.delete(key: _biometricEnabledKey);
    await StorageService.setBiometricEnabled(false);
  }
}

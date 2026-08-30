import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import 'biometric_service.dart';
import 'storage_service.dart';

class LocalUser {
  final String uid;
  final String username;
  final String name;

  const LocalUser({
    required this.uid,
    required this.username,
    required this.name,
  });
}

class AuthService {
  LocalUser? _currentUser;

  LocalUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<LocalUser?> restoreSession() async {
    final uid = StorageService.getSessionUid();
    if (uid == null) return null;
    final account = StorageService.getAccountByUid(uid);
    if (account == null) {
      await StorageService.clearSession();
      return null;
    }
    _currentUser = _userFromAccount(account);
    await StorageService.setUsername(_currentUser!.username);
    return _currentUser;
  }

  Future<String?> register({
    required String username,
    required String password,
  }) async {
    final normalized = username.trim().toLowerCase();
    if (!RegExp(r'^[a-zA-Z0-9_]{3,}$').hasMatch(normalized)) {
      return 'Username minimal 3 karakter dan hanya boleh huruf, angka, atau underscore.';
    }
    if (password.length < 6) return 'Password minimal 6 karakter.';
    if (StorageService.getAccountByUsername(normalized) != null) {
      return 'Username sudah digunakan di perangkat ini.';
    }

    final user = LocalUser(
      uid: _createLocalUid(),
      username: normalized,
      name: username.trim(),
    );
    final accounts = StorageService.getAccounts()
      ..add({
        'uid': user.uid,
        'username': user.username,
        'name': user.name,
        'passwordSalt': _createSalt(),
        'createdAt': DateTime.now().toIso8601String(),
      });
    accounts.last['passwordHash'] = _hashPassword(
      password,
      accounts.last['passwordSalt'] as String,
    );
    await StorageService.saveAccounts(accounts);
    await _activate(user);
    return null;
  }

  Future<String?> login({
    required String username,
    required String password,
  }) async {
    final account = StorageService.getAccountByUsername(username);
    final salt = account?['passwordSalt'] as String?;
    if (account == null ||
        salt == null ||
        account['passwordHash'] != _hashPassword(password, salt)) {
      return 'Username atau password salah.';
    }
    await _activate(_userFromAccount(account));
    return null;
  }

  Future<bool> loginWithBiometric() async {
    final uid = await BiometricService.getEnabledUid();
    if (uid == null || uid.isEmpty) return false;
    final account = StorageService.getAccountByUid(uid);
    if (account == null || !await BiometricService.authenticate()) return false;
    await _activate(_userFromAccount(account));
    return true;
  }

  Future<void> logout() async {
    final uid = _currentUser?.uid;
    _currentUser = null;
    await StorageService.clearSession();
    if (uid != null) await BiometricService.disable();
  }

  Future<void> _activate(LocalUser user) async {
    _currentUser = user;
    await StorageService.setSessionUid(user.uid);
    await StorageService.setUsername(user.username);
  }

  LocalUser _userFromAccount(Map<String, dynamic> account) => LocalUser(
        uid: account['uid'] as String,
        username: account['username'] as String,
        name: account['name'] as String? ?? account['username'] as String,
      );

  static String _hashPassword(String password, String salt) => sha256
      .convert(utf8.encode('tka-local-v2:$salt:$password'))
      .toString();

  static String _createSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  static String _createLocalUid() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }
}
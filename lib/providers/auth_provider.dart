import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  LocalUser? _currentUser;
  UserProfile? _userProfile;
  bool _isLoading = false;
  bool _initialized = false;
  String? _errorMessage;
  Future<void>? _initialization;

  Future<void> initialize() => _initialization ??= _restoreSession();

  Future<void> _restoreSession() async {
    _currentUser = await _authService.restoreSession();
    _userProfile = _currentUser == null ? null : _profileFromUser(_currentUser!);
    _initialized = true;
    notifyListeners();
  }

  LocalUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isInitialized => _initialized;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  String get uid => _currentUser?.uid ?? '';
  String get username => _currentUser?.username ?? 'Siswa';
  UserProfile? get userProfile => _userProfile;

  Future<bool> register({
    required String username,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    final error = await _authService.register(
      username: username,
      password: password,
    );
    return _finishAuth(error);
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    final error = await _authService.login(
      username: username,
      password: password,
    );
    return _finishAuth(error);
  }

  Future<bool> loginWithBiometric() async {
    _setLoading(true);
    _clearError();
    final success = await _authService.loginWithBiometric();
    if (success) {
      _currentUser = _authService.currentUser;
      _userProfile = _profileFromUser(_currentUser!);
    } else {
      _setError('Biometric belum diaktifkan atau autentikasi gagal.');
    }
    _setLoading(false);
    return success;
  }

  Future<bool> enableBiometric() async {
    if (_currentUser == null) return false;
    if (!await BiometricService.isBiometricAvailable()) return false;
    if (!await BiometricService.authenticate()) return false;
    await BiometricService.enableForUid(_currentUser!.uid);
    return true;
  }

  Future<void> logout() async {
    _setLoading(true);
    await _authService.logout();
    _currentUser = null;
    _userProfile = null;
    _setLoading(false);
  }

  Future<void> reloadProfile() async {
    if (_currentUser != null) {
      _userProfile = _profileFromUser(_currentUser!);
      notifyListeners();
    }
  }

  void setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  bool _finishAuth(String? error) {
    if (error != null) {
      _setError(error);
      _setLoading(false);
      return false;
    }
    _currentUser = _authService.currentUser;
    _userProfile = _profileFromUser(_currentUser!);
    _setLoading(false);
    return true;
  }

  UserProfile _profileFromUser(LocalUser user) {
    final now = DateTime.now();
    return UserProfile(
      uid: user.uid,
      username: user.username,
      name: user.name,
      email: '',
      createdAt: now,
      updatedAt: now,
    );
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() => _errorMessage = null;
}
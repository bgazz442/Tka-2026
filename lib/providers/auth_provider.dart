import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _firebaseUser;
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  User? get firebaseUser => _firebaseUser;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _firebaseUser != null;
  String get uid => _firebaseUser?.uid ?? '';

  String get username {
    if (_userProfile != null) {
      final name = (_userProfile!.name).trim();
      if (name.isNotEmpty) return name;
      final username = (_userProfile!.username).trim();
      if (username.isNotEmpty) return username;
    }
    final email = _firebaseUser?.email ?? '';
    if (email.isNotEmpty) return email.split('@').first;
    return 'Siswa';
  }

  void _onAuthStateChanged(User? user) async {
    _firebaseUser = user;
    if (user != null) {
      await _loadProfile(user.uid);
    } else {
      _userProfile = null;
    }
    notifyListeners();
  }

  Future<void> _loadProfile(String uid) async {
    final profile = await _firestoreService.getUserProfile(uid);
    if (profile != null) {
      _userProfile = profile;
      return;
    }

    final fallbackName = _firebaseUser?.displayName?.trim().isNotEmpty == true
        ? _firebaseUser!.displayName!
        : (_firebaseUser?.email ?? '').split('@').first;

    final fallbackEmail = _firebaseUser?.email ?? '';
    _userProfile = await _firestoreService.ensureUserProfile(
      uid: uid,
      name: fallbackName,
      email: fallbackEmail,
    );
  }

  Future<bool> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    final error = await _authService.registerWithEmail(
      name: name,
      email: email,
      password: password,
    );

    if (error != null) {
      _setError(error);
      _setLoading(false);
      return false;
    }

    _setLoading(false);
    return true;
  }

  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    final error = await _authService.loginWithEmail(
      email: email,
      password: password,
    );

    if (error != null) {
      _setError(error);
      _setLoading(false);
      return false;
    }

    _setLoading(false);
    return true;
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    final error = await _authService.signInWithGoogle();
    if (error != null) {
      _setError(error);
      _setLoading(false);
      return false;
    }

    if (!kIsWeb) {
      final uid = _authService.currentUser?.uid;
      if (uid != null && uid.isNotEmpty) {
        await BiometricService.enableForUid(uid);
      }
    }

    _setLoading(false);
    return true;
  }

  Future<bool> registerWithGoogle() async {
    return signInWithGoogle();
  }

  Future<bool> loginWithBiometric() async {
    _setLoading(true);
    _clearError();

    final storedUid = await BiometricService.getEnabledUid();
    if (storedUid == null || storedUid.isEmpty) {
      _setError('Biometric belum diaktifkan untuk akun ini.');
      _setLoading(false);
      return false;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.uid == storedUid) {
      _setLoading(false);
      return true;
    }

    final authenticated = await BiometricService.authenticate();
    if (!authenticated) {
      _setError('Autentikasi biometrik gagal.');
      _setLoading(false);
      return false;
    }

    final activeUser = FirebaseAuth.instance.currentUser;
    if (activeUser != null && activeUser.uid == storedUid) {
      _setLoading(false);
      return true;
    }

    _setError('Biometric tidak valid untuk akun saat ini.');
    _setLoading(false);
    return false;
  }

  Future<bool> register({
    required String username,
    required String password,
  }) async {
    final email = username.trim();
    return registerWithEmail(
      name: email.contains('@') ? email.split('@').first : email,
      email: email,
      password: password,
    );
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    return loginWithEmail(
      email: username,
      password: password,
    );
  }

  Future<void> logout() async {
    _setLoading(true);
    await _authService.logout();
    _firebaseUser = null;
    _userProfile = null;
    _setLoading(false);
  }

  Future<void> reloadProfile() async {
    if (_firebaseUser == null) return;
    await _loadProfile(_firebaseUser!.uid);
    notifyListeners();
  }

  Future<String?> resetPassword(String email) async {
    return _authService.resetPassword(email);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

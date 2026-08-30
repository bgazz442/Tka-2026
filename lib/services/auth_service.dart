import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'biometric_service.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  bool get isLoggedIn => _auth.currentUser != null;

  static String normalizeEmail(String email) => email.trim();

  Future<String?> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanedName = name.trim();
    final cleanedEmail = normalizeEmail(email);

    if (cleanedName.isEmpty) return 'Nama wajib diisi.';
    if (cleanedEmail.isEmpty || !cleanedEmail.contains('@')) {
      return 'Format email tidak valid.';
    }
    if (password.isEmpty) return 'Password wajib diisi.';
    if (password.length < 6) return 'Password minimal 6 karakter.';

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: cleanedEmail,
        password: password,
      );

      final uid = credential.user!.uid;
      await _firestore.ensureUserProfile(
        uid: uid,
        name: cleanedName,
        email: cleanedEmail,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _parseAuthError(e);
    } catch (e) {
      debugPrint('Register email failed: $e');
      return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  Future<String?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final cleanedEmail = normalizeEmail(email);

    if (cleanedEmail.isEmpty || !cleanedEmail.contains('@')) {
      return 'Format email tidak valid.';
    }
    if (password.isEmpty) return 'Password wajib diisi.';

    try {
      await _auth.signInWithEmailAndPassword(
        email: cleanedEmail,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _parseAuthError(e);
    } catch (e) {
      debugPrint('Login email failed: $e');
      return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        final userCredential = await _auth.signInWithPopup(provider);
        final user = userCredential.user;
        if (user == null) {
          return 'Login Google gagal.';
        }

        await _firestore.ensureUserProfile(
          uid: user.uid,
          name: user.displayName ?? user.email?.split('@').first ?? 'User',
          email: user.email ?? '',
        );
        return null;
      }

      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return 'Google Sign-In dibatalkan.';
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        return 'Login Google gagal.';
      }

      await _firestore.ensureUserProfile(
        uid: user.uid,
        name: user.displayName ?? user.email?.split('@').first ?? 'User',
        email: user.email ?? '',
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _parseAuthError(e);
    } catch (e) {
      debugPrint('Google sign in failed: $e');
      return 'Google Sign-In gagal. Coba lagi.';
    }
  }

  Future<String?> registerWithGoogle() async {
    return signInWithGoogle();
  }

  Future<String?> resetPassword(String email) async {
    final cleanedEmail = normalizeEmail(email);
    if (cleanedEmail.isEmpty || !cleanedEmail.contains('@')) {
      return 'Format email tidak valid.';
    }

    try {
      await _auth.sendPasswordResetEmail(email: cleanedEmail);
      return null;
    } on FirebaseAuthException catch (e) {
      return _parseAuthError(e);
    } catch (e) {
      debugPrint('Reset password failed: $e');
      return 'Gagal mengirim reset password.';
    }
  }

  Future<void> logout() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    final enabledUid = await BiometricService.getEnabledUid();
    if (enabledUid == _auth.currentUser?.uid) {
      await BiometricService.disable();
    }
    await _auth.signOut();
  }

  static String _parseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah.';
      case 'email-already-in-use':
        return 'Email tersebut sudah terdaftar. Silakan login.';
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet.';
      case 'operation-not-allowed':
        return 'Metode login belum diaktifkan di Firebase.';
      default:
        return 'Terjadi kesalahan autentikasi. Silakan coba lagi.';
    }
  }
}

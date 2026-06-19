import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthResult {
  final bool success;
  final String message;
  AuthResult({required this.success, required this.message});
}

class AuthService {
  static const _base = 'http://91.108.113.135';
  static const _timeout = Duration(seconds: 20);

  final _fb = FirebaseAuth.instance;

  // ─── SIGNUP ──────────────────────────────────────────────────────────────────
  Future<AuthResult> signup({
    required String email,
    required String password,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/api/auth/signup'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(_timeout);

      final json = _decode(res);
      final ok = json['success'] == true;

      // Mirror the account in Firebase so password operations work later.
      if (ok) {
        try {
          await _fb.createUserWithEmailAndPassword(
              email: email, password: password);
        } catch (_) {
          // Firebase account may already exist; that's fine.
        }
      }

      return AuthResult(
        success: ok,
        message: json['message']?.toString() ??
            (res.statusCode == 201
                ? 'Registration successful'
                : 'Something went wrong (${res.statusCode})'),
      );
    } catch (_) {
      return AuthResult(
          success: false,
          message: 'Network error. Check your internet connection');
    }
  }

  // ─── VERIFY EMAIL ─────────────────────────────────────────────────────────
  Future<AuthResult> verifyEmail(String token) async {
    try {
      final res = await http
          .get(Uri.parse('$_base/api/auth/verify/$token'))
          .timeout(_timeout);
      final json = _decode(res);
      return AuthResult(
        success: json['success'] == true || res.statusCode == 200,
        message: json['message']?.toString() ??
            (res.statusCode == 200 ? 'Verified' : 'Verification failed'),
      );
    } catch (_) {
      return AuthResult(
          success: false,
          message: 'Network error. Check your internet connection');
    }
  }

  // ─── LOGIN ────────────────────────────────────────────────────────────────
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/api/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(_timeout);

      final json = _decode(res);

      // Save backend token early (present even in some verify-required responses).
      final token = _extractToken(json);
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token);
        await prefs.setString('userEmail', email);
      }

      if (json['success'] != true) {
        return AuthResult(
          success: false,
          message: json['message']?.toString() ?? 'Login failed',
        );
      }

      if (token == null) {
        return AuthResult(
            success: false,
            message: 'Unexpected server response, please try again');
      }

      // Mirror into Firebase so password-management methods work.
      await _signIntoFirebase(email, password);

      return AuthResult(
        success: true,
        message: json['message']?.toString() ?? 'Logged in',
      );
    } catch (_) {
      return AuthResult(
          success: false,
          message: 'Network error. Check your internet connection');
    }
  }

  // ─── CHANGE PASSWORD (Firebase) ──────────────────────────────────────────
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
    String? email,
  }) async {
    try {
      final resolvedEmail = email ?? await getEmail();
      if (resolvedEmail == null) {
        return AuthResult(
            success: false, message: 'Could not find account email.');
      }

      // Sign into Firebase with current credentials (creates account if needed).
      await _signIntoFirebase(resolvedEmail, currentPassword);
      User? user = _fb.currentUser;

      if (user == null) {
        return AuthResult(
            success: false,
            message: 'Authentication failed. Check your current password.');
      }

      // Re-authenticate before the sensitive updatePassword call.
      final cred = EmailAuthProvider.credential(
          email: resolvedEmail, password: currentPassword);
      await user.reauthenticateWithCredential(cred);

      await user.updatePassword(newPassword);

      return AuthResult(success: true, message: 'Password changed successfully');
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _fbError(e));
    } catch (_) {
      return AuthResult(
          success: false,
          message: 'Network error. Check your internet connection');
    }
  }

  // ─── FORGOT PASSWORD ─────────────────────────────────────────────────────
  // Tries the backend first (direct reset with email+newPassword).
  // Falls back to Firebase email link if backend has no such endpoint.
  Future<AuthResult> forgotPassword({
    required String email,
    required String newPassword,
  }) async {
    // ── 1. Try backend ──────────────────────────────────────────────────────
    for (final path in [
      '/api/auth/forgot-password',
      '/api/auth/reset-password',
    ]) {
      try {
        final res = await http
            .post(
              Uri.parse('$_base$path'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'email': email, 'newPassword': newPassword}),
            )
            .timeout(_timeout);

        final json = _decode(res);
        if (json['success'] == true || res.statusCode == 200) {
          return AuthResult(
              success: true, message: 'Password changed successfully!');
        }
        // 4xx from this endpoint → try the next one
      } catch (_) {
        // timeout / network → fall through to Firebase
      }
    }

    // ── 2. Fallback: Firebase reset email ───────────────────────────────────
    try {
      await _fb.sendPasswordResetEmail(email: email);
      return AuthResult(
        success: true,
        // Signal the UI that we fell back to email mode
        message: '__EMAIL_SENT__',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _fbError(e));
    } catch (_) {
      return AuthResult(
          success: false,
          message: 'Network error. Check your internet connection');
    }
  }

  // ─── LOGOUT ───────────────────────────────────────────────────────────────
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('userEmail');
    try {
      await _fb.signOut();
    } catch (_) {}
  }

  // ─── SEND PASSWORD RESET EMAIL ────────────────────────────────────────────
  Future<void> sendPasswordReset(String email) async {
    try {
      await _fb.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_fbError(e));
    } catch (_) {
      throw Exception('Network error. Check your internet connection');
    }
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────
  Future<void> _signIntoFirebase(String email, String password) async {
    try {
      await _fb.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // Account doesn't exist in Firebase yet — create it silently.
        try {
          await _fb.createUserWithEmailAndPassword(
              email: email, password: password);
        } catch (_) {}
      }
      // Other errors (wrong-password etc.) are non-fatal here; the backend
      // is still the primary auth source for the app's login flow.
    }
  }

  String _fbError(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Current password is incorrect.';
      case 'user-not-found':
        return 'No account found for this email.';
      case 'weak-password':
        return 'New password is too weak (min 6 characters).';
      case 'requires-recent-login':
        return 'Please log out and log in again, then retry.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }

  String? _extractToken(Map<String, dynamic> json) {
    for (final key in ['token', 'access_token', 'accessToken', 'jwt']) {
      final v = json[key];
      if (v is String && v.isNotEmpty) return v;
    }
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      final nested = _extractToken(data);
      if (nested != null) return nested;
    }
    final user = json['user'];
    if (user is Map<String, dynamic>) {
      for (final key in ['token', 'access_token', 'accessToken']) {
        final v = user[key];
        if (v is String && v.isNotEmpty) return v;
      }
    }
    return null;
  }

  Map<String, dynamic> _decode(http.Response res) {
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return {};
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail') ?? prefs.getString('localEmail');
  }
}

import 'dart:convert';
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
      return AuthResult(
        success: json['success'] == true,
        message: json['message']?.toString() ??
            (res.statusCode == 201
                ? 'Registration successful'
                : 'Something went wrong (${res.statusCode})'),
      );
    } catch (_) {
      return AuthResult(
        success: false,
        message: 'Network error. Check your internet connection',
      );
    }
  }

  Future<AuthResult> verifyEmail(String token) async {
    try {
      final res =
          await http.get(Uri.parse('$_base/api/auth/verify/$token')).timeout(_timeout);
      final json = _decode(res);
      return AuthResult(
        success: json['success'] == true || res.statusCode == 200,
        message: json['message']?.toString() ??
            (res.statusCode == 200 ? 'Verified' : 'Verification failed'),
      );
    } catch (_) {
      return AuthResult(
        success: false,
        message: 'Network error. Check your internet connection',
      );
    }
  }

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

      // Always try to extract and save the token first — some backends include
      // a token even when returning a "please verify" failure response.
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
          message: 'Unexpected server response, please try again',
        );
      }

      return AuthResult(
        success: true,
        message: json['message']?.toString() ?? 'Logged in',
      );
    } catch (_) {
      return AuthResult(
        success: false,
        message: 'Network error. Check your internet connection',
      );
    }
  }

  // The backend doesn't document the exact token field name (the official
  // Postman collection itself checks both `token` and `access_token`), so
  // we defensively try every plausible shape.
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
    return prefs.getString('userEmail');
  }

  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      String? token = await getToken();
      final email = await getEmail();

      // If token is missing (e.g. user bypassed email verification during login),
      // re-authenticate silently using the current password to get a fresh token.
      if (token == null && email != null) {
        final reAuth = await login(email: email, password: currentPassword);
        if (reAuth.success) {
          token = await getToken();
        }
      }

      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final body = <String, dynamic>{
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      };
      if (email != null) body['email'] = email;

      final res = await http
          .post(
            Uri.parse('$_base/api/auth/change-password'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      final json = _decode(res);
      final ok = json['success'] == true || res.statusCode == 200;
      return AuthResult(
        success: ok,
        message: json['message']?.toString() ??
            (ok ? 'Password changed successfully' : 'Failed to change password (${res.statusCode})'),
      );
    } catch (_) {
      return AuthResult(
        success: false,
        message: 'Network error. Check your internet connection',
      );
    }
  }

  Future<AuthResult> forgotPassword({required String email}) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/api/auth/forgot-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(_timeout);

      final json = _decode(res);
      final ok = json['success'] == true || res.statusCode == 200;
      return AuthResult(
        success: ok,
        message: json['message']?.toString() ??
            (ok
                ? 'Reset link sent — check your email'
                : 'Request failed (${res.statusCode})'),
      );
    } catch (_) {
      return AuthResult(
        success: false,
        message: 'Network error. Check your internet connection',
      );
    }
  }

  Future<AuthResult> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/api/auth/reset-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'newPassword': newPassword}),
          )
          .timeout(_timeout);

      final json = _decode(res);
      final ok = json['success'] == true || res.statusCode == 200;
      return AuthResult(
        success: ok,
        message: json['message']?.toString() ??
            (ok ? 'Password reset successfully' : 'Reset failed (${res.statusCode})'),
      );
    } catch (_) {
      return AuthResult(
        success: false,
        message: 'Network error. Check your internet connection',
      );
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('userEmail');
  }
}

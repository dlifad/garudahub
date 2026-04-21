import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:garudahub/core/models/user_model.dart';
import 'package:garudahub/core/constants/constants.dart';
import 'package:garudahub/core/services/biometric_service.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  // Register
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );
      final data = jsonDecode(res.body);
      return {'success': res.statusCode == 201, 'data': data};
    } catch (e) {
      return {'success': false, 'data': {'message': AppStrings.networkError}};
    }
  }

  // Verify Email
  static Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/verify-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}),
      );
      final data = jsonDecode(res.body);
      return {'success': res.statusCode == 200, 'data': data};
    } catch (e) {
      return {'success': false, 'data': {'message': AppStrings.networkError}};
    }
  }

  // Resend Code
  static Future<Map<String, dynamic>> resendCode({required String email}) async {
    try {
      final res = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/resend-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      final data = jsonDecode(res.body);
      return {'success': res.statusCode == 200, 'data': data};
    } catch (e) {
      return {'success': false, 'data': {'message': AppStrings.networkError}};
    }
  }

  // Login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['token'] != null) {
        final token = data['token'];

        await _storage.write(key: AppConstants.tokenKey, value: token);

        final isBioEnabled = await BiometricService.isEnabled();

        if (isBioEnabled) {
          await BiometricService.saveToken(token);
        }

        if (data['user'] != null) {
          await _storage.write(
            key: AppConstants.userKey,
            value: jsonEncode(data['user']),
          );
        }
        return {'success': true, 'data': data};
      }
      return {'success': false, 'data': data};
    } catch (e) {
      return {'success': false, 'data': {'message': AppStrings.networkError}};
    }
  }

  // Get Me
  static Future<UserModel?> getMe() async {
    try {
      final token = await _storage.read(key: AppConstants.tokenKey);
      if (token == null) return null;
      final res = await http.get(
        Uri.parse('${AppConstants.baseUrl}/auth/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return UserModel.fromJson(data['user'] ?? data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // Logout
  static Future<void> logout() async {
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.userKey);
  }

  // Check Session
  static Future<bool> hasValidToken() async {
    final token = await _storage.read(key: AppConstants.tokenKey);
    return token != null && token.isNotEmpty;
  }

  // Get Cached User
  static Future<UserModel?> getCachedUser() async {
    final raw = await _storage.read(key: AppConstants.userKey);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.tokenKey);
  }

  // change pass
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await getToken();

      final res = await http.put(
        Uri.parse('${AppConstants.baseUrl}/auth/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        await BiometricService.clearToken();
        await _storage.delete(key: AppConstants.tokenKey);
        await _storage.delete(key: AppConstants.userKey);

        return {
          'success': true,
          'message': data['message'] ?? 'Password berhasil diubah',
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal mengubah password',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan jaringan',
      };
    }
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final res = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim()}),
      );

      final data = jsonDecode(res.body);

      return {
        'success': res.statusCode == 200,
        'message': data['message'] ?? 'Terjadi kesalahan',
      };
    } catch (_) {
      return {
        'success': false,
        'message': AppStrings.networkError,
      };
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code.trim(),
          'new_password': newPassword,
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        await BiometricService.clearToken();

        return {
          'success': true,
          'message': data['message'] ?? 'Password berhasil direset',
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal reset password',
      };
    } catch (_) {
      return {
        'success': false,
        'message': AppStrings.networkError,
      };
    }
  }
}
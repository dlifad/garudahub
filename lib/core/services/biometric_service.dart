import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:garudahub/core/constants/constants.dart';

enum BiometricLoginResult {
  success,
  failedAuth,
  noToken,
}

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static const _storage = FlutterSecureStorage();

  static const _bioKey = 'biometric_enabled';
  static const _bioTokenKey = 'biometric_token';

  static Future<bool> canCheck() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final supported = await _auth.isDeviceSupported();
      return canCheck && supported;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> authenticate() async {
    try {
      final result = await _auth.authenticate(
        localizedReason: 'Gunakan biometrik untuk masuk',
        options: const AuthenticationOptions(
          biometricOnly: true,
        ),
      );
      return result;
    } catch (_) {
      return false;
    }
  }

  static Future<void> setEnabled(bool value) async {
    await _storage.write(key: _bioKey, value: value.toString());
  }

  static Future<bool> isEnabled() async {
    final val = await _storage.read(key: _bioKey);
    return val == 'true';
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _bioTokenKey, value: token);
  }

  static Future<BiometricLoginResult> loginWithBiometric() async {
    final isAuth = await authenticate();
    if (!isAuth) return BiometricLoginResult.failedAuth;

    final token = await _storage.read(key: _bioTokenKey);
    if (token == null) return BiometricLoginResult.noToken;

    await _storage.write(key: AppConstants.tokenKey, value: token);
    return BiometricLoginResult.success;
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: _bioTokenKey);
  }
}
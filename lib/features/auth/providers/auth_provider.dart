import 'package:flutter/foundation.dart';
import 'package:garudahub/features/auth/services/auth_service.dart';

import 'package:garudahub/core/models/user_model.dart';
import 'package:garudahub/core/services/biometric_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  bool _isBiometricEnabled = false;
  bool get isBiometricEnabled => _isBiometricEnabled;

  Future<void> checkAuth() async {
    _isBiometricEnabled = await BiometricService.isEnabled();
    _isLoading = true;
    notifyListeners();

    final hasToken = await AuthService.hasValidToken();

    if (hasToken) {
      _user = await AuthService.getCachedUser();
      _isAuthenticated = true;

      AuthService.getMe().then((freshUser) {
        if (freshUser != null) {
          _user = freshUser;
          notifyListeners();
        }
      });
    } else {
      _isAuthenticated = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  AuthProvider() {
    _loadBiometric();
  }

  Future<void> _loadBiometric() async {
    _isBiometricEnabled = await BiometricService.isEnabled();
    notifyListeners();
  }

  void setUser(UserModel user) {
    _user = user;
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> setBiometricEnabled(bool value) async {
    await BiometricService.setEnabled(value);
    _isBiometricEnabled = value;
    notifyListeners();
  }

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
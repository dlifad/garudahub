import 'package:flutter/material.dart';
import 'dart:io';

import 'package:garudahub/features/auth/providers/auth_provider.dart';

import 'package:garudahub/features/profile/services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProfile(AuthProvider auth) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await ProfileService.getProfile();
      auth.setUser(user);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(
    AuthProvider auth, {
    required String name,
    File? imageFile,
    bool removePhoto = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await ProfileService.updateProfile(
        name: name,
        imageFile: imageFile,
        removePhoto: removePhoto,
      );
      auth.setUser(user);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
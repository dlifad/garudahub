import 'package:flutter/material.dart';
import 'package:garudahub/features/shop/merchandise/models/merchandise_model.dart';
import 'package:garudahub/features/shop/merchandise/services/merchandise_service.dart';

class MerchandiseProvider extends ChangeNotifier {
  final MerchandiseService _service = MerchandiseService();

  List<MerchandiseModel> _items = [];
  bool _isLoading = false;

  List<MerchandiseModel> get items => _items;
  bool get isLoading => _isLoading;
  String? _error;
  String? get error => _error;

  Future<void> fetch() async {
    if (_isLoading || _items.isNotEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _service.getAll();
      _items = data;
    } catch (e) {
      _error = 'Gagal terhubung ke server';
    }

    _isLoading = false;
    notifyListeners();
  }

  
}
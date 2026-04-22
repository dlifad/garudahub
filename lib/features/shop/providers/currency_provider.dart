import 'package:flutter/material.dart';
import 'package:garudahub/features/shop/services/currency_service.dart';

class CurrencyProvider extends ChangeNotifier {
  String _selected = 'IDR';
  Map<String, double> _rates = {};
  bool _isLoading = false;

  String get selected => _selected;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _rates = await CurrencyService.getRates();
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  void setCurrency(String val) {
    _selected = val;
    notifyListeners();
  }

  double convert(double price) {
    if (_selected == 'IDR') return price;

    final rate = _rates[_selected];
    if (rate == null) return price;

    return price * rate;
  }

  void resetCurrency() {
    _selected = 'IDR';
    notifyListeners();
  }
}
import 'package:flutter/material.dart';
import 'package:garudahub/features/shop/ticket/services/ticket_service.dart';

class TicketProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetch() async {
    if (_isLoading || _items.isNotEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await TicketService.getTickets();
    } catch (e) {
      _error = 'Gagal terhubung ke server';
    }

    _isLoading = false;
    notifyListeners();
  }
}
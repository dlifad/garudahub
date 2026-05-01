import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

class TimezoneProvider extends ChangeNotifier {
  String _selected = 'local';

  String get selected => _selected;

  static const options = {
    'local': 'Waktu Lokal',

    // Indonesia
    'Asia/Jakarta': 'WIB',
    'Asia/Makassar': 'WITA',
    'Asia/Jayapura': 'WIT',

    // Luar negeri (pakai kota)
    'Asia/Kuala_Lumpur': 'Kuala Lumpur',
    'Asia/Singapore': 'Singapore',
    'Asia/Brunei': 'Bandar Seri Begawan',
    'Asia/Shanghai': 'Shanghai',
    'Asia/Hong_Kong': 'Hong Kong',
    'Asia/Taipei': 'Taipei',

    'Asia/Riyadh': 'Riyadh',
    'Asia/Dubai': 'Dubai',

    'Australia/Sydney': 'Sydney',
    'America/New_York': 'New York',
  };

  void setTimezone(String val) {
    _selected = val;
    notifyListeners();
  }

  DateTime convert(DateTime utc) {
    if (_selected == 'local') return utc.toLocal();

    final location = tz.getLocation(_selected);
    return tz.TZDateTime.from(utc, location);
  }

  /// Label yang ditampilkan di UI
  String get label {
    if (_selected == 'local') {
      return DateTime.now().timeZoneName;
    }

    return options[_selected] ?? _selected;
  }
}
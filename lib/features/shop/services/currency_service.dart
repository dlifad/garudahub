import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:garudahub/core/constants/constants.dart';

class CurrencyService {
  static Future<Map<String, double>> getRates() async {
    final res = await http.get(
      Uri.parse(
        'https://v6.exchangerate-api.com/v6/${AppConstants.exchangeApiKey}/latest/IDR',
      ),
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal ambil kurs');
    }

    final data = json.decode(res.body);

    final rates = Map<String, dynamic>.from(data['conversion_rates']);

    return rates.map((k, v) => MapEntry(k, v.toDouble()));
  }
}
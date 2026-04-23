import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:garudahub/core/constants/constants.dart';

class TicketService {
  static Future<List<dynamic>> getTickets() async {
    final response = await http.get(
      // Uri.parse('${AppConstants.baseUrl}/matches?has_ticket=true'),
      Uri.parse('${AppConstants.baseUrl}/matches?has_ticket=true&upcoming=true'),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data'];
    } else {
      throw Exception('Failed to load tickets');
    }
  }
}
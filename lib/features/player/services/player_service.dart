import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:garudahub/core/constants/constants.dart';
import '../models/player_model.dart';

class PlayerService {
  static const _base = AppConstants.baseUrl;

  Future<List<PlayerModel>> getActivePlayers({String? position}) async {
    try {
      final params = <String, String>{'is_active': 'true'};
      if (position != null) params['position'] = position;
      final res = await http.get(
        Uri.parse('$_base/players').replace(queryParameters: params),
      );
      if (res.statusCode != 200) return [];
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return (body['data'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(PlayerModel.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<SquadResponse?> getSquadByTournament(int tournamentId) async {
    try {
      final res = await http.get(
        Uri.parse('$_base/players/squad/$tournamentId'),
      );
      if (res.statusCode != 200) return null;
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (body['success'] != true) return null;
      return SquadResponse.fromJson(body);
    } catch (_) {
      return null;
    }
  }
}

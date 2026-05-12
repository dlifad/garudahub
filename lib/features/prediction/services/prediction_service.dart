import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:garudahub/core/constants/constants.dart';
import 'package:garudahub/features/auth/services/auth_service.dart';
import 'package:garudahub/features/prediction/models/prediction_history.dart';

class PredictionSubmitResult {
  final int statusCode;
  final String? message;

  const PredictionSubmitResult({required this.statusCode, this.message});
}

class PredictionService {
  Future<List<PredictionHistory>> getMyPredictions() async {
    final token = await AuthService.getToken();
    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/predictions/mine'),
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) return [];

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = body['data'] as List? ?? [];
    return list
        .map((e) => PredictionHistory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PredictionSubmitResult> submitPrediction({
    required int matchId,
    required int predictedIndonesiaScore,
    required int predictedOpponentScore,
  }) async {
    final token = await AuthService.getToken();
    final res = await http.post(
      Uri.parse('${AppConstants.baseUrl}/predictions'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'match_id': matchId,
        'predicted_indonesia_score': predictedIndonesiaScore,
        'predicted_opponent_score': predictedOpponentScore,
      }),
    );

    String? message;
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      message = body['message']?.toString();
    } catch (_) {}

    return PredictionSubmitResult(statusCode: res.statusCode, message: message);
  }

  Future<void> deletePrediction(int id) async {
    final token = await AuthService.getToken();
    await http.delete(
      Uri.parse('${AppConstants.baseUrl}/predictions/$id'),
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/constants.dart';

class DirectionsResult {
  final double distanceMeters;
  final double durationSeconds;

  DirectionsResult({
    required this.distanceMeters,
    required this.durationSeconds,
  });
}

class DirectionsService {
  static Future<DirectionsResult?> getRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=$startLat,$startLng'
      '&destination=$endLat,$endLng'
      '&key=${AppConstants.mapsApiKey}',
    );

    final res = await http.get(url);

    if (res.statusCode != 200) return null;

    final data = jsonDecode(res.body);

    if (data['routes'] == null || data['routes'].isEmpty) return null;

    final leg = data['routes'][0]['legs'][0];

    return DirectionsResult(
      distanceMeters: (leg['distance']['value'] as num).toDouble(),
      durationSeconds: (leg['duration']['value'] as num).toDouble(),
    );
  }
}
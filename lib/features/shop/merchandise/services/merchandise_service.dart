import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:garudahub/core/constants/constants.dart';
import 'package:garudahub/features/shop/merchandise/models/merchandise_model.dart';

class MerchandiseService {
  // GET ALL
  Future<List<MerchandiseModel>> getAll() async {
    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/merchandise'),
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => MerchandiseModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal load merchandise');
    }
  }

  // GET DETAIL
  Future<MerchandiseModel> getById(int id) async {
    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/merchandise/$id'),
    );

    if (res.statusCode == 200) {
      return MerchandiseModel.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Data tidak ditemukan');
    }
  }
}
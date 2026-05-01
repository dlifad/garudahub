import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../../../core/constants/constants.dart';
import '../../auth/services/auth_service.dart';
import '../../../core/models/user_model.dart';

class ProfileService {

  static Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // GET PROFILE
  static Future<UserModel> getProfile() async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan');
    }

    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/profile'),
      headers: _headers(token),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200) {
      return UserModel.fromJson(data);
    } else {
      throw Exception(data['message'] ?? 'Gagal mengambil profil');
    }
  }

  // UPDATE PROFILE
  static Future<UserModel> updateProfile({
    required String name,
    File? imageFile,
    bool removePhoto = false,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final uri = Uri.parse('${AppConstants.baseUrl}/profile');

    final request = http.MultipartRequest('PUT', uri);

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['name'] = name;

    // kalau hapus foto
    if (removePhoto) {
      request.fields['remove_photo'] = 'true';
    }

    // kalau upload foto
    if (imageFile != null) {
      final mimeType = lookupMimeType(imageFile.path)?.split('/');

      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_photo',
          imageFile.path,
          contentType: MediaType(mimeType![0], mimeType[1]),
        ),
      );
    }

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    final data = jsonDecode(res.body);

    if (res.statusCode == 200) {
      return UserModel.fromJson(data);
    } else {
      throw Exception(data['message'] ?? 'Gagal update profil');
    }
  }

  // REQUEST OTP EMAIL BARU
  static Future<void> requestEmailUpdateOtp(String email) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final res = await http.post(
      Uri.parse('${AppConstants.baseUrl}/profile/request-email-update'),
      headers: _headers(token),
      body: jsonEncode({'email': email}),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal kirim OTP');
    }
  }

  // VERIFY OTP EMAIL BARU
  static Future<UserModel> verifyEmailUpdateOtp({
    required String email,
    required String otp,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final res = await http.post(
      Uri.parse('${AppConstants.baseUrl}/profile/verify-email-update'),
      headers: _headers(token),
      body: jsonEncode({
        'email': email,
        'code': otp,
      }),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200) {
      return UserModel.fromJson(data);
    } else {
      throw Exception(data['message'] ?? 'OTP salah');
    }
  }
}
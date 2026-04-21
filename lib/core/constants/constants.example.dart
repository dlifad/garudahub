class AppConstants {
  // API
  static const String baseUrl = 'http://YOUR_IP:3000/api';

  // Exchange Rate API
  static const String exchangeApiKey = 'YOUR_API_KEY';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  
  // Colors
  static const int primaryColor = 0xFFCC0001;    // Merah Garuda
  static const int secondaryColor = 0xFF14213D;  // Navy
  static const int accentColor = 0xFFFCA311;     // Kuning
  static const int bgColor = 0xFF0A0A0A;         // Dark bg
  static const int cardColor = 0xFF1A1A2E;       // Card dark
  static const int surfaceColor = 0xFF16213E;    // Surface dark
}

class AppStrings {
  static const String appName = 'GarudaHub';
  static const String tagline = 'Pusat Informasi Timnas Indonesia';
  static const String login = 'Masuk';
  static const String register = 'Daftar';
  static const String email = 'Email';
  static const String password = 'Kata Sandi';
  static const String name = 'Nama Lengkap';
  static const String loginSuccess = 'Berhasil masuk!';
  static const String registerSuccess = 'Registrasi berhasil! Cek email untuk verifikasi.';
  static const String networkError = 'Gagal terhubung ke server.';
}
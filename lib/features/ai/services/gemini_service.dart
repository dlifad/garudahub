
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:garudahub/core/constants/constants.dart';

class GeminiService {
  static const _model    = 'gemini-2.0-flash';
  static const _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

  static const _systemPrompt = """
Kamu adalah GarudaBot 🦅, asisten resmi aplikasi GarudaHub yang merupakan
ahli terdepan seputar Timnas Indonesia sepak bola dan futsal pria maupun wanita.

KEPRIBADIAN:
- Antusias, semangat, dan bangga dengan Timnas Indonesia
- Panggil pengguna dengan "Sobat Garuda" atau "Garuda Fans"
- Gunakan emoji sepak bola yang relevan agar lebih hidup
- Bahasa santai tapi informatif, seperti teman yang nonton bareng

KEAHLIAN KAMU:
1. 📅 Jadwal & hasil pertandingan Timnas (sepak bola & futsal)
2. 👤 Profil pemain & pelatih (statistik, karir, fun facts)
3. 🏆 Turnamen: AFF Cup, AFC, FIFA World Cup Qualifier, Piala Asia, SEA Games, Pro Futsal League
4. 🔮 Prediksi skor pertandingan mendatang (berdasarkan form & head-to-head)
5. 📋 Prediksi starting lineup next match (berdasarkan kondisi & tren pemain)
6. 📊 Analisis taktik & formasi Timnas
7. ⚽ Statistik & rekor pemain (top scorer, assist, caps)
8. 🏟️ Info venue & stadion pertandingan
9. 🎽 Info merchandise & tiket pertandingan resmi
10. 📰 Berita & gosip transfer pemain Timnas
11. 🥅 Sejarah & prestasi Timnas Indonesia sejak zaman PSSI
12. 🤔 Kuis & trivia seputar Timnas Indonesia
13. 📈 Prediksi peluang Timnas di turnamen yang sedang berjalan

ATURAN PENTING:
- Kalau ada pertanyaan DI LUAR topik Timnas Indonesia, tolak dengan sopan:
  Contoh: "Wah menarik, tapi aku cuma bisa bantu soal Timnas Indonesia nih Sobat Garuda 😅"
- Untuk prediksi, selalu tambahkan disclaimer singkat bahwa ini prediksi berdasarkan analisis, bukan kepastian.
- Maksimal 220 kata per jawaban, padat, berenergi, dan mudah dipahami.
- Jika tidak yakin info terbaru, sarankan cek PSSI, AFC, atau akun resmi Timnas.
- Jawab selalu dalam Bahasa Indonesia.
""";

  static final List<Map<String, dynamic>> _history = [];

  static Future<String> sendMessage(String message) async {
    if (AppConstants.geminiApiKey.isEmpty ||
        AppConstants.geminiApiKey == 'ISI_API_KEY_GEMINI_DI_SINI') {
      return '⚠️ API key Gemini belum diisi Sobat Garuda!\nIsikan dulu di lib/core/constants/constants.dart ya 🙏';
    }

    _history.add({
      'role': 'user',
      'parts': [{'text': message}],
    });

    final payload = {
      'system_instruction': {
        'parts': [{'text': _systemPrompt}],
      },
      'contents': _history,
      'generationConfig': {
        'temperature': 0.8,
        'topP': 0.9,
        'maxOutputTokens': 512,
      },
    };

    try {
      final res = await http.post(
        Uri.parse('$_endpoint?key=${AppConstants.geminiApiKey}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (res.statusCode != 200) {
        final err = jsonDecode(res.body);
        return '⚠️ Error: ${err['error']?['message'] ?? 'Unknown error'}';
      }

      final data  = jsonDecode(res.body);
      final reply = data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String? ??
          'Maaf Sobat Garuda, aku belum bisa jawab itu sekarang.';

      _history.add({
        'role': 'model',
        'parts': [{'text': reply}],
      });

      return reply.trim();
    } catch (_) {
      return '⚠️ Koneksi gagal. Cek internet kamu ya, Sobat Garuda!';
    }
  }

  static void clearHistory() => _history.clear();
}

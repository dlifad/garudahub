import 'package:garudahub/core/constants/constants.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const _modelName = 'gemini-2.0-flash';

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

  static GenerativeModel? _model;
  static ChatSession? _chat;

  static GenerativeModel _getModel() {
    return _model ??= GenerativeModel(
      model: _modelName,
      apiKey: AppConstants.geminiApiKey,
      systemInstruction: Content.system(_systemPrompt),
      generationConfig: GenerationConfig(
        temperature: 0.8,
        topP: 0.9,
        maxOutputTokens: 512,
      ),
    );
  }

  static Future<String> sendMessage(String message) async {
    final apiKey = AppConstants.geminiApiKey.trim();
    if (apiKey.isEmpty || apiKey == 'ISI_API_KEY_GEMINI_DI_SINI') {
      return '⚠️ API key Gemini belum diisi Sobat Garuda!\nIsikan dulu di lib/core/constants/constants.dart ya 🙏';
    }
    try {
      final chat = _chat ??= _getModel().startChat();
      final response = await chat.sendMessage(Content.text(message));
      final reply = response.text?.trim();
      if (reply == null || reply.isEmpty) {
        return 'Maaf Sobat Garuda, aku belum bisa jawab itu sekarang.';
      }
      return reply;
    } on GenerativeAIException catch (e) {
      return '⚠️ Error Gemini: ${e.message}';
    } catch (_) {
      return '⚠️ Koneksi gagal. Cek internet kamu ya, Sobat Garuda!';
    }
  }

  static void clearHistory() {
    _chat = null;
  }
}

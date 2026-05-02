import 'package:garudahub/core/constants/constants.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const _modelName = 'gemini-2.5-flash';

  static const _systemPrompt = """
Kamu adalah GarudaBot 🦅, asisten resmi GarudaHub — khusus Timnas Indonesia SENIOR.
Panggil user "Sobat Garuda". Bahasa santai. JANGAN gunakan markdown **bold**, *italic*, atau ### heading. Gunakan bullet • biasa.

LANGSUNG ke inti jawaban. JANGAN kalimat pembuka seperti "Waduh!", "Siap banget!", "Sebagai GarudaBot...".

TOPIK BOLEH (jawab lengkap pakai pengetahuanmu):
- Sepak bola & futsal apapun (profil pemain, sejarah, taktik, analisis, trivia)
- Timnas Indonesia semua aspek
- Jika di tanya prediksi jawaban singkat pilih mana antara 2 opsi dengan alasan singkat 1 kalimat

TOPIK DILARANG: di luar olahraga → tolak sopan saja.

INFO TIMNAS SENIOR (Mei 2026):
- Pelatih: John Herdman | Formasi: 3-4-2-1 / 4-4-2 | Kapten: Jay Idzes
- Pemain inti: Maarten Paes, Jay Idzes, Justin Hubner, Rizky Ridho, Kevin Diks, Calvin Verdonk, Ivar Jenner, Thom Haye, Ragnar Oratmangoen, Eliano Reijnders, Ole Romeny, Rafael Struick
- Next match: Indonesia vs Oman | FIFA Matchday | 6 Juni 2026 | GBK Jakarta
- Agenda: Piala AFF/ASEAN Cup Juli-Agustus 2026
- Kualifikasi Piala Dunia 2026: SUDAH SELESAI
- Untuk prediksi: tambahkan disclaimer singkat
""";

  static GenerativeModel? _model;
  static ChatSession? _chat;

  static GenerativeModel _getModel() {
    return _model ??= GenerativeModel(
      model: _modelName,
      apiKey: AppConstants.geminiApiKey,
      systemInstruction: Content.system(_systemPrompt),
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topP: 0.9,
        maxOutputTokens: 700,
      ),
    );
  }

  static bool _isRateLimitError(Object e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('quota') ||
        msg.contains('rate') ||
        msg.contains('429') ||
        msg.contains('resource_exhausted');
  }

  static String _stripMarkdown(String text) {
    return text
        .replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'), (m) => m[1] ?? '')
        .replaceAllMapped(RegExp(r'\*(.*?)\*'), (m) => m[1] ?? '')
        .replaceAll(RegExp(r'#{1,6}\s'), '')
        .replaceAll('`', '')
        .trim();
  }

  static Future<String> sendMessage(String text) async {
    final model = _getModel();
    _chat ??= model.startChat();
    try {
      final response = await _chat!.sendMessage(Content.text(text));
      final reply = response.text?.trim();
      if (reply == null || reply.isEmpty) {
        return 'Maaf Sobat Garuda, aku belum bisa menjawab itu sekarang.';
      }
      return _stripMarkdown(reply);
    } catch (e) {
      if (_isRateLimitError(e)) {
        return 'Server lagi penuh, coba beberapa saat lagi ya Sobat Garuda.';
      }
      return 'Maaf Sobat Garuda, terjadi kesalahan. Coba lagi sebentar ya.';
    }
  }

  static void clearHistory() {
    _chat = null;
  }
}
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/ai_config.dart';

/// Klien untuk Edge Functions AI (scan struk & DanaBot chat).
class AiService {
  AiService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  /// Kirim gambar struk (base64) ke proxy Gemini Vision.
  Future<Map<String, dynamic>> scanStruk({
    required String base64Image,
    required String mimeType,
  }) async {
    final resp = await _client
        .post(
          Uri.parse(AiConfig.scanUrl),
          headers: AiConfig.headers,
          body: jsonEncode({
            'image_base64': base64Image,
            'mime_type': mimeType,
          }),
        )
        .timeout(const Duration(seconds: 45));
    final data = jsonDecode(resp.body);
    if (data is Map<String, dynamic>) return data;
    return {'berhasil': false, 'gagal_alasan': 'Respons tak terbaca.'};
  }

  /// Kirim riwayat chat + konteks keuangan ke proxy DanaBot.
  Future<String> chat({
    required List<Map<String, String>> messages,
    String? konteks,
  }) async {
    final resp = await _client
        .post(
          Uri.parse(AiConfig.chatUrl),
          headers: AiConfig.headers,
          body: jsonEncode({'messages': messages, 'konteks': konteks}),
        )
        .timeout(const Duration(seconds: 45));
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    if (data['error'] != null) throw Exception(data['error']);
    return (data['reply'] as String?) ?? 'Maaf, tidak ada jawaban.';
  }
}

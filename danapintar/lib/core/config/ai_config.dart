/// Konfigurasi endpoint AI (Supabase Edge Functions).
///
/// AI = SATU-SATUNYA komponen cloud. Key Gemini ada di server (secret Edge
/// Function), TIDAK di app. App hanya memanggil endpoint proxy dengan anon key.
abstract class AiConfig {
  /// Project Supabase 'danapintar' (mgaonsjwcaahwlcfqxeg), di-restore untuk AI.
  static const String supabaseUrl = 'https://mgaonsjwcaahwlcfqxeg.supabase.co';

  /// Anon/publishable key project. Ambil dari Supabase Dashboard → Settings →
  /// API. Aman ditanam di app (bukan service_role). Isi sebelum fitur AI aktif.
  static const String anonKey = 'ISI_ANON_KEY_SUPABASE_DI_SINI';

  static bool get configured =>
      anonKey != 'ISI_ANON_KEY_SUPABASE_DI_SINI' && anonKey.isNotEmpty;

  static String get scanUrl => '$supabaseUrl/functions/v1/gemini-scan';
  static String get chatUrl => '$supabaseUrl/functions/v1/gemini-chat';

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $anonKey',
    'apikey': anonKey,
  };
}

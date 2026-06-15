/// Konfigurasi endpoint AI (Supabase Edge Functions).
///
/// AI = SATU-SATUNYA komponen cloud. Key Gemini ada di server (secret Edge
/// Function), TIDAK di app. App hanya memanggil endpoint proxy dengan anon key.
abstract class AiConfig {
  /// Project Supabase DanaPintar (Account utama). Hanya untuk Edge Functions AI.
  static const String supabaseUrl = 'https://lmyvddqwmmpsrpigzygi.supabase.co';

  /// Anon/publishable key project (role `anon`). Aman ditanam di app —
  /// memang dirancang publik & dilindungi RLS; di sini hanya gerbang ke
  /// Edge Function AI (tidak menyentuh data keuangan yang 100% lokal).
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
      '.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxteXZkZHF3bW1wc3JwaWd6eWdpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkxNzQ0NjQsImV4cCI6MjA5NDc1MDQ2NH0'
      '.Cv41r1Mo6fR164y3g8OX-zP_Cmj0NiR9zyRzkmYJi9I';

  static bool get configured => anonKey.isNotEmpty;

  static String get scanUrl => '$supabaseUrl/functions/v1/gemini-scan';
  static String get chatUrl => '$supabaseUrl/functions/v1/gemini-chat';

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $anonKey',
    'apikey': anonKey,
  };
}

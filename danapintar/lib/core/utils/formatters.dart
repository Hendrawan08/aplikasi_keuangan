import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

/// Format rupiah — port dari `rp()` di kode Python (`f"Rp {n:,.0f}"`),
/// disesuaikan ke konvensi Indonesia (pemisah ribuan titik).
/// Contoh: 1000000 → "Rp 1.000.000".
final NumberFormat _rupiah = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

String rp(num n) => _rupiah.format(n);

/// Kunci bulan: "{NamaBulan}_{tahun}", mis. "Mei_2026".
/// Port dari pola `f"{_bln}_{_thn}"` di kode Python.
String bulanKey(int month, int year) => '${kamusBulan[month]}_$year';

/// Inisial untuk avatar — port dari `inisial()` di kode Python.
String inisial(String nama, String email) {
  final t = nama.trim().isNotEmpty ? nama.trim() : email;
  final b = t.split(RegExp(r'\s+'));
  if (b.length >= 2 && b[0].isNotEmpty && b[1].isNotEmpty) {
    return (b[0][0] + b[1][0]).toUpperCase();
  }
  return (t.length >= 2 ? t.substring(0, 2) : t).toUpperCase();
}

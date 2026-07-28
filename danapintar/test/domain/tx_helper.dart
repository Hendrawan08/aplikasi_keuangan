import 'package:danapintar/core/utils/formatters.dart';
import 'package:danapintar/domain/models.dart';

/// Builder ringkas [TxView] untuk pengujian domain.
/// [tanggal] dalam format "YYYY-MM-DD".
TxView tx(
  String tanggal, {
  int nominal = 10000,
  String kategori = 'Makanan',
  String sifat = 'Wajib',
  int jam = 10,
}) {
  final d = DateTime.parse(tanggal);
  final dt = DateTime(d.year, d.month, d.day, jam);
  return TxView(
    waktu: dt,
    nominal: nominal,
    kategori: kategori,
    sifat: sifat,
    bulanKey: bulanKey(d.month, d.year),
  );
}

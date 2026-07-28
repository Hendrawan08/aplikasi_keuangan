import 'models.dart';

/// Analitik lintas bulan — port dari logika auditor tren MoM pada kode Python
/// (`dp.groupby(["tahun","bulan"])["nominal"].sum().mean()`).

/// Rata-rata total pengeluaran bulan-bulan SELAIN [bulanKeyIni].
/// Mengembalikan null bila tidak ada bulan pembanding.
double? rataRataBulanLain(List<TxView> semuaTransaksi, String bulanKeyIni) {
  final perBulan = <String, int>{};
  for (final t in semuaTransaksi) {
    if (t.bulanKey != bulanKeyIni) {
      perBulan[t.bulanKey] = (perBulan[t.bulanKey] ?? 0) + t.nominal;
    }
  }
  if (perBulan.isEmpty) return null;
  final total = perBulan.values.fold(0, (s, v) => s + v);
  return total / perBulan.length;
}

/// Jumlah hari unik yang memiliki transaksi (untuk skor Konsistensi).
int hariUnikCatat(Iterable<TxView> transaksi) =>
    transaksi.map((t) => t.tanggal).toSet().length;

/// Total nominal bersifat 'Sukarela'.
int totalSukarela(Iterable<TxView> transaksi) => transaksi
    .where((t) => t.sifat == 'Sukarela')
    .fold(0, (s, t) => s + t.nominal);

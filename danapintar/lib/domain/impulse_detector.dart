import 'models.dart';

/// Deteksi belanja impulsif jam rawan — port dari §6.3 dokumen rencana
/// (`_dfv[(_dfv["jam"]>=20)|(_dfv["jam"]<=5)]` pada kode Python).

/// True bila [jam] (0–23) termasuk jam rawan: malam (>=20) atau dini hari (<=5).
bool isJamRawan(int jam) => jam >= 20 || jam <= 5;

/// Total nominal transaksi yang terjadi pada jam rawan.
int totalBelanjaJamRawan(Iterable<TxView> transaksi) => transaksi
    .where((t) => isJamRawan(t.jam))
    .fold(0, (sum, t) => sum + t.nominal);

/// Daftar transaksi pada jam rawan.
List<TxView> transaksiJamRawan(Iterable<TxView> transaksi) =>
    transaksi.where((t) => isJamRawan(t.jam)).toList();

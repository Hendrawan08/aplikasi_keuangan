/// Model nilai untuk domain layer. Murni Dart — tidak bergantung pada
/// Flutter, drift, atau lapisan lain. Lapisan data memetakan baris DB ke
/// tipe-tipe ini sebelum memanggil fungsi domain.
library;

/// Representasi ringan satu transaksi pengeluaran untuk perhitungan domain.
/// [waktu] adalah waktu lokal perangkat saat transaksi dicatat.
class TxView {
  final DateTime waktu;
  final int nominal;
  final String kategori;
  final String sifat; // 'Wajib' | 'Sukarela'
  final String bulanKey; // "{NamaBulan}_{tahun}", mis. "Mei_2026"

  const TxView({
    required this.waktu,
    required this.nominal,
    required this.kategori,
    required this.sifat,
    required this.bulanKey,
  });

  int get jam => waktu.hour;

  /// Tanggal tanpa komponen jam (untuk hitung streak & hari unik).
  DateTime get tanggal => DateTime(waktu.year, waktu.month, waktu.day);
}

/// Sebuah lencana gamifikasi.
class Badge {
  final String ikon;
  final String nama;
  final String deskripsi;

  const Badge(this.ikon, this.nama, this.deskripsi);

  @override
  bool operator ==(Object other) =>
      other is Badge &&
      other.ikon == ikon &&
      other.nama == nama &&
      other.deskripsi == deskripsi;

  @override
  int get hashCode => Object.hash(ikon, nama, deskripsi);

  @override
  String toString() => 'Badge($ikon $nama: $deskripsi)';
}

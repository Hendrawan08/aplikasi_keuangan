import 'dart:math';

/// Financial Health Score — port SETIA dari `health_score()` & `label_hs()`
/// pada `aplikasi_keuangan.py` (§6.2 dokumen rencana). Murni Dart, tertotal 100.

enum HealthLabel {
  excellent,
  sehat,
  perluPerhatian,
  kritis;

  String get display => switch (this) {
        HealthLabel.excellent => '💚 Excellent',
        HealthLabel.sehat => '💛 Sehat',
        HealthLabel.perluPerhatian => '🟠 Perlu Perhatian',
        HealthLabel.kritis => '🔴 Kritis',
      };
}

class HealthResult {
  final int total; // 0..100
  final int rasioTabungan; // maks 40
  final int konsistensi; // maks 20
  final int porsiSukarela; // maks 20
  final int tren; // maks 20

  const HealthResult({
    required this.total,
    required this.rasioTabungan,
    required this.konsistensi,
    required this.porsiSukarela,
    required this.tren,
  });

  /// Rincian untuk ditampilkan (label → skor), nilai maksimum di
  /// [breakdownMaks].
  Map<String, int> get breakdown => {
        'Rasio Tabungan': rasioTabungan,
        'Konsistensi Catat': konsistensi,
        'Porsi Sukarela': porsiSukarela,
        'Tren Pengeluaran': tren,
      };

  static const Map<String, int> breakdownMaks = {
    'Rasio Tabungan': 40,
    'Konsistensi Catat': 20,
    'Porsi Sukarela': 20,
    'Tren Pengeluaran': 20,
  };
}

/// Hitung Health Score.
///
/// - [hariUnikCatat]: jumlah hari berbeda dengan transaksi pada periode ini.
/// - [adaData]: true jika ada transaksi pada periode ini (df_view tidak kosong).
/// - [rataRataBulanLain]: rata-rata total pengeluaran bulan-bulan lain
///   (null bila tak ada histori).
HealthResult hitungHealthScore({
  required int totalPengeluaran,
  required int budget,
  required int target,
  required int sukarela,
  required int hariUnikCatat,
  required bool adaData,
  double? rataRataBulanLain,
}) {
  // a) Rasio Tabungan (maks 40)
  final int s1;
  if (budget > 0 && target > 0) {
    final batas = max(0, budget - target);
    s1 = totalPengeluaran <= batas
        ? 40
        : max(0, 40 - (((totalPengeluaran - batas) / budget) * 80).toInt());
  } else if (budget > 0) {
    s1 = max(0, ((1 - totalPengeluaran / budget) * 40).toInt());
  } else {
    s1 = 20;
  }

  // b) Konsistensi Catat (maks 20)
  final int s2 =
      adaData ? (min(1.0, hariUnikCatat / 15) * 20).toInt() : 0;

  // c) Porsi Sukarela (maks 20)
  final int s3;
  if (budget > 0 && adaData) {
    final r = sukarela / budget;
    s3 = r <= 0.3
        ? 20
        : (r <= 0.5 ? 12 : max(0, ((1 - r) * 20).toInt()));
  } else {
    s3 = 10;
  }

  // d) Tren Pengeluaran (maks 20)
  int s4 = 10;
  if (rataRataBulanLain != null && adaData) {
    final rata = rataRataBulanLain;
    s4 = totalPengeluaran < rata
        ? 20
        : max(0,
            ((1 - (totalPengeluaran - rata) / max(rata, 1.0)) * 20).toInt());
  }

  return HealthResult(
    total: min(100, s1 + s2 + s3 + s4),
    rasioTabungan: s1,
    konsistensi: s2,
    porsiSukarela: s3,
    tren: s4,
  );
}

HealthLabel labelHealth(int score) {
  if (score >= 80) return HealthLabel.excellent;
  if (score >= 60) return HealthLabel.sehat;
  if (score >= 40) return HealthLabel.perluPerhatian;
  return HealthLabel.kritis;
}

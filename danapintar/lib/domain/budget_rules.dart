import 'dart:math';

/// Aturan anggaran — port dari logika `batas_belanja` & porsi sukarela
/// pada `aplikasi_keuangan.py` (§6.1 & §6.4 dokumen rencana).

/// Batas belanja = anggaran dikurangi target tabungan (tidak pernah negatif).
int batasBelanja(int anggaran, int targetTabungan) =>
    max(0, anggaran - targetTabungan);

/// Sisa anggaran setelah pengeluaran (boleh negatif = tekor).
int sisaAnggaran(int anggaran, int totalPengeluaran) =>
    anggaran - totalPengeluaran;

/// Persentase porsi sukarela terhadap anggaran (0 bila anggaran 0).
double porsiSukarelaPersen(int totalSukarela, int anggaran) =>
    anggaran > 0 ? totalSukarela / anggaran * 100 : 0;

/// True bila porsi sukarela melebihi 50% anggaran (ambang peringatan).
bool sukarelaBerlebihan(int totalSukarela, int anggaran) =>
    porsiSukarelaPersen(totalSukarela, anggaran) > 50;

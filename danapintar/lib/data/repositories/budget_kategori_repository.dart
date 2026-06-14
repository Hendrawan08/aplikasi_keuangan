import 'package:drift/drift.dart';

import '../local/database.dart';

/// Akses anggaran per kategori per bulan (SQLite lokal).
class BudgetKategoriRepository {
  BudgetKategoriRepository(this._db);
  final AppDatabase _db;

  /// Stream Map kategori→nominal untuk [bulanKey].
  Stream<Map<String, int>> watchByBulan(String bulanKey) {
    return (_db.select(_db.budgetKategori)
          ..where((b) => b.bulanKey.equals(bulanKey)))
        .watch()
        .map((rows) => {for (final r in rows) r.kategori: r.nominal});
  }

  /// Set/hapus anggaran sebuah kategori (nominal 0 = hapus).
  Future<void> set(String bulanKey, String kategori, int nominal) async {
    await _db.transaction(() async {
      await (_db.delete(_db.budgetKategori)..where(
            (b) => b.bulanKey.equals(bulanKey) & b.kategori.equals(kategori),
          ))
          .go();
      if (nominal > 0) {
        await _db
            .into(_db.budgetKategori)
            .insert(
              BudgetKategoriCompanion.insert(
                bulanKey: bulanKey,
                kategori: kategori,
                nominal: nominal,
              ),
            );
      }
    });
  }
}

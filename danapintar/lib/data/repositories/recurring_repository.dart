import 'package:uuid/uuid.dart';

import '../local/database.dart';

/// Akses template transaksi berulang (SQLite lokal).
class RecurringRepository {
  RecurringRepository(this._db);
  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<RecurringTemplate>> watchAll() =>
      _db.select(_db.recurringTemplates).watch();

  Future<void> tambah({
    required String catatan,
    required int nominal,
    required String kategori,
    required String sifat,
    required String frekuensi,
  }) {
    return _db
        .into(_db.recurringTemplates)
        .insert(
          RecurringTemplatesCompanion.insert(
            id: _uuid.v4(),
            catatan: catatan,
            nominal: nominal,
            kategori: kategori,
            sifat: sifat,
            frekuensi: frekuensi,
          ),
        );
  }

  Future<void> hapus(String id) =>
      (_db.delete(_db.recurringTemplates)..where((r) => r.id.equals(id))).go();
}

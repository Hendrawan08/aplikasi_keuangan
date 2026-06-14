import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../local/database.dart';

/// Akses data kategori custom (pengeluaran/pemasukan, SQLite lokal).
class CustomKategoriRepository {
  CustomKategoriRepository(this._db);
  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<CustomKategoriData>> watchAll() =>
      _db.select(_db.customKategori).watch();

  Future<void> tambah({
    required String nama,
    required String tipe, // 'pengeluaran' | 'pemasukan'
    String ikon = '📌',
  }) {
    return _db
        .into(_db.customKategori)
        .insert(
          CustomKategoriCompanion.insert(
            id: _uuid.v4(),
            nama: nama,
            tipe: tipe,
            ikon: Value(ikon),
          ),
        );
  }

  Future<void> hapus(String id) =>
      (_db.delete(_db.customKategori)..where((k) => k.id.equals(id))).go();
}

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../local/database.dart';

/// Akses data pemasukan (SQLite lokal).
class PemasukanRepository {
  PemasukanRepository(this._db);
  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<PemasukanData>> watchAll() {
    return (_db.select(
      _db.pemasukan,
    )..orderBy([(t) => OrderingTerm.desc(t.waktuPemasukan)])).watch();
  }

  Future<void> tambah({
    required String sumber,
    required int nominal,
    required String kategori,
    required DateTime waktu,
    String? walletId,
  }) {
    return _db
        .into(_db.pemasukan)
        .insert(
          PemasukanCompanion.insert(
            id: _uuid.v4(),
            sumber: sumber,
            nominal: nominal,
            kategori: kategori,
            waktuPemasukan: waktu,
            walletId: Value(walletId),
          ),
        );
  }

  Future<void> hapus(String id) =>
      (_db.delete(_db.pemasukan)..where((t) => t.id.equals(id))).go();
}

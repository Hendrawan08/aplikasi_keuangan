import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../local/database.dart';

/// Akses data Hutang & Piutang (SQLite lokal).
class HutangRepository {
  HutangRepository(this._db);
  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<HutangPiutangData>> watchAll() => (_db.select(
    _db.hutangPiutang,
  )..orderBy([(h) => OrderingTerm.desc(h.tanggal)])).watch();

  Future<void> tambah({
    required String tipe, // 'hutang' | 'piutang'
    required String nama,
    required int nominal,
    required DateTime tanggal,
  }) {
    return _db
        .into(_db.hutangPiutang)
        .insert(
          HutangPiutangCompanion.insert(
            id: _uuid.v4(),
            tipe: tipe,
            nama: nama,
            nominal: nominal,
            tanggal: tanggal,
          ),
        );
  }

  Future<void> setStatus(String id, String status) {
    return (_db.update(_db.hutangPiutang)..where((h) => h.id.equals(id))).write(
      HutangPiutangCompanion(status: Value(status)),
    );
  }

  Future<void> hapus(String id) =>
      (_db.delete(_db.hutangPiutang)..where((h) => h.id.equals(id))).go();
}

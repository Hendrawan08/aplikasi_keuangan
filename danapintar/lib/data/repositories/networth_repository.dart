import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../local/database.dart';

/// Akses data Net Worth (aset & liabilitas per bulan, SQLite lokal).
class NetworthRepository {
  NetworthRepository(this._db);
  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<NetworthHistoryData>> watchAll() => (_db.select(
    _db.networthHistory,
  )..orderBy([(n) => OrderingTerm.asc(n.recordedAt)])).watch();

  /// Catat/perbarui net worth untuk [bulanKey] (mengganti entri bulan tsb).
  Future<void> simpan({
    required String bulanKey,
    required int totalAset,
    required int totalLiabilitas,
  }) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.networthHistory,
      )..where((n) => n.bulanKey.equals(bulanKey))).go();
      await _db
          .into(_db.networthHistory)
          .insert(
            NetworthHistoryCompanion.insert(
              id: _uuid.v4(),
              bulanKey: bulanKey,
              totalAset: Value(totalAset),
              totalLiabilitas: Value(totalLiabilitas),
            ),
          );
    });
  }

  Future<void> hapus(String id) =>
      (_db.delete(_db.networthHistory)..where((n) => n.id.equals(id))).go();
}

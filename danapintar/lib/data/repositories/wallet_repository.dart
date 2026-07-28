import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../local/database.dart';

/// Akses data dompet (SQLite lokal).
class WalletRepository {
  WalletRepository(this._db);
  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<Wallet>> watchAll() => _db.select(_db.wallets).watch();

  Future<void> tambah({
    required String nama,
    required String tipe,
    int saldoAwal = 0,
    String warna = '#2E7D32',
  }) {
    return _db
        .into(_db.wallets)
        .insert(
          WalletsCompanion.insert(
            id: _uuid.v4(),
            nama: nama,
            tipe: tipe,
            saldoAwal: Value(saldoAwal),
            warna: Value(warna),
          ),
        );
  }

  Future<void> hapus(String id) =>
      (_db.delete(_db.wallets)..where((w) => w.id.equals(id))).go();
}

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../local/database.dart';

/// Akses data transaksi pengeluaran (SQLite lokal).
class TransaksiRepository {
  TransaksiRepository(this._db);
  final AppDatabase _db;
  static const _uuid = Uuid();

  /// Stream seluruh transaksi, terbaru di atas.
  Stream<List<TransaksiData>> watchAll() {
    return (_db.select(_db.transaksi)
          ..orderBy([(t) => OrderingTerm.desc(t.waktuTransaksi)]))
        .watch();
  }

  Future<void> tambah({
    required String catatan,
    required int nominal,
    required String kategori,
    required String sifat,
    required DateTime waktu,
    String? walletId,
  }) {
    return _db.into(_db.transaksi).insert(
          TransaksiCompanion.insert(
            id: _uuid.v4(),
            catatan: catatan,
            nominal: nominal,
            kategori: kategori,
            sifat: sifat,
            waktuTransaksi: waktu,
            walletId: Value(walletId),
          ),
        );
  }

  Future<void> ubah({
    required String id,
    required String catatan,
    required int nominal,
    required String kategori,
    required String sifat,
    required DateTime waktu,
    String? walletId,
  }) {
    return (_db.update(_db.transaksi)..where((t) => t.id.equals(id))).write(
      TransaksiCompanion(
        catatan: Value(catatan),
        nominal: Value(nominal),
        kategori: Value(kategori),
        sifat: Value(sifat),
        waktuTransaksi: Value(waktu),
        walletId: Value(walletId),
      ),
    );
  }

  Future<void> hapus(String id) =>
      (_db.delete(_db.transaksi)..where((t) => t.id.equals(id))).go();
}

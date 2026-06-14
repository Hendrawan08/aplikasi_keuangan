import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danapintar/data/local/database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('skema terbentuk & transaksi bisa ditulis lalu dibaca', () async {
    await db.into(db.transaksi).insert(
          TransaksiCompanion.insert(
            id: 'tx-1',
            catatan: 'Kopi',
            nominal: 25000,
            kategori: 'Makanan',
            sifat: 'Sukarela',
            waktuTransaksi: DateTime.utc(2026, 6, 14, 9, 30),
          ),
        );

    final rows = await db.select(db.transaksi).get();
    expect(rows, hasLength(1));
    expect(rows.first.nominal, 25000);
    expect(rows.first.kategori, 'Makanan');
  });

  test('default value kolom diterapkan', () async {
    await db.into(db.wallets).insert(
          WalletsCompanion.insert(id: 'w-1', nama: 'Dompet', tipe: '💵 Cash'),
        );
    final w = await (db.select(db.wallets)).getSingle();
    expect(w.saldoAwal, 0);
    expect(w.warna, '#2E7D32');
  });
}

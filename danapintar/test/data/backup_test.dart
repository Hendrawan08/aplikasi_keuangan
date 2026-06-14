import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danapintar/data/backup/backup_service.dart';
import 'package:danapintar/data/local/database.dart';

void main() {
  test('export → import memulihkan seluruh data', () async {
    final db1 = AppDatabase.forTesting(NativeDatabase.memory());
    await db1
        .into(db1.transaksi)
        .insert(
          TransaksiCompanion.insert(
            id: 't1',
            catatan: 'Kopi',
            nominal: 25000,
            kategori: 'Makanan',
            sifat: 'Sukarela',
            waktuTransaksi: DateTime(2026, 6, 14, 9, 30),
          ),
        );
    await db1
        .into(db1.wallets)
        .insert(
          WalletsCompanion.insert(id: 'w1', nama: 'Dompet', tipe: '💵 Cash'),
        );
    await db1
        .into(db1.budgets)
        .insert(
          BudgetsCompanion.insert(bulanKey: 'Juni_2026', nominal: 1000000),
        );

    final json = await BackupService(db1).exportJson();
    await db1.close();

    final db2 = AppDatabase.forTesting(NativeDatabase.memory());
    await BackupService(db2).importJson(json);

    final tx = await db2.select(db2.transaksi).get();
    final w = await db2.select(db2.wallets).get();
    final b = await db2.select(db2.budgets).get();

    expect(tx, hasLength(1));
    expect(tx.first.catatan, 'Kopi');
    expect(tx.first.nominal, 25000);
    expect(tx.first.waktuTransaksi.year, 2026);
    expect(tx.first.waktuTransaksi.month, 6);
    expect(tx.first.waktuTransaksi.day, 14);
    expect(tx.first.waktuTransaksi.hour, 9);
    expect(w.first.nama, 'Dompet');
    expect(b.first.nominal, 1000000);

    await db2.close();
  });

  test('import idempoten (tidak menggandakan data)', () async {
    final db1 = AppDatabase.forTesting(NativeDatabase.memory());
    await db1
        .into(db1.transaksi)
        .insert(
          TransaksiCompanion.insert(
            id: 't1',
            catatan: 'A',
            nominal: 1000,
            kategori: 'Makanan',
            sifat: 'Wajib',
            waktuTransaksi: DateTime(2026, 6, 1),
          ),
        );
    final json = await BackupService(db1).exportJson();

    // Impor dua kali ke DB yang sama → tetap 1 baris (insertOrReplace).
    await BackupService(db1).importJson(json);
    await BackupService(db1).importJson(json);
    expect(await db1.select(db1.transaksi).get(), hasLength(1));
    await db1.close();
  });

  test('import menolak file asing', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    expect(
      () => BackupService(db).importJson('{"app":"bukan_danapintar"}'),
      throwsFormatException,
    );
    await db.close();
  });
}

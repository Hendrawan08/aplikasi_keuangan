import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danapintar/data/local/database.dart';
import 'package:danapintar/data/mappers.dart';
import 'package:danapintar/data/repositories/budget_repository.dart';
import 'package:danapintar/data/repositories/transaksi_repository.dart';
import 'package:danapintar/data/repositories/wallet_repository.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('TransaksiRepository: tambah → terbaca via watch', () async {
    final repo = TransaksiRepository(db);
    await repo.tambah(
      catatan: 'Kopi',
      nominal: 25000,
      kategori: 'Makanan',
      sifat: 'Sukarela',
      waktu: DateTime(2026, 6, 14, 9, 30),
    );
    final rows = await repo.watchAll().first;
    expect(rows, hasLength(1));
    expect(rows.first.nominal, 25000);

    // Mapper ke domain berfungsi.
    final view = rows.first.toTxView();
    expect(view.kategori, 'Makanan');
    expect(view.bulanKey, 'Juni_2026');
    expect(view.jam, 9);
  });

  test('TransaksiRepository: ubah & hapus', () async {
    final repo = TransaksiRepository(db);
    await repo.tambah(
      catatan: 'A',
      nominal: 1000,
      kategori: 'Makanan',
      sifat: 'Wajib',
      waktu: DateTime(2026, 6, 1),
    );
    var rows = await repo.watchAll().first;
    final id = rows.first.id;

    await repo.ubah(
      id: id,
      catatan: 'B',
      nominal: 2000,
      kategori: 'Transportasi',
      sifat: 'Wajib',
      waktu: DateTime(2026, 6, 1),
    );
    rows = await repo.watchAll().first;
    expect(rows.first.catatan, 'B');
    expect(rows.first.nominal, 2000);

    await repo.hapus(id);
    expect(await repo.watchAll().first, isEmpty);
  });

  test('WalletRepository: tambah dengan default', () async {
    final repo = WalletRepository(db);
    await repo.tambah(nama: 'Dompet', tipe: '💵 Cash');
    final rows = await repo.watchAll().first;
    expect(rows, hasLength(1));
    expect(rows.first.saldoAwal, 0);
    expect(rows.first.warna, '#2E7D32');
  });

  test('BudgetRepository: kunci anggaran & target (upsert)', () async {
    final repo = BudgetRepository(db);
    await repo.kunciAnggaran('Juni_2026', 1000000);
    await repo.kunciAnggaran('Juni_2026', 1500000); // upsert, bukan duplikat
    await repo.setTarget('Juni_2026', 300000);

    final budgets = await repo.watchBudgets().first;
    final targets = await repo.watchTargets().first;
    expect(budgets['Juni_2026'], 1500000);
    expect(targets['Juni_2026'], 300000);

    await repo.hapusAnggaran('Juni_2026');
    expect(await repo.watchBudgets().first, isEmpty);
  });
}

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danapintar/data/local/database.dart';
import 'package:danapintar/data/repositories/budget_kategori_repository.dart';
import 'package:danapintar/data/repositories/recurring_repository.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('RecurringRepository: tambah & hapus', () async {
    final repo = RecurringRepository(db);
    await repo.tambah(
      catatan: 'Langganan',
      nominal: 50000,
      kategori: 'Hiburan/Gaya Hidup',
      sifat: 'Sukarela',
      frekuensi: 'Bulanan',
    );
    var list = await repo.watchAll().first;
    expect(list, hasLength(1));
    expect(list.first.frekuensi, 'Bulanan');

    await repo.hapus(list.first.id);
    expect(await repo.watchAll().first, isEmpty);
  });

  test('BudgetKategoriRepository: set, ganti, dan nol = hapus', () async {
    final repo = BudgetKategoriRepository(db);
    await repo.set('Juni_2026', 'Makanan', 500000);
    expect((await repo.watchByBulan('Juni_2026').first)['Makanan'], 500000);

    // set ulang menimpa
    await repo.set('Juni_2026', 'Makanan', 700000);
    final m = await repo.watchByBulan('Juni_2026').first;
    expect(m['Makanan'], 700000);
    expect(m.length, 1);

    // nol = hapus
    await repo.set('Juni_2026', 'Makanan', 0);
    expect(await repo.watchByBulan('Juni_2026').first, isEmpty);
  });
}

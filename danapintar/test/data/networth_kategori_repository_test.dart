import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danapintar/data/local/database.dart';
import 'package:danapintar/data/repositories/custom_kategori_repository.dart';
import 'package:danapintar/data/repositories/networth_repository.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('NetworthRepository: simpan menimpa entri bulan yang sama', () async {
    final repo = NetworthRepository(db);
    await repo.simpan(
      bulanKey: 'Juni_2026',
      totalAset: 10000000,
      totalLiabilitas: 3000000,
    );
    await repo.simpan(
      bulanKey: 'Juni_2026',
      totalAset: 12000000,
      totalLiabilitas: 2000000,
    );
    final list = await repo.watchAll().first;
    expect(list, hasLength(1)); // tidak menggandakan
    expect(list.first.totalAset, 12000000);
    expect(list.first.totalLiabilitas, 2000000);
  });

  test('CustomKategoriRepository: tambah & hapus', () async {
    final repo = CustomKategoriRepository(db);
    await repo.tambah(nama: 'Snack', tipe: 'pengeluaran', ikon: '🍫');
    var list = await repo.watchAll().first;
    expect(list, hasLength(1));
    expect(list.first.nama, 'Snack');
    expect(list.first.ikon, '🍫');

    await repo.hapus(list.first.id);
    expect(await repo.watchAll().first, isEmpty);
  });
}

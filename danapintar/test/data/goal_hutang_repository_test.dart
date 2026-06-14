import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danapintar/data/local/database.dart';
import 'package:danapintar/data/repositories/goal_repository.dart';
import 'package:danapintar/data/repositories/hutang_repository.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('GoalRepository: tambah, update terkumpul, hapus', () async {
    final repo = GoalRepository(db);
    await repo.tambah(nama: 'Dana Darurat', target: 5000000);
    var goals = await repo.watchAll().first;
    expect(goals, hasLength(1));
    expect(goals.first.targetNominal, 5000000);
    expect(goals.first.terkumpul, 0);
    expect(goals.first.ikon, '🎯');

    await repo.setTerkumpul(goals.first.id, 1500000);
    goals = await repo.watchAll().first;
    expect(goals.first.terkumpul, 1500000);

    await repo.hapus(goals.first.id);
    expect(await repo.watchAll().first, isEmpty);
  });

  test('HutangRepository: tambah, toggle status, hapus', () async {
    final repo = HutangRepository(db);
    await repo.tambah(
      tipe: 'hutang',
      nama: 'Pinjam Budi',
      nominal: 200000,
      tanggal: DateTime(2026, 6, 1),
    );
    var list = await repo.watchAll().first;
    expect(list, hasLength(1));
    expect(list.first.tipe, 'hutang');
    expect(list.first.status, 'belum');

    await repo.setStatus(list.first.id, 'lunas');
    list = await repo.watchAll().first;
    expect(list.first.status, 'lunas');

    await repo.hapus(list.first.id);
    expect(await repo.watchAll().first, isEmpty);
  });
}

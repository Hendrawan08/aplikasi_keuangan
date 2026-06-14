import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../local/database.dart';

/// Akses data Financial Goals (SQLite lokal).
class GoalRepository {
  GoalRepository(this._db);
  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<FinancialGoal>> watchAll() => (_db.select(
    _db.financialGoals,
  )..orderBy([(g) => OrderingTerm.asc(g.createdAt)])).watch();

  Future<void> tambah({
    required String nama,
    required int target,
    int terkumpul = 0,
    DateTime? deadline,
    String kategori = 'Tabungan',
    String ikon = '🎯',
  }) {
    return _db
        .into(_db.financialGoals)
        .insert(
          FinancialGoalsCompanion.insert(
            id: _uuid.v4(),
            nama: nama,
            targetNominal: target,
            terkumpul: Value(terkumpul),
            deadline: Value(deadline),
            kategori: Value(kategori),
            ikon: Value(ikon),
          ),
        );
  }

  Future<void> setTerkumpul(String id, int terkumpul) {
    return (_db.update(_db.financialGoals)..where((g) => g.id.equals(id)))
        .write(FinancialGoalsCompanion(terkumpul: Value(terkumpul)));
  }

  Future<void> hapus(String id) =>
      (_db.delete(_db.financialGoals)..where((g) => g.id.equals(id))).go();
}

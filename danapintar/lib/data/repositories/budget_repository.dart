import '../local/database.dart';

/// Akses anggaran terkunci & target tabungan per bulan (SQLite lokal).
/// Map di-key dengan bulanKey ("Mei_2026").
class BudgetRepository {
  BudgetRepository(this._db);
  final AppDatabase _db;

  Stream<Map<String, int>> watchBudgets() =>
      _db.select(_db.budgets).watch().map(
            (rows) => {for (final r in rows) r.bulanKey: r.nominal},
          );

  Stream<Map<String, int>> watchTargets() =>
      _db.select(_db.savingsGoals).watch().map(
            (rows) => {for (final r in rows) r.bulanKey: r.targetNominal},
          );

  Future<void> kunciAnggaran(String bulanKey, int nominal) {
    return _db.into(_db.budgets).insertOnConflictUpdate(
          BudgetsCompanion.insert(bulanKey: bulanKey, nominal: nominal),
        );
  }

  Future<void> hapusAnggaran(String bulanKey) =>
      (_db.delete(_db.budgets)..where((b) => b.bulanKey.equals(bulanKey))).go();

  Future<void> setTarget(String bulanKey, int target) {
    return _db.into(_db.savingsGoals).insertOnConflictUpdate(
          SavingsGoalsCompanion.insert(
            bulanKey: bulanKey,
            targetNominal: target,
          ),
        );
  }

  Future<void> hapusTarget(String bulanKey) =>
      (_db.delete(_db.savingsGoals)..where((s) => s.bulanKey.equals(bulanKey)))
          .go();
}

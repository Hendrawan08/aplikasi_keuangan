import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'database.g.dart';

/// Database lokal SQLite (drift). Satu-satunya tempat data keuangan disimpan —
/// 100% di perangkat, tanpa cloud.
@DriftDatabase(
  tables: [
    Profiles,
    Budgets,
    SavingsGoals,
    BudgetKategori,
    CustomKategori,
    Wallets,
    FinancialGoals,
    NetworthHistory,
    Transaksi,
    Pemasukan,
    HutangPiutang,
    RecurringTemplates,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Konstruktor untuk pengujian (mis. in-memory database).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'danapintar.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

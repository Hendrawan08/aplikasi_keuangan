import 'dart:convert';

import 'package:drift/drift.dart';

import '../local/database.dart';

/// Ekspor/impor seluruh data ke/dari satu file JSON — jaring pengaman data
/// untuk arsitektur 100% lokal. Logika murni (tanpa plugin file/share) agar
/// dapat diuji.
class BackupService {
  BackupService(this._db);
  final AppDatabase _db;

  static const int schemaVersion = 1;

  /// Susun seluruh isi database menjadi string JSON ber-versi.
  Future<String> exportJson() async {
    final data = <String, dynamic>{
      'app': 'danapintar',
      'version': schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'tables': {
        'profiles':
            (await _db.select(_db.profiles).get()).map((e) => e.toJson()).toList(),
        'budgets':
            (await _db.select(_db.budgets).get()).map((e) => e.toJson()).toList(),
        'savings_goals': (await _db.select(_db.savingsGoals).get())
            .map((e) => e.toJson())
            .toList(),
        'budget_kategori': (await _db.select(_db.budgetKategori).get())
            .map((e) => e.toJson())
            .toList(),
        'custom_kategori': (await _db.select(_db.customKategori).get())
            .map((e) => e.toJson())
            .toList(),
        'wallets':
            (await _db.select(_db.wallets).get()).map((e) => e.toJson()).toList(),
        'financial_goals': (await _db.select(_db.financialGoals).get())
            .map((e) => e.toJson())
            .toList(),
        'networth_history': (await _db.select(_db.networthHistory).get())
            .map((e) => e.toJson())
            .toList(),
        'transaksi': (await _db.select(_db.transaksi).get())
            .map((e) => e.toJson())
            .toList(),
        'pemasukan': (await _db.select(_db.pemasukan).get())
            .map((e) => e.toJson())
            .toList(),
        'hutang_piutang': (await _db.select(_db.hutangPiutang).get())
            .map((e) => e.toJson())
            .toList(),
        'recurring_templates': (await _db.select(_db.recurringTemplates).get())
            .map((e) => e.toJson())
            .toList(),
      },
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Pulihkan database dari string JSON backup. Mengganti seluruh data lama.
  /// Melempar [FormatException] jika file tidak valid.
  Future<void> importJson(String jsonStr) async {
    final root = jsonDecode(jsonStr);
    if (root is! Map || root['app'] != 'danapintar') {
      throw const FormatException('File ini bukan backup DanaPintar yang valid.');
    }
    final tables = (root['tables'] as Map?)?.cast<String, dynamic>() ?? {};

    List<Map<String, dynamic>> rows(String key) =>
        ((tables[key] as List?) ?? const [])
            .map((e) => (e as Map).cast<String, dynamic>())
            .toList();

    await _db.transaction(() async {
      // Kosongkan seluruh tabel.
      await _db.delete(_db.transaksi).go();
      await _db.delete(_db.pemasukan).go();
      await _db.delete(_db.wallets).go();
      await _db.delete(_db.budgets).go();
      await _db.delete(_db.savingsGoals).go();
      await _db.delete(_db.budgetKategori).go();
      await _db.delete(_db.customKategori).go();
      await _db.delete(_db.financialGoals).go();
      await _db.delete(_db.networthHistory).go();
      await _db.delete(_db.hutangPiutang).go();
      await _db.delete(_db.recurringTemplates).go();
      await _db.delete(_db.profiles).go();

      // Isi ulang dari backup.
      for (final m in rows('profiles')) {
        await _db.into(_db.profiles).insert(Profile.fromJson(m),
            mode: InsertMode.insertOrReplace);
      }
      for (final m in rows('budgets')) {
        await _db.into(_db.budgets).insert(Budget.fromJson(m),
            mode: InsertMode.insertOrReplace);
      }
      for (final m in rows('savings_goals')) {
        await _db.into(_db.savingsGoals).insert(SavingsGoal.fromJson(m),
            mode: InsertMode.insertOrReplace);
      }
      for (final m in rows('budget_kategori')) {
        await _db.into(_db.budgetKategori).insert(
            BudgetKategoriData.fromJson(m),
            mode: InsertMode.insertOrReplace);
      }
      for (final m in rows('custom_kategori')) {
        await _db.into(_db.customKategori).insert(
            CustomKategoriData.fromJson(m),
            mode: InsertMode.insertOrReplace);
      }
      for (final m in rows('wallets')) {
        await _db.into(_db.wallets).insert(Wallet.fromJson(m),
            mode: InsertMode.insertOrReplace);
      }
      for (final m in rows('financial_goals')) {
        await _db.into(_db.financialGoals).insert(FinancialGoal.fromJson(m),
            mode: InsertMode.insertOrReplace);
      }
      for (final m in rows('networth_history')) {
        await _db.into(_db.networthHistory).insert(
            NetworthHistoryData.fromJson(m),
            mode: InsertMode.insertOrReplace);
      }
      for (final m in rows('transaksi')) {
        await _db.into(_db.transaksi).insert(TransaksiData.fromJson(m),
            mode: InsertMode.insertOrReplace);
      }
      for (final m in rows('pemasukan')) {
        await _db.into(_db.pemasukan).insert(PemasukanData.fromJson(m),
            mode: InsertMode.insertOrReplace);
      }
      for (final m in rows('hutang_piutang')) {
        await _db.into(_db.hutangPiutang).insert(HutangPiutangData.fromJson(m),
            mode: InsertMode.insertOrReplace);
      }
      for (final m in rows('recurring_templates')) {
        await _db.into(_db.recurringTemplates).insert(
            RecurringTemplate.fromJson(m),
            mode: InsertMode.insertOrReplace);
      }
    });
  }
}

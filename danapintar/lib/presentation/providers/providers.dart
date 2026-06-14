import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/backup/backup_service.dart';
import '../../data/local/database.dart';
import '../../data/repositories/budget_repository.dart';
import '../../data/repositories/pemasukan_repository.dart';
import '../../data/repositories/transaksi_repository.dart';
import '../../data/repositories/wallet_repository.dart';
import 'database_provider.dart';

// ── Repositories ──────────────────────────────────────────────
final transaksiRepoProvider = Provider(
  (ref) => TransaksiRepository(ref.watch(databaseProvider)),
);
final pemasukanRepoProvider = Provider(
  (ref) => PemasukanRepository(ref.watch(databaseProvider)),
);
final walletRepoProvider = Provider(
  (ref) => WalletRepository(ref.watch(databaseProvider)),
);
final budgetRepoProvider = Provider(
  (ref) => BudgetRepository(ref.watch(databaseProvider)),
);
final backupServiceProvider = Provider(
  (ref) => BackupService(ref.watch(databaseProvider)),
);

// ── Stream data (reaktif dari DB) ─────────────────────────────
final transaksiListProvider = StreamProvider<List<TransaksiData>>(
  (ref) => ref.watch(transaksiRepoProvider).watchAll(),
);
final pemasukanListProvider = StreamProvider<List<PemasukanData>>(
  (ref) => ref.watch(pemasukanRepoProvider).watchAll(),
);
final walletListProvider = StreamProvider<List<Wallet>>(
  (ref) => ref.watch(walletRepoProvider).watchAll(),
);
final budgetMapProvider = StreamProvider<Map<String, int>>(
  (ref) => ref.watch(budgetRepoProvider).watchBudgets(),
);
final targetMapProvider = StreamProvider<Map<String, int>>(
  (ref) => ref.watch(budgetRepoProvider).watchTargets(),
);

// ── Periode terpilih (bulan & tahun) ──────────────────────────
typedef Periode = ({int month, int year});

final selectedPeriodeProvider = StateProvider<Periode>((ref) {
  final now = DateTime.now();
  return (month: now.month, year: now.year);
});

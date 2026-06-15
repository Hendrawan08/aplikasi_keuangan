import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../data/ai/ai_service.dart';
import '../../data/backup/backup_service.dart';
import '../../data/local/database.dart';
import '../../data/repositories/budget_kategori_repository.dart';
import '../../data/repositories/budget_repository.dart';
import '../../data/repositories/custom_kategori_repository.dart';
import '../../data/repositories/goal_repository.dart';
import '../../data/repositories/hutang_repository.dart';
import '../../data/repositories/networth_repository.dart';
import '../../data/repositories/pemasukan_repository.dart';
import '../../data/repositories/recurring_repository.dart';
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
final goalRepoProvider = Provider(
  (ref) => GoalRepository(ref.watch(databaseProvider)),
);
final hutangRepoProvider = Provider(
  (ref) => HutangRepository(ref.watch(databaseProvider)),
);
final networthRepoProvider = Provider(
  (ref) => NetworthRepository(ref.watch(databaseProvider)),
);
final customKategoriRepoProvider = Provider(
  (ref) => CustomKategoriRepository(ref.watch(databaseProvider)),
);
final recurringRepoProvider = Provider(
  (ref) => RecurringRepository(ref.watch(databaseProvider)),
);
final budgetKategoriRepoProvider = Provider(
  (ref) => BudgetKategoriRepository(ref.watch(databaseProvider)),
);
final backupServiceProvider = Provider(
  (ref) => BackupService(ref.watch(databaseProvider)),
);
final aiServiceProvider = Provider((ref) => AiService());

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
final goalListProvider = StreamProvider<List<FinancialGoal>>(
  (ref) => ref.watch(goalRepoProvider).watchAll(),
);
final hutangListProvider = StreamProvider<List<HutangPiutangData>>(
  (ref) => ref.watch(hutangRepoProvider).watchAll(),
);
final networthListProvider = StreamProvider<List<NetworthHistoryData>>(
  (ref) => ref.watch(networthRepoProvider).watchAll(),
);
final customKategoriListProvider = StreamProvider<List<CustomKategoriData>>(
  (ref) => ref.watch(customKategoriRepoProvider).watchAll(),
);
final recurringListProvider = StreamProvider<List<RecurringTemplate>>(
  (ref) => ref.watch(recurringRepoProvider).watchAll(),
);
final budgetKategoriProvider = StreamProvider<Map<String, int>>((ref) {
  final sel = ref.watch(selectedPeriodeProvider);
  return ref
      .watch(budgetKategoriRepoProvider)
      .watchByBulan(bulanKey(sel.month, sel.year));
});

// Kategori gabungan: default + custom (dipakai dropdown form).
final kategoriPengeluaranProvider = Provider<List<String>>((ref) {
  final custom = ref.watch(customKategoriListProvider).value ?? const [];
  final extra = custom
      .where((k) => k.tipe == 'pengeluaran')
      .map((k) => k.nama)
      .where((n) => !kategoriPengeluaranDefault.contains(n));
  return [...kategoriPengeluaranDefault, ...extra];
});
final kategoriPemasukanProvider = Provider<List<String>>((ref) {
  final custom = ref.watch(customKategoriListProvider).value ?? const [];
  final extra = custom
      .where((k) => k.tipe == 'pemasukan')
      .map((k) => k.nama)
      .where((n) => !kategoriPemasukanDefault.contains(n));
  return [...kategoriPemasukanDefault, ...extra];
});

// ── Periode terpilih (bulan & tahun) ──────────────────────────
typedef Periode = ({int month, int year});

final selectedPeriodeProvider = StateProvider<Periode>((ref) {
  final now = DateTime.now();
  return (month: now.month, year: now.year);
});

// ── Onboarding ────────────────────────────────────────────────
const _kOnboardingKey = 'onboarding_done';

final onboardingDoneProvider = FutureProvider<bool>((ref) async {
  final p = await SharedPreferences.getInstance();
  return p.getBool(_kOnboardingKey) ?? false;
});

Future<void> selesaikanOnboarding(WidgetRef ref) async {
  final p = await SharedPreferences.getInstance();
  await p.setBool(_kOnboardingKey, true);
  ref.invalidate(onboardingDoneProvider);
}

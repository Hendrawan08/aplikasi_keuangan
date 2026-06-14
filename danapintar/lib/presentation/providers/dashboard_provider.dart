import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/formatters.dart';
import '../../data/local/database.dart';
import '../../data/mappers.dart';
import '../../domain/badges.dart';
import '../../domain/budget_rules.dart';
import '../../domain/health_score.dart';
import '../../domain/impulse_detector.dart';
import '../../domain/models.dart';
import '../../domain/monthly_analytics.dart';
import '../../domain/notifikasi.dart';
import 'providers.dart';

/// Ringkasan keuangan periode terpilih, hasil komputasi domain.
class DashboardData {
  final int totalPengeluaran;
  final int totalPemasukan;
  final int net;
  final int anggaran;
  final int target;
  final int batas;
  final int sisa;
  final int sukarela;
  final bool adaData;
  final HealthResult health;
  final HealthLabel label;
  final List<Badge> badges;
  final List<Notif> notifikasi;
  final Map<String, int> pengeluaranPerKategori;
  final List<TransaksiData> transaksiBulan;
  final List<PemasukanData> pemasukanBulan;

  const DashboardData({
    required this.totalPengeluaran,
    required this.totalPemasukan,
    required this.net,
    required this.anggaran,
    required this.target,
    required this.batas,
    required this.sisa,
    required this.sukarela,
    required this.adaData,
    required this.health,
    required this.label,
    required this.badges,
    required this.notifikasi,
    required this.pengeluaranPerKategori,
    required this.transaksiBulan,
    required this.pemasukanBulan,
  });
}

final dashboardProvider = Provider<DashboardData>((ref) {
  final sel = ref.watch(selectedPeriodeProvider);
  final allTx =
      ref.watch(transaksiListProvider).value ?? const <TransaksiData>[];
  final allPm =
      ref.watch(pemasukanListProvider).value ?? const <PemasukanData>[];
  final budgets = ref.watch(budgetMapProvider).value ?? const <String, int>{};
  final targets = ref.watch(targetMapProvider).value ?? const <String, int>{};

  final key = bulanKey(sel.month, sel.year);

  final txBulan = allTx
      .where(
        (t) =>
            t.waktuTransaksi.month == sel.month &&
            t.waktuTransaksi.year == sel.year,
      )
      .toList();
  final pmBulan = allPm
      .where(
        (p) =>
            p.waktuPemasukan.month == sel.month &&
            p.waktuPemasukan.year == sel.year,
      )
      .toList();

  final totalPglr = txBulan.fold<int>(0, (s, t) => s + t.nominal);
  final totalMsuk = pmBulan.fold<int>(0, (s, p) => s + p.nominal);

  final txViews = txBulan.toTxViews();
  final allViews = allTx.toTxViews();
  final sukarela = totalSukarela(txViews);

  final anggaran = budgets[key] ?? 0;
  final target = targets[key] ?? 0;
  final batas = batasBelanja(anggaran, target);

  final health = hitungHealthScore(
    totalPengeluaran: totalPglr,
    budget: anggaran,
    target: target,
    sukarela: sukarela,
    hariUnikCatat: hariUnikCatat(txViews),
    adaData: txViews.isNotEmpty,
    rataRataBulanLain: rataRataBulanLain(allViews, key),
  );

  final perKategori = <String, int>{};
  for (final t in txBulan) {
    perKategori[t.kategori] = (perKategori[t.kategori] ?? 0) + t.nominal;
  }

  return DashboardData(
    totalPengeluaran: totalPglr,
    totalPemasukan: totalMsuk,
    net: totalMsuk - totalPglr,
    anggaran: anggaran,
    target: target,
    batas: batas,
    sisa: sisaAnggaran(batas, totalPglr),
    sukarela: sukarela,
    adaData: txViews.isNotEmpty,
    health: health,
    label: labelHealth(health.total),
    badges: cekBadges(
      transaksi: allViews,
      budgetByMonth: budgets,
      targetByMonth: targets,
    ),
    notifikasi: generateNotifikasi(
      anggaranTerkunci: anggaran > 0,
      targetAda: target > 0,
      totalPengeluaran: totalPglr,
      batasBelanja: batas,
      belanjaJamRawan: totalBelanjaJamRawan(txViews),
      sukarelaBerlebihan: sukarelaBerlebihan(sukarela, anggaran),
    ),
    pengeluaranPerKategori: perKategori,
    transaksiBulan: txBulan,
    pemasukanBulan: pmBulan,
  );
});

/// Bungkus status loading/error dari sumber data agar dashboard bisa
/// membedakan "sedang memuat" / "gagal" dari "memang kosong".
final dashboardAsyncProvider = Provider<AsyncValue<DashboardData>>((ref) {
  final sources = <AsyncValue<dynamic>>[
    ref.watch(transaksiListProvider),
    ref.watch(pemasukanListProvider),
    ref.watch(budgetMapProvider),
    ref.watch(targetMapProvider),
  ];
  for (final s in sources) {
    if (s.hasError) {
      return AsyncValue.error(s.error!, s.stackTrace ?? StackTrace.current);
    }
  }
  if (sources.any((s) => s.isLoading && !s.hasValue)) {
    return const AsyncValue.loading();
  }
  return AsyncValue.data(ref.watch(dashboardProvider));
});

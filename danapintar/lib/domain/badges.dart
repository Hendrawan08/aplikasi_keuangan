import 'dart:math';

import 'models.dart';

/// Gamifikasi badge — port SETIA dari `cek_badges()` pada
/// `aplikasi_keuangan.py` (§6.5 dokumen rencana).
///
/// [budgetByMonth] & [targetByMonth] di-key dengan bulanKey ("Mei_2026").
List<Badge> cekBadges({
  required List<TxView> transaksi,
  required Map<String, int> budgetByMonth,
  required Map<String, int> targetByMonth,
}) {
  final badges = <Badge>[];
  if (transaksi.isEmpty) return badges;

  // 🗓️ Pencatat Setia — streak hari pencatatan ≥ 7 berturut-turut.
  final tanggal = transaksi.map((t) => t.tanggal).toSet().toList()..sort();
  int streak = 1, mx = 1;
  for (var i = 1; i < tanggal.length; i++) {
    if (tanggal[i].difference(tanggal[i - 1]).inDays == 1) {
      streak++;
      mx = max(mx, streak);
    } else {
      streak = 1;
    }
  }
  if (mx >= 7) {
    badges.add(Badge('🗓️', 'Pencatat Setia', 'Streak $mx hari berturut-turut'));
  }

  // 🏆 Penabung Konsisten — ≥ 2 bulan total ≤ (anggaran − target).
  int bh = 0;
  budgetByMonth.forEach((k, bud) {
    final tgt = targetByMonth[k] ?? 0;
    final bts = max(0, bud - tgt);
    final monthTxs = transaksi.where((t) => t.bulanKey == k);
    if (monthTxs.isNotEmpty &&
        monthTxs.fold(0, (s, t) => s + t.nominal) <= bts) {
      bh++;
    }
  });
  if (bh >= 2) {
    badges.add(Badge('🏆', 'Penabung Konsisten', '$bh bulan di bawah batas'));
  }

  // 🌈 Pengelola Lengkap — ≥ 5 kategori berbeda di bulan terakhir berdata.
  final sorted = [...transaksi]
    ..sort((a, b) => a.waktuWib.compareTo(b.waktuWib));
  final lastKey = sorted.last.bulanKey;
  final nk = transaksi
      .where((t) => t.bulanKey == lastKey)
      .map((t) => t.kategori)
      .toSet()
      .length;
  if (nk >= 5) {
    badges.add(Badge('🌈', 'Pengelola Lengkap', '$nk kategori berbeda'));
  }

  // 💎 Big Saver — target ≥ 20% anggaran & total ≤ (anggaran − target).
  for (final entry in budgetByMonth.entries) {
    final bud = entry.value;
    final tgt = targetByMonth[entry.key] ?? 0;
    if (bud > 0 && tgt / bud >= 0.2) {
      final monthTxs = transaksi.where((t) => t.bulanKey == entry.key);
      if (monthTxs.isNotEmpty &&
          monthTxs.fold(0, (s, t) => s + t.nominal) <= (bud - tgt)) {
        final namaBulan = entry.key.split('_').first;
        badges.add(Badge('💎', 'Big Saver', 'Target ≥20% di $namaBulan'));
        break;
      }
    }
  }

  return badges;
}

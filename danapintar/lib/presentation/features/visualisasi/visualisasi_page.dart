import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/providers.dart';
import '../../widgets/heatmap_calendar.dart';

/// Halaman visualisasi: heatmap kalender, komparatif, tren bulanan.
class VisualisasiPage extends ConsumerWidget {
  const VisualisasiPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sel = ref.watch(selectedPeriodeProvider);
    final tx = ref.watch(transaksiListProvider).value ?? const [];
    final pm = ref.watch(pemasukanListProvider).value ?? const [];

    // Pengeluaran per hari (bulan terpilih).
    final perHari = <int, int>{};
    for (final t in tx) {
      if (t.waktuTransaksi.month == sel.month &&
          t.waktuTransaksi.year == sel.year) {
        perHari[t.waktuTransaksi.day] =
            (perHari[t.waktuTransaksi.day] ?? 0) + t.nominal;
      }
    }

    // Komparatif bulan terpilih vs bulan sebelumnya.
    final prevMonth = sel.month == 1 ? 12 : sel.month - 1;
    final prevYear = sel.month == 1 ? sel.year - 1 : sel.year;
    int pglrBulan(int m, int y) => tx
        .where((t) => t.waktuTransaksi.month == m && t.waktuTransaksi.year == y)
        .fold<int>(0, (s, t) => s + t.nominal);
    final pglrNow = pglrBulan(sel.month, sel.year);
    final pglrPrev = pglrBulan(prevMonth, prevYear);
    final msukNow = pm
        .where(
          (p) =>
              p.waktuPemasukan.month == sel.month &&
              p.waktuPemasukan.year == sel.year,
        )
        .fold<int>(0, (s, p) => s + p.nominal);

    // Tren pengeluaran per bulan (semua data).
    final perBulan = <String, int>{};
    final urutan = <String>[];
    for (final t in [
      ...tx,
    ]..sort((a, b) => a.waktuTransaksi.compareTo(b.waktuTransaksi))) {
      final k = bulanKey(t.waktuTransaksi.month, t.waktuTransaksi.year);
      if (!perBulan.containsKey(k)) urutan.add(k);
      perBulan[k] = (perBulan[k] ?? 0) + t.nominal;
    }
    final maxBulan = perBulan.values.isEmpty
        ? 0
        : perBulan.values.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(title: const Text('📊 Visualisasi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _periodeSelector(ref, sel.month, sel.year),
          const SizedBox(height: 12),
          _card(
            '📅 Heatmap Pengeluaran — ${kamusBulan[sel.month]}',
            HeatmapCalendar(month: sel.month, year: sel.year, perHari: perHari),
          ),
          const SizedBox(height: 12),
          _card(
            '↔️ Komparatif Pengeluaran',
            Row(
              children: [
                Expanded(
                  child: _miniStat(
                    '${kamusBulan[prevMonth]}',
                    rp(pglrPrev),
                    AppColors.text2,
                  ),
                ),
                Expanded(
                  child: _miniStat(
                    '${kamusBulan[sel.month]}',
                    rp(pglrNow),
                    pglrNow > pglrPrev ? AppColors.expense : AppColors.accent,
                  ),
                ),
                Expanded(
                  child: _miniStat(
                    'Pemasukan ${kamusBulan[sel.month]}',
                    rp(msukNow),
                    AppColors.income,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _card(
            '📈 Tren Pengeluaran Bulanan',
            urutan.isEmpty
                ? const Text(
                    'Belum ada data.',
                    style: TextStyle(color: AppColors.text2),
                  )
                : Column(
                    children: urutan
                        .map(
                          (k) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      k.replaceAll('_', ' '),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      rp(perBulan[k]!),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: maxBulan == 0
                                        ? 0
                                        : perBulan[k]! / maxBulan,
                                    minHeight: 7,
                                    backgroundColor: AppColors.bg3,
                                    valueColor: const AlwaysStoppedAnimation(
                                      AppColors.expense,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _periodeSelector(WidgetRef ref, int month, int year) {
    void shift(int delta) {
      var m = month + delta;
      var y = year;
      if (m < 1) {
        m = 12;
        y--;
      } else if (m > 12) {
        m = 1;
        y++;
      }
      ref.read(selectedPeriodeProvider.notifier).state = (month: m, year: y);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => shift(-1),
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          '${kamusBulan[month]} $year',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        IconButton(
          onPressed: () => shift(1),
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _card(String title, Widget child) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.bg2,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );

  Widget _miniStat(String label, String value, Color color) => Column(
    children: [
      Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.text2, fontSize: 11),
      ),
      const SizedBox(height: 2),
      Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../providers/providers.dart';

/// Pemilih periode (bulan & tahun) bersama — dipakai dashboard & visualisasi.
class PeriodeSelector extends ConsumerWidget {
  const PeriodeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sel = ref.watch(selectedPeriodeProvider);

    void shift(int delta) {
      var m = sel.month + delta;
      var y = sel.year;
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
          '${kamusBulan[sel.month]} ${sel.year}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        IconButton(
          onPressed: () => shift(1),
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

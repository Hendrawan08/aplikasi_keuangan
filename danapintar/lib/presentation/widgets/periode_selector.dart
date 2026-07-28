import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../providers/providers.dart';

/// Pemilih periode (bulan & tahun) bersama — dipakai dashboard & visualisasi.
/// Ketuk label tengah untuk lompat cepat ke bulan/tahun mana pun.
class PeriodeSelector extends ConsumerWidget {
  const PeriodeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sel = ref.watch(selectedPeriodeProvider);

    void setPeriode(int m, int y) {
      ref.read(selectedPeriodeProvider.notifier).state = (month: m, year: y);
    }

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
      setPeriode(m, y);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton.filledTonal(
          onPressed: () => shift(-1),
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Bulan sebelumnya',
        ),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () async {
              final picked =
                  await showModalBottomSheet<({int month, int year})>(
                    context: context,
                    builder: (_) =>
                        _PeriodePickerSheet(month: sel.month, year: sel.year),
                  );
              if (picked != null) setPeriode(picked.month, picked.year);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.bg2,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.6),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.event, size: 18, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '${kamusBulan[sel.month]} ${sel.year}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: AppColors.text2),
                ],
              ),
            ),
          ),
        ),
        IconButton.filledTonal(
          onPressed: () => shift(1),
          icon: const Icon(Icons.chevron_right),
          tooltip: 'Bulan berikutnya',
        ),
      ],
    );
  }
}

/// Sheet pemilih bulan & tahun: stepper tahun + grid 12 bulan.
class _PeriodePickerSheet extends StatefulWidget {
  const _PeriodePickerSheet({required this.month, required this.year});
  final int month;
  final int year;

  @override
  State<_PeriodePickerSheet> createState() => _PeriodePickerSheetState();
}

class _PeriodePickerSheetState extends State<_PeriodePickerSheet> {
  late int _year = widget.year;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Pilih periode',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.pop(
                    context,
                    (month: now.month, year: now.year),
                  ),
                  icon: const Icon(Icons.today, size: 16),
                  label: const Text('Bulan ini'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Stepper tahun.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => setState(() => _year--),
                  icon: const Icon(Icons.chevron_left),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    '$_year',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _year < now.year + 1
                      ? () => setState(() => _year++)
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Grid 12 bulan.
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.3,
              children: List.generate(12, (i) {
                final m = i + 1;
                final selected = m == widget.month && _year == widget.year;
                final isFuture =
                    _year > now.year || (_year == now.year && m > now.month);
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.pop(context, (month: m, year: _year)),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.accent.withValues(alpha: 0.18)
                          : AppColors.bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? AppColors.accent : AppColors.border,
                      ),
                    ),
                    child: Text(
                      kamusBulan[m] ?? '$m',
                      style: TextStyle(
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                        color: selected
                            ? AppColors.accent
                            : (isFuture ? AppColors.text2 : AppColors.text),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

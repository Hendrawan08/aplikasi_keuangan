import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Heatmap kalender pengeluaran per hari dalam satu bulan.
class HeatmapCalendar extends StatelessWidget {
  const HeatmapCalendar({
    super.key,
    required this.month,
    required this.year,
    required this.perHari,
  });

  final int month;
  final int year;
  final Map<int, int> perHari; // hari (1..31) → total

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstWeekday = DateTime(year, month, 1).weekday; // 1=Sen..7=Min
    final maxVal = perHari.values.isEmpty ? 0 : perHari.values.reduce(max);

    const header = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final cells = <Widget>[
      for (final h in header)
        Center(
          child: Text(
            h,
            style: const TextStyle(
              color: AppColors.text2,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      // sel kosong sebelum tanggal 1
      for (var i = 1; i < firstWeekday; i++) const SizedBox.shrink(),
      // tanggal
      for (var d = 1; d <= daysInMonth; d++) _cell(d, maxVal),
    ];

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: cells,
    );
  }

  Widget _cell(int day, int maxVal) {
    final val = perHari[day] ?? 0;
    final intensity = maxVal == 0 ? 0.0 : (val / maxVal).clamp(0.0, 1.0);
    final color = val == 0
        ? AppColors.bg3
        : Color.lerp(
            AppColors.bg3,
            AppColors.expense,
            0.25 + intensity * 0.75,
          )!;
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        '$day',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: intensity > 0.5 ? Colors.white : AppColors.text2,
        ),
      ),
    );
  }
}

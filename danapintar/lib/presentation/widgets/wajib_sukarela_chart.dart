import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';

/// Donut perbandingan pengeluaran Wajib vs Sukarela.
class WajibSukarelaChart extends StatelessWidget {
  const WajibSukarelaChart({
    super.key,
    required this.wajib,
    required this.sukarela,
  });

  final int wajib;
  final int sukarela;

  @override
  Widget build(BuildContext context) {
    final total = wajib + sukarela;
    if (total == 0) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚖️ Wajib vs Sukarela',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 34,
                    sections: [
                      PieChartSectionData(
                        value: wajib.toDouble(),
                        color: AppColors.accent2,
                        title: '${(wajib / total * 100).round()}%',
                        radius: 26,
                        titleStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                      PieChartSectionData(
                        value: sukarela.toDouble(),
                        color: const Color(0xFFF59E0B),
                        title: '${(sukarela / total * 100).round()}%',
                        radius: 26,
                        titleStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Legend(
                        color: AppColors.accent2,
                        label: 'Wajib',
                        value: wajib),
                    const SizedBox(height: 8),
                    _Legend(
                        color: const Color(0xFFF59E0B),
                        label: 'Sukarela',
                        value: sukarela),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend(
      {required this.color, required this.label, required this.value});
  final Color color;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12)),
              Text(rp(value),
                  style: const TextStyle(
                      color: AppColors.text2, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

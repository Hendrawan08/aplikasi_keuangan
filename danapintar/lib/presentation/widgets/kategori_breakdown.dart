import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';

/// Rincian pengeluaran per kategori sebagai bar proporsi (terurut menurun).
class KategoriBreakdown extends StatelessWidget {
  const KategoriBreakdown({super.key, required this.perKategori});

  final Map<String, int> perKategori;

  @override
  Widget build(BuildContext context) {
    if (perKategori.isEmpty) return const SizedBox.shrink();
    final entries = perKategori.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maks = entries.first.value;

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
          const Text('📊 Pengeluaran per Kategori',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(e.key,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13)),
                        ),
                        Text(rp(e.value),
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: maks == 0 ? 0 : e.value / maks,
                        minHeight: 8,
                        backgroundColor: AppColors.bg3,
                        valueColor:
                            const AlwaysStoppedAnimation(AppColors.accent),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/form_utils.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/providers.dart';

/// Halaman anggaran per kategori — alokasi & realisasi pengeluaran.
class BudgetKategoriPage extends ConsumerWidget {
  const BudgetKategoriPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sel = ref.watch(selectedPeriodeProvider);
    final key = bulanKey(sel.month, sel.year);
    final budgets = ref.watch(budgetKategoriProvider).value ?? const {};
    final dash = ref.watch(dashboardProvider);
    final kategori = ref.watch(kategoriPengeluaranProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('📂 Budget Kategori · ${kamusBulan[sel.month]}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: kategori.map((kat) {
          final budget = budgets[kat] ?? 0;
          final spent = dash.pengeluaranPerKategori[kat] ?? 0;
          final pct = budget == 0 ? 0.0 : (spent / budget).clamp(0.0, 1.0);
          final over = budget > 0 && spent > budget;
          return Card(
            child: ListTile(
              title: Text(
                kat,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    budget == 0
                        ? 'Terpakai ${rp(spent)} · belum ada anggaran'
                        : 'Terpakai ${rp(spent)} / ${rp(budget)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: over ? AppColors.expense : AppColors.text2,
                    ),
                  ),
                  if (budget > 0) ...[
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 6,
                        backgroundColor: AppColors.bg3,
                        valueColor: AlwaysStoppedAnimation(
                          over ? AppColors.expense : AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => _atur(context, ref, key, kat, budget),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _atur(
    BuildContext context,
    WidgetRef ref,
    String key,
    String kategori,
    int current,
  ) async {
    final ctrl = TextEditingController(text: current == 0 ? '' : '$current');
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Anggaran $kategori'),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Anggaran (Rp)',
              prefixText: 'Rp ',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Simpan'),
            ),
          ],
        ),
      );
      if (ok == true) {
        await ref
            .read(budgetKategoriRepoProvider)
            .set(key, kategori, parseNominal(ctrl.text));
      }
    } finally {
      ctrl.dispose();
    }
  }
}

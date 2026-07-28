import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/form_utils.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/local/database.dart';
import '../../providers/providers.dart';
import '../../widgets/confirm_dialog.dart';

/// Halaman Financial Goals — target finansial dengan progress.
class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(goalListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('🎯 Financial Goals')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _tambahGoal(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Goal'),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (goals) {
          if (goals.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Belum ada goal.\nKetuk + untuk membuat target finansial.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(12),
            children: goals.map((g) => _GoalCard(g)).toList(),
          );
        },
      ),
    );
  }

  Future<void> _tambahGoal(BuildContext context, WidgetRef ref) async {
    final namaCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    var ikon = goalIkonList.first;
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => StatefulBuilder(
          builder: (context, setLocal) => AlertDialog(
            title: const Text('Goal Baru'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama goal',
                    hintText: 'Mis. Dana darurat',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: targetCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Target (Rp)',
                    prefixText: 'Rp ',
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: ikon,
                  decoration: const InputDecoration(labelText: 'Ikon'),
                  items: dropdownItems(goalIkonList),
                  onChanged: (v) => setLocal(() => ikon = v!),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Buat'),
              ),
            ],
          ),
        ),
      );
      if (ok == true &&
          namaCtrl.text.trim().isNotEmpty &&
          parseNominal(targetCtrl.text) > 0) {
        await ref
            .read(goalRepoProvider)
            .tambah(
              nama: namaCtrl.text.trim(),
              target: parseNominal(targetCtrl.text),
              ikon: ikon,
            );
      }
    } finally {
      namaCtrl.dispose();
      targetCtrl.dispose();
    }
  }
}

class _GoalCard extends ConsumerWidget {
  const _GoalCard(this.g);
  final FinancialGoal g;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pct = g.targetNominal == 0
        ? 0.0
        : (g.terkumpul / g.targetNominal).clamp(0.0, 1.0);
    final selesai = pct >= 1.0;
    return Card(
      child: InkWell(
        onTap: () => _updateTerkumpul(context, ref),
        onLongPress: () async {
          final ok = await konfirmasiHapus(
            context,
            judul: 'Hapus goal?',
            pesan: '"${g.nama}" akan dihapus.',
          );
          if (ok) await ref.read(goalRepoProvider).hapus(g.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(g.ikon, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      g.nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Text(
                    '${(pct * 100).round()}%',
                    style: TextStyle(
                      color: selesai ? AppColors.accent : AppColors.text2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 8,
                  backgroundColor: AppColors.bg3,
                  valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${rp(g.terkumpul)} / ${rp(g.targetNominal)}',
                style: const TextStyle(color: AppColors.text2, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateTerkumpul(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController(text: '${g.terkumpul}');
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Update "${g.nama}"'),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Terkumpul (Rp)',
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
            .read(goalRepoProvider)
            .setTerkumpul(g.id, parseNominal(ctrl.text));
      }
    } finally {
      ctrl.dispose();
    }
  }
}

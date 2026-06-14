import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/form_utils.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/providers.dart';

/// Halaman Net Worth — aset vs liabilitas + riwayat bulanan.
class NetWorthPage extends ConsumerWidget {
  const NetWorthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(networthListProvider);
    final now = DateTime.now();
    final key = bulanKey(now.month, now.year);

    return Scaffold(
      appBar: AppBar(title: const Text('💎 Net Worth')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          final cocok = list.where((n) => n.bulanKey == key).toList();
          final current = cocok.isEmpty ? null : cocok.first;
          final aset = current?.totalAset ?? 0;
          final liab = current?.totalLiabilitas ?? 0;
          final net = aset - liab;
          final riwayat = [...list]
            ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: AppColors.balanceGradient,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NET WORTH · ${kamusBulan[now.month]} ${now.year}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      rp(net),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '🟢 Aset\n${rp(aset)}',
                            style: const TextStyle(
                              color: AppColors.incomeSoft,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '🔴 Liabilitas\n${rp(liab)}',
                            style: const TextStyle(
                              color: AppColors.expenseSoft,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.edit, size: 16),
                label: Text(current == null ? 'Catat Net Worth' : 'Perbarui'),
                onPressed: () => _catat(context, ref, key, aset, liab),
              ),
              const SizedBox(height: 16),
              const Text(
                'Riwayat',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              if (riwayat.isEmpty)
                const Text(
                  'Belum ada riwayat.',
                  style: TextStyle(color: AppColors.text2),
                )
              else
                ...riwayat.map(
                  (n) => Card(
                    child: ListTile(
                      title: Text(n.bulanKey.replaceAll('_', ' ')),
                      subtitle: Text(
                        'Aset ${rp(n.totalAset)} · Liab ${rp(n.totalLiabilitas)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Text(
                        rp(n.totalAset - n.totalLiabilitas),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _catat(
    BuildContext context,
    WidgetRef ref,
    String key,
    int aset,
    int liab,
  ) async {
    final asetCtrl = TextEditingController(text: aset == 0 ? '' : '$aset');
    final liabCtrl = TextEditingController(text: liab == 0 ? '' : '$liab');
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Catat Net Worth'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: asetCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Total Aset (Rp)',
                  prefixText: 'Rp ',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: liabCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Total Liabilitas (Rp)',
                  prefixText: 'Rp ',
                ),
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
              child: const Text('Simpan'),
            ),
          ],
        ),
      );
      if (ok == true) {
        await ref
            .read(networthRepoProvider)
            .simpan(
              bulanKey: key,
              totalAset: parseNominal(asetCtrl.text),
              totalLiabilitas: parseNominal(liabCtrl.text),
            );
      }
    } finally {
      asetCtrl.dispose();
      liabCtrl.dispose();
    }
  }
}

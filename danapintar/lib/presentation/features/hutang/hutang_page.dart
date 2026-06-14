import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/form_utils.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/providers.dart';
import '../../widgets/confirm_dialog.dart';

/// Halaman pelacakan Hutang & Piutang.
class HutangPage extends ConsumerWidget {
  const HutangPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(hutangListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('💸 Hutang & Piutang')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _tambah(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Catat'),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Belum ada catatan hutang/piutang.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final h = list[i];
              final isHutang = h.tipe == 'hutang';
              final lunas = h.status == 'lunas';
              final warna = isHutang ? AppColors.expense : AppColors.income;
              return Card(
                child: ListTile(
                  onLongPress: () async {
                    final ok = await konfirmasiHapus(
                      context,
                      judul: 'Hapus catatan?',
                      pesan: '"${h.nama}" akan dihapus.',
                    );
                    if (ok) await ref.read(hutangRepoProvider).hapus(h.id);
                  },
                  leading: CircleAvatar(
                    backgroundColor: warna.withValues(alpha: 0.15),
                    child: Text(
                      isHutang ? '↙' : '↗',
                      style: TextStyle(
                        color: warna,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    h.nama,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      decoration: lunas ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text(
                    '${isHutang ? 'Hutang' : 'Piutang'} · ${rp(h.nominal)}',
                    style: const TextStyle(color: AppColors.text2),
                  ),
                  trailing: TextButton(
                    onPressed: () => ref
                        .read(hutangRepoProvider)
                        .setStatus(h.id, lunas ? 'belum' : 'lunas'),
                    child: Text(lunas ? '↩ Belum' : '✓ Lunas'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _tambah(BuildContext context, WidgetRef ref) async {
    final namaCtrl = TextEditingController();
    final nominalCtrl = TextEditingController();
    var tipe = 'hutang';
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => StatefulBuilder(
          builder: (context, setLocal) => AlertDialog(
            title: const Text('Catat Hutang/Piutang'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'hutang', label: Text('Hutang')),
                    ButtonSegment(value: 'piutang', label: Text('Piutang')),
                  ],
                  selected: {tipe},
                  onSelectionChanged: (s) => setLocal(() => tipe = s.first),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: namaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama / keterangan',
                    hintText: 'Mis. Pinjam ke Budi',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nominalCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Nominal (Rp)',
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
        ),
      );
      if (ok == true &&
          namaCtrl.text.trim().isNotEmpty &&
          parseNominal(nominalCtrl.text) > 0) {
        await ref
            .read(hutangRepoProvider)
            .tambah(
              tipe: tipe,
              nama: namaCtrl.text.trim(),
              nominal: parseNominal(nominalCtrl.text),
              tanggal: DateTime.now(),
            );
      }
    } finally {
      namaCtrl.dispose();
      nominalCtrl.dispose();
    }
  }
}

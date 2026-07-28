import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/form_utils.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/providers.dart';
import '../../widgets/confirm_dialog.dart';

/// Halaman template transaksi berulang.
class RecurringPage extends ConsumerWidget {
  const RecurringPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(recurringListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('🔄 Transaksi Berulang')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _tambah(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Template'),
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
                  'Belum ada template.\nBuat untuk transaksi rutin '
                  '(mis. langganan, cicilan).',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final r = list[i];
              return Card(
                child: ListTile(
                  onLongPress: () async {
                    final ok = await konfirmasiHapus(
                      context,
                      judul: 'Hapus template?',
                      pesan: '"${r.catatan}" akan dihapus.',
                    );
                    if (ok) await ref.read(recurringRepoProvider).hapus(r.id);
                  },
                  title: Text(
                    r.catatan,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${r.kategori} · ${r.frekuensi} · ${rp(r.nominal)}',
                    style: const TextStyle(
                      color: AppColors.text2,
                      fontSize: 12,
                    ),
                  ),
                  trailing: FilledButton.tonal(
                    onPressed: () async {
                      await ref
                          .read(transaksiRepoProvider)
                          .tambah(
                            catatan: r.catatan,
                            nominal: r.nominal,
                            kategori: r.kategori,
                            sifat: r.sifat,
                            waktu: DateTime.now(),
                          );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('✅ "${r.catatan}" dicatat')),
                        );
                      }
                    },
                    child: const Text('Terapkan'),
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
    final catatanCtrl = TextEditingController();
    final nominalCtrl = TextEditingController();
    var kategori = kategoriPengeluaranDefault.first;
    var sifat = 'Wajib';
    var frekuensi = frekuensiBerulang.first;
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => StatefulBuilder(
          builder: (context, setLocal) => AlertDialog(
            title: const Text('Template Baru'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: catatanCtrl,
                    decoration: const InputDecoration(labelText: 'Catatan'),
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
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: kategori,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    items: dropdownItems(kategoriPengeluaranDefault),
                    onChanged: (v) => setLocal(() => kategori = v!),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: frekuensi,
                    decoration: const InputDecoration(labelText: 'Frekuensi'),
                    items: dropdownItems(frekuensiBerulang),
                    onChanged: (v) => setLocal(() => frekuensi = v!),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: sifatList
                        .map((s) => ButtonSegment(value: s, label: Text(s)))
                        .toList(),
                    selected: {sifat},
                    onSelectionChanged: (s) => setLocal(() => sifat = s.first),
                  ),
                ],
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
        ),
      );
      if (ok == true &&
          catatanCtrl.text.trim().isNotEmpty &&
          parseNominal(nominalCtrl.text) > 0) {
        await ref
            .read(recurringRepoProvider)
            .tambah(
              catatan: catatanCtrl.text.trim(),
              nominal: parseNominal(nominalCtrl.text),
              kategori: kategori,
              sifat: sifat,
              frekuensi: frekuensi,
            );
      }
    } finally {
      catatanCtrl.dispose();
      nominalCtrl.dispose();
    }
  }
}

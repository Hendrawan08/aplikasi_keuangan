import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/local/database.dart';
import '../../providers/providers.dart';

/// Halaman kelola kategori custom (pengeluaran & pemasukan).
class KategoriPage extends ConsumerWidget {
  const KategoriPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(customKategoriListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('🏷️ Custom Kategori')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (all) {
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _Section(
                judul: 'Pengeluaran',
                tipe: 'pengeluaran',
                defaults: kategoriPengeluaranDefault,
                custom: all.where((k) => k.tipe == 'pengeluaran').toList(),
              ),
              const SizedBox(height: 12),
              _Section(
                judul: 'Pemasukan',
                tipe: 'pemasukan',
                defaults: kategoriPemasukanDefault,
                custom: all.where((k) => k.tipe == 'pemasukan').toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Section extends ConsumerWidget {
  const _Section({
    required this.judul,
    required this.tipe,
    required this.defaults,
    required this.custom,
  });
  final String judul;
  final String tipe;
  final List<String> defaults;
  final List<CustomKategoriData> custom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            judul,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Default:',
            style: TextStyle(color: AppColors.text2, fontSize: 12),
          ),
          Wrap(
            spacing: 6,
            children: defaults
                .map(
                  (d) => Chip(
                    label: Text(d, style: const TextStyle(fontSize: 12)),
                    backgroundColor: AppColors.bg,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          const Text(
            'Custom:',
            style: TextStyle(color: AppColors.text2, fontSize: 12),
          ),
          if (custom.isEmpty)
            const Text(
              'Belum ada.',
              style: TextStyle(color: AppColors.text2, fontSize: 12),
            )
          else
            Wrap(
              spacing: 6,
              children: custom
                  .map(
                    (k) => Chip(
                      avatar: Text(k.ikon),
                      label: Text(k.nama, style: const TextStyle(fontSize: 12)),
                      backgroundColor: AppColors.bg,
                      side: const BorderSide(color: AppColors.accent),
                      onDeleted: () =>
                          ref.read(customKategoriRepoProvider).hapus(k.id),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.add, size: 16),
            label: Text('Tambah kategori $judul'),
            onPressed: () => _tambah(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _tambah(BuildContext context, WidgetRef ref) async {
    final namaCtrl = TextEditingController();
    final ikonCtrl = TextEditingController(text: '📌');
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Kategori $judul Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaCtrl,
                decoration: const InputDecoration(labelText: 'Nama kategori'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: ikonCtrl,
                decoration: const InputDecoration(labelText: 'Ikon (emoji)'),
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
              child: const Text('Tambah'),
            ),
          ],
        ),
      );
      final nama = namaCtrl.text.trim();
      if (ok == true &&
          nama.isNotEmpty &&
          !defaults.contains(nama) &&
          !custom.any((k) => k.nama == nama)) {
        await ref
            .read(customKategoriRepoProvider)
            .tambah(
              nama: nama,
              tipe: tipe,
              ikon: ikonCtrl.text.trim().isEmpty ? '📌' : ikonCtrl.text.trim(),
            );
      }
    } finally {
      namaCtrl.dispose();
      ikonCtrl.dispose();
    }
  }
}

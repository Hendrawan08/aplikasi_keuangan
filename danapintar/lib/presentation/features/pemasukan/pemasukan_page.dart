import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../../widgets/tx_tile.dart';

/// Daftar pemasukan dengan hapus.
class PemasukanPage extends ConsumerWidget {
  const PemasukanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(pemasukanListProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (list) {
        if (list.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('Belum ada pemasukan.\nKetuk + untuk mencatat.',
                  textAlign: TextAlign.center),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: list.length,
          itemBuilder: (context, i) {
            final p = list[i];
            return TxTile(
              judul: p.sumber,
              subtitle: p.kategori,
              nominal: p.nominal,
              waktu: p.waktuPemasukan,
              isExpense: false,
              onLongPress: () => _konfirmasiHapus(context, ref, p.id, p.sumber),
            );
          },
        );
      },
    );
  }

  Future<void> _konfirmasiHapus(
      BuildContext context, WidgetRef ref, String id, String nama) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus pemasukan?'),
        content: Text('"$nama" akan dihapus permanen.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(pemasukanRepoProvider).hapus(id);
    }
  }
}

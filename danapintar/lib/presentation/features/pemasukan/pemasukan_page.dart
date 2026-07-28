import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../../widgets/confirm_dialog.dart';
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
              child: Text(
                'Belum ada pemasukan.\nKetuk + untuk mencatat.',
                textAlign: TextAlign.center,
              ),
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
              onLongPress: () async {
                final ok = await konfirmasiHapus(
                  context,
                  judul: 'Hapus pemasukan?',
                  pesan: '"${p.sumber}" akan dihapus permanen.',
                );
                if (ok) await ref.read(pemasukanRepoProvider).hapus(p.id);
              },
            );
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../../widgets/tx_tile.dart';
import 'transaksi_form_page.dart';

/// Daftar seluruh transaksi pengeluaran dengan edit & hapus.
class TransaksiPage extends ConsumerWidget {
  const TransaksiPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(transaksiListProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (list) {
        if (list.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('Belum ada pengeluaran.\nKetuk + untuk mencatat.',
                  textAlign: TextAlign.center),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: list.length,
          itemBuilder: (context, i) {
            final t = list[i];
            return TxTile(
              judul: t.catatan,
              subtitle: '${t.kategori} · ${t.sifat}',
              nominal: t.nominal,
              waktu: t.waktuTransaksi,
              isExpense: true,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => TransaksiFormPage(
                  existing: TransaksiExisting(
                    id: t.id,
                    catatan: t.catatan,
                    nominal: t.nominal,
                    kategori: t.kategori,
                    sifat: t.sifat,
                    waktu: t.waktuTransaksi,
                  ),
                ),
              )),
              onLongPress: () => _konfirmasiHapus(context, ref, t.id, t.catatan),
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
        title: const Text('Hapus transaksi?'),
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
      await ref.read(transaksiRepoProvider).hapus(id);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/providers.dart';

/// Pengaturan: anggaran terkunci, target tabungan, dan dompet.
class PengaturanPage extends ConsumerWidget {
  const PengaturanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sel = ref.watch(selectedPeriodeProvider);
    final key = bulanKey(sel.month, sel.year);
    final anggaran = (ref.watch(budgetMapProvider).value ?? {})[key] ?? 0;
    final target = (ref.watch(targetMapProvider).value ?? {})[key] ?? 0;
    final wallets = ref.watch(walletListProvider).value ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Card(
          title: '🔒 Anggaran & Target — ${kamusBulan[sel.month]} ${sel.year}',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _kv('Anggaran terkunci', rp(anggaran)),
              _kv('Target tabungan', rp(target)),
              _kv('Batas belanja', rp((anggaran - target).clamp(0, 1 << 62))),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Atur'),
                  onPressed: () => _aturAnggaran(
                      context, ref, key, anggaran, target),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Card(
          title: '👛 Dompet',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (wallets.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Belum ada dompet.',
                      style: TextStyle(color: AppColors.text2)),
                )
              else
                ...wallets.map((w) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text('${w.tipe} ${w.nama}'),
                      subtitle: Text('Saldo awal: ${rp(w.saldoAwal)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.expense),
                        onPressed: () =>
                            ref.read(walletRepoProvider).hapus(w.id),
                      ),
                    )),
              const SizedBox(height: 4),
              OutlinedButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Tambah Dompet'),
                onPressed: () => _tambahDompet(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k, style: const TextStyle(color: AppColors.text2)),
            Text(v, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      );

  Future<void> _aturAnggaran(BuildContext context, WidgetRef ref, String key,
      int anggaran, int target) async {
    final aCtrl = TextEditingController(text: anggaran == 0 ? '' : '$anggaran');
    final tCtrl = TextEditingController(text: target == 0 ? '' : '$target');
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Atur Anggaran & Target'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: aCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                  labelText: 'Anggaran (Rp)', prefixText: 'Rp '),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: tCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                  labelText: 'Target Tabungan (Rp)', prefixText: 'Rp '),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Simpan')),
        ],
      ),
    );
    if (ok == true) {
      final repo = ref.read(budgetRepoProvider);
      final a = int.tryParse(aCtrl.text) ?? 0;
      final t = int.tryParse(tCtrl.text) ?? 0;
      if (a > 0) {
        await repo.kunciAnggaran(key, a);
      } else {
        await repo.hapusAnggaran(key);
      }
      if (t > 0) {
        await repo.setTarget(key, t);
      } else {
        await repo.hapusTarget(key);
      }
    }
  }

  Future<void> _tambahDompet(BuildContext context, WidgetRef ref) async {
    final namaCtrl = TextEditingController();
    var tipe = tipeWallet.first;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('Tambah Dompet'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaCtrl,
                decoration: const InputDecoration(labelText: 'Nama dompet'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: tipe,
                decoration: const InputDecoration(labelText: 'Tipe'),
                items: tipeWallet
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setLocal(() => tipe = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal')),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Tambah')),
          ],
        ),
      ),
    );
    if (ok == true && namaCtrl.text.trim().isNotEmpty) {
      await ref
          .read(walletRepoProvider)
          .tambah(nama: namaCtrl.text.trim(), tipe: tipe);
    }
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
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
          Text(title,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

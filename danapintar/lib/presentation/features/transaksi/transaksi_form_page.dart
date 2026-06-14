import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/form_utils.dart';
import '../../providers/providers.dart';

/// Form catat / edit transaksi pengeluaran.
class TransaksiFormPage extends ConsumerStatefulWidget {
  const TransaksiFormPage({super.key, this.existing});

  /// Bila diisi, form dalam mode edit.
  final TransaksiExisting? existing;

  @override
  ConsumerState<TransaksiFormPage> createState() => _TransaksiFormPageState();
}

/// Data minimal untuk mode edit.
class TransaksiExisting {
  final String id;
  final String catatan;
  final int nominal;
  final String kategori;
  final String sifat;
  final DateTime waktu;
  final String? walletId;
  const TransaksiExisting({
    required this.id,
    required this.catatan,
    required this.nominal,
    required this.kategori,
    required this.sifat,
    required this.waktu,
    this.walletId,
  });
}

class _TransaksiFormPageState extends ConsumerState<TransaksiFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _catatan;
  late final TextEditingController _nominal;
  late String _kategori;
  late String _sifat;
  late DateTime _tanggal;
  late TimeOfDay _waktu;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _catatan = TextEditingController(text: e?.catatan ?? '');
    _nominal = TextEditingController(text: e == null ? '' : '${e.nominal}');
    _kategori = e?.kategori ?? kategoriPengeluaranDefault.first;
    _sifat = e?.sifat ?? 'Wajib';
    _tanggal = e?.waktu ?? DateTime.now();
    _waktu = TimeOfDay.fromDateTime(e?.waktu ?? DateTime.now());
  }

  @override
  void dispose() {
    _catatan.dispose();
    _nominal.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    final nominal = parseNominal(_nominal.text);
    final waktu = DateTime(
      _tanggal.year,
      _tanggal.month,
      _tanggal.day,
      _waktu.hour,
      _waktu.minute,
    );
    final repo = ref.read(transaksiRepoProvider);
    final e = widget.existing;
    try {
      if (e == null) {
        await repo.tambah(
          catatan: _catatan.text.trim(),
          nominal: nominal,
          kategori: _kategori,
          sifat: _sifat,
          waktu: waktu,
        );
      } else {
        await repo.ubah(
          id: e.id,
          catatan: _catatan.text.trim(),
          nominal: nominal,
          kategori: _kategori,
          sifat: _sifat,
          waktu: waktu,
          walletId: e.walletId, // pertahankan kaitan dompet saat edit
        );
      }
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Gagal menyimpan: $err')));
      }
      return;
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Pengeluaran' : 'Catat Pengeluaran'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _catatan,
              decoration: const InputDecoration(
                labelText: 'Catatan',
                hintText: 'Mis. Makan siang',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nominal,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Nominal (Rp)',
                prefixText: 'Rp ',
              ),
              validator: validatorNominal,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _kategori,
              decoration: const InputDecoration(labelText: 'Kategori'),
              items: dropdownItems(kategoriPengeluaranDefault),
              onChanged: (v) => setState(() => _kategori = v!),
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: sifatList
                  .map((s) => ButtonSegment(value: s, label: Text(s)))
                  .toList(),
              selected: {_sifat},
              onSelectionChanged: (sel) => setState(() => _sifat = sel.first),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      '${_tanggal.day} ${kamusBulan[_tanggal.month]} ${_tanggal.year}',
                    ),
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _tanggal,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (d != null) setState(() => _tanggal = d);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.access_time, size: 16),
                    label: Text(_waktu.format(context)),
                    onPressed: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: _waktu,
                      );
                      if (t != null) setState(() => _waktu = t);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _simpan,
              child: Text(isEdit ? 'Simpan Perubahan' : 'Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

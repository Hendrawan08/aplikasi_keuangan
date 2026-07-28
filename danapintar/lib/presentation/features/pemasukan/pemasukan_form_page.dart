import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/form_utils.dart';
import '../../providers/providers.dart';

/// Form catat pemasukan.
class PemasukanFormPage extends ConsumerStatefulWidget {
  const PemasukanFormPage({super.key});

  @override
  ConsumerState<PemasukanFormPage> createState() => _PemasukanFormPageState();
}

class _PemasukanFormPageState extends ConsumerState<PemasukanFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _sumber = TextEditingController();
  final _nominal = TextEditingController();
  String _kategori = kategoriPemasukanDefault.first;
  DateTime _tanggal = DateTime.now();

  @override
  void dispose() {
    _sumber.dispose();
    _nominal.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    final nominal = parseNominal(_nominal.text);
    final now = DateTime.now();
    final waktu = DateTime(
      _tanggal.year,
      _tanggal.month,
      _tanggal.day,
      now.hour,
      now.minute,
    );
    try {
      await ref
          .read(pemasukanRepoProvider)
          .tambah(
            sumber: _sumber.text.trim(),
            nominal: nominal,
            kategori: _kategori,
            waktu: waktu,
          );
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
    final kategoriList = ref.watch(kategoriPemasukanProvider);
    final kategoriItems = kategoriList.contains(_kategori)
        ? kategoriList
        : [_kategori, ...kategoriList];
    return Scaffold(
      appBar: AppBar(title: const Text('Catat Pemasukan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _sumber,
              decoration: const InputDecoration(
                labelText: 'Sumber',
                hintText: 'Mis. Gaji Juni',
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
              items: dropdownItems(kategoriItems),
              onChanged: (v) => setState(() => _kategori = v!),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
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
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _simpan, child: const Text('Simpan')),
          ],
        ),
      ),
    );
  }
}

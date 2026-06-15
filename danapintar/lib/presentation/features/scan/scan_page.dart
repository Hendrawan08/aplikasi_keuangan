import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/config/ai_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/form_utils.dart';
import '../../providers/providers.dart';
import '../../widgets/ai_belum_siap.dart';

/// Scan struk: foto → Gemini Vision (via Edge Function) → preview/edit → simpan.
class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
  bool _busy = false;
  String? _error;
  bool _preview = false;

  final _namaCtrl = TextEditingController();
  final _nominalCtrl = TextEditingController();
  String _kategori = kategoriPengeluaranDefault.first;
  String _sifat = 'Sukarela';
  DateTime _tanggal = DateTime.now();

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nominalCtrl.dispose();
    super.dispose();
  }

  Future<void> _scan(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 1600,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
      _preview = false;
    });
    try {
      final bytes = await picked.readAsBytes();
      final res = await ref
          .read(aiServiceProvider)
          .scanStruk(
            base64Image: base64Encode(bytes),
            mimeType: picked.mimeType ?? 'image/jpeg',
          );
      if (!mounted) return;
      if (res['berhasil'] == true) {
        _namaCtrl.text = (res['nama_transaksi'] ?? res['nama_toko'] ?? '')
            .toString();
        _nominalCtrl.text = '${(res['total'] as num?)?.toInt() ?? 0}';
        final kat = res['kategori_saran']?.toString();
        if (kat != null && kategoriPengeluaranDefault.contains(kat)) {
          _kategori = kat;
        }
        _tanggal =
            DateTime.tryParse(res['tanggal']?.toString() ?? '') ??
            DateTime.now();
        setState(() => _preview = true);
      } else {
        setState(
          () => _error =
              res['gagal_alasan']?.toString() ?? 'Gagal membaca struk.',
        );
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _simpan() async {
    final nominal = parseNominal(_nominalCtrl.text);
    if (_namaCtrl.text.trim().isEmpty || nominal <= 0) {
      setState(() => _error = 'Nama & nominal wajib valid.');
      return;
    }
    final waktu = DateTime(_tanggal.year, _tanggal.month, _tanggal.day, 12);
    try {
      await ref
          .read(transaksiRepoProvider)
          .tambah(
            catatan: _namaCtrl.text.trim(),
            nominal: nominal,
            kategori: _kategori,
            sifat: _sifat,
            waktu: waktu,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('📸 Transaksi dari struk disimpan!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Gagal simpan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AiConfig.configured) {
      return Scaffold(
        appBar: AppBar(title: const Text('📸 Scan Struk')),
        body: const AiBelumSiap(),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('📸 Scan Struk')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Foto struk → AI baca otomatis (toko, total, kategori) → '
            'cek & simpan.',
            style: TextStyle(color: AppColors.text2, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _busy ? null : () => _scan(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Kamera'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : () => _scan(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galeri'),
                ),
              ),
            ],
          ),
          if (_busy) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 8),
            const Center(child: Text('AI membaca struk…')),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              '⚠️ $_error',
              style: const TextStyle(color: AppColors.expense),
            ),
          ],
          if (_preview) ...[
            const SizedBox(height: 16),
            const Text(
              'Hasil baca AI — cek & edit bila perlu:',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _namaCtrl,
              decoration: const InputDecoration(labelText: 'Nama transaksi'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nominalCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Total (Rp)',
                prefixText: 'Rp ',
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _kategori,
              decoration: const InputDecoration(labelText: 'Kategori'),
              items: dropdownItems(kategoriPengeluaranDefault),
              onChanged: (v) => setState(() => _kategori = v!),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: sifatList
                  .map((s) => ButtonSegment(value: s, label: Text(s)))
                  .toList(),
              selected: {_sifat},
              onSelectionChanged: (s) => setState(() => _sifat = s.first),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _simpan, child: const Text('Simpan')),
          ],
        ],
      ),
    );
  }
}

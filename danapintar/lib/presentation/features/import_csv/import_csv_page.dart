import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/form_utils.dart';
import '../../providers/providers.dart';

/// Import transaksi massal dari file CSV mutasi bank.
class ImportCsvPage extends ConsumerStatefulWidget {
  const ImportCsvPage({super.key});

  @override
  ConsumerState<ImportCsvPage> createState() => _ImportCsvPageState();
}

class _ImportCsvPageState extends ConsumerState<ImportCsvPage> {
  List<List<dynamic>>? _rows;
  List<String> _headers = [];
  int? _tglIdx;
  int? _deskIdx;
  int? _nomIdx;
  final _formatCtrl = TextEditingController(text: 'dd/MM/yyyy');
  String _kategori = kategoriPengeluaranDefault.last;
  String _sifat = 'Wajib';
  bool _busy = false;

  @override
  void dispose() {
    _formatCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );
    final bytes = res?.files.single.bytes;
    if (bytes == null) return;

    var content = utf8.decode(bytes, allowMalformed: true);
    content = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    // Deteksi pemisah sederhana (',' atau ';').
    final sep = content.split('\n').first.contains(';') ? ';' : ',';
    final parsed = CsvDecoder(fieldDelimiter: sep).convert(content);
    final clean = parsed.where((r) => r.isNotEmpty).toList();
    if (clean.length < 2) {
      _snack('❌ CSV tidak terbaca atau kosong.');
      return;
    }
    setState(() {
      _rows = clean;
      _headers = clean.first.map((e) => e.toString().trim()).toList();
      _tglIdx = null;
      _deskIdx = null;
      _nomIdx = null;
    });
  }

  Future<void> _import() async {
    if (_rows == null ||
        _tglIdx == null ||
        _deskIdx == null ||
        _nomIdx == null) {
      _snack('Pilih kolom Tanggal, Deskripsi, dan Nominal dulu.');
      return;
    }
    setState(() => _busy = true);
    final fmt = DateFormat(_formatCtrl.text.trim());
    final repo = ref.read(transaksiRepoProvider);
    var ok = 0, gagal = 0;
    for (final row in _rows!.skip(1)) {
      try {
        final tglStr = row[_tglIdx!].toString().trim();
        final nominal = parseNominal(row[_nomIdx!].toString());
        final desk = row[_deskIdx!].toString().trim();
        if (nominal <= 0 || desk.isEmpty) {
          gagal++;
          continue;
        }
        final tgl = fmt.parseStrict(tglStr);
        await repo.tambah(
          catatan: desk.length > 200 ? desk.substring(0, 200) : desk,
          nominal: nominal,
          kategori: _kategori,
          sifat: _sifat,
          waktu: DateTime(tgl.year, tgl.month, tgl.day, 12),
        );
        ok++;
      } catch (_) {
        gagal++;
      }
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _rows = null;
    });
    _snack('✅ $ok transaksi diimport${gagal > 0 ? ', $gagal dilewati' : ''}.');
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📥 Import CSV')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Import transaksi dari file CSV mutasi bank (BCA, Mandiri, dll). '
            'Pilih file, cocokkan kolom, lalu import.',
            style: TextStyle(color: AppColors.text2, fontSize: 13),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.upload_file, size: 16),
            label: const Text('Pilih File CSV'),
            onPressed: _busy ? null : _pick,
          ),
          if (_rows != null) ...[
            const SizedBox(height: 16),
            Text(
              'Terbaca ${_rows!.length - 1} baris, ${_headers.length} kolom.',
              style: const TextStyle(color: AppColors.text2, fontSize: 12),
            ),
            const SizedBox(height: 12),
            _kolomDropdown('📅 Kolom Tanggal', _tglIdx, (v) => _tglIdx = v),
            _kolomDropdown('📝 Kolom Deskripsi', _deskIdx, (v) => _deskIdx = v),
            _kolomDropdown('💰 Kolom Nominal', _nomIdx, (v) => _nomIdx = v),
            const SizedBox(height: 8),
            TextField(
              controller: _formatCtrl,
              decoration: const InputDecoration(
                labelText: 'Format Tanggal',
                hintText: 'dd/MM/yyyy',
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _kategori,
              decoration: const InputDecoration(labelText: 'Kategori default'),
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
            FilledButton.icon(
              icon: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download),
              label: const Text('Import Sekarang'),
              onPressed: _busy ? null : _import,
            ),
          ],
        ],
      ),
    );
  }

  Widget _kolomDropdown(String label, int? value, void Function(int?) onSet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DropdownButtonFormField<int>(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        items: [
          for (var i = 0; i < _headers.length; i++)
            DropdownMenuItem(value: i, child: Text(_headers[i])),
        ],
        onChanged: (v) => setState(() => onSet(v)),
      ),
    );
  }
}

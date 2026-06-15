import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/providers.dart';

/// Halaman generate laporan keuangan PDF (bulan terpilih).
class LaporanPage extends ConsumerWidget {
  const LaporanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sel = ref.watch(selectedPeriodeProvider);
    final data = ref.watch(dashboardProvider);
    final periode = '${kamusBulan[sel.month]} ${sel.year}';
    // Pastikan data sudah termuat agar PDF tidak berisi angka nol palsu.
    final ready =
        ref.watch(transaksiListProvider).hasValue &&
        ref.watch(pemasukanListProvider).hasValue;

    return Scaffold(
      appBar: AppBar(title: const Text('📄 Laporan PDF')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bg2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ringkasan $periode',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                _row('Pemasukan', rp(data.totalPemasukan)),
                _row('Pengeluaran', rp(data.totalPengeluaran)),
                _row('Net Cash Flow', rp(data.net)),
                _row('Health Score', '${data.health.total}/100'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.picture_as_pdf),
            label: Text(ready ? 'Buat & Bagikan PDF' : 'Memuat data…'),
            onPressed: ready ? () => _buatPdf(context, periode, data) : null,
          ),
        ],
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: const TextStyle(color: AppColors.text2)),
        Text(v, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );

  Future<void> _buatPdf(
    BuildContext context,
    String periode,
    DashboardData data,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final doc = pw.Document();
      final kategori = data.pengeluaranPerKategori.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // MultiPage agar tabel kategori panjang otomatis berpindah halaman.
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (ctx) => [
            pw.Text(
              'DanaPintar AI — Laporan Keuangan',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(periode, style: const pw.TextStyle(fontSize: 12)),
            pw.Divider(),
            pw.SizedBox(height: 8),
            _pdfRow('Pemasukan', rp(data.totalPemasukan)),
            _pdfRow('Pengeluaran', rp(data.totalPengeluaran)),
            _pdfRow('Net Cash Flow', rp(data.net)),
            _pdfRow('Anggaran', rp(data.anggaran)),
            _pdfRow('Target Tabungan', rp(data.target)),
            _pdfRow('Batas Belanja', rp(data.batas)),
            _pdfRow('Sisa Anggaran', rp(data.sisa)),
            _pdfRow('Health Score', '${data.health.total}/100'),
            pw.SizedBox(height: 12),
            pw.Text(
              'Pengeluaran per Kategori',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            if (kategori.isEmpty)
              pw.Text('Belum ada pengeluaran.')
            else
              pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                children: [
                  for (final e in kategori)
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(e.key),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(rp(e.value)),
                        ),
                      ],
                    ),
                ],
              ),
            pw.SizedBox(height: 16),
            pw.Text(
              'Dibuat oleh DanaPintar AI',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
            ),
          ],
        ),
      );

      final bytes = await doc.save();
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'DanaPintar_${periode.replaceAll(' ', '_')}.pdf',
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('❌ Gagal membuat PDF: $e')),
      );
    }
  }

  pw.Widget _pdfRow(String k, String v) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [pw.Text(k), pw.Text(v)],
    ),
  );
}

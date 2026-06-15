import 'package:flutter/material.dart';

import '../budget_kategori/budget_kategori_page.dart';
import '../changelog/changelog_page.dart';
import '../chat/chat_page.dart';
import '../goals/goals_page.dart';
import '../hutang/hutang_page.dart';
import '../import_csv/import_csv_page.dart';
import '../kategori/kategori_page.dart';
import '../laporan/laporan_page.dart';
import '../networth/networth_page.dart';
import '../recurring/recurring_page.dart';
import '../scan/scan_page.dart';
import '../visualisasi/visualisasi_page.dart';

/// Hub menu fitur tambahan.
class LainnyaPage extends StatelessWidget {
  const LainnyaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_MenuItem>[
      _MenuItem(
        '📸',
        'Scan Struk (AI)',
        'Foto struk → otomatis jadi transaksi',
        () => const ScanPage(),
      ),
      _MenuItem(
        '🤖',
        'DanaBot (AI)',
        'Chat asisten keuangan pribadi',
        () => const ChatPage(),
      ),
      _MenuItem(
        '🎯',
        'Financial Goals',
        'Target finansial dengan progress',
        () => const GoalsPage(),
      ),
      _MenuItem(
        '💸',
        'Hutang & Piutang',
        'Lacak pinjaman & tagihan',
        () => const HutangPage(),
      ),
      _MenuItem(
        '💎',
        'Net Worth',
        'Aset vs liabilitas & tren',
        () => const NetWorthPage(),
      ),
      _MenuItem(
        '🏷️',
        'Custom Kategori',
        'Tambah kategori sendiri',
        () => const KategoriPage(),
      ),
      _MenuItem(
        '📂',
        'Budget per Kategori',
        'Alokasi anggaran tiap pos',
        () => const BudgetKategoriPage(),
      ),
      _MenuItem(
        '🔄',
        'Transaksi Berulang',
        'Template transaksi rutin',
        () => const RecurringPage(),
      ),
      _MenuItem(
        '📊',
        'Visualisasi',
        'Heatmap, komparatif & tren',
        () => const VisualisasiPage(),
      ),
      _MenuItem(
        '📥',
        'Import CSV',
        'Impor mutasi bank dari file',
        () => const ImportCsvPage(),
      ),
      _MenuItem(
        '📄',
        'Laporan PDF',
        'Generate & bagikan laporan',
        () => const LaporanPage(),
      ),
      _MenuItem(
        '📋',
        'Changelog',
        'Riwayat perubahan aplikasi',
        () => const ChangelogPage(),
      ),
    ];
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        ...items.map(
          (m) => Card(
            child: ListTile(
              leading: Text(m.ikon, style: const TextStyle(fontSize: 22)),
              title: Text(
                m.judul,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(m.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (_) => m.builder())),
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuItem {
  final String ikon;
  final String judul;
  final String subtitle;
  final Widget Function() builder;
  const _MenuItem(this.ikon, this.judul, this.subtitle, this.builder);
}

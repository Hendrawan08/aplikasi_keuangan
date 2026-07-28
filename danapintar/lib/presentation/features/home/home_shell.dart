import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/notification_provider.dart';
import '../dashboard/dashboard_page.dart';
import '../lainnya/lainnya_page.dart';
import '../pemasukan/pemasukan_form_page.dart';
import '../pemasukan/pemasukan_page.dart';
import '../pengaturan/pengaturan_page.dart';
import '../transaksi/transaksi_form_page.dart';
import '../transaksi/transaksi_page.dart';

/// Kerangka utama dengan navigasi bawah.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Setelah frame pertama: minta izin notifikasi & pasang jadwal.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notifSettingsProvider.notifier).bootstrap();
    });
  }

  static const _titles = [
    '📊 DanaPintar AI',
    '📋 Pengeluaran',
    '💵 Pemasukan',
    '📦 Lainnya',
    '⚙️ Pengaturan',
  ];

  static const _pages = [
    DashboardPage(),
    TransaksiPage(),
    PemasukanPage(),
    LainnyaPage(),
    PengaturanPage(),
  ];

  void _push(Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  /// Sheet pemilih: tombol "+" → pilih Pengeluaran atau Pemasukan.
  void _showTambahSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bg2,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 14),
                child: Text(
                  'Catat transaksi',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
              _opsiTambah(
                icon: Icons.trending_down_rounded,
                color: AppColors.expense,
                title: 'Pengeluaran',
                subtitle: 'Catat uang yang keluar',
                onTap: () {
                  Navigator.pop(ctx);
                  _push(const TransaksiFormPage());
                },
              ),
              const SizedBox(height: 10),
              _opsiTambah(
                icon: Icons.trending_up_rounded,
                color: AppColors.income,
                title: 'Pemasukan',
                subtitle: 'Catat uang yang masuk',
                onTap: () {
                  Navigator.pop(ctx);
                  _push(const PemasukanFormPage());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _opsiTambah({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.text2,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.text2),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Pantau kondisi bulan berjalan → picu notifikasi event (anggaran, dll.).
    ref.listen<CurMonthStatus?>(currentMonthStatusProvider, (prev, next) {
      if (next == null) return;
      final cfg = ref.read(notifSettingsProvider).value;
      if (cfg != null) evaluateEventNotifications(next, cfg);
    });

    final showFab = _index < 3; // tampil di Beranda/Pengeluaran/Pemasukan saja
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_index],
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: IndexedStack(index: _index, children: _pages),
      floatingActionButton: showFab
          ? FloatingActionButton(
              onPressed: _showTambahSheet,
              tooltip: 'Catat transaksi',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments),
            label: 'Keluar',
          ),
          NavigationDestination(
            icon: Icon(Icons.savings_outlined),
            selectedIcon: Icon(Icons.savings),
            label: 'Masuk',
          ),
          NavigationDestination(
            icon: Icon(Icons.widgets_outlined),
            selectedIcon: Icon(Icons.widgets),
            label: 'Lainnya',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Atur',
          ),
        ],
      ),
    );
  }
}

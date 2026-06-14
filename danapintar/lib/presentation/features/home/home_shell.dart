import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  void _tambah() {
    final route = _index == 2
        ? MaterialPageRoute<void>(builder: (_) => const PemasukanFormPage())
        : MaterialPageRoute<void>(builder: (_) => const TransaksiFormPage());
    Navigator.of(context).push(route);
  }

  @override
  Widget build(BuildContext context) {
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
          ? FloatingActionButton.extended(
              onPressed: _tambah,
              icon: const Icon(Icons.add),
              label: Text(_index == 2 ? 'Pemasukan' : 'Pengeluaran'),
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

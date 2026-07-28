import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Riwayat perubahan aplikasi.
class ChangelogPage extends StatelessWidget {
  const ChangelogPage({super.key});

  static const _entries = <({String versi, String tanggal, List<String> poin})>[
    (
      versi: '2.0 (Flutter)',
      tanggal: 'Juni 2026',
      poin: [
        '📱 Ditulis ulang penuh ke Flutter — aplikasi mobile native',
        '🔒 Data 100% lokal di perangkat (tanpa cloud)',
        '💾 Backup & Restore ke file',
        '🎯 Goals, 💸 Hutang/Piutang, 💎 Net Worth',
        '🏷️ Custom kategori, 📂 budget per kategori, 🔄 transaksi berulang',
        '📊 Grafik Wajib vs Sukarela & breakdown kategori',
      ],
    ),
    (
      versi: '1.x (Streamlit)',
      tanggal: 'Maret–Mei 2026',
      poin: [
        '🌐 Versi web berbasis Streamlit (Python)',
        '🧠 AI Auditor, Health Score, gamifikasi',
        '☁️ Sinkronisasi cloud Supabase',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📋 Changelog')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _entries
            .map(
              (e) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.bg2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'v${e.versi}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.accent,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          e.tanggal,
                          style: const TextStyle(
                            color: AppColors.text2,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...e.poin.map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(p, style: const TextStyle(fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

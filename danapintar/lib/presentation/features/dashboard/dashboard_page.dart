import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/notifikasi.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/providers.dart';
import '../../widgets/health_card.dart';
import '../../widgets/kategori_breakdown.dart';
import '../../widgets/tx_tile.dart';
import '../../widgets/wajib_sukarela_chart.dart';

/// Dashboard utama — menampilkan ringkasan keuangan periode terpilih.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardAsyncProvider);
    final sel = ref.watch(selectedPeriodeProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Gagal memuat data: $e',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.expense),
          ),
        ),
      ),
      data: (data) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _PeriodeSelector(month: sel.month, year: sel.year),
          const SizedBox(height: 12),
          ...data.notifikasi.map((n) => _NotifCard(n)),
          if (data.notifikasi.isNotEmpty) const SizedBox(height: 4),
          _BalanceCard(data: data),
          const SizedBox(height: 16),
          _MetricsRow(data: data),
          const SizedBox(height: 16),
          HealthCard(health: data.health, label: data.label),
          const SizedBox(height: 16),
          if (data.adaData) ...[
            WajibSukarelaChart(
              wajib: data.totalPengeluaran - data.sukarela,
              sukarela: data.sukarela,
            ),
            const SizedBox(height: 16),
            KategoriBreakdown(perKategori: data.pengeluaranPerKategori),
            const SizedBox(height: 16),
          ],
          if (data.badges.isNotEmpty) ...[
            const _SectionTitle('🏅 Badges'),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: data.badges
                  .map(
                    (b) => Chip(
                      label: Text('${b.ikon} ${b.nama}'),
                      backgroundColor: AppColors.bg2,
                      side: const BorderSide(color: AppColors.accent),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
          const _SectionTitle('🧾 Transaksi Terakhir'),
          if (data.transaksiBulan.isEmpty)
            const _EmptyHint('Belum ada transaksi bulan ini.')
          else
            ...data.transaksiBulan
                .take(5)
                .map(
                  (t) => TxTile(
                    judul: t.catatan,
                    subtitle: '${t.kategori} · ${t.sifat}',
                    nominal: t.nominal,
                    waktu: t.waktuTransaksi,
                    isExpense: true,
                  ),
                ),
        ],
      ),
    );
  }
}

class _PeriodeSelector extends ConsumerWidget {
  const _PeriodeSelector({required this.month, required this.year});
  final int month;
  final int year;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void shift(int delta) {
      var m = month + delta;
      var y = year;
      if (m < 1) {
        m = 12;
        y--;
      } else if (m > 12) {
        m = 1;
        y++;
      }
      ref.read(selectedPeriodeProvider.notifier).state = (month: m, year: y);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => shift(-1),
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          '${kamusBulan[month]} $year',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        IconButton(
          onPressed: () => shift(1),
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.data});
  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final netColor = data.net >= 0
        ? AppColors.incomeSoft
        : AppColors.expenseSoft;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        gradient: AppColors.balanceGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💹 RINGKASAN KEUANGAN',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            rp(data.net),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            data.net >= 0 ? 'Surplus' : 'Defisit',
            style: TextStyle(color: netColor, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _SubBalance(
                  label: '⬆ Pemasukan',
                  value: data.totalPemasukan,
                  color: AppColors.incomeSoft,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SubBalance(
                  label: '⬇ Pengeluaran',
                  value: data.totalPengeluaran,
                  color: AppColors.expenseSoft,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubBalance extends StatelessWidget {
  const _SubBalance({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            rp(value),
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({required this.data});
  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _Metric('Anggaran', rp(data.anggaran))),
        const SizedBox(width: 8),
        Expanded(child: _Metric('Batas Belanja', rp(data.batas))),
        const SizedBox(width: 8),
        Expanded(
          child: _Metric(
            'Sisa',
            rp(data.sisa),
            valueColor: data.sisa >= 0 ? AppColors.accent : AppColors.expense,
          ),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, {this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.text2, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.text,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
    ),
  );
}

class _NotifCard extends StatelessWidget {
  const _NotifCard(this.notif);
  final Notif notif;

  Color get _color => switch (notif.level) {
    NotifLevel.sukses => AppColors.accent,
    NotifLevel.info => AppColors.income,
    NotifLevel.peringatan => const Color(0xFFF59E0B),
    NotifLevel.bahaya => AppColors.expense,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Text(notif.ikon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              notif.pesan,
              style: const TextStyle(fontSize: 12.5, color: AppColors.text),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.bg2,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(color: AppColors.text2),
    ),
  );
}

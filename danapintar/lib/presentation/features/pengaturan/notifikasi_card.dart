import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/notifications/notif_settings.dart';
import '../../../data/notifications/notification_service.dart';
import '../../providers/notification_provider.dart';

/// Kartu pengaturan notifikasi: saklar utama, sub-toggle per jenis,
/// pemilih jam pengingat harian, banner izin sistem, dan tombol uji.
class NotifikasiCard extends ConsumerStatefulWidget {
  const NotifikasiCard({super.key});

  @override
  ConsumerState<NotifikasiCard> createState() => _NotifikasiCardState();
}

class _NotifikasiCardState extends ConsumerState<NotifikasiCard>
    with WidgetsBindingObserver {
  bool? _permEnabled; // null = belum dicek

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshPerm();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Saat kembali dari Setelan HP, perbarui status izin.
    if (state == AppLifecycleState.resumed) _refreshPerm();
  }

  Future<void> _refreshPerm() async {
    final e = await NotificationService.instance.areEnabled();
    if (mounted) setState(() => _permEnabled = e);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(notifSettingsProvider);
    final notifier = ref.read(notifSettingsProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🔔 Notifikasi',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pengingat & peringatan keuangan langsung di HP.',
            style: TextStyle(color: AppColors.text2, fontSize: 12),
          ),
          const SizedBox(height: 4),
          async.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Gagal memuat pengaturan: $e',
                style: const TextStyle(color: AppColors.expense),
              ),
            ),
            data: (s) {
              final on = s.enabled;
              return Column(
                children: [
                  if (on && _permEnabled == false) _permBanner(),
                  _switch(
                    'Aktifkan notifikasi',
                    'Saklar utama untuk semua notifikasi.',
                    s.enabled,
                    (v) async {
                      await notifier.setEnabled(v);
                      await _refreshPerm();
                    },
                    bold: true,
                  ),
                  if (on) ...[
                    const Divider(height: 8),
                    _dailyTile(s, notifier),
                    _switch(
                      '⚠️ Peringatan anggaran',
                      'Saat pengeluaran tembus 80% & 100% batas belanja.',
                      s.budgetAlert,
                      notifier.setBudgetAlert,
                    ),
                    _switch(
                      '🌙 Belanja impulsif',
                      'Saat ada belanja di jam rawan (malam/dini hari).',
                      s.impulse,
                      notifier.setImpulse,
                    ),
                    _switch(
                      '🎯 Target tabungan tercapai',
                      'Saat tabungan bersih bulan ini mencapai target.',
                      s.savingsGoal,
                      notifier.setSavingsGoal,
                    ),
                    _switch(
                      '🔒 Pengingat awal bulan',
                      'Mengingatkan mengunci anggaran tiap tanggal 1.',
                      s.monthStart,
                      notifier.setMonthStart,
                    ),
                    _switch(
                      '📊 Laporan bulanan',
                      'Ringkasan keuangan bulan lalu tiap awal bulan.',
                      s.monthlyReport,
                      notifier.setMonthlyReport,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        icon: const Icon(
                          Icons.notifications_active_outlined,
                          size: 16,
                        ),
                        label: const Text('Kirim notifikasi uji'),
                        onPressed: () => _test(notifier),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _permBanner() {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.expense.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.expense.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_off, color: AppColors.expense, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Izin notifikasi dimatikan di sistem. Aktifkan agar pengingat & '
              'peringatan bisa muncul.',
              style: TextStyle(fontSize: 12, color: AppColors.text),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.expense,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              visualDensity: VisualDensity.compact,
            ),
            onPressed: () async {
              await NotificationService.instance.openSystemSettings();
            },
            child: const Text('Buka Setelan'),
          ),
        ],
      ),
    );
  }

  Widget _switch(
    String title,
    String subtitle,
    bool value,
    Future<void> Function(bool) onChanged, {
    bool bold = false,
  }) {
    return SwitchListTile.adaptive(
      dense: true,
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: (v) => onChanged(v),
      title: Text(
        title,
        style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.text2, fontSize: 11),
      ),
    );
  }

  Widget _dailyTile(NotifSettings s, NotifSettingsNotifier notifier) {
    return Column(
      children: [
        _switch(
          '📝 Pengingat harian',
          'Ingatkan mencatat transaksi setiap hari.',
          s.dailyReminder,
          notifier.setDailyReminder,
        ),
        if (s.dailyReminder)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.schedule, size: 15, color: AppColors.text2),
                const SizedBox(width: 6),
                const Text(
                  'Jam pengingat:',
                  style: TextStyle(color: AppColors.text2, fontSize: 12),
                ),
                const SizedBox(width: 8),
                ActionChip(
                  label: Text(s.jamFormatted),
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: s.dailyHour,
                        minute: s.dailyMinute,
                      ),
                    );
                    if (picked != null) {
                      await notifier.setDailyTime(picked.hour, picked.minute);
                    }
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _test(NotifSettingsNotifier notifier) async {
    final ok = await notifier.sendTest();
    await _refreshPerm();
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔔 Notifikasi uji dikirim — cek panel notifikasi HP.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 6),
          content: const Text(
            '⚠️ Izin notifikasi belum aktif di sistem. Buka Setelan untuk mengaktifkan.',
          ),
          action: SnackBarAction(
            label: 'BUKA SETELAN',
            onPressed: () => NotificationService.instance.openSystemSettings(),
          ),
        ),
      );
    }
  }
}

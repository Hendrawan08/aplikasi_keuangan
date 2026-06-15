import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/notifications/notif_settings.dart';
import '../../providers/notification_provider.dart';

/// Kartu pengaturan notifikasi: saklar utama, sub-toggle per jenis,
/// pemilih jam pengingat harian, dan tombol uji.
class NotifikasiCard extends ConsumerWidget {
  const NotifikasiCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  _switch(
                    'Aktifkan notifikasi',
                    'Saklar utama untuk semua notifikasi.',
                    s.enabled,
                    notifier.setEnabled,
                    bold: true,
                  ),
                  if (on) ...[
                    const Divider(height: 8),
                    _dailyTile(context, s, notifier),
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
                        onPressed: () => _test(context, notifier),
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

  Widget _dailyTile(
    BuildContext context,
    NotifSettings s,
    NotifSettingsNotifier notifier,
  ) {
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
                const Icon(
                  Icons.schedule,
                  size: 15,
                  color: AppColors.text2,
                ),
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

  Future<void> _test(
    BuildContext context,
    NotifSettingsNotifier notifier,
  ) async {
    final ok = await notifier.sendTest();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? '🔔 Notifikasi uji dikirim — cek panel notifikasi HP.'
              : '⚠️ Izin notifikasi belum aktif. Aktifkan di Setelan HP → Notifikasi → DanaPintar AI.',
        ),
      ),
    );
  }
}

import 'package:shared_preferences/shared_preferences.dart';

/// Preferensi notifikasi pengguna — disimpan lokal (SharedPreferences).
class NotifSettings {
  final bool enabled; // saklar utama
  final bool dailyReminder; // pengingat harian catat transaksi
  final int dailyHour;
  final int dailyMinute;
  final bool budgetAlert; // peringatan anggaran 80% & 100%
  final bool impulse; // deteksi belanja jam rawan
  final bool savingsGoal; // target tabungan tercapai
  final bool monthStart; // pengingat kunci anggaran awal bulan
  final bool monthlyReport; // ringkasan laporan akhir/awal bulan

  const NotifSettings({
    this.enabled = true,
    this.dailyReminder = true,
    this.dailyHour = 20,
    this.dailyMinute = 0,
    this.budgetAlert = true,
    this.impulse = true,
    this.savingsGoal = true,
    this.monthStart = true,
    this.monthlyReport = true,
  });

  NotifSettings copyWith({
    bool? enabled,
    bool? dailyReminder,
    int? dailyHour,
    int? dailyMinute,
    bool? budgetAlert,
    bool? impulse,
    bool? savingsGoal,
    bool? monthStart,
    bool? monthlyReport,
  }) {
    return NotifSettings(
      enabled: enabled ?? this.enabled,
      dailyReminder: dailyReminder ?? this.dailyReminder,
      dailyHour: dailyHour ?? this.dailyHour,
      dailyMinute: dailyMinute ?? this.dailyMinute,
      budgetAlert: budgetAlert ?? this.budgetAlert,
      impulse: impulse ?? this.impulse,
      savingsGoal: savingsGoal ?? this.savingsGoal,
      monthStart: monthStart ?? this.monthStart,
      monthlyReport: monthlyReport ?? this.monthlyReport,
    );
  }

  String get jamFormatted =>
      '${dailyHour.toString().padLeft(2, '0')}:'
      '${dailyMinute.toString().padLeft(2, '0')}';

  static const _prefix = 'notif_';

  static Future<NotifSettings> load() async {
    final p = await SharedPreferences.getInstance();
    bool b(String k, bool d) => p.getBool('$_prefix$k') ?? d;
    int i(String k, int d) => p.getInt('$_prefix$k') ?? d;
    return NotifSettings(
      enabled: b('enabled', true),
      dailyReminder: b('dailyReminder', true),
      dailyHour: i('dailyHour', 20),
      dailyMinute: i('dailyMinute', 0),
      budgetAlert: b('budgetAlert', true),
      impulse: b('impulse', true),
      savingsGoal: b('savingsGoal', true),
      monthStart: b('monthStart', true),
      monthlyReport: b('monthlyReport', true),
    );
  }

  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('${_prefix}enabled', enabled);
    await p.setBool('${_prefix}dailyReminder', dailyReminder);
    await p.setInt('${_prefix}dailyHour', dailyHour);
    await p.setInt('${_prefix}dailyMinute', dailyMinute);
    await p.setBool('${_prefix}budgetAlert', budgetAlert);
    await p.setBool('${_prefix}impulse', impulse);
    await p.setBool('${_prefix}savingsGoal', savingsGoal);
    await p.setBool('${_prefix}monthStart', monthStart);
    await p.setBool('${_prefix}monthlyReport', monthlyReport);
  }
}

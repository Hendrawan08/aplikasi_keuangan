import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/formatters.dart';
import '../../data/mappers.dart';
import '../../data/notifications/notif_settings.dart';
import '../../data/notifications/notification_service.dart';
import '../../domain/budget_rules.dart';
import '../../domain/impulse_detector.dart';
import 'providers.dart';

// ── ID notifikasi stabil ──────────────────────────────────────
const int _idDaily = 1001;
const int _idMonthStart = 1002;
const int _idMonthlyReport = 1003;
const int _idTest = 1900;
const int _idEvtBudget80 = 2001;
const int _idEvtBudget100 = 2002;
const int _idEvtGoal = 2003;
const int _idEvtImpulse = 2004;

// ── Status keuangan BULAN BERJALAN (untuk notifikasi event) ────
class CurMonthStatus {
  final String key;
  final int totalPengeluaran;
  final int batas;
  final int target;
  final int net;
  final int belanjaJamRawan;
  final bool anggaranTerkunci;
  final bool targetAda;

  const CurMonthStatus({
    required this.key,
    required this.totalPengeluaran,
    required this.batas,
    required this.target,
    required this.net,
    required this.belanjaJamRawan,
    required this.anggaranTerkunci,
    required this.targetAda,
  });
}

/// Dihitung dari data mentah untuk bulan kalender SAAT INI (bukan periode
/// yang dipilih pengguna), agar peringatan selalu relevan dengan kondisi nyata.
final currentMonthStatusProvider = Provider<CurMonthStatus?>((ref) {
  final tx = ref.watch(transaksiListProvider).value;
  final pm = ref.watch(pemasukanListProvider).value;
  final budgets = ref.watch(budgetMapProvider).value;
  final targets = ref.watch(targetMapProvider).value;
  if (tx == null || pm == null || budgets == null || targets == null) {
    return null;
  }

  final now = DateTime.now();
  final key = bulanKey(now.month, now.year);
  final txBulan = tx
      .where(
        (t) =>
            t.waktuTransaksi.month == now.month &&
            t.waktuTransaksi.year == now.year,
      )
      .toList();
  final pmBulan = pm
      .where(
        (p) =>
            p.waktuPemasukan.month == now.month &&
            p.waktuPemasukan.year == now.year,
      )
      .toList();

  final totalPglr = txBulan.fold<int>(0, (s, t) => s + t.nominal);
  final totalMsuk = pmBulan.fold<int>(0, (s, p) => s + p.nominal);
  final anggaran = budgets[key] ?? 0;
  final target = targets[key] ?? 0;

  return CurMonthStatus(
    key: key,
    totalPengeluaran: totalPglr,
    batas: batasBelanja(anggaran, target),
    target: target,
    net: totalMsuk - totalPglr,
    belanjaJamRawan: totalBelanjaJamRawan(txBulan.toTxViews()),
    anggaranTerkunci: anggaran > 0,
    targetAda: target > 0,
  );
});

// ── Preferensi notifikasi (reaktif) ───────────────────────────
final notifSettingsProvider =
    AsyncNotifierProvider<NotifSettingsNotifier, NotifSettings>(
      NotifSettingsNotifier.new,
    );

class NotifSettingsNotifier extends AsyncNotifier<NotifSettings> {
  @override
  Future<NotifSettings> build() => NotifSettings.load();

  NotifSettings get _cur => state.value ?? const NotifSettings();

  Future<void> _update(NotifSettings s) async {
    state = AsyncData(s);
    await s.save();
    await _applySchedules(s);
  }

  /// Dipanggil sekali saat aplikasi mulai: minta izin + pasang jadwal.
  Future<void> bootstrap() async {
    final s = await future;
    if (s.enabled) {
      await NotificationService.instance.requestPermission();
    }
    await _applySchedules(s);
  }

  Future<void> setEnabled(bool v) async {
    if (v) await NotificationService.instance.requestPermission();
    await _update(_cur.copyWith(enabled: v));
  }

  Future<void> setDailyReminder(bool v) async =>
      _update(_cur.copyWith(dailyReminder: v));
  Future<void> setDailyTime(int hour, int minute) async =>
      _update(_cur.copyWith(dailyHour: hour, dailyMinute: minute));
  Future<void> setBudgetAlert(bool v) async =>
      _update(_cur.copyWith(budgetAlert: v));
  Future<void> setImpulse(bool v) async => _update(_cur.copyWith(impulse: v));
  Future<void> setSavingsGoal(bool v) async =>
      _update(_cur.copyWith(savingsGoal: v));
  Future<void> setMonthStart(bool v) async =>
      _update(_cur.copyWith(monthStart: v));
  Future<void> setMonthlyReport(bool v) async =>
      _update(_cur.copyWith(monthlyReport: v));

  /// Kirim notifikasi uji.
  Future<bool> sendTest() async {
    final ok = await NotificationService.instance.requestPermission();
    await NotificationService.instance.show(
      _idTest,
      '🔔 Notifikasi DanaPintar aktif',
      'Bagus! Kamu akan menerima pengingat & peringatan keuangan di sini.',
      channel: NotificationService.chUmum,
      channelName: 'Umum',
    );
    return ok;
  }

  Future<void> _applySchedules(NotifSettings s) async {
    final svc = NotificationService.instance;
    // Pengingat harian catat transaksi.
    if (s.enabled && s.dailyReminder) {
      await svc.scheduleDaily(
        _idDaily,
        s.dailyHour,
        s.dailyMinute,
        '📝 Catat transaksi hari ini',
        'Jangan lupa catat pemasukan & pengeluaranmu agar laporan tetap akurat.',
      );
    } else {
      await svc.cancel(_idDaily);
    }
    // Pengingat kunci anggaran di awal bulan (tgl 1, 09:00).
    if (s.enabled && s.monthStart) {
      await svc.scheduleMonthly(
        _idMonthStart,
        1,
        9,
        0,
        '🔒 Bulan baru — kunci anggaran',
        'Atur anggaran & target tabungan bulan ini lewat menu Pengaturan.',
      );
    } else {
      await svc.cancel(_idMonthStart);
    }
    // Ringkasan laporan bulan lalu (tgl 1, 08:30).
    if (s.enabled && s.monthlyReport) {
      await svc.scheduleMonthly(
        _idMonthlyReport,
        1,
        8,
        30,
        '📊 Laporan bulan lalu siap',
        'Lihat ringkasan keuanganmu bulan kemarin di menu Lainnya → Laporan.',
      );
    } else {
      await svc.cancel(_idMonthlyReport);
    }
  }
}

/// Evaluasi kondisi bulan berjalan & picu notifikasi event (sekali per bulan
/// per jenis, di-dedup lewat SharedPreferences).
Future<void> evaluateEventNotifications(
  CurMonthStatus s,
  NotifSettings cfg,
) async {
  if (!cfg.enabled) return;
  final svc = NotificationService.instance;
  final p = await SharedPreferences.getInstance();

  Future<bool> once(String tag) async {
    final k = 'notif_evt_${tag}_${s.key}';
    if (p.getBool(k) ?? false) return false;
    await p.setBool(k, true);
    return true;
  }

  if (cfg.budgetAlert && s.batas > 0) {
    final pct = (s.totalPengeluaran / s.batas * 100).round();
    if (pct >= 100 && await once('b100')) {
      await svc.show(
        _idEvtBudget100,
        '🚨 Batas belanja terlampaui!',
        'Pengeluaran bulan ini sudah $pct% dari batas. Target tabunganmu terancam.',
        channel: NotificationService.chAlert,
        channelName: 'Peringatan Keuangan',
      );
    } else if (pct >= 80 && await once('b80')) {
      await svc.show(
        _idEvtBudget80,
        '⚠️ Pengeluaran sudah $pct%',
        'Kamu sudah memakai $pct% dari batas belanja bulan ini. Mulai rem pengeluaran ya.',
        channel: NotificationService.chAlert,
        channelName: 'Peringatan Keuangan',
      );
    }
  }

  if (cfg.savingsGoal && s.targetAda && s.target > 0 && s.net >= s.target) {
    if (await once('goal')) {
      await svc.show(
        _idEvtGoal,
        '🎯 Target tabungan tercapai!',
        'Selamat! Tabungan bersihmu bulan ini sudah mencapai target. 👏',
        channel: NotificationService.chAlert,
        channelName: 'Peringatan Keuangan',
      );
    }
  }

  if (cfg.impulse && s.belanjaJamRawan > 0) {
    if (await once('impulse')) {
      await svc.show(
        _idEvtImpulse,
        '🌙 Belanja di jam rawan',
        'Terdeteksi pengeluaran di jam rawan (malam/dini hari). Waspadai impulsive buying.',
        channel: NotificationService.chAlert,
        channelName: 'Peringatan Keuangan',
      );
    }
  }
}

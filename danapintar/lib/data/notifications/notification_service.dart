import 'package:app_settings/app_settings.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Pembungkus tipis untuk notifikasi OS (Android), memakai
/// `flutter_local_notifications`. Singleton agar mudah diakses dari mana saja.
///
/// Tiga kanal (channel) Android:
///  - `reminder`  → pengingat terjadwal (harian, awal bulan, laporan).
///  - `alert`     → peringatan keuangan (anggaran, impulsif, target).
///  - `umum`      → notifikasi uji & lain-lain.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _ready = false;
  bool _granted = false;

  /// Apakah izin notifikasi (Android 13+) sudah diberikan.
  bool get granted => _granted;

  // Warna aksen merek (hijau DanaPintar) untuk lampu/ikon kecil.
  static const int _accent = 0xFF4ADE80;

  static const String chReminder = 'reminder';
  static const String chAlert = 'alert';
  static const String chUmum = 'umum';

  /// Inisialisasi plugin + zona waktu. Aman dipanggil berkali-kali.
  Future<void> init() async {
    if (_ready) return;
    try {
      // Zona waktu untuk penjadwalan tepat (zonedSchedule butuh tz.local benar).
      tzdata.initializeTimeZones();
      try {
        final name = await FlutterTimezone.getLocalTimezone().timeout(
          const Duration(seconds: 4),
        );
        tz.setLocalLocation(tz.getLocation(name));
      } catch (e) {
        // Fallback aman untuk pengguna Indonesia bila deteksi gagal.
        try {
          tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
        } catch (_) {/* biarkan UTC default */}
        debugPrint('NotificationService: gagal deteksi zona waktu ($e)');
      }

      const androidInit = AndroidInitializationSettings(
        '@drawable/ic_stat_danapintar',
      );
      await _plugin.initialize(
        const InitializationSettings(android: androidInit),
      );

      await _createChannels();
      _ready = true;
    } catch (e) {
      // Jangan pernah biarkan kegagalan notifikasi memblok aplikasi.
      debugPrint('NotificationService.init gagal: $e');
    }
  }

  Future<void> _createChannels() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return;
    const channels = [
      AndroidNotificationChannel(
        chReminder,
        'Pengingat',
        description: 'Pengingat catat transaksi, awal bulan, & laporan.',
        importance: Importance.defaultImportance,
      ),
      AndroidNotificationChannel(
        chAlert,
        'Peringatan Keuangan',
        description:
            'Peringatan anggaran, belanja impulsif, & target tabungan.',
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        chUmum,
        'Umum',
        description: 'Notifikasi umum & uji coba.',
        importance: Importance.defaultImportance,
      ),
    ];
    for (final c in channels) {
      await android.createNotificationChannel(c);
    }
  }

  /// Minta izin notifikasi (Android 13+) lalu kembalikan status SEBENARNYA
  /// dari sistem (bukan sekadar hasil dialog), agar UI akurat.
  Future<bool> requestPermission() async {
    await init();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) {
      _granted = true; // platform non-Android: anggap tersedia.
      return true;
    }
    try {
      await android.requestNotificationsPermission();
    } catch (_) {/* abaikan; cek status di bawah */}
    // Catatan: di sebagian perangkat (mis. MIUI) areNotificationsEnabled bisa
    // mengembalikan null walau notifikasi aktif → anggap aktif bila tak pasti.
    _granted = await android.areNotificationsEnabled() ?? true;
    return _granted;
  }

  /// Buka layar pengaturan notifikasi aplikasi di sistem (Setelan HP).
  Future<void> openSystemSettings() async {
    try {
      await AppSettings.openAppSettings(type: AppSettingsType.notification);
    } catch (e) {
      debugPrint('openSystemSettings gagal: $e');
    }
  }

  /// Status izin notifikasi sistem saat ini (tanpa memunculkan dialog).
  Future<bool> areEnabled() async {
    await init();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return true;
    _granted = await android.areNotificationsEnabled() ?? true;
    return _granted;
  }

  NotificationDetails _details(String channel, String channelName) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channel,
        channelName,
        channelDescription: channelName,
        importance: channel == chAlert ? Importance.high : Importance.defaultImportance,
        priority: channel == chAlert ? Priority.high : Priority.defaultPriority,
        color: const Color(_accent),
        icon: '@drawable/ic_stat_danapintar',
        styleInformation: const DefaultStyleInformation(true, true),
      ),
    );
  }

  /// Tampilkan notifikasi seketika. Mengembalikan true bila berhasil dikirim.
  Future<bool> show(
    int id,
    String title,
    String body, {
    String channel = chUmum,
    String channelName = 'Umum',
  }) async {
    await init();
    try {
      await _plugin.show(id, title, body, _details(channel, channelName));
      return true;
    } catch (e) {
      debugPrint('show notifikasi gagal ($e) — coba ikon cadangan');
      // Jaring pengaman: bila ikon kustom bermasalah, pakai ikon peluncur.
      try {
        await _plugin.show(
          id,
          title,
          body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel,
              channelName,
              channelDescription: channelName,
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
        return true;
      } catch (e2) {
        debugPrint('show notifikasi cadangan gagal: $e2');
        return false;
      }
    }
  }

  /// Jadwalkan notifikasi harian berulang pada jam:menit tertentu.
  Future<void> scheduleDaily(
    int id,
    int hour,
    int minute,
    String title,
    String body, {
    String channel = chReminder,
    String channelName = 'Pengingat',
  }) async {
    await init();
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      _details(channel, channelName),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Jadwalkan notifikasi bulanan pada tanggal `day` jam:menit tertentu.
  Future<void> scheduleMonthly(
    int id,
    int day,
    int hour,
    int minute,
    String title,
    String body, {
    String channel = chReminder,
    String channelName = 'Pengingat',
  }) async {
    await init();
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfDay(day, hour, minute),
      _details(channel, channelName),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );
  }

  Future<void> cancel(int id) async {
    await init();
    await _plugin.cancel(id);
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  tz.TZDateTime _nextInstanceOfDay(int day, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      day,
      hour,
      minute,
    );
    while (!scheduled.isAfter(now)) {
      // pindah ke bulan berikutnya
      final m = scheduled.month == 12 ? 1 : scheduled.month + 1;
      final y = scheduled.month == 12 ? scheduled.year + 1 : scheduled.year;
      scheduled = tz.TZDateTime(tz.local, y, m, day, hour, minute);
    }
    return scheduled;
  }
}

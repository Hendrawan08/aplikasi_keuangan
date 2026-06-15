/// Notifikasi in-app cerdas — port dari `generate_notifikasi()` kode Python.
/// Murni Dart, dapat diuji.
library;

enum NotifLevel { info, sukses, peringatan, bahaya }

class Notif {
  final String ikon;
  final String pesan;
  final NotifLevel level;
  const Notif(this.ikon, this.pesan, this.level);

  @override
  bool operator ==(Object other) =>
      other is Notif &&
      other.ikon == ikon &&
      other.pesan == pesan &&
      other.level == level;

  @override
  int get hashCode => Object.hash(ikon, pesan, level);
}

/// Hasilkan daftar notifikasi berdasarkan kondisi keuangan bulan berjalan.
List<Notif> generateNotifikasi({
  required bool anggaranTerkunci,
  required bool targetAda,
  required int totalPengeluaran,
  required int batasBelanja,
  required int belanjaJamRawan,
  required bool sukarelaBerlebihan,
}) {
  final out = <Notif>[];

  if (!anggaranTerkunci) {
    out.add(
      const Notif(
        '🔒',
        'Anggaran bulan ini belum dikunci. Kunci dulu untuk evaluasi akurat.',
        NotifLevel.peringatan,
      ),
    );
  } else if (!targetAda) {
    out.add(
      const Notif(
        '🎯',
        'Anggaran sudah dikunci, tapi target tabungan belum diatur.',
        NotifLevel.info,
      ),
    );
  }

  // Ambang persen terhadap batas belanja (port: >=100% bahaya, >=80% peringatan).
  if (batasBelanja > 0) {
    final pct = (totalPengeluaran / batasBelanja * 100).round();
    if (pct >= 100) {
      out.add(
        Notif(
          '🚨',
          'Pengeluaran sudah $pct% dari batas! Target tabungan terancam.',
          NotifLevel.bahaya,
        ),
      );
    } else if (pct >= 80) {
      out.add(
        Notif(
          '⚠️',
          'Pengeluaran sudah $pct% dari batas belanja bulan ini.',
          NotifLevel.peringatan,
        ),
      );
    } else if (anggaranTerkunci && targetAda) {
      out.add(
        const Notif(
          '✅',
          'Pengeluaran masih dalam batas. Pertahankan!',
          NotifLevel.sukses,
        ),
      );
    }
  }

  if (belanjaJamRawan > 0) {
    out.add(
      const Notif(
        '🌙',
        'Terdeteksi belanja di jam rawan (malam/dini hari). Waspadai '
            'impulsive buying.',
        NotifLevel.peringatan,
      ),
    );
  }

  if (sukarelaBerlebihan) {
    out.add(
      const Notif(
        '💸',
        'Porsi pengeluaran sukarela melebihi 50% anggaran.',
        NotifLevel.peringatan,
      ),
    );
  }

  return out;
}

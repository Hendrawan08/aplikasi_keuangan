# DanaPintar AI — Aplikasi Flutter (Lokal-First)

Aplikasi mobile manajemen keuangan personal. Hasil migrasi dari versi Streamlit/Python
ke Flutter, dengan arsitektur **layered + tested** dan penyimpanan **100% lokal di perangkat**.

> Lihat rencana lengkap di [`../docs/RENCANA_MIGRASI_FLUTTER.md`](../docs/RENCANA_MIGRASI_FLUTTER.md).

## Status

**Fase 0 — Pondasi** ✅ · **Fase 1 — MVP Core** ✅ · **Fase 2 — Fitur Lengkap** ✅

Sudah berfungsi:
- Catat / edit / hapus pengeluaran & pemasukan (presisi jam-menit)
- Anggaran terkunci & target tabungan per bulan, batas belanja
- Multi-wallet (dompet)
- Dashboard hidup: kartu saldo, Financial Health Score, metrik, badge,
  notifikasi in-app, transaksi terakhir, pemilih bulan
- 🎯 Financial Goals, 💸 Hutang/Piutang, 💎 Net Worth tracker
- 🏷️ Custom kategori (terintegrasi ke form), 📂 budget per kategori,
  🔄 transaksi berulang
- 📊 Visualisasi: heatmap kalender, komparatif bulan, tren bulanan,
  donut Wajib vs Sukarela, breakdown kategori (`fl_chart`)
- 📥 Import CSV mutasi bank · 📄 Laporan PDF · 📋 Changelog
- 🎉 Onboarding wizard pengguna baru
- **Backup & Restore ke file** (ekspor via share, impor via file picker)
- Domain layer murni + unit test (health score, badge, jam rawan, aturan
  anggaran, notifikasi)

Belum (Fase 3): AI — Scan Struk & DanaBot via Supabase Edge Function.
Lihat `../docs/RENCANA_MIGRASI_FLUTTER.md`.

## Struktur

```
lib/
├── core/          # theme, constants, utils (rp(), wibNow(), bulanKey())
├── data/local/    # drift: tables.dart, database.dart (+ database.g.dart hasil codegen)
├── domain/        # (Fase 1) rumus bisnis murni + test
└── presentation/  # providers + features (dashboard, dst.)
```

## Menjalankan

Butuh [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable).

```bash
flutter pub get
dart run build_runner build   # regenerasi kode drift bila skema berubah
flutter run                   # jalankan di emulator/perangkat
```

## Uji & Analisis

```bash
flutter analyze
flutter test
```

## Catatan

- File `lib/data/local/database.g.dart` di-generate oleh `drift_dev`/`build_runner`.
  Ia di-commit agar repo langsung bisa di-analyze/run; jalankan ulang `build_runner`
  setiap kali mengubah definisi tabel.
- Data disimpan di SQLite privat aplikasi pada perangkat (tanpa cloud).

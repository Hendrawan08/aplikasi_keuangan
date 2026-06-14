# DanaPintar AI — Aplikasi Flutter (Lokal-First)

Aplikasi mobile manajemen keuangan personal. Hasil migrasi dari versi Streamlit/Python
ke Flutter, dengan arsitektur **layered + tested** dan penyimpanan **100% lokal di perangkat**.

> Lihat rencana lengkap di [`../docs/RENCANA_MIGRASI_FLUTTER.md`](../docs/RENCANA_MIGRASI_FLUTTER.md).

## Status

**Fase 0 — Pondasi** ✅ (selesai)
- Struktur folder layered (`core / data / domain / presentation`)
- Database lokal SQLite (`drift`) + seluruh tabel skema
- Tema gelap (`ThemeData`) — port palet warna dari versi lama
- State management: Riverpod
- Kerangka dashboard (keadaan kosong)

Fase berikutnya (1+): model `freezed`, repository, domain layer (health score, badge, dsb.),
pencatatan transaksi, chart, dan fitur Backup/Restore. Lihat dokumen rencana.

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

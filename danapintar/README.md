# DanaPintar AI — Aplikasi Flutter (Lokal-First)

Aplikasi mobile manajemen keuangan personal. Hasil migrasi dari versi Streamlit/Python
ke Flutter, dengan arsitektur **layered + tested** dan penyimpanan **100% lokal di perangkat**.

> Lihat rencana lengkap di [`../docs/RENCANA_MIGRASI_FLUTTER.md`](../docs/RENCANA_MIGRASI_FLUTTER.md).

## Status

**Fase 0** ✅ · **Fase 1 (MVP)** ✅ · **Fase 2 (Fitur Lengkap)** ✅ · **Fase 3 (AI)** 🟡 kode siap, perlu deploy

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

**Fase 3 — AI** (📸 Scan Struk & 🤖 DanaBot): kode lengkap (Edge Functions di
`supabase/functions/` + UI Flutter). Untuk mengaktifkan: deploy Edge Functions,
set secret `GEMINI_API_KEY`, isi anon key di `lib/core/config/ai_config.dart`.

## Mengaktifkan AI (Fase 3)

1. Restore/aktifkan project Supabase `danapintar`.
2. Set secret: `supabase secrets set GEMINI_API_KEY=<key>` (atau via Dashboard →
   Edge Functions → Secrets).
3. Deploy:
   `supabase functions deploy gemini-scan --no-verify-jwt`
   `supabase functions deploy gemini-chat --no-verify-jwt`
4. Isi `anonKey` di `lib/core/config/ai_config.dart` (Dashboard → Settings → API).

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

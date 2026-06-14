# Rencana Migrasi: DanaPintar AI → Flutter (Dart) — Edisi LOKAL-FIRST

> Status: **DRAFT untuk review** · Belum ada implementasi kode aplikasi.
> Revisi: arsitektur diubah dari cloud (Supabase) → **100% lokal di HP**.

---

## 1. Ringkasan & Tujuan

DanaPintar AI saat ini = aplikasi web Streamlit (Python), **satu file** ~3.974 baris. Akan **ditulis ulang total** sebagai aplikasi mobile **Flutter (Dart)**.

**Keputusan arah (final):**
- 📱 **Android dulu**, didistribusikan sebagai **APK via Firebase App Distribution** (link "klik → install"). **Bukan** Play Store (hindari biaya). iOS ditunda (butuh Apple Developer $99/th — tidak bisa via link).
- 🔒 **100% LOKAL — semua data keuangan disimpan di HP, tanpa cloud.** Privasi maksimal, biaya server Rp 0.
- 💾 **Backup/Restore manual ke file** sebagai jaring pengaman anti-kehilangan data.
- 🤖 Fitur AI (Scan & DanaBot) **ditunda**; saat tiba waktunya, jalan lewat **proxy tipis** (Supabase Edge Function — satu-satunya unsur cloud, hanya untuk AI, bukan simpan data).

**Yang berpindah dari versi lama:** logika domain ("opini produk"), prompt Gemini, dan ide UX. **Kode UI & backend cloud TIDAK berpindah.**

---

## 2. Konsensus yang Sudah Disepakati

| Aspek | Keputusan |
|---|---|
| Platform | Flutter; **Android dulu** via APK link |
| Distribusi | **Firebase App Distribution** (gratis, link install) |
| Penyimpanan data | **100% lokal di HP** (DB SQLite via `drift`) — tanpa cloud |
| Backup | **Export/Import ke file** (tombol manual; di sinilah izin folder dipakai) |
| Auth | **Kunci lokal opsional** (PIN/biometrik) — tanpa akun/email |
| Fitur AI | Ditunda; nanti via **proxy tipis** Edge Function |
| Supabase project `danapintar` | **Di-pause** (gratis); diaktifkan saat fase AI |
| Arsitektur | Layered + tested; domain layer murni |
| State management | Riverpod |
| Model data | `freezed` + `json_serializable` |

---

## 3. Arsitektur Target

```
danapintar/
├── lib/
│   ├── core/
│   │   ├── theme/            # ThemeData (pengganti ~320 baris CSS)
│   │   ├── constants/        # KAMUS_BULAN, kategori default, dll.
│   │   └── utils/            # rp(), wib(), format tanggal WIB
│   ├── data/
│   │   ├── local/            # ⭐ drift: definisi tabel + DAO (SQLite lokal)
│   │   ├── models/           # freezed: Transaksi, Pemasukan, Wallet, Goal, ...
│   │   ├── repositories/     # Repository (baca/tulis ke DB lokal)
│   │   └── backup/           # ⭐ Export/Import file backup (.json) + izin folder
│   ├── domain/               # ⭐ JIWA APP — ZERO dependensi UI/DB
│   │   ├── health_score.dart
│   │   ├── budget_rules.dart
│   │   ├── impulse_detector.dart
│   │   ├── trend_auditor.dart
│   │   └── badges.dart
│   └── presentation/
│       ├── providers/        # Riverpod providers
│       └── features/
│           ├── lock/  dashboard/  transaksi/  pemasukan/
│           ├── wallet/  goals/  networth/  hutang/
│           ├── kategori/  import_csv/  visualisasi/  backup/
│           ├── scan/  chat/  laporan/        # (fase AI / lanjutan)
└── (Supabase hanya dipakai NANTI untuk Edge Function AI — di luar repo app)
```

### Aturan emas
1. **`domain/` murni Dart** — tidak impor apa pun dari `data/`, `presentation/`, atau Flutter. Bisa dites tanpa emulator.
2. **Hanya `data/repositories/`** yang menyentuh DB lokal. UI tidak pernah query DB langsung.
3. **Tidak ada secret di app.** Saat fase AI tiba, panggilan Gemini lewat Edge Function (key di server).
4. **Data tidak pernah keluar HP** kecuali saat user sendiri mengekspor file backup.

### Stack final
| Kebutuhan | Package |
|---|---|
| DB lokal | **`drift`** (SQLite bertipe) |
| State | `flutter_riverpod` |
| Model | `freezed`, `json_serializable` |
| Kunci app | `local_auth` (PIN/biometrik) — opsional |
| Backup/share file | `file_picker`, `share_plus`, `path_provider` |
| Chart | `fl_chart` + grid kustom (heatmap kalender) |
| PDF/laporan | `pdf` + `printing` |
| Kamera/file (scan) | `image_picker` / `file_picker` |
| Format angka/tanggal | `intl` |

---

## 4. Pemetaan Fitur: Lama → Baru

| Fitur (Streamlit) | Status | Catatan |
|---|---|---|
| Auth akun (email/password) | 🔁 Ganti | → kunci lokal PIN/biometrik (opsional), tanpa akun |
| ☁️ Sinkronisasi cloud | ❌ Hapus | Diganti **backup/restore file** |
| Pengeluaran (presisi jam-menit) | ✅ Pertahankan | Inti |
| Pemasukan | ✅ Pertahankan | Inti |
| Anggaran terkunci per bulan | ✅ Pertahankan | Pembeda |
| Target tabungan + batas belanja | ✅ Pertahankan | → domain |
| Budget per kategori | ✅ Pertahankan | |
| Multi-wallet | ✅ Pertahankan | |
| Net Worth tracker | ✅ Pertahankan | |
| Hutang/Piutang | ✅ Pertahankan | |
| Financial Goals | ✅ Pertahankan | |
| Custom kategori | ✅ Pertahankan | |
| Recurring templates | ✅ Pertahankan | |
| Import CSV mutasi | ✅ Pertahankan | parsing Dart |
| Health Score | ✅ Pertahankan | → domain + **test** |
| Gamifikasi/badge | ✅ Pertahankan | → domain + **test** |
| Auditor tren MoM | ✅ Pertahankan | → domain (butuh histori → makin penting backup) |
| Deteksi jam rawan | ✅ Pertahankan | → domain |
| Visualisasi (tren/kategori/komparatif) | ✅ Pertahankan | Altair → `fl_chart` |
| Heatmap kalender | ✅ Pertahankan | grid kustom |
| Onboarding wizard | ✅ Pertahankan | |
| Notifikasi in-app | ✅ Pertahankan | |
| Laporan PDF & visual | ✅ Pertahankan | → `pdf`/`printing` |
| **Backup & Restore ke file** | 🆕 Tambah | Tombol Export/Import; **izin folder di sini** |
| Scan Struk (Gemini Vision) | 🔁 Fase AI | Via Edge Function proxy |
| DanaBot chat (Gemini) | 🔁 Fase AI | Via Edge Function proxy |
| Dark mode | ✅ Pertahankan | → `ThemeData` |
| Changelog | ✅ Pertahankan | aset statis |
| ~320 baris CSS + UI Streamlit | ❌ Buang | → widget Flutter |

---

## 5. Skema Data LOKAL (drift / SQLite)

Entitas sama seperti versi lama, tapi sekarang **tabel SQLite di HP** (bukan Postgres cloud). Tanpa `user_id` & tanpa RLS (single-user per device).

| Tabel lokal | Kolom utama |
|---|---|
| `profile` | nama, lokasi, foto_path (opsional) |
| `budgets` | bulan_key, nominal |
| `savings_goals` | bulan_key, target_nominal |
| `budget_kategori` | bulan_key, kategori, nominal |
| `custom_kategori` | id, nama, tipe, ikon |
| `wallets` | id, nama, tipe, saldo_awal, warna |
| `financial_goals` | id, nama, target_nominal, terkumpul, deadline, kategori, ikon |
| `networth_history` | id, bulan_key, total_aset, total_liabilitas, catatan_aset, catatan_liabilitas |
| `transaksi` | id, catatan, nominal, kategori, sifat, wallet_id, waktu_transaksi |
| `pemasukan` | id, sumber, nominal, kategori, wallet_id, waktu_pemasukan |
| `hutang_piutang` | id, tipe, nama, nominal, status, tanggal |
| `recurring_templates` | id, ... (frekuensi: Bulanan/Mingguan/2 Mingguan) |

> **`bulan_key`:** `"{NamaBulan}_{tahun}"`, mis. `"Mei_2026"`. **Timezone:** Asia/Jakarta (WIB).

### Format file Backup (Export/Import)
- Satu file `.json` berisi seluruh tabel di atas + nomor versi skema (untuk kompatibilitas saat upgrade).
- Export: user pilih lokasi simpan (folder HP / Drive / share) → **muncul izin folder**.
- Import: user pilih file → app validasi versi → restore (mengganti/menggabung data).

---

## 6. Domain Layer — Rumus Bisnis (port SETIA, wajib di-test)

> Diekstrak langsung dari `aplikasi_keuangan.py`. **Tidak berubah** meski sumber data jadi lokal.

### 6.1 Batas Belanja
```
batasBelanja = max(0, anggaran - targetTabungan)
```

### 6.2 Health Score (di-cap 100)
**a) Rasio Tabungan (maks 40)**
```
jika anggaran>0 dan target>0:
    batas = max(0, anggaran - target)
    s1 = 40                                                jika totalPengeluaran <= batas
       = max(0, 40 - ((totalPengeluaran - batas)/anggaran) * 80)  jika tidak
jika anggaran>0 (target=0): s1 = max(0, (1 - totalPengeluaran/anggaran) * 40)
jika tidak: s1 = 20
```
**b) Konsistensi Catat (maks 20)**
```
s2 = min(1.0, jumlahHariUnikTransaksi / 15) * 20   (0 jika tidak ada data)
```
**c) Porsi Sukarela (maks 20)**
```
jika anggaran>0 dan ada data:
    r = totalSukarela / anggaran
    s3 = 20 jika r<=0.3 ; 12 jika r<=0.5 ; selain itu max(0,(1-r)*20)
jika tidak: s3 = 10
```
**d) Tren Pengeluaran (maks 20)**
```
default 10
jika ada histori bulan lain:
    rata = rata-rata total pengeluaran bulan-bulan sebelumnya
    s4 = 20 jika totalBulanIni < rata
       = max(0, (1 - (totalBulanIni - rata)/max(rata,1)) * 20) jika tidak
```
**Total:** `min(100, s1+s2+s3+s4)`
**Label:** `>=80` Excellent · `>=60` Sehat · `>=40` Perlu Perhatian · `<40` Kritis

### 6.3 Deteksi Jam Rawan (impulsif)
```
transaksi rawan = jam >= 20 ATAU jam <= 5
```

### 6.4 Alert Porsi Sukarela
```
persenSukarela = (totalSukarela / anggaran) * 100   →  alert jika > 50
```

### 6.5 Badges
| Badge | Syarat |
|---|---|
| 🗓️ Pencatat Setia | streak pencatatan ≥ 7 hari berturut-turut |
| 🏆 Penabung Konsisten | ≥ 2 bulan dengan total ≤ (anggaran − target) |
| 🌈 Pengelola Lengkap | ≥ 5 kategori berbeda di bulan terakhir |
| 💎 Big Saver | target ≥ 20% anggaran **dan** total ≤ (anggaran − target) di suatu bulan |

### 6.6 Konstanta
- **Kategori pengeluaran default:** Makanan, Transportasi, Hiburan/Gaya Hidup, Kebutuhan Rumah/Kesehatan, Tagihan Wajib, Lain-lain
- **Kategori pemasukan default:** Gaji, Freelance, Bisnis, Investasi, Hadiah/Bonus, Passive Income, Lain-lain
- **Sifat:** Wajib / Sukarela · **Anggaran min:** 10.000 · **default:** 1.000.000

---

## 7. Fitur AI (Fase lanjutan — proxy tipis)

Saat fase AI tiba:
- Aktifkan kembali (restore) project Supabase `danapintar` (`mgaonsjwcaahwlcfqxeg`).
- Deploy **Edge Functions** `gemini-scan` & `gemini-chat`. **Hanya** sebagai perantara ke Gemini — **tidak menyimpan data keuangan**. Gemini API key = secret di server.
- App mengirim foto struk / pesan chat ke endpoint, menerima hasil. Data keuangan tetap di HP.
- Model awal: `gemini-2.5-flash`.

---

## 8. Roadmap Berfase

### Fase 0 — Pondasi
- Inisialisasi project Flutter + struktur folder layered.
- Setup `drift` (skema DB lokal §5) + DAO.
- `ThemeData` dasar (dark mode) — pengganti CSS.
- (Opsional) kunci lokal PIN/biometrik.
- **DoD:** app jalan, DB lokal terbentuk, bisa lihat dashboard kosong.

### Fase 1 — MVP Core (target: bisa di-share via APK link)
- Model `freezed` + repository (transaksi, pemasukan, budget, wallet).
- Domain: `health_score`, `budget_rules`, `impulse_detector`, `badges` (+ **unit test**).
- UI: dashboard, input/list pengeluaran & pemasukan (pagination + search/filter), anggaran terkunci, target tabungan, wallet.
- Chart dasar (`fl_chart`).
- **Backup/Restore ke file** (penting sejak awal — jaring pengaman data).
- **DoD:** alur catat→lihat→analisis lengkap; test domain hijau; build APK rilis.

### Fase 2 — Fitur Lanjutan
- Goals, Net Worth, Hutang/Piutang, custom kategori, budget per kategori, recurring.
- Import CSV mutasi, heatmap kalender, dashboard komparatif.
- Laporan PDF/visual, onboarding, notifikasi in-app, changelog.

### Fase 3 — AI (opsional, butuh internet)
- Restore project Supabase, deploy Edge Functions `gemini-scan` + `gemini-chat`.
- UI Scan Struk (kamera/file → preview/edit → simpan) & DanaBot chat.

### Fase 4 — Distribusi
- Build APK release (signed).
- Setup **Firebase App Distribution** → bagikan link install ke tester/user.
- (Nanti, jika mau ke Play Store/iOS → siapkan akun berbayar + privacy policy.)

---

## 9. Risiko & Mitigasi

| Risiko | Dampak | Mitigasi |
|---|---|---|
| **Kehilangan data** (HP reset/rusak/uninstall) | Data keuangan lenyap | **Backup/Restore ke file** (Fase 1), edukasi user backup rutin |
| Data lama di Supabase produksi lama | Tidak ikut pindah ke app lokal | Putuskan: mulai bersih, atau buat importer satu kali (lihat open items) |
| Scope creep (14 tab) | Tak kunjung selesai | Fasing ketat; MVP core dulu |
| Format backup berubah saat upgrade | Restore gagal | Sertakan nomor versi skema di file backup |
| Terjemahan rumus tak setia | Hasil beda dari versi lama | Unit test berbasis rumus §6 |
| "Install dari sumber tak dikenal" (Android) | User bingung saat install APK | Sediakan panduan singkat saat bagikan link |

---

## 10. Open Items (perlu diputuskan)

1. **Data lama:** apakah ada data di Supabase produksi lama (`lmyvddqwmmpsrpigzygi`) yang perlu di-import sekali ke app lokal, atau mulai dari nol?
2. **Bundle/Application ID** (mis. `com.hendrawan.danapintar`).
3. **Kunci lokal**: pakai PIN/biometrik, atau tanpa kunci sama sekali?
4. **Minimum Android** (mis. Android 8/API 26+).
5. **Branding**: pertahankan palet dark-hijau sekarang atau refresh?

---

## 11. Definition of Done (keseluruhan)

- [ ] Semua fitur §4 berstatus "Pertahankan/Tambah" hadir di Flutter.
- [ ] Data tersimpan 100% lokal (drift), tidak ada data keuangan ke cloud.
- [ ] **Backup/Restore ke file berfungsi & teruji.**
- [ ] Domain layer bebas dependensi UI/DB, ter-cover unit test.
- [ ] Tidak ada secret/API key di dalam app.
- [ ] Build APK release sukses & terdistribusi via Firebase App Distribution.

---

> **Catatan:** Implementasi kode **belum dimulai**. Menunggu persetujuan rencana ini.

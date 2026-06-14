# Rencana Migrasi: DanaPintar AI → Flutter (Dart)

> Status: **DRAFT untuk review** · Belum ada implementasi kode.
> Tujuan dokumen ini: mencapai konsensus 100% sebelum baris kode pertama ditulis.

---

## 1. Ringkasan & Tujuan

DanaPintar AI saat ini adalah aplikasi web Streamlit (Python) berupa **satu file** `aplikasi_keuangan.py` (~3.974 baris). Aplikasi akan **ditulis ulang total** sebagai aplikasi mobile native menggunakan **Flutter (Dart)**, dengan tujuan akhir **distribusi resmi di App Store & Google Play**.

Ini adalah **rewrite**, bukan port. Reuse kode Python ≈ 0%. Yang berpindah adalah *konsep, logika bisnis, prompt AI, dan backend* — bukan kode UI.

### Aset yang bertahan utuh
- **Backend Supabase** (Postgres + Auth + Storage + RLS) → dipakai langsung via `supabase_flutter`.
- **Skema database & data pengguna** → tidak perlu disentuh (hanya didokumentasikan ulang sebagai migrasi).
- **Logika domain / "opini produk"** → diterjemahkan ke Dart + **dites**.
- **Prompt Gemini** (scan struk + DanaBot) → aset teks, dipindahkan ke Edge Functions.

---

## 2. Konsensus yang Sudah Disepakati

| Aspek | Keputusan |
|---|---|
| Platform | Flutter, target App Store + Google Play (native) |
| Strategi AI | Proxy via Supabase Edge Functions (key TIDAK ditanam di app) |
| Arsitektur | Layered + tested; domain layer murni tanpa dependensi UI/DB |
| State management | Riverpod |
| Fasing AI | Bertahap — rilis core dulu, AI menyusul di update |
| Offline | Tidak untuk v1 (online-first); dapat ditambah kemudian |
| Model data | `freezed` + `json_serializable` (anti dict mentah) |

---

## 3. Arsitektur Target

```
danapintar/
├── lib/
│   ├── core/
│   │   ├── theme/            # ThemeData (pengganti ~320 baris CSS)
│   │   ├── constants/        # KAMUS_BULAN, kategori default, dll.
│   │   └── utils/            # rp(), wib(), parsing waktu WIB
│   ├── data/
│   │   ├── models/           # freezed: Transaksi, Pemasukan, Wallet, Goal,
│   │   │                     #          NetWorth, Hutang, BudgetKategori, ...
│   │   └── repositories/     # SATU-SATUNYA tempat akses Supabase
│   ├── domain/               # ⭐ JIWA APP — ZERO dependensi UI/Supabase
│   │   ├── health_score.dart
│   │   ├── budget_rules.dart
│   │   ├── impulse_detector.dart
│   │   ├── trend_auditor.dart
│   │   └── badges.dart
│   └── presentation/
│       ├── providers/        # Riverpod providers
│       └── features/
│           ├── auth/  dashboard/  transaksi/  pemasukan/
│           ├── wallet/  goals/  networth/  hutang/
│           ├── kategori/  import_csv/  visualisasi/
│           ├── scan/  chat/  laporan/        # (fase AI / lanjutan)
├── supabase/
│   ├── migrations/           # skema DB ter-version (bukan komentar lagi)
│   └── functions/
│       ├── gemini-scan/      # Edge Function: scan struk
│       └── gemini-chat/      # Edge Function: DanaBot
└── test/
    └── domain/               # unit test untuk SEMUA rumus finansial
```

### Aturan emas
1. **`domain/` tidak boleh mengimpor** apa pun dari `data/`, `presentation/`, Supabase, atau Flutter. Murni Dart → bisa dites tanpa emulator.
2. **Hanya `data/repositories/`** yang menyentuh Supabase. UI tidak pernah memanggil DB langsung (berbeda total dari versi sekarang).
3. **Tidak ada secret di app.** Semua panggilan Gemini lewat Edge Function.

### Stack final
| Kebutuhan | Package |
|---|---|
| Backend | `supabase_flutter` |
| State | `flutter_riverpod` |
| Model | `freezed`, `json_serializable` |
| Chart | `fl_chart` (tren/bar/donat) + grid kustom (heatmap kalender) |
| PDF/laporan | `pdf` + `printing` |
| Kamera/file (scan) | `image_picker` / `file_picker` |
| Format angka/tanggal | `intl` |

---

## 4. Pemetaan Fitur: Lama → Baru

| Fitur (Streamlit) | Status | Catatan migrasi |
|---|---|---|
| Auth (login/register) | ✅ Pertahankan | `supabase_flutter` auth |
| Pengeluaran + presisi jam-menit | ✅ Pertahankan | Inti |
| Pemasukan | ✅ Pertahankan | Inti |
| Anggaran terkunci per bulan | ✅ Pertahankan | Pembeda produk |
| Target tabungan + batas belanja | ✅ Pertahankan | → domain `budget_rules` |
| Budget per kategori | ✅ Pertahankan | |
| Multi-wallet | ✅ Pertahankan | |
| Net Worth tracker | ✅ Pertahankan | |
| Hutang/Piutang | ✅ Pertahankan | |
| Financial Goals | ✅ Pertahankan | |
| Custom kategori | ✅ Pertahankan | |
| Recurring templates | ✅ Pertahankan | |
| Import CSV mutasi | ✅ Pertahankan | `file_picker` + parsing Dart |
| Health Score | ✅ Pertahankan | → domain + **test** |
| Gamifikasi/badge | ✅ Pertahankan | → domain + **test** |
| Auditor tren MoM | ✅ Pertahankan | → domain |
| Deteksi jam rawan | ✅ Pertahankan | → domain |
| Visualisasi (tren/kategori/komparatif) | ✅ Pertahankan | Altair → `fl_chart` |
| Heatmap kalender | ✅ Pertahankan | grid kustom Flutter |
| Onboarding wizard | ✅ Pertahankan | |
| Notifikasi in-app | ✅ Pertahankan | (push native = peningkatan opsional) |
| Laporan PDF & visual | ✅ Pertahankan | FPDF/matplotlib → `pdf`/`printing` |
| Scan Struk (Gemini Vision) | 🔁 Fase AI | Lewat Edge Function `gemini-scan` |
| DanaBot chat (Gemini) | 🔁 Fase AI | Lewat Edge Function `gemini-chat` |
| Dark mode | ✅ Pertahankan | → `ThemeData` |
| Changelog | ✅ Pertahankan | aset statis |
| ~320 baris CSS | ❌ Buang | Ganti `ThemeData` |
| Seluruh UI Streamlit | ❌ Buang | Ganti widget Flutter |

---

## 5. Skema Database (didokumentasikan ulang)

Tabel yang terdeteksi dari kode (semua **wajib RLS aktif**, kunci `user_id`):

| Tabel | Kolom utama |
|---|---|
| `profiles` | id (uid), nama, lokasi, foto_url, updated_at |
| `budgets` | user_id, bulan_key, nominal |
| `savings_goals` | user_id, bulan_key, target_nominal |
| `budget_kategori` | user_id, bulan_key, kategori, nominal |
| `custom_kategori` | id, user_id, nama, tipe, ikon |
| `wallets` | id, user_id, nama, tipe, saldo_awal, warna |
| `financial_goals` | id, user_id, nama, target_nominal, terkumpul, deadline, kategori, ikon |
| `networth_history` | id, user_id, bulan_key, total_aset, total_liabilitas, catatan_aset (jsonb), catatan_liabilitas (jsonb) |
| `transaksi` | id, user_id, catatan, nominal, kategori, sifat, wallet_id, waktu_transaksi |
| `pemasukan` | id, user_id, sumber, nominal, kategori, wallet_id, waktu_pemasukan |
| `hutang_piutang` | id, user_id, tipe, nama, nominal, status, tanggal |
| `recurring_templates` | id, user_id, ... (frekuensi: Bulanan/Mingguan/2 Mingguan) |

Storage bucket: `profile-photos`.

> **Format `bulan_key`:** `"{NamaBulan}_{tahun}"`, mis. `"Mei_2026"`.

### ⚠️ Tindakan keamanan WAJIB (Fase 0)
- **Verifikasi setiap tabel benar-benar punya RLS aktif + policy SELECT/INSERT/UPDATE/DELETE berbasis `user_id = auth.uid()`.** Ini krusial karena anon key memang ditanam di app mobile (normal). RLS = satu-satunya pelindung antar-user.
- Pindahkan skema dari komentar di kode ke `supabase/migrations/` (ter-version).

---

## 6. Domain Layer — Rumus Bisnis yang Harus Diport (SETIA)

> Diekstrak langsung dari `aplikasi_keuangan.py`. Inilah "jiwa" produk. Semua wajib punya unit test di `test/domain/`.

### 6.1 Batas Belanja
```
batasBelanja = max(0, anggaran - targetTabungan)
```

### 6.2 Health Score (total di-cap 100)
**a) Rasio Tabungan (maks 40)**
```
jika anggaran>0 dan target>0:
    batas = max(0, anggaran - target)
    s1 = 40                            jika totalPengeluaran <= batas
       = max(0, 40 - ((totalPengeluaran - batas) / anggaran) * 80)   jika tidak
jika anggaran>0 (target=0):
    s1 = max(0, (1 - totalPengeluaran/anggaran) * 40)
jika tidak:
    s1 = 20
```
**b) Konsistensi Catat (maks 20)**
```
s2 = min(1.0, jumlahHariUnikTransaksi / 15) * 20   (0 jika tidak ada data)
```
**c) Porsi Sukarela (maks 20)**
```
jika anggaran>0 dan ada data:
    r = totalSukarela / anggaran
    s3 = 20  jika r<=0.3 ; 12 jika r<=0.5 ; selain itu max(0,(1-r)*20)
jika tidak: s3 = 10
```
**d) Tren Pengeluaran (maks 20)**
```
default 10
jika ada histori bulan lain:
    rata = rata-rata total pengeluaran bulan-bulan sebelumnya
    s4 = 20  jika totalBulanIni < rata
       = max(0, (1 - (totalBulanIni - rata)/max(rata,1)) * 20)  jika tidak
```
**Total:** `min(100, s1+s2+s3+s4)`

**Label:** `>=80` Excellent · `>=60` Sehat · `>=40` Perlu Perhatian · `<40` Kritis

### 6.3 Deteksi Jam Rawan (impulsif)
```
transaksi rawan = jam >= 20 ATAU jam <= 5   (malam/dini hari)
```

### 6.4 Alert Porsi Sukarela
```
persenSukarela = (totalSukarela / anggaran) * 100
alert "berlebihan" jika persenSukarela > 50
```

### 6.5 Badges (gamifikasi)
| Badge | Syarat |
|---|---|
| 🗓️ Pencatat Setia | streak pencatatan ≥ 7 hari berturut-turut |
| 🏆 Penabung Konsisten | ≥ 2 bulan dengan total pengeluaran ≤ (anggaran − target) |
| 🌈 Pengelola Lengkap | ≥ 5 kategori berbeda di bulan terakhir |
| 💎 Big Saver | target ≥ 20% anggaran **dan** total ≤ (anggaran − target) di suatu bulan |

### 6.6 Konstanta
- **Kategori pengeluaran default:** Makanan, Transportasi, Hiburan/Gaya Hidup, Kebutuhan Rumah/Kesehatan, Tagihan Wajib, Lain-lain
- **Kategori pemasukan default:** Gaji, Freelance, Bisnis, Investasi, Hadiah/Bonus, Passive Income, Lain-lain
- **Sifat:** Wajib / Sukarela
- **Anggaran minimum:** 10.000 · **default:** 1.000.000
- **Timezone:** Asia/Jakarta (WIB)

---

## 7. Kontrak Edge Functions (Fase AI)

Key Gemini disimpan sebagai **secret di Supabase**, bukan di app.

### 7.1 `gemini-scan` (scan struk)
- **Request:** `{ image_base64, mime_type }` (auth: JWT user)
- **Proses:** kirim ke Gemini Vision dengan prompt scan struk (port dari kode).
- **Response (JSON):**
  ```json
  {
    "berhasil": true, "confidence": "tinggi",
    "nama_toko": "Indomaret", "tanggal": "2026-05-31",
    "total": 87500, "items": [{"nama":"...","harga":4000,"qty":2}],
    "kategori_saran": "Makanan", "nama_transaksi": "...",
    "catatan_ai": "...", "gagal_alasan": ""
  }
  ```
- App menampilkan **preview & edit** sebelum simpan (jangan auto-save).

### 7.2 `gemini-chat` (DanaBot)
- **Request:** `{ messages[], konteks_keuangan }` (auth: JWT user)
- **System prompt** (port dari kode) + ringkasan keuangan periode aktif.
- **Response:** `{ reply }`

> Model awal: `gemini-2.5-flash` (sesuai versi sekarang) — dapat ditinjau ulang saat fase AI.

---

## 8. Roadmap Berfase

### Fase 0 — Pondasi & Keamanan
- ✅ Verifikasi & kuatkan RLS produksi (PRIORITAS keamanan).
- Inisialisasi project Flutter + struktur folder layered.
- Migrasi skema DB → `supabase/migrations/`.
- Auth Supabase (login/register/logout) jalan di Flutter.
- Setup `ThemeData` dasar (dark mode).
- **DoD:** user bisa login dan melihat dashboard kosong.

### Fase 1 — MVP Core (target: submit ke store)
- Model `freezed` untuk entitas inti.
- Repository: transaksi, pemasukan, budget, wallet.
- Domain: `health_score`, `budget_rules`, `impulse_detector`, `badges` (+ **unit test**).
- UI: dashboard (balance card, health score, metrik), input/list pengeluaran & pemasukan (pagination + search/filter), anggaran terkunci, target tabungan, wallet.
- Chart dasar (`fl_chart`): tren & kategori.
- **DoD:** alur catat→lihat→analisis dasar lengkap; semua test domain hijau; siap build rilis.

### Fase 2 — Fitur Lanjutan
- Goals, Net Worth, Hutang/Piutang, custom kategori, budget per kategori.
- Import CSV mutasi, recurring templates.
- Heatmap kalender, dashboard komparatif.
- Laporan PDF/visual.
- Onboarding wizard, notifikasi in-app, changelog.

### Fase 3 — AI
- Edge Functions `gemini-scan` + `gemini-chat` (secret Gemini di server).
- UI Scan Struk (kamera/file → preview/edit → simpan).
- UI DanaBot chat.

### Fase 4 — Rilis Store
- Privacy policy + deklarasi data (termasuk data yang dikirim ke Gemini).
- Ikon, splash, screenshot store, akun demo untuk reviewer.
- Akun Apple Developer ($99/th) & Google Play ($25 sekali).

---

## 9. Risiko & Mitigasi

| Risiko | Dampak | Mitigasi |
|---|---|---|
| RLS ternyata tidak aktif/bocor | Data semua user terekspos (anon key publik) | **Fase 0 wajib** verifikasi sebelum hal lain |
| Scope creep (14 tab sekaligus) | Tidak pernah selesai | Fasing ketat; MVP core dulu |
| Review Apple menolak app finansial | Tertunda rilis | Privacy policy + akun demo sejak awal |
| Biaya Gemini membengkak | Tagihan | Edge Function + rate limit per user |
| Terjemahan rumus tidak setia | Hasil beda dari versi lama | Unit test berbasis rumus di §6 |
| Mengulang "dosa monolit" | Sulit dirawat lagi | Aturan emas arsitektur §3 ditegakkan |

---

## 10. Yang Masih Perlu Diputuskan (Open Items)

1. **Nama package/bundle ID** (mis. `com.hendrawan.danapintar`).
2. **Branding visual** mobile (pertahankan palet dark hijau sekarang, atau refresh?).
3. **Penyedia push notification** (jika notifikasi diangkat ke native nanti).
4. **Strategi versioning data** jika skema perlu berubah saat migrasi.
5. **Minimum OS** target (mis. iOS 13+, Android 8+).

---

## 11. Definition of Done (keseluruhan)

- [ ] Semua fitur §4 berstatus "Pertahankan" hadir di Flutter.
- [ ] Domain layer 100% bebas dependensi UI/DB, ter-cover unit test.
- [ ] Tidak ada secret/API key di dalam app.
- [ ] RLS terverifikasi untuk semua tabel.
- [ ] Skema DB ter-version di `supabase/migrations/`.
- [ ] Build rilis lolos di iOS & Android.
- [ ] Privacy policy & kelengkapan store siap.

---

> **Catatan:** Dokumen ini adalah artefak konsensus. Implementasi kode **tidak dimulai** sampai Anda menyetujui rencana ini (atau kita iterasi lagi).

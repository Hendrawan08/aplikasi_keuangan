import streamlit as st
from supabase import create_client, Client
import pandas as pd
import altair as alt
from datetime import datetime, time, date
import traceback

# ==========================================
# SETUP HALAMAN UTAMA
# ==========================================
st.set_page_config(page_title="DanaPintar AI Premium", page_icon="📊", layout="wide")
st.markdown("<h1 style='text-align: center; color: #2E7D32;'>📊 DanaPintar AI — Multi-Month Auditor</h1>", unsafe_allow_html=True)
st.markdown("<p style='text-align: center; color: #37474F;'>Sistem Pencatatan Presisi Manual dengan Analisis Otak AI Lintas Waktu</p>", unsafe_allow_html=True)
st.markdown("---")

# ==========================================
# KONFIGURASI SUPABASE (Gunakan secrets di production)
# ==========================================
SUPABASE_URL = "https://lmyvddqwmmpsrpigzygi.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxteXZkZHF3bW1wc3JwaWd6eWdpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkxNzQ0NjQsImV4cCI6MjA5NDc1MDQ2NH0.Cv41r1Mo6fR164y3g8OX-zP_Cmj0NiR9zyRzkmYJi9I"

@st.cache_resource
def init_supabase() -> Client:
    try:
        client = create_client(SUPABASE_URL, SUPABASE_KEY)
        # Tes koneksi sederhana (opsional)
        client.auth.get_session()
        return client
    except Exception as e:
        st.error(f"❌ Gagal tersambung ke database cloud: {e}")
        st.stop()

supabase = init_supabase()

# ==========================================
# SESSION STATE & PERSISTENSI ANGGARAN
# ==========================================
if 'user_aktif' not in st.session_state:
    st.session_state.user_aktif = None
if 'anggaran_terkunci' not in st.session_state:
    st.session_state.anggaran_terkunci = {}
if 'pesan_error' not in st.session_state:
    st.session_state.pesan_error = ""

KAMUS_BULAN = {
    1: "Januari", 2: "Februari", 3: "Maret", 4: "April", 5: "Mei", 6: "Juni",
    7: "Juli", 8: "Agustus", 9: "September", 10: "Oktober", 11: "November", 12: "Desember"
}

def muat_anggaran_dari_cloud(user_id):
    """Ambil semua anggaran yang tersimpan di tabel budgets untuk user ini."""
    try:
        res = supabase.table("budgets").select("*").eq("user_id", user_id).execute()
        if res.data:
            for row in res.data:
                key = row["bulan_key"]
                st.session_state.anggaran_terkunci[key] = row["nominal"]
    except Exception as e:
        st.warning(f"Gagal memuat anggaran tersimpan: {e}")

def simpan_anggaran_ke_cloud(user_id, bulan_key, nominal):
    """Simpan satu entri anggaran ke tabel budgets (upsert)."""
    try:
        # Hapus dulu jika ada
        supabase.table("budgets").delete().eq("user_id", user_id).eq("bulan_key", bulan_key).execute()
        # Insert baru
        supabase.table("budgets").insert({
            "user_id": user_id,
            "bulan_key": bulan_key,
            "nominal": nominal,
            "updated_at": datetime.now().isoformat()
        }).execute()
    except Exception as e:
        st.error(f"Gagal menyimpan anggaran ke cloud: {e}")

# ==========================================
# 3. GERBANG AUTH
# ==========================================
if st.session_state.user_aktif is None:
    tab_login, tab_daftar = st.tabs(["🔑 Masuk", "📝 Daftar"])
    with tab_login:
        email = st.text_input("Email", key="log_email")
        password = st.text_input("Password", type="password", key="log_pass")
        if st.button("Masuk 🚀"):
            try:
                resp = supabase.auth.sign_in_with_password({"email": email, "password": password})
                st.session_state.user_aktif = resp.user
                muat_anggaran_dari_cloud(resp.user.id)  # muat anggaran setelah login
                st.rerun()
            except Exception as e:
                st.error(f"Login gagal: {e}")
    with tab_daftar:
        email_reg = st.text_input("Email Baru", key="reg_email")
        password_reg = st.text_input("Password (min 6 karakter)", type="password", key="reg_pass")
        if st.button("Daftar ✨"):
            try:
                supabase.auth.sign_up({"email": email_reg, "password": password_reg})
                st.success("Akun berhasil dibuat! Silakan masuk.")
            except Exception as e:
                st.error(f"Pendaftaran gagal: {e}")
    st.stop()

# ==========================================
# 4. DASHBOARD UTAMA SETELAH LOGIN
# ==========================================
uid = st.session_state.user_aktif.id
email_user = st.session_state.user_aktif.email
waktu_sekarang = datetime.now()

# Muat anggaran jika belum (saat pertama masuk session)
if not st.session_state.anggaran_terkunci:
    muat_anggaran_dari_cloud(uid)

# ---------- SIDEBAR ----------
st.sidebar.success(f"👤 {email_user}")
if st.sidebar.button("Logout 🚪"):
    try:
        supabase.auth.sign_out()
    except:
        pass
    st.session_state.user_aktif = None
    st.session_state.anggaran_terkunci = {}
    st.rerun()

st.sidebar.markdown("---")
st.sidebar.subheader("🔒 Kunci Anggaran Bulanan")

# Pemilihan bulan & tahun anggaran
bln_budget = st.sidebar.selectbox("Bulan Anggaran", list(KAMUS_BULAN.values()),
                                  index=waktu_sekarang.month - 1)
thn_budget = st.sidebar.selectbox("Tahun Anggaran", [2025, 2026, 2027], index=1)
key_budget = f"{bln_budget}_{thn_budget}"

# Cek status anggaran
if key_budget in st.session_state.anggaran_terkunci:
    budget_aktif = st.session_state.anggaran_terkunci[key_budget]
    st.sidebar.success(f"🔒 Anggaran {bln_budget} terkunci:\n**Rp {budget_aktif:,.0f}**")
    if st.sidebar.button("🔓 Reset Anggaran (Hati-hati)"):
        # Konfirmasi reset
        with st.sidebar.expander("Konfirmasi Reset"):
            if st.button("Ya, reset anggaran ini"):
                del st.session_state.anggaran_terkunci[key_budget]
                # Hapus juga dari cloud
                try:
                    supabase.table("budgets").delete().eq("user_id", uid).eq("bulan_key", key_budget).execute()
                except:
                    pass
                st.rerun()
else:
    input_budget = st.sidebar.number_input(f"Set Anggaran {bln_budget} (Rp):",
                                           min_value=10000, value=1000000, step=100000)
    # Tombol kunci dengan konfirmasi cerdas
    if st.sidebar.button(f"🔐 KUNCI Anggaran {bln_budget}"):
        # Cek apakah sudah ada transaksi di bulan ini (peringatan)
        try:
            cek_transaksi = supabase.table("transaksi").select("id").eq("user_id", uid) \
                .gte("waktu_transaksi", f"{thn_budget}-{list(KAMUS_BULAN.keys())[list(KAMUS_BULAN.values()).index(bln_budget)]:02d}-01") \
                .limit(1).execute()
            if cek_transaksi.data:
                st.sidebar.warning("⚠️ Sudah ada transaksi di bulan ini. Mengunci anggaran mungkin tidak akurat jika sudah terlanjur boros.")
        except:
            pass
        st.session_state.anggaran_terkunci[key_budget] = input_budget
        simpan_anggaran_ke_cloud(uid, key_budget, input_budget)
        st.rerun()
    budget_aktif = input_budget  # untuk evaluasi sementara (jika belum terkunci, pakai input ini)

# ---------- FORM INPUT TRANSAKSI ----------
st.sidebar.markdown("---")
st.sidebar.subheader("✍️ Catat Transaksi")

with st.sidebar.form("form_transaksi", clear_on_submit=True):
    in_catatan = st.text_input("Nama Transaksi:", placeholder="Contoh: Beli Tissue")
    in_nominal = st.number_input("Nominal (Rp):", min_value=0, value=0, step=1000)
    in_kategori = st.selectbox("Kategori:", ["Makanan", "Transportasi", "Hiburan/Gaya Hidup",
                                             "Kebutuhan Rumah/Kesehatan", "Tagihan Wajib", "Lain-lain"])
    in_sifat = st.radio("Sifat:", ["Wajib", "Sukarela"])
    in_tanggal = st.date_input("Tanggal", waktu_sekarang.date())
    in_waktu = st.time_input("Jam & Menit", waktu_sekarang.time())
    submitted = st.form_submit_button("💾 Simpan Transaksi")

if submitted:
    # Validasi ketat
    errors = []
    if not in_catatan.strip():
        errors.append("Nama transaksi tidak boleh kosong.")
    if in_nominal <= 0:
        errors.append("Nominal harus lebih dari 0.")
    if errors:
        for e in errors:
            st.sidebar.error(e)
    else:
        try:
            waktu_gabung = datetime.combine(in_tanggal, in_waktu)
            data_insert = {
                "user_id": uid,
                "catatan": in_catatan.strip(),
                "nominal": in_nominal,
                "kategori": in_kategori,
                "sifat": in_sifat,
                "waktu_transaksi": waktu_gabung.isoformat()
            }
            resp = supabase.table("transaksi").insert(data_insert).execute()
            if resp.data:
                st.sidebar.success("✅ Transaksi tersimpan!")
                st.rerun()
            else:
                st.sidebar.error("Gagal menyimpan data, respons kosong.")
        except Exception as e:
            st.sidebar.error(f"Error: {e}")

# ---------- LOAD & OLAH DATA TRANSAKSI ----------
@st.cache_data(ttl=5)
def ambil_data_transaksi(user_id):
    try:
        res = supabase.table("transaksi").select("*").eq("user_id", user_id).order("waktu_transaksi", desc=False).execute()
        return res.data if res.data else []
    except Exception as e:
        st.error(f"Gagal mengambil data: {e}")
        return []

data_mentah = ambil_data_transaksi(uid)

if not data_mentah:
    st.info("📭 Belum ada transaksi. Mulai catat di sidebar kiri.")
    st.stop()

# Konversi ke DataFrame & Bersihkan
df = pd.DataFrame(data_mentah)

# Pastikan kolom nominal numerik, hapus yang invalid
df['nominal'] = pd.to_numeric(df['nominal'], errors='coerce')
invalid_nominal = df['nominal'].isna().sum()
if invalid_nominal > 0:
    st.warning(f"⚠️ Terdapat {invalid_nominal} transaksi dengan nominal tidak valid dan akan diabaikan.")
    df = df.dropna(subset=['nominal'])

# Konversi waktu dengan proteksi
try:
    df['waktu_transaksi'] = pd.to_datetime(df['waktu_transaksi'], errors='coerce')
    df = df.dropna(subset=['waktu_transaksi'])
    df['bulan'] = df['waktu_transaksi'].dt.month.map(KAMUS_BULAN)
    df['tahun'] = df['waktu_transaksi'].dt.year.astype(int)
    df['jam'] = df['waktu_transaksi'].dt.hour.fillna(0).astype(int)
    df['menit'] = df['waktu_transaksi'].dt.minute.fillna(0).astype(int)
except Exception as e:
    st.error(f"Gagal memproses kolom waktu: {e}")
    st.stop()

# ---------- FILTER DASHBOARD ----------
st.markdown("### 🗓️ Filter Periode")
c1, c2 = st.columns(2)
pilihan_bulan = c1.selectbox("Bulan", ["Semua Bulan"] + list(KAMUS_BULAN.values()),
                             index=waktu_sekarang.month if waktu_sekarang.month <= 12 else 0)
pilihan_tahun = c2.selectbox("Tahun", sorted(df['tahun'].unique()), index=len(sorted(df['tahun'].unique()))-1)

if pilihan_bulan == "Semua Bulan":
    df_view = df[df['tahun'] == pilihan_tahun].copy()
    # Anggaran evaluasi: total dari bulan-bulan yang sudah dikunci pada tahun tersebut
    budget_evaluasi = sum(
        v for k, v in st.session_state.anggaran_terkunci.items()
        if k.endswith(f"_{pilihan_tahun}")
    )
else:
    df_view = df[(df['bulan'] == pilihan_bulan) & (df['tahun'] == pilihan_tahun)].copy()
    key_eval = f"{pilihan_bulan}_{pilihan_tahun}"
    budget_evaluasi = st.session_state.anggaran_terkunci.get(key_eval, 0)

total_pengeluaran = df_view['nominal'].sum()
sisa = budget_evaluasi - total_pengeluaran

# ---------- METRIK ----------
km1, km2, km3 = st.columns(3)
km1.metric(f"Anggaran {pilihan_bulan} {pilihan_tahun}", f"Rp {budget_evaluasi:,.0f}")
km2.metric("Total Pengeluaran", f"Rp {total_pengeluaran:,.0f}")
if budget_evaluasi > 0:
    if sisa >= 0:
        km3.metric("Sisa / Hemat 🎉", f"Rp {sisa:,.0f}", delta="Aman 🟢")
    else:
        km3.metric("Defisit 🚨", f"Rp {abs(sisa):,.0f}", delta="Tekor 🔴", delta_color="inverse")
else:
    km3.metric("Sisa", f"Rp {total_pengeluaran:,.0f} (belum ada anggaran)")

# ---------- TABEL DATA ----------
st.markdown("### 📋 Lembar Catatan Keuangan")
if not df_view.empty:
    df_view["Jam Catat"] = df_view.apply(lambda r: f"{r['jam']:02d}:{r['menit']:02d} WIB", axis=1)
    df_tampil = df_view[["bulan", "catatan", "nominal", "kategori", "sifat", "Jam Catat"]].copy()
    df_tampil.columns = ["Bulan", "Deskripsi", "Nominal (Rp)", "Kategori", "Sifat", "Waktu"]
    st.dataframe(df_tampil, use_container_width=True)
    # Tombol unduh CSV
    csv = df_tampil.to_csv(index=False).encode('utf-8')
    st.download_button("📥 Unduh CSV", csv, f"transaksi_{pilihan_bulan}_{pilihan_tahun}.csv", "text/csv")
else:
    st.info("Tidak ada transaksi pada periode ini.")

# ---------- VISUALISASI ----------
st.markdown("### 📊 Visualisasi")
g1, g2 = st.columns(2)

with g1:
    st.markdown("**Tren Pengeluaran Bulanan**")
    df_trend = df.groupby(["tahun", "bulan"])["nominal"].sum().reset_index()
    if not df_trend.empty:
        chart_line = alt.Chart(df_trend).mark_line(point=True, color="#2E7D32").encode(
            x=alt.X('bulan:N', sort=list(KAMUS_BULAN.values()), title='Bulan'),
            y=alt.Y('nominal:Q', title='Total (Rp)'),
            tooltip=['bulan', 'nominal']
        ).properties(height=300)
        st.altair_chart(chart_line, use_container_width=True)
    else:
        st.write("Data tidak cukup.")

with g2:
    st.markdown("**Porsi Kategori**")
    if not df_view.empty:
        chart_pie = alt.Chart(df_view).mark_arc(innerRadius=40).encode(
            theta=alt.Theta(field="nominal", type="quantitative"),
            color=alt.Color(field="kategori", type="nominal", scale=alt.Scale(scheme='accent')),
            tooltip=['kategori', 'nominal']
        ).properties(height=300)
        st.altair_chart(chart_pie, use_container_width=True)
    else:
        st.write("Data kosong.")

# ---------- 🧠 AI AUDITOR CERDAS (DIPERKUAT) ----------
st.markdown("---")
st.markdown("### 🧠 Analisis AI Cerdas")
if not df_view.empty:
    with st.expander("🔍 Buka Laporan AI", expanded=True):
        # 1. Perbandingan Historis
        df_lain = df[~((df['bulan'] == pilihan_bulan) & (df['tahun'] == pilihan_tahun))]
        if not df_lain.empty:
            rata_lalu = df_lain.groupby(["tahun", "bulan"])["nominal"].sum().mean()
            if total_pengeluaran > rata_lalu:
                selisih = total_pengeluaran - rata_lalu
                kategori_boros = df_view.groupby('kategori')['nominal'].sum().idxmax()
                st.error(f"📈 **Tren Memburuk:** Pengeluaran periode ini lebih tinggi **Rp {selisih:,.0f}** dari rata-rata bulan sebelumnya. Penyumbang terbesar: **{kategori_boros}**.")
            else:
                selisih = rata_lalu - total_pengeluaran
                st.success(f"📉 **Tren Membaik:** Anda lebih hemat **Rp {selisih:,.0f}** dibanding rata-rata historis.")
        else:
            st.info("Belum ada data historis untuk dibandingkan.")

        # 2. Alarm Waktu Rawan (Malam + Dini Hari)
        st.write("#### ⏰ Deteksi Waktu Rawan")
        malam_boros = df_view[(df_view['jam'] >= 20) | (df_view['jam'] <= 5)]
        if not malam_boros.empty:
            total_malam = malam_boros['nominal'].sum()
            st.warning(f"🌙 **Belanja Malam/Dini Hari:** Terdeteksi **Rp {total_malam:,.0f}** transaksi di jam 20:00–05:00. Waspadai impulsive buying saat lelah atau begadang.")
        else:
            st.success("✅ Tidak ada transaksi mencurigakan di jam rawan.")

        # 3. Analisis Kewajiban vs Sukarela
        wajib = df_view[df_view['sifat'] == 'Wajib']['nominal'].sum()
        sukarela = df_view[df_view['sifat'] == 'Sukarela']['nominal'].sum()
        if budget_evaluasi > 0:
            persen_sukarela = (sukarela / budget_evaluasi) * 100
            if persen_sukarela > 50:
                st.error(f"💸 **Porsi Sukarela Terlalu Besar:** {persen_sukarela:.1f}% dari anggaran habis untuk pengeluaran sukarela. Evaluasi prioritas!")
            else:
                st.info(f"💡 Porsi pengeluaran sukarela masih terkendali ({persen_sukarela:.1f}% anggaran).")

        # 4. Rekomendasi Strategis
        st.write("#### 🎯 Rekomendasi Penghematan")
        top_kategori = df_view.groupby('kategori')['nominal'].sum().idxmax()
        nominal_top = df_view[df_view['kategori'] == top_kategori]['nominal'].sum()
        target_pangkas = int(nominal_top * 0.2)
        if target_pangkas > 0:
            st.info(f"➔ Kurangi 20% dari **{top_kategori}** (sekitar Rp {target_pangkas:,}) untuk penghematan signifikan bulan depan.")
        if budget_evaluasi > 0 and sisa < 0:
            st.info("➔ Karena anggaran sudah tekor, alokasikan dana darurat di kategori 'Wajib' di awal bulan berikutnya.")
else:
    st.info("Tidak ada data transaksi untuk dianalisis AI.")
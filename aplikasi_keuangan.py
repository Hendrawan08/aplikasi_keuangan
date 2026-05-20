import streamlit as st
from supabase import create_client, Client
import pandas as pd
import altair as alt
from datetime import datetime, time, date, timedelta
import pytz
import os
import numpy as np
from fpdf import FPDF

# ==========================================
# SETUP HALAMAN UTAMA
# ==========================================
st.set_page_config(page_title="DanaPintar AI Premium", page_icon="📊", layout="centered")

# ---------- CSS KUSTOM UNTUK MOBILE-FRIENDLY ----------
st.markdown("""
<style>
    html, body, [data-testid="stAppViewContainer"] { font-size: 16px; }
    h1 { font-size: 2.2rem !important; }
    h2 { font-size: 1.8rem !important; }
    h3 { font-size: 1.4rem !important; }
    .stButton button, .stFormSubmitButton button {
        font-size: 1rem !important; padding: 0.6rem 1.2rem !important;
        border-radius: 8px !important; transition: all 0.2s ease;
    }
    .stButton button:hover { transform: scale(1.02); box-shadow: 0 2px 8px rgba(0,0,0,0.15); }
    input, textarea, select, .stTextInput input, .stNumberInput input,
    .stDateInput input, .stTimeInput input {
        font-size: 1rem !important; padding: 0.5rem !important; border-radius: 6px !important;
    }
    [data-testid="stSidebar"] { background-color: #0f172a; }
    [data-testid="stMetricValue"] { font-size: 1.8rem !important; }
    [data-testid="stMetricLabel"] { font-size: 0.9rem !important; }
    .stDataFrame { font-size: 0.95rem !important; }
    @media (max-width: 768px) {
        h1 { font-size: 1.8rem !important; }
        h2 { font-size: 1.5rem !important; }
        h3 { font-size: 1.3rem !important; }
        .stButton button, .stFormSubmitButton button {
            font-size: 1.1rem !important; padding: 0.8rem 1.5rem !important;
            min-height: 48px !important; width: 100%; display: block;
        }
        input, textarea, select, .stTextInput input, .stNumberInput input,
        .stDateInput input, .stTimeInput input { font-size: 1.05rem !important; padding: 0.65rem !important; }
        [data-testid="stMetricValue"] { font-size: 1.6rem !important; }
        [data-testid="stMetricLabel"] { font-size: 1rem !important; }
        [data-testid="stSidebar"] .stMarkdown, [data-testid="stSidebar"] .stButton button { font-size: 1rem !important; }
        [data-testid="stHorizontalBlock"] > div { flex: 1 1 100% !important; max-width: 100% !important; }
        .element-container iframe { max-width: 100% !important; }
    }
</style>
""", unsafe_allow_html=True)

# ---------- HEADER DENGAN TOMBOL LOGOUT CEPAT ----------
col_header_left, col_header_right = st.columns([0.85, 0.15])
with col_header_right:
    if st.session_state.get("user_aktif") is not None:
        if st.button("🚪", key="quick_logout", help="Logout cepat"):
            try:
                supabase.auth.sign_out()
            except:
                pass
            for key in ['user_aktif', 'anggaran_terkunci', 'target_tabungan',
                        'muat_anggaran_sukses', 'muat_tabungan_sukses',
                        'toast_kondisi_ditampilkan']:
                st.session_state.pop(key, None)
            st.rerun()

st.markdown("<h1 style='text-align: center; color: #2E7D32;'>📊 DanaPintar AI — Multi-Month Auditor</h1>", unsafe_allow_html=True)
st.markdown("<p style='text-align: center; color: #37474F;'>Sistem Pencatatan Presisi Manual dengan Analisis Otak AI Lintas Waktu</p>", unsafe_allow_html=True)
st.markdown("---")

# ==========================================
# KONFIGURASI SUPABASE & TIMEZONE
# ==========================================
SUPABASE_URL = "https://lmyvddqwmmpsrpigzygi.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxteXZkZHF3bW1wc3JwaWd6eWdpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkxNzQ0NjQsImV4cCI6MjA5NDc1MDQ2NH0.Cv41r1Mo6fR164y3g8OX-zP_Cmj0NiR9zyRzkmYJi9I"

try:
    TZ = pytz.timezone('Asia/Jakarta')
except:
    TZ = pytz.FixedOffset(7 * 60)

def waktu_sekarang_wib():
    return datetime.now(TZ)

for var in ['HTTP_PROXY', 'HTTPS_PROXY', 'http_proxy', 'https_proxy']:
    os.environ.pop(var, None)

@st.cache_resource
def init_supabase() -> Client:
    try:
        client = create_client(SUPABASE_URL, SUPABASE_KEY)
        client.auth.get_session()
        return client
    except Exception as e:
        st.error(f"❌ Gagal tersambung ke database: {e}")
        st.stop()

supabase = init_supabase()

# ==========================================
# SESSION STATE
# ==========================================
if 'user_aktif' not in st.session_state:
    st.session_state.user_aktif = None
if 'anggaran_terkunci' not in st.session_state:
    st.session_state.anggaran_terkunci = {}
if 'muat_anggaran_sukses' not in st.session_state:
    st.session_state.muat_anggaran_sukses = False
if 'target_tabungan' not in st.session_state:
    st.session_state.target_tabungan = {}
if 'muat_tabungan_sukses' not in st.session_state:
    st.session_state.muat_tabungan_sukses = False
if 'simpan_sukses' not in st.session_state:
    st.session_state.simpan_sukses = False
if 'pesan_toast' not in st.session_state:
    st.session_state.pesan_toast = ""
if 'jam_input' not in st.session_state:
    st.session_state.jam_input = datetime.now(TZ).hour
if 'menit_input' not in st.session_state:
    st.session_state.menit_input = datetime.now(TZ).minute
if 'hapus_sukses' not in st.session_state:
    st.session_state.hapus_sukses = False
if 'toast_kondisi_ditampilkan' not in st.session_state:
    st.session_state.toast_kondisi_ditampilkan = False
if 'filter_bulan_sebelumnya' not in st.session_state:
    st.session_state.filter_bulan_sebelumnya = None
if 'filter_tahun_sebelumnya' not in st.session_state:
    st.session_state.filter_tahun_sebelumnya = None

KAMUS_BULAN = {
    1: "Januari", 2: "Februari", 3: "Maret", 4: "April", 5: "Mei", 6: "Juni",
    7: "Juli", 8: "Agustus", 9: "September", 10: "Oktober", 11: "November", 12: "Desember"
}

def muat_anggaran_dari_cloud(uid, paksa=False):
    if not paksa and st.session_state.muat_anggaran_sukses:
        return
    try:
        res = supabase.table("budgets").select("*").eq("user_id", uid).execute()
        if res.data:
            baru = {}
            for row in res.data:
                key = row["bulan_key"]
                baru[key] = row["nominal"]
            st.session_state.anggaran_terkunci = baru
            st.session_state.muat_anggaran_sukses = True
        else:
            st.session_state.anggaran_terkunci = {}
            st.session_state.muat_anggaran_sukses = True
    except Exception as e:
        st.error(f"Gagal memuat anggaran dari cloud: {e}")
        st.session_state.muat_anggaran_sukses = False

def simpan_anggaran_ke_cloud(uid, bulan_key, nominal):
    try:
        supabase.table("budgets").delete().eq("user_id", uid).eq("bulan_key", bulan_key).execute()
        supabase.table("budgets").insert({
            "user_id": uid,
            "bulan_key": bulan_key,
            "nominal": nominal,
            "updated_at": datetime.now(TZ).isoformat()
        }).execute()
        return True
    except Exception as e:
        st.error(f"Gagal menyimpan anggaran: {e}")
        return False

def muat_target_tabungan_dari_cloud(uid, paksa=False):
    if not paksa and st.session_state.muat_tabungan_sukses:
        return
    try:
        res = supabase.table("savings_goals").select("*").eq("user_id", uid).execute()
        if res.data:
            baru = {}
            for row in res.data:
                key = row["bulan_key"]
                baru[key] = row["target_nominal"]
            st.session_state.target_tabungan = baru
            st.session_state.muat_tabungan_sukses = True
        else:
            st.session_state.target_tabungan = {}
            st.session_state.muat_tabungan_sukses = True
    except Exception as e:
        st.error(f"Gagal memuat target tabungan dari cloud: {e}")
        st.session_state.muat_tabungan_sukses = False

def simpan_target_tabungan_ke_cloud(uid, bulan_key, target):
    try:
        supabase.table("savings_goals").delete().eq("user_id", uid).eq("bulan_key", bulan_key).execute()
        supabase.table("savings_goals").insert({
            "user_id": uid,
            "bulan_key": bulan_key,
            "target_nominal": target,
            "updated_at": datetime.now(TZ).isoformat()
        }).execute()
        return True
    except Exception as e:
        st.error(f"Gagal menyimpan target tabungan: {e}")
        return False

# ==========================================
# GERBANG AUTH
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
                muat_anggaran_dari_cloud(resp.user.id, paksa=True)
                muat_target_tabungan_dari_cloud(resp.user.id, paksa=True)
                st.session_state.toast_kondisi_ditampilkan = False
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
# DASHBOARD UTAMA
# ==========================================
uid = st.session_state.user_aktif.id
email_user = st.session_state.user_aktif.email

if not st.session_state.muat_anggaran_sukses or not st.session_state.anggaran_terkunci:
    muat_anggaran_dari_cloud(uid, paksa=True)
if not st.session_state.muat_tabungan_sukses:
    muat_target_tabungan_dari_cloud(uid, paksa=True)

# ---------- LOAD REMINDERS (dengan perlindungan error) ----------
@st.cache_data(ttl=10)
def load_reminders(uid):
    try:
        res = supabase.table("reminders").select("*").eq("user_id", uid).eq("is_active", True).execute()
        return res.data if res.data else []
    except Exception as e:
        st.warning(f"Gagal memuat pengingat: {e}")
        return []

reminders = load_reminders(uid)

# ---------- TAMPILKAN TOAST ----------
if st.session_state.simpan_sukses:
    st.toast(st.session_state.pesan_toast, icon="✅")
    st.session_state.simpan_sukses = False
if st.session_state.hapus_sukses:
    st.toast(st.session_state.pesan_toast, icon="🗑️")
    st.session_state.hapus_sukses = False
    st.session_state.pesan_toast = ""

# ---------- SIDEBAR ----------
with st.sidebar.container():
    st.markdown("""
    <style>
    .profile-card {
        background: linear-gradient(135deg, #2E7D32 0%, #43A047 100%);
        border-radius: 16px; padding: 1.2rem 1rem; margin-bottom: 0.5rem;
        color: white; box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    }
    .profile-card .email { font-size: 0.95rem; font-weight: 500; word-break: break-all; opacity: 0.95; margin-top: 0.3rem; }
    .profile-card .label { font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.5px; opacity: 0.7; }
    </style>
    """, unsafe_allow_html=True)
    st.markdown(f"""
    <div class="profile-card">
        <div style="display: flex; align-items: center; gap: 8px;">
            <span style="font-size: 1.8rem;">👤</span>
            <div>
                <div class="label">Akun Aktif</div>
                <div class="email">{email_user}</div>
            </div>
        </div>
    </div>
    """, unsafe_allow_html=True)
    if st.button("🚪 Logout", key="sidebar_logout", use_container_width=True):
        try:
            supabase.auth.sign_out()
        except:
            pass
        for key in ['user_aktif', 'anggaran_terkunci', 'target_tabungan',
                    'muat_anggaran_sukses', 'muat_tabungan_sukses',
                    'toast_kondisi_ditampilkan']:
            st.session_state.pop(key, None)
        st.rerun()

st.sidebar.markdown("---")
st.sidebar.subheader("🔒 Kunci Anggaran Bulanan")
waktu_sekarang = waktu_sekarang_wib()
bln_budget = st.sidebar.selectbox("Bulan Anggaran", list(KAMUS_BULAN.values()), index=waktu_sekarang.month - 1)
thn_budget = st.sidebar.selectbox("Tahun Anggaran", [2025, 2026, 2027], index=1)
key_budget = f"{bln_budget}_{thn_budget}"
anggaran_terkunci = st.session_state.anggaran_terkunci.get(key_budget)

if anggaran_terkunci is not None:
    st.sidebar.success(f"🔒 Anggaran {bln_budget} {thn_budget}\n**Rp {anggaran_terkunci:,.0f}**")
    if st.sidebar.checkbox("🔓 Buka Reset Anggaran", key=f"reset_chk_{key_budget}"):
        with st.sidebar.form(f"form_reset_{key_budget}"):
            st.warning("⚠️ Reset akan menghapus kunci anggaran bulan ini.")
            konfirmasi = st.text_input("Ketik 'RESET' untuk melanjutkan", key=f"reset_text_{key_budget}")
            if st.form_submit_button("Ya, Reset"):
                if konfirmasi.strip().upper() == "RESET":
                    if key_budget in st.session_state.anggaran_terkunci:
                        del st.session_state.anggaran_terkunci[key_budget]
                    try:
                        supabase.table("budgets").delete().eq("user_id", uid).eq("bulan_key", key_budget).execute()
                        st.sidebar.success("✅ Anggaran berhasil direset!")
                        st.rerun()
                    except Exception as e:
                        st.sidebar.error(f"Gagal menghapus di cloud: {e}")
                else:
                    st.sidebar.error("Ketik 'RESET' dengan benar.")
else:
    input_budget = st.sidebar.number_input(f"Set Anggaran {bln_budget} {thn_budget} (Rp):", min_value=10000, value=1000000, step=100000)
    if st.sidebar.button(f"🔐 KUNCI Anggaran {bln_budget} {thn_budget}"):
        if input_budget <= 0:
            st.sidebar.error("Nominal anggaran harus lebih dari 0.")
        else:
            st.session_state.anggaran_terkunci[key_budget] = input_budget
            if simpan_anggaran_ke_cloud(uid, key_budget, input_budget):
                st.sidebar.success(f"✅ Anggaran {bln_budget} {thn_budget} terkunci!")
                st.rerun()
            else:
                del st.session_state.anggaran_terkunci[key_budget]
                st.sidebar.error("Gagal menyimpan, silakan coba lagi.")

# Target Tabungan
st.sidebar.markdown("---")
st.sidebar.subheader("💰 Target Tabungan Bulanan")
if anggaran_terkunci is not None:
    target_sekarang = st.session_state.target_tabungan.get(key_budget)
    if target_sekarang is not None:
        st.sidebar.success(f"🎯 Target Tabungan {bln_budget}:\n**Rp {target_sekarang:,.0f}**")
        if st.sidebar.button("🔄 Ubah Target Tabungan", key=f"ubah_target_{key_budget}"):
            st.session_state.target_tabungan.pop(key_budget, None)
            try:
                supabase.table("savings_goals").delete().eq("user_id", uid).eq("bulan_key", key_budget).execute()
            except:
                pass
            st.rerun()
    else:
        input_target = st.sidebar.number_input(
            f"Target Tabungan {bln_budget} (Rp):", min_value=0,
            max_value=int(anggaran_terkunci), value=0, step=50000,
            help=f"Maksimal Rp {anggaran_terkunci:,.0f} (sesuai anggaran)"
        )
        if st.sidebar.button("💾 Simpan Target Tabungan", key=f"save_target_{key_budget}"):
            if input_target < 0:
                st.sidebar.error("Target tidak boleh negatif.")
            elif input_target > anggaran_terkunci:
                st.sidebar.error("Target tabungan tidak boleh melebihi anggaran.")
            else:
                st.session_state.target_tabungan[key_budget] = input_target
                if simpan_target_tabungan_ke_cloud(uid, key_budget, input_target):
                    st.sidebar.success("✅ Target tabungan disimpan!")
                    st.rerun()
                else:
                    del st.session_state.target_tabungan[key_budget]
                    st.sidebar.error("Gagal menyimpan target tabungan.")
else:
    st.sidebar.info("Kunci anggaran terlebih dahulu untuk mengatur target tabungan.")

# ---------- ALOKASI ANGGARAN PER KATEGORI (FITUR 5 - SIDEBAR) ----------
st.sidebar.markdown("---")
st.sidebar.subheader("📊 Alokasi Anggaran per Kategori")
if anggaran_terkunci is not None:
    try:
        res_alloc_sidebar = supabase.table("budget_allocations").select("*").eq("user_id", uid).eq("bulan_key", key_budget).execute()
        current_alloc_sidebar = {row['kategori']: row['persentase'] for row in res_alloc_sidebar.data} if res_alloc_sidebar.data else {}
    except Exception as e:
        st.sidebar.error(f"Gagal memuat alokasi: {e}")
        current_alloc_sidebar = {}

    if not current_alloc_sidebar:
        st.sidebar.info("Belum ada alokasi. Atur persentase:")
        with st.sidebar.form("form_alloc_sidebar"):
            kategoris = ["Makanan", "Transportasi", "Hiburan/Gaya Hidup",
                         "Kebutuhan Rumah/Kesehatan", "Tagihan Wajib", "Lain-lain"]
            persen_dict = {}
            for kat in kategoris:
                persen_dict[kat] = st.number_input(f"{kat} %", 0, 100, 15 if kat in ["Makanan","Transportasi"] else 10)
            total_persen = sum(persen_dict.values())
            if total_persen != 100:
                st.error(f"Total harus 100%, sekarang {total_persen}%")
            if st.form_submit_button("Simpan Alokasi"):
                if total_persen == 100:
                    try:
                        supabase.table("budget_allocations").delete().eq("user_id", uid).eq("bulan_key", key_budget).execute()
                        for kat, pers in persen_dict.items():
                            if pers > 0:
                                supabase.table("budget_allocations").insert({
                                    "user_id": uid, "bulan_key": key_budget,
                                    "kategori": kat, "persentase": pers
                                }).execute()
                        st.rerun()
                    except Exception as e:
                        st.error(f"Gagal menyimpan alokasi: {e}")
    else:
        st.sidebar.success("Alokasi tersimpan")
        if st.sidebar.button("🔄 Ubah Alokasi", key=f"ubah_alloc_{key_budget}"):
            try:
                supabase.table("budget_allocations").delete().eq("user_id", uid).eq("bulan_key", key_budget).execute()
                st.rerun()
            except Exception as e:
                st.error(f"Gagal mengubah alokasi: {e}")
else:
    st.sidebar.info("Kunci anggaran dulu untuk atur alokasi.")

# ---------- FORM INPUT TRANSAKSI ----------
st.sidebar.markdown("---")
st.sidebar.subheader("✍️ Catat Transaksi")
with st.sidebar.form("form_transaksi"):
    in_catatan = st.text_input("Nama Transaksi:", placeholder="Contoh: Beli Tissue")
    in_nominal = st.number_input("Nominal (Rp):", min_value=0, value=0, step=1000)
    in_kategori = st.selectbox("Kategori:", ["Makanan", "Transportasi", "Hiburan/Gaya Hidup",
                                             "Kebutuhan Rumah/Kesehatan", "Tagihan Wajib", "Lain-lain"])
    in_sifat = st.radio("Sifat:", ["Wajib", "Sukarela"])
    sekarang = datetime.now(TZ)
    default_date = sekarang.date()
    in_tanggal = st.date_input("Tanggal", value=default_date, format="DD/MM/YYYY")
    col_jam, col_menit = st.columns(2)
    with col_jam:
        jam_input = st.number_input("Jam", min_value=0, max_value=23, value=st.session_state.jam_input, step=1, key="input_jam")
    with col_menit:
        menit_input = st.number_input("Menit", min_value=0, max_value=59, value=st.session_state.menit_input, step=1, key="input_menit")
    in_waktu = time(jam_input, menit_input)
    st.session_state.jam_input = jam_input
    st.session_state.menit_input = menit_input
    submitted = st.form_submit_button("💾 Simpan Transaksi")

if submitted:
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
            waktu_gabung = datetime(in_tanggal.year, in_tanggal.month, in_tanggal.day, in_waktu.hour, in_waktu.minute)
            waktu_lokal = TZ.localize(waktu_gabung)
            waktu_iso = waktu_lokal.astimezone(pytz.UTC).isoformat()
            data_insert = {
                "user_id": uid,
                "catatan": in_catatan.strip(),
                "nominal": in_nominal,
                "kategori": in_kategori,
                "sifat": in_sifat,
                "waktu_transaksi": waktu_iso
            }
            resp = supabase.table("transaksi").insert(data_insert).execute()
            if resp.data:
                st.cache_data.clear()
                st.session_state.simpan_sukses = True
                st.session_state.pesan_toast = f"✅ Transaksi '{in_catatan.strip()}' berhasil dicatat!"
                sekarang = datetime.now(TZ)
                st.session_state.jam_input = sekarang.hour
                st.session_state.menit_input = sekarang.minute
                st.session_state.toast_kondisi_ditampilkan = False
                st.sidebar.success("✅ Transaksi tersimpan!")
                st.rerun()
            else:
                st.sidebar.error("Gagal menyimpan, respons kosong.")
        except Exception as e:
            st.sidebar.error(f"Error: {e}")

# ---------- PENGINGAT TAGIHAN (FITUR 4 - SIDEBAR) ----------
st.sidebar.markdown("---")
st.sidebar.subheader("📌 Pengingat Tagihan")
if reminders:
    for rem in reminders:
        col1, col2 = st.sidebar.columns([0.8, 0.2])
        col1.write(f"🔹 {rem['nama']} - Rp {rem['nominal']:,} ({rem['tanggal_jatuh_tempo']})")
        if col2.button("❌", key=f"del_rem_{rem['id']}"):
            try:
                supabase.table("reminders").update({"is_active": False}).eq("id", rem["id"]).execute()
                st.cache_data.clear()
                st.rerun()
            except Exception as e:
                st.sidebar.error(f"Gagal menghapus pengingat: {e}")

with st.sidebar.expander("➕ Tambah Pengingat"):
    with st.form("form_reminder"):
        nama = st.text_input("Nama Tagihan")
        nominal = st.number_input("Nominal", min_value=1000, step=1000)
        kategori = st.selectbox("Kategori", ["Tagihan Wajib", "Lain-lain"])
        tgl = st.date_input("Tanggal Jatuh Tempo", value=date.today())
        if st.form_submit_button("Simpan Pengingat"):
            if not nama.strip():
                st.error("Nama tagihan wajib diisi.")
            elif nominal <= 0:
                st.error("Nominal harus lebih dari 0.")
            else:
                try:
                    supabase.table("reminders").insert({
                        "user_id": uid,
                        "nama": nama.strip(),
                        "nominal": nominal,
                        "tanggal_jatuh_tempo": tgl.isoformat(),
                        "kategori": kategori
                    }).execute()
                    st.cache_data.clear()
                    st.success("Pengingat berhasil ditambahkan!")
                    st.rerun()
                except Exception as e:
                    st.error(f"Gagal menyimpan pengingat: {e}")

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

df = pd.DataFrame(data_mentah)
df['nominal'] = pd.to_numeric(df['nominal'], errors='coerce')
invalid_nominal = df['nominal'].isna().sum()
if invalid_nominal > 0:
    st.warning(f"⚠️ Terdapat {invalid_nominal} transaksi dengan nominal tidak valid, akan diabaikan.")
    df = df.dropna(subset=['nominal'])

try:
    df['waktu_transaksi'] = pd.to_datetime(df['waktu_transaksi'], utc=True, errors='coerce')
    df['waktu_transaksi'] = df['waktu_transaksi'].dt.tz_convert(TZ)
    df = df.dropna(subset=['waktu_transaksi'])
    df['bulan'] = df['waktu_transaksi'].dt.month.map(KAMUS_BULAN)
    df['tahun'] = df['waktu_transaksi'].dt.year.astype(int)
    df['jam'] = df['waktu_transaksi'].dt.hour.fillna(0).astype(int)
    df['menit'] = df['waktu_transaksi'].dt.minute.fillna(0).astype(int)
    df["Tanggal Lengkap"] = df["waktu_transaksi"].apply(lambda t: f"{t.day} {KAMUS_BULAN[t.month]} {t.year}")
except Exception as e:
    st.error(f"Gagal memproses kolom waktu: {e}")
    st.stop()

# ---------- FILTER DASHBOARD ----------
st.markdown("### 🗓️ Filter Periode")
c1, c2 = st.columns(2)
daftar_tahun = sorted(df['tahun'].unique())
pilihan_bulan = c1.selectbox("Bulan", ["Semua Bulan"] + list(KAMUS_BULAN.values()), index=waktu_sekarang.month if waktu_sekarang.month <= 12 else 0)
pilihan_tahun = c2.selectbox("Tahun", daftar_tahun, index=len(daftar_tahun)-1 if daftar_tahun else 0)

if (st.session_state.filter_bulan_sebelumnya != pilihan_bulan or st.session_state.filter_tahun_sebelumnya != pilihan_tahun):
    st.session_state.toast_kondisi_ditampilkan = False
    st.session_state.filter_bulan_sebelumnya = pilihan_bulan
    st.session_state.filter_tahun_sebelumnya = pilihan_tahun

if pilihan_bulan == "Semua Bulan":
    df_view = df[df['tahun'] == pilihan_tahun].copy()
    budget_evaluasi = sum(v for k, v in st.session_state.anggaran_terkunci.items() if k.endswith(f"_{pilihan_tahun}"))
    target_evaluasi = sum(v for k, v in st.session_state.target_tabungan.items() if k.endswith(f"_{pilihan_tahun}"))
    jumlah_hari_dalam_bulan = 30
    current_alloc_dashboard = {}
else:
    df_view = df[(df['bulan'] == pilihan_bulan) & (df['tahun'] == pilihan_tahun)].copy()
    key_eval = f"{pilihan_bulan}_{pilihan_tahun}"
    budget_evaluasi = st.session_state.anggaran_terkunci.get(key_eval, 0)
    target_evaluasi = st.session_state.target_tabungan.get(key_eval, 0)
    try:
        res_alloc_dash = supabase.table("budget_allocations").select("*").eq("user_id", uid).eq("bulan_key", key_eval).execute()
        current_alloc_dashboard = {row['kategori']: row['persentase'] for row in res_alloc_dash.data} if res_alloc_dash.data else {}
    except:
        current_alloc_dashboard = {}
    try:
        bulan_idx = list(KAMUS_BULAN.values()).index(pilihan_bulan) + 1
        if bulan_idx == 12:
            jumlah_hari_dalam_bulan = 31
        else:
            jumlah_hari_dalam_bulan = (date(pilihan_tahun, bulan_idx % 12 + 1, 1) - timedelta(days=1)).day
    except:
        jumlah_hari_dalam_bulan = 30

total_pengeluaran = df_view['nominal'].sum()
batas_belanja = budget_evaluasi - target_evaluasi
sisa_anggaran = budget_evaluasi - total_pengeluaran

# ---------- TOAST PENGINGAT TAGIHAN JATUH TEMPO ----------
if reminders:
    today = datetime.now(TZ).date()
    due_soon = [r for r in reminders if r.get('tanggal_jatuh_tempo') and (date.fromisoformat(r['tanggal_jatuh_tempo']) - today).days <= 3 and (date.fromisoformat(r['tanggal_jatuh_tempo']) - today).days >= 0]
    for d in due_soon:
        st.toast(f"📅 Tagihan '{d['nama']}' jatuh tempo {d['tanggal_jatuh_tempo']} (Rp {d['nominal']:,})", icon="⏰")

# ---------- TOAST KONDISI KEUANGAN ----------
if not st.session_state.toast_kondisi_ditampilkan and batas_belanja > 0:
    persen = (total_pengeluaran / batas_belanja) * 100
    if persen >= 100:
        st.toast("🚨 Target tabungan terancam! Pengeluaran melebihi batas.", icon="⚠️")
    elif persen >= 80:
        st.toast(f"🟠 Hati-hati! Pengeluaran sudah {persen:.0f}% dari batas belanja.", icon="📊")
    else:
        st.toast(f"🟢 Pengeluaran masih aman ({persen:.0f}%). Tabungan terlindungi.", icon="✅")
    st.session_state.toast_kondisi_ditampilkan = True

# ---------- METRIK UTAMA ----------
st.markdown("### 💹 Ringkasan Keuangan")
km1, km2, km3 = st.columns(3)
km1.metric("Anggaran", f"Rp {budget_evaluasi:,.0f}")
km2.metric("Target Tabungan", f"Rp {target_evaluasi:,.0f}")
km3.metric("Batas Belanja Maks", f"Rp {batas_belanja:,.0f}", help="Anggaran dikurangi target tabungan")
km4, km5, km6 = st.columns(3)
km4.metric("Total Pengeluaran", f"Rp {total_pengeluaran:,.0f}")
if batas_belanja > 0:
    sisa_dari_batas = batas_belanja - total_pengeluaran
    delta_text = f"{'Sisa' if sisa_dari_batas >=0 else 'Defisit'} tabungan"
    km5.metric("Vs Batas Belanja", f"Rp {abs(sisa_dari_batas):,.0f}", delta=delta_text, delta_color="normal" if sisa_dari_batas>=0 else "inverse")
else:
    km5.metric("Vs Batas Belanja", "Rp 0", delta="Tidak ada batas")
km6.metric("Sisa Anggaran Utuh", f"Rp {sisa_anggaran:,.0f}")

# ---------- PREDIKSI BULAN DEPAN (FITUR 1) ----------
if budget_evaluasi > 0 and pilihan_bulan != "Semua Bulan" and len(df_view) > 0:
    st.markdown("#### 🔮 Prediksi Pengeluaran Bulan Depan")
    try:
        bulan_idx = list(KAMUS_BULAN.values()).index(pilihan_bulan) + 1
        tahun_ini = pilihan_tahun
        periods = []
        for i in range(1, 4):
            m = bulan_idx - i
            y = tahun_ini
            if m <= 0:
                m += 12
                y -= 1
            periods.append((y, m))
        df_hist = df[(df['tahun'].isin([p[0] for p in periods])) & (df['bulan'].isin([KAMUS_BULAN[p[1]] for p in periods]))]
        if len(df_hist) >= 2:
            df_hist_agg = df_hist.groupby(['tahun', 'bulan'])['nominal'].sum().reset_index()
            df_hist_agg['bulan_num'] = df_hist_agg.apply(lambda r: (r['tahun']-2000)*12 + list(KAMUS_BULAN.values()).index(r['bulan']) + 1, axis=1)
            next_month_num = (tahun_ini-2000)*12 + bulan_idx + 1
            x = df_hist_agg['bulan_num'].values
            y = df_hist_agg['nominal'].values
            coeffs = np.polyfit(x, y, 1)
            pred = np.polyval(coeffs, next_month_num)
            pred = max(0, pred)
            st.info(f"🧠 Prediksi total pengeluaran bulan depan: **Rp {pred:,.0f}** (± deviasi berdasarkan tren)")
        else:
            st.info("Data historis belum cukup (minimal 2 bulan) untuk prediksi.")
    except Exception as e:
        st.info("Prediksi belum tersedia.")

# ---------- NOTIFIKASI BATAS HARIAN ----------
if budget_evaluasi > 0 and pilihan_bulan != "Semua Bulan":
    st.markdown("#### ⏳ Analisis Harian")
    hari_ini = datetime.now(TZ).date()
    pengeluaran_hari_ini = df_view[df_view['waktu_transaksi'].dt.date == hari_ini]['nominal'].sum()
    hari_sudah_berlalu = (hari_ini - date(pilihan_tahun, list(KAMUS_BULAN.values()).index(pilihan_bulan)+1, 1)).days + 1
    if hari_sudah_berlalu < 1:
        hari_sudah_berlalu = 1
    rata_harian = total_pengeluaran / hari_sudah_berlalu
    batas_harian = batas_belanja / jumlah_hari_dalam_bulan if jumlah_hari_dalam_bulan > 0 else 0
    col_harian1, col_harian2 = st.columns(2)
    col_harian1.metric("Pengeluaran Hari Ini", f"Rp {pengeluaran_hari_ini:,.0f}")
    col_harian2.metric("Batas Harian Ideal", f"Rp {batas_harian:,.0f}", help=f"Total batas belanja dibagi {jumlah_hari_dalam_bulan} hari")
    if pengeluaran_hari_ini > batas_harian * 1.3:
        st.warning(f"⚡ Pengeluaran hari ini melebihi 130% batas harian. Waspada!")
    elif pengeluaran_hari_ini > 0:
        st.info("Pengeluaran hari ini masih dalam koridor aman.")

# ---------- TABEL DATA ----------
st.markdown("### 📋 Lembar Catatan Keuangan")
if not df_view.empty:
    df_view["Jam Catat"] = df_view.apply(lambda r: f"{r['jam']:02d}:{r['menit']:02d} WIB", axis=1)
    df_tampil = df_view[["Tanggal Lengkap", "bulan", "catatan", "nominal", "kategori", "sifat", "Jam Catat"]].copy()
    df_tampil.columns = ["Tanggal", "Bulan", "Deskripsi", "Nominal (Rp)", "Kategori", "Sifat", "Waktu"]
    selection = st.dataframe(df_tampil, use_container_width=True, hide_index=True, selection_mode="multi-row", on_select="rerun", key="tabel_transaksi")
    if st.button("🗑️ Hapus Transaksi Terpilih"):
        selected_indices = selection.selection.rows
        if selected_indices:
            valid_indices = [i for i in selected_indices if i < len(df_view)]
            if valid_indices:
                with st.expander("🔍 Konfirmasi data yang akan dihapus", expanded=True):
                    st.dataframe(df_view.iloc[valid_indices][['Tanggal Lengkap','catatan','nominal']], use_container_width=True)
                if st.button("✅ Ya, hapus yang dipilih", key="confirm_delete"):
                    ids_to_delete = df_view.iloc[valid_indices]["id"].tolist()
                    try:
                        for trans_id in ids_to_delete:
                            supabase.table("transaksi").delete().eq("id", trans_id).execute()
                        st.cache_data.clear()
                        if "tabel_transaksi" in st.session_state:
                            del st.session_state["tabel_transaksi"]
                        st.session_state.hapus_sukses = True
                        st.session_state.pesan_toast = f"🗑️ {len(ids_to_delete)} transaksi berhasil dihapus."
                        st.rerun()
                    except Exception as e:
                        st.error(f"Gagal menghapus: {e}")
        else:
            st.warning("Pilih minimal satu transaksi terlebih dahulu.")
    col_down1, col_down2 = st.columns(2)
    with col_down1:
        csv = df_tampil.to_csv(index=False).encode('utf-8')
        st.download_button("📥 Unduh CSV", csv, f"transaksi_{pilihan_bulan}_{pilihan_tahun}.csv", "text/csv")
    with col_down2:
        if st.button("📄 Unduh Laporan PDF"):
            try:
                pdf = FPDF()
                pdf.add_page()
                pdf.set_font("Helvetica", "B", 16)
                pdf.cell(0, 10, f"Laporan Keuangan - {pilihan_bulan} {pilihan_tahun}", ln=True, align="C")
                pdf.ln(5)
                pdf.set_font("Helvetica", "", 12)
                pdf.cell(0, 8, f"Anggaran: Rp {budget_evaluasi:,.0f}", ln=True)
                pdf.cell(0, 8, f"Target Tabungan: Rp {target_evaluasi:,.0f}", ln=True)
                pdf.cell(0, 8, f"Total Pengeluaran: Rp {total_pengeluaran:,.0f}", ln=True)
                pdf.cell(0, 8, f"Sisa Anggaran: Rp {sisa_anggaran:,.0f}", ln=True)
                pdf.ln(5)
                pdf.set_font("Helvetica", "B", 10)
                col_widths = [40, 50, 30, 40, 30]
                headers = ["Tanggal", "Deskripsi", "Nominal", "Kategori", "Sifat"]
                for i, h in enumerate(headers):
                    pdf.cell(col_widths[i], 8, h, border=1)
                pdf.ln()
                pdf.set_font("Helvetica", "", 9)
                for _, row in df_tampil.iterrows():
                    pdf.cell(col_widths[0], 7, str(row["Tanggal"]), border=1)
                    pdf.cell(col_widths[1], 7, str(row["Deskripsi"])[:30], border=1)
                    pdf.cell(col_widths[2], 7, f"Rp {row['Nominal (Rp)']:,.0f}", border=1)
                    pdf.cell(col_widths[3], 7, str(row["Kategori"]), border=1)
                    pdf.cell(col_widths[4], 7, str(row["Sifat"]), border=1)
                    pdf.ln()
                pdf_bytes = pdf.output(dest='S').encode('latin-1')
                st.download_button(label="⬇️ Klik untuk Unduh PDF", data=pdf_bytes, file_name="laporan_keuangan.pdf", mime="application/pdf")
            except Exception as e:
                st.error(f"Gagal membuat PDF: {e}")
    if not df.empty:
        df_all = df[["Tanggal Lengkap", "bulan", "catatan", "nominal", "kategori", "sifat"]].copy()
        df_all.columns = ["Tanggal", "Bulan", "Deskripsi", "Nominal", "Kategori", "Sifat"]
        csv_all = df_all.to_csv(index=False).encode('utf-8')
        st.download_button("📦 Unduh Semua Riwayat", csv_all, "riwayat_lengkap.csv", "text/csv")
else:
    st.info("Tidak ada transaksi pada periode ini.")

# ---------- VISUALISASI ----------
st.markdown("### 📊 Visualisasi")
g1, g2 = st.columns(2)
with g1:
    st.markdown("**Tren Pengeluaran Bulanan**")
    df_trend = df.groupby(["tahun", "bulan"])["nominal"].sum().reset_index()
    if not df_trend.empty:
        chart_line = alt.Chart(df_trend).mark_line(point=True).encode(
            x=alt.X('bulan:N', sort=list(KAMUS_BULAN.values()), title='Bulan'),
            y=alt.Y('nominal:Q', title='Total (Rp)'),
            color=alt.Color('tahun:N', title='Tahun'),
            tooltip=['tahun', 'bulan', 'nominal']
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

# ---------- PERBANDINGAN ANGGARAN VS AKTUAL PER KATEGORI (FITUR 5) ----------
if budget_evaluasi > 0 and current_alloc_dashboard:
    st.markdown("#### 📊 Anggaran vs Pengeluaran per Kategori")
    batas_per_kategori = {}
    for kat, pers in current_alloc_dashboard.items():
        batas_per_kategori[kat] = (pers / 100) * batas_belanja
    aktual_per_kategori = df_view.groupby('kategori')['nominal'].sum().to_dict()
    data_comp = []
    for kat in current_alloc_dashboard.keys():
        data_comp.append({
            "Kategori": kat,
            "Anggaran": batas_per_kategori.get(kat, 0),
            "Aktual": aktual_per_kategori.get(kat, 0)
        })
    df_comp = pd.DataFrame(data_comp)
    df_comp_melt = df_comp.melt(id_vars="Kategori", var_name="Jenis", value_name="Nominal")
    chart_bar = alt.Chart(df_comp_melt).mark_bar().encode(
        x=alt.X('Kategori:N', title=None),
        y=alt.Y('Nominal:Q'),
        color=alt.Color('Jenis:N', scale=alt.Scale(domain=['Anggaran','Aktual'], range=['#2E7D32','#FFA000'])),
        column=alt.Column('Jenis:N', title=None)
    ).properties(width=150)
    st.altair_chart(chart_bar, use_container_width=True)

# ---------- AI AUDITOR ----------
st.markdown("---")
st.markdown("### 🧠 Analisis AI Cerdas + Target Tabungan")
if not df_view.empty:
    with st.expander("🔍 Buka Laporan AI", expanded=True):
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
        st.write("#### ⏰ Deteksi Waktu Rawan")
        malam_boros = df_view[(df_view['jam'] >= 20) | (df_view['jam'] <= 5)]
        if not malam_boros.empty:
            total_malam = malam_boros['nominal'].sum()
            st.warning(f"🌙 **Belanja Malam/Dini Hari:** Terdeteksi **Rp {total_malam:,.0f}** transaksi di jam 20:00–05:00.")
        else:
            st.success("✅ Tidak ada transaksi mencurigakan di jam rawan.")
        st.write("#### ⚖️ Porsi Pengeluaran")
        wajib = df_view[df_view['sifat'] == 'Wajib']['nominal'].sum()
        sukarela = df_view[df_view['sifat'] == 'Sukarela']['nominal'].sum()
        if budget_evaluasi > 0:
            persen_sukarela = (sukarela / budget_evaluasi) * 100
            if persen_sukarela > 50:
                st.error(f"💸 **Porsi Sukarela Terlalu Besar:** {persen_sukarela:.1f}% dari anggaran habis untuk pengeluaran sukarela.")
            else:
                st.info(f"💡 Porsi pengeluaran sukarela masih terkendali ({persen_sukarela:.1f}% anggaran).")
        else:
            st.info("Anggaran belum diatur, tidak bisa mengevaluasi porsi.")
        st.write("#### 🎯 Evaluasi Target Tabungan")
        if target_evaluasi > 0:
            if total_pengeluaran <= batas_belanja:
                lebih = batas_belanja - total_pengeluaran
                st.success(f"✅ **Target Tercapai!** Pengeluaran masih di bawah batas, tabungan aman.")
            else:
                kekurangan = total_pengeluaran - batas_belanja
                st.error(f"🚨 **Target Tabungan Terancam!** Pengeluaran melebihi batas sebesar **Rp {kekurangan:,.0f}**.")
        else:
            st.info("📌 Anda belum menetapkan target tabungan untuk bulan ini.")
        st.write("#### 🎯 Rekomendasi Penghematan Umum")
        if budget_evaluasi > 0 and not df_view.empty:
            top_kategori = df_view.groupby('kategori')['nominal'].sum().idxmax()
            nominal_top = df_view[df_view['kategori'] == top_kategori]['nominal'].sum()
            target_pangkas = int(nominal_top * 0.2)
            if target_pangkas > 0:
                st.info(f"➔ Kurangi 20% dari **{top_kategori}** (sekitar Rp {target_pangkas:,}) untuk penghematan.")
            if sisa_anggaran < 0:
                st.info("➔ Karena anggaran sudah tekor, alokasikan dana darurat di kategori 'Wajib' di awal bulan berikutnya.")
        else:
            st.info("Atur anggaran terlebih dahulu.")
else:
    st.info("Tidak ada data transaksi untuk dianalisis AI.")

# ---------- FOOTER ----------
st.markdown("---")
st.markdown("<p style='text-align: center; color: #2E7D32; font-size: 14px;'>🛠️ Dibangun dengan ❤️ oleh <strong>Hendrawan Lotanto</strong> — © 2026 DanaPintar AI</p>", unsafe_allow_html=True)

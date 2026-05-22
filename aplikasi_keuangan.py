# ============================================================
# DanaPintar AI Premium — Full Version
# Author : Hendrawan Lotanto
# Version: 2.0.0
# ============================================================
#
# SETUP SUPABASE — Jalankan SQL ini di Supabase SQL Editor
# sebelum menjalankan aplikasi:
#
# -- Tabel Pemasukan (BARU)
# CREATE TABLE pemasukan (
#     id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
#     user_id UUID REFERENCES auth.users(id),
#     sumber TEXT NOT NULL,
#     nominal NUMERIC NOT NULL,
#     kategori TEXT,
#     waktu_pemasukan TIMESTAMPTZ,
#     created_at TIMESTAMPTZ DEFAULT NOW()
# );
# ALTER TABLE pemasukan ENABLE ROW LEVEL SECURITY;
# CREATE POLICY "Users can CRUD own pemasukan" ON pemasukan
#     USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
#
# -- Tabel Recurring Templates (BARU)
# CREATE TABLE recurring_templates (
#     id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
#     user_id UUID REFERENCES auth.users(id),
#     catatan TEXT NOT NULL,
#     nominal NUMERIC NOT NULL,
#     kategori TEXT,
#     sifat TEXT,
#     frekuensi TEXT,
#     created_at TIMESTAMPTZ DEFAULT NOW()
# );
# ALTER TABLE recurring_templates ENABLE ROW LEVEL SECURITY;
# CREATE POLICY "Users can CRUD own recurring" ON recurring_templates
#     USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
#
# SETUP SECRETS — Buat file .streamlit/secrets.toml:
# [secrets]
# SUPABASE_URL = "https://xxx.supabase.co"
# SUPABASE_KEY = "eyJ..."
# ANTHROPIC_API_KEY = "sk-ant-..."
# ============================================================

import streamlit as st
from supabase import create_client, Client
import pandas as pd
import altair as alt
from datetime import datetime, time, date, timedelta
import pytz
import os

# --- Dependensi opsional ---
try:
    from fpdf import FPDF
    PDF_AVAILABLE = True
except ImportError:
    PDF_AVAILABLE = False

try:
    import google.generativeai as genai
    GEMINI_AVAILABLE = True
except ImportError:
    GEMINI_AVAILABLE = False


# ============================================================
# KONFIGURASI HALAMAN
# ============================================================
st.set_page_config(
    page_title="DanaPintar AI Premium",
    page_icon="📊",
    layout="centered"
)

# ============================================================
# KONSTANTA
# ============================================================
KAMUS_BULAN = {
    1: "Januari", 2: "Februari", 3: "Maret", 4: "April",
    5: "Mei", 6: "Juni", 7: "Juli", 8: "Agustus",
    9: "September", 10: "Oktober", 11: "November", 12: "Desember"
}

KATEGORI_PENGELUARAN = [
    "Makanan", "Transportasi", "Hiburan/Gaya Hidup",
    "Kebutuhan Rumah/Kesehatan", "Tagihan Wajib", "Lain-lain"
]
KATEGORI_PEMASUKAN = [
    "Gaji", "Freelance", "Bisnis", "Investasi",
    "Hadiah/Bonus", "Passive Income", "Lain-lain"
]
FREKUENSI_BERULANG = ["Bulanan", "Mingguan", "2 Mingguan"]

ANGGARAN_MIN     = 10_000
ANGGARAN_DEFAULT = 1_000_000


# ============================================================
# CSS KUSTOM
# ============================================================
st.markdown("""
<style>
    html, body, [data-testid="stAppViewContainer"] { font-size: 16px; }
    h1 { font-size: 2.2rem !important; }
    h2 { font-size: 1.8rem !important; }
    h3 { font-size: 1.4rem !important; }

    .stButton button, .stFormSubmitButton button {
        font-size: 1rem !important;
        padding: 0.6rem 1.2rem !important;
        border-radius: 8px !important;
        transition: all 0.2s ease;
    }
    .stButton button:hover {
        transform: scale(1.02);
        box-shadow: 0 2px 8px rgba(0,0,0,0.15);
    }

    input, textarea, select,
    .stTextInput input, .stNumberInput input,
    .stDateInput input, .stTimeInput input {
        font-size: 1rem !important;
        padding: 0.5rem !important;
        border-radius: 6px !important;
    }

    [data-testid="stSidebar"] { background-color: #0f172a; }

    [data-testid="stMetricValue"] { font-size: 1.8rem !important; }
    [data-testid="stMetricLabel"] { font-size: 0.9rem !important; }

    .stDataFrame { font-size: 0.95rem !important; }

    .profile-card {
        background: linear-gradient(135deg, #2E7D32 0%, #43A047 100%);
        border-radius: 16px; padding: 1.2rem 1rem; margin-bottom: 0.5rem;
        color: white; box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    }
    .profile-card .email {
        font-size: 0.95rem; font-weight: 500; word-break: break-all;
    }
    .profile-card .label {
        font-size: 0.75rem; text-transform: uppercase;
        letter-spacing: 0.5px; opacity: 0.7;
    }

    @media (max-width: 768px) {
        h1 { font-size: 1.8rem !important; }
        h2 { font-size: 1.5rem !important; }
        h3 { font-size: 1.3rem !important; }
        .stButton button, .stFormSubmitButton button {
            font-size: 1.1rem !important; padding: 0.8rem 1.5rem !important;
            min-height: 48px !important; width: 100%; display: block;
        }
        input, textarea, select,
        .stTextInput input, .stNumberInput input,
        .stDateInput input, .stTimeInput input {
            font-size: 1.05rem !important; padding: 0.65rem !important;
        }
        [data-testid="stMetricValue"] { font-size: 1.6rem !important; }
        [data-testid="stMetricLabel"] { font-size: 1rem !important; }
        [data-testid="stHorizontalBlock"] > div {
            flex: 1 1 100% !important; max-width: 100% !important;
        }
    }
</style>
""", unsafe_allow_html=True)

st.markdown(
    "<h1 style='text-align:center;color:#2E7D32;'>📊 DanaPintar AI — Premium</h1>",
    unsafe_allow_html=True
)
st.markdown(
    "<p style='text-align:center;color:#37474F;'>"
    "Sistem Keuangan Cerdas · AI Chat · Target Tabungan · Analitik Lintas Waktu"
    "</p>",
    unsafe_allow_html=True
)
st.markdown("---")


# ============================================================
# INISIALISASI SECRETS & KONEKSI
# ============================================================
# [PERBAIKAN KEAMANAN] Baca dari st.secrets, fallback ke hardcode dengan peringatan
try:
    SUPABASE_URL = st.secrets["SUPABASE_URL"]
    SUPABASE_KEY = st.secrets["SUPABASE_KEY"]
except (KeyError, FileNotFoundError):
    SUPABASE_URL = "https://lmyvddqwmmpsrpigzygi.supabase.co"
    SUPABASE_KEY = (
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"
        ".eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxteXZkZHF3bW1wc3JwaWd6eWdpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkxNzQ0NjQsImV4cCI6MjA5NDc1MDQ2NH0"
        ".Cv41r1Mo6fR164y3g8OX-zP_Cmj0NiR9zyRzkmYJi9I"
    )
    st.warning(
        "⚠️ **Keamanan:** API key masih hardcoded. "
        "Pindahkan ke `.streamlit/secrets.toml` sebelum deploy ke production.",
        icon="🔐"
    )

try:
    GEMINI_API_KEY = st.secrets["GEMINI_API_KEY"]
    if not GEMINI_API_KEY:
        GEMINI_API_KEY = None
except (KeyError, FileNotFoundError):
    GEMINI_API_KEY = None

try:
    TZ = pytz.timezone("Asia/Jakarta")
except Exception:
    TZ = pytz.FixedOffset(7 * 60)

for _var in ["HTTP_PROXY", "HTTPS_PROXY", "http_proxy", "https_proxy"]:
    os.environ.pop(_var, None)


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


# ============================================================
# SESSION STATE DEFAULTS
# ============================================================
_defaults = {
    "user_aktif": None,
    "anggaran_terkunci": {},
    "muat_anggaran_sukses": False,
    "target_tabungan": {},
    "muat_tabungan_sukses": False,
    "simpan_sukses": False,
    "pesan_toast": "",
    "jam_input": datetime.now(TZ).hour,
    "menit_input": datetime.now(TZ).minute,
    "hapus_sukses": False,
    "toast_kondisi_ditampilkan": False,
    "chat_history": [],
}
for _k, _v in _defaults.items():
    if _k not in st.session_state:
        st.session_state[_k] = _v


# ============================================================
# HELPER FUNCTIONS
# ============================================================
def waktu_sekarang_wib() -> datetime:
    return datetime.now(TZ)


def format_rupiah(nominal: float) -> str:
    return f"Rp {nominal:,.0f}"


def parse_df_waktu(df: pd.DataFrame, col: str = "waktu_transaksi") -> pd.DataFrame:
    """Parse, localize ke WIB, tambah kolom bulan/tahun/tanggal/jam/menit."""
    df[col] = pd.to_datetime(df[col], errors="coerce")
    if df[col].dt.tz is None:
        df[col] = df[col].dt.tz_localize("UTC")
    df[col] = df[col].dt.tz_convert(TZ)
    df = df.dropna(subset=[col])
    df["bulan"]  = df[col].dt.month.map(KAMUS_BULAN)
    df["tahun"]  = df[col].dt.year.astype(int)
    df["tanggal"] = df[col].dt.day.astype(int)
    df["jam"]    = df[col].dt.hour.astype(int)
    df["menit"]  = df[col].dt.minute.astype(int)
    return df


# ============================================================
# DB FUNCTIONS — ANGGARAN
# ============================================================
def muat_anggaran_dari_cloud(uid: str, paksa: bool = False) -> None:
    if not paksa and st.session_state.muat_anggaran_sukses:
        return
    try:
        res = supabase.table("budgets").select("*").eq("user_id", uid).execute()
        baru = {row["bulan_key"]: row["nominal"] for row in (res.data or [])}
        st.session_state.anggaran_terkunci = baru
        st.session_state.muat_anggaran_sukses = True
    except Exception as e:
        st.error(f"Gagal memuat anggaran: {e}")


def simpan_anggaran_ke_cloud(uid: str, bulan_key: str, nominal: float) -> bool:
    try:
        supabase.table("budgets").delete()\
            .eq("user_id", uid).eq("bulan_key", bulan_key).execute()
        supabase.table("budgets").insert({
            "user_id": uid, "bulan_key": bulan_key, "nominal": nominal,
            "updated_at": waktu_sekarang_wib().isoformat()
        }).execute()
        return True
    except Exception as e:
        st.error(f"Gagal menyimpan anggaran: {e}")
        return False


# ============================================================
# DB FUNCTIONS — TARGET TABUNGAN
# ============================================================
def muat_target_tabungan_dari_cloud(uid: str, paksa: bool = False) -> None:
    if not paksa and st.session_state.muat_tabungan_sukses:
        return
    try:
        res = supabase.table("savings_goals").select("*").eq("user_id", uid).execute()
        baru = {row["bulan_key"]: row["target_nominal"] for row in (res.data or [])}
        st.session_state.target_tabungan = baru
        st.session_state.muat_tabungan_sukses = True
    except Exception as e:
        st.error(f"Gagal memuat target tabungan: {e}")


def simpan_target_tabungan_ke_cloud(uid: str, bulan_key: str, target: float) -> bool:
    try:
        supabase.table("savings_goals").delete()\
            .eq("user_id", uid).eq("bulan_key", bulan_key).execute()
        supabase.table("savings_goals").insert({
            "user_id": uid, "bulan_key": bulan_key, "target_nominal": target,
            "updated_at": waktu_sekarang_wib().isoformat()
        }).execute()
        return True
    except Exception as e:
        st.error(f"Gagal menyimpan target tabungan: {e}")
        return False


# ============================================================
# DB FUNCTIONS — TRANSAKSI
# ============================================================
@st.cache_data(ttl=5)
def ambil_data_transaksi(user_id: str):
    try:
        res = supabase.table("transaksi").select("*").eq("user_id", user_id)\
            .order("waktu_transaksi", desc=False).execute()
        return res.data or []
    except Exception as e:
        st.error(f"Gagal mengambil transaksi: {e}")
        return []


# ============================================================
# DB FUNCTIONS — PEMASUKAN
# ============================================================
@st.cache_data(ttl=5)
def ambil_data_pemasukan(user_id: str):
    try:
        res = supabase.table("pemasukan").select("*").eq("user_id", user_id)\
            .order("waktu_pemasukan", desc=False).execute()
        return res.data or []
    except Exception as e:
        st.error(f"Gagal mengambil pemasukan: {e}")
        return []


# ============================================================
# DB FUNCTIONS — RECURRING TEMPLATES
# ============================================================
@st.cache_data(ttl=30)
def ambil_recurring(user_id: str):
    try:
        res = supabase.table("recurring_templates").select("*")\
            .eq("user_id", user_id).execute()
        return res.data or []
    except Exception:
        return []


# ============================================================
# FINANCIAL HEALTH SCORE
# ============================================================
def hitung_health_score(
    total_pengeluaran: float,
    budget_evaluasi: float,
    target_evaluasi: float,
    sukarela: float,
    df_view: pd.DataFrame,
    df_all: pd.DataFrame,
) -> tuple:
    """
    Hitung skor kesehatan keuangan 0–100.
    Return: (skor_int, detail_dict)
    """
    skor   = 0
    detail = {}

    # 1. Rasio Tabungan (40 poin)
    if budget_evaluasi > 0 and target_evaluasi > 0:
        batas = max(0, budget_evaluasi - target_evaluasi)
        if total_pengeluaran <= batas:
            s_tab = 40
        else:
            kelebihan_ratio = (total_pengeluaran - batas) / budget_evaluasi
            s_tab = max(0, 40 - int(kelebihan_ratio * 80))
    elif budget_evaluasi > 0:
        ratio = total_pengeluaran / budget_evaluasi
        s_tab = max(0, int((1 - ratio) * 40))
    else:
        s_tab = 20
    skor += s_tab
    detail["Rasio Tabungan"] = s_tab

    # 2. Konsistensi Pencatatan (20 poin)
    if not df_view.empty and "waktu_transaksi" in df_view.columns:
        hari_unik = df_view["waktu_transaksi"].dt.date.nunique()
        konsistensi = min(1.0, hari_unik / 15)
        s_kons = int(konsistensi * 20)
    else:
        s_kons = 0
    skor += s_kons
    detail["Konsistensi Catat"] = s_kons

    # 3. Porsi Sukarela Terkendali (20 poin)
    if budget_evaluasi > 0 and not df_view.empty:
        ratio_suka = sukarela / budget_evaluasi
        if ratio_suka <= 0.30:
            s_suka = 20
        elif ratio_suka <= 0.50:
            s_suka = 12
        else:
            s_suka = max(0, int((1 - ratio_suka) * 20))
    else:
        s_suka = 10
    skor += s_suka
    detail["Porsi Sukarela"] = s_suka

    # 4. Tren Membaik (20 poin)
    s_tren = 10
    if (
        not df_all.empty
        and not df_view.empty
        and "bulan" in df_view.columns
        and "tahun" in df_view.columns
    ):
        try:
            cur_bln = df_view["bulan"].iloc[0]
            cur_thn = int(df_view["tahun"].iloc[0])
            df_prev = df_all[
                ~((df_all["bulan"] == cur_bln) & (df_all["tahun"] == cur_thn))
            ]
            if not df_prev.empty:
                rata_lalu = df_prev.groupby(["tahun", "bulan"])["nominal"].sum().mean()
                if total_pengeluaran < rata_lalu:
                    s_tren = 20
                else:
                    ratio_naik = (total_pengeluaran - rata_lalu) / max(rata_lalu, 1)
                    s_tren = max(0, int((1 - ratio_naik) * 20))
        except Exception:
            pass
    skor += s_tren
    detail["Tren Pengeluaran"] = s_tren

    return min(100, skor), detail


def label_health_score(skor: int) -> tuple:
    """Return (label, warna_hex, bg_hex)."""
    if skor >= 80:
        return "💚 Excellent",      "#2E7D32", "#E8F5E9"
    elif skor >= 60:
        return "💛 Sehat",          "#F57F17", "#FFFDE7"
    elif skor >= 40:
        return "🟠 Perlu Perhatian","#E65100", "#FFF3E0"
    else:
        return "🔴 Kritis",         "#B71C1C", "#FFEBEE"


# ============================================================
# GAMIFIKASI — BADGES
# ============================================================
def cek_badges(df_all: pd.DataFrame, budget_dict: dict, target_dict: dict) -> list:
    """Return list of (icon, nama, deskripsi)."""
    badges = []
    if df_all.empty:
        return badges

    # Badge 1: Pencatat Setia — streak ≥ 7 hari
    tanggal_unik = sorted(df_all["waktu_transaksi"].dt.date.unique())
    streak = max_streak = 1
    for i in range(1, len(tanggal_unik)):
        if (tanggal_unik[i] - tanggal_unik[i - 1]).days == 1:
            streak += 1
            max_streak = max(max_streak, streak)
        else:
            streak = 1
    if max_streak >= 7:
        badges.append(("🗓️", "Pencatat Setia", f"Streak {max_streak} hari berturut-turut"))

    # Badge 2: Penabung Konsisten — 2+ bulan di bawah batas belanja
    bulan_hemat = 0
    for key, budget in budget_dict.items():
        target = target_dict.get(key, 0)
        batas  = max(0, budget - target)
        try:
            parts  = key.rsplit("_", 1)
            bln_k  = parts[0]
            thn_k  = int(parts[1])
            df_b   = df_all[(df_all["bulan"] == bln_k) & (df_all["tahun"] == thn_k)]
            if not df_b.empty and df_b["nominal"].sum() <= batas:
                bulan_hemat += 1
        except Exception:
            pass
    if bulan_hemat >= 2:
        badges.append(("🏆", "Penabung Konsisten", f"{bulan_hemat} bulan di bawah batas belanja"))

    # Badge 3: Pengelola Lengkap — 5+ kategori dalam 1 bulan
    if "bulan" in df_all.columns and not df_all.empty:
        bln_terakhir = df_all.iloc[-1]["bulan"]
        n_kat = df_all[df_all["bulan"] == bln_terakhir]["kategori"].nunique()
        if n_kat >= 5:
            badges.append(("🌈", "Pengelola Lengkap", f"Mencatat {n_kat} kategori berbeda"))

    # Badge 4: Big Saver — target tabungan ≥ 20% anggaran & tercapai
    for key, budget in budget_dict.items():
        target = target_dict.get(key, 0)
        if budget > 0 and target / budget >= 0.20:
            try:
                bln_k = key.rsplit("_", 1)[0]
                thn_k = int(key.rsplit("_", 1)[1])
                df_b  = df_all[(df_all["bulan"] == bln_k) & (df_all["tahun"] == thn_k)]
                if not df_b.empty and df_b["nominal"].sum() <= (budget - target):
                    badges.append(("💎", "Big Saver", f"Target tabungan ≥20% di {bln_k}"))
                    break
            except Exception:
                pass

    return badges


# ============================================================
# PDF GENERATOR
# ============================================================
def buat_laporan_pdf(
    email: str,
    pilihan_bulan: str,
    pilihan_tahun: int,
    df_view: pd.DataFrame,
    df_pemasukan_view: pd.DataFrame,
    budget_evaluasi: float,
    target_evaluasi: float,
    total_pengeluaran: float,
    total_pemasukan: float,
    health_score: int,
    label_score: str,
) -> bytes | None:
    if not PDF_AVAILABLE:
        return None

    pdf = FPDF()
    pdf.add_page()
    pdf.set_auto_page_break(auto=True, margin=15)

    # Header banner
    pdf.set_fill_color(46, 125, 50)
    pdf.rect(0, 0, 210, 38, "F")
    pdf.set_text_color(255, 255, 255)
    pdf.set_font("Helvetica", "B", 18)
    pdf.set_xy(10, 8)
    pdf.cell(0, 10, "DanaPintar AI  --  Laporan Keuangan", ln=True)
    pdf.set_font("Helvetica", "", 11)
    pdf.set_xy(10, 21)
    pdf.cell(0, 7, f"Periode: {pilihan_bulan} {pilihan_tahun}   |   Akun: {email}", ln=True)
    pdf.set_text_color(0, 0, 0)
    pdf.set_y(48)

    # Ringkasan
    pdf.set_font("Helvetica", "B", 13)
    pdf.cell(0, 8, "Ringkasan Keuangan", ln=True)
    pdf.set_font("Helvetica", "", 11)
    items_ringkasan = [
        ("Anggaran",           format_rupiah(budget_evaluasi)),
        ("Total Pemasukan",    format_rupiah(total_pemasukan)),
        ("Total Pengeluaran",  format_rupiah(total_pengeluaran)),
        ("Target Tabungan",    format_rupiah(target_evaluasi)),
        ("Sisa Anggaran",      format_rupiah(budget_evaluasi - total_pengeluaran)),
        ("Net Cash Flow",      format_rupiah(total_pemasukan - total_pengeluaran)),
        ("Health Score",       f"{health_score}/100  ({label_score.replace(chr(0x1F49A),'').replace(chr(0x1F49B),'').strip()})"),
    ]
    for lbl, val in items_ringkasan:
        pdf.cell(75, 7, lbl + ":", border=0)
        pdf.cell(0, 7, val, ln=True)
    pdf.ln(4)

    # Tabel pengeluaran
    if not df_view.empty:
        pdf.set_font("Helvetica", "B", 13)
        pdf.cell(0, 8, "Detail Pengeluaran", ln=True)
        cols_h   = ["Tanggal", "Deskripsi", "Kategori", "Sifat", "Nominal (Rp)"]
        cols_w   = [28, 60, 35, 22, 35]
        pdf.set_font("Helvetica", "B", 9)
        pdf.set_fill_color(220, 240, 220)
        for h, w in zip(cols_h, cols_w):
            pdf.cell(w, 7, h, border=1, fill=True)
        pdf.ln()
        pdf.set_font("Helvetica", "", 8)
        for _, row in df_view.iterrows():
            vals = [
                f"{int(row.get('tanggal', 0))} {str(row.get('bulan',''))[:3]}",
                str(row.get("catatan", ""))[:30],
                str(row.get("kategori", ""))[:20],
                str(row.get("sifat", "")),
                f"{row['nominal']:,.0f}",
            ]
            for v, w in zip(vals, cols_w):
                pdf.cell(w, 6, v, border=1)
            pdf.ln()
        pdf.set_font("Helvetica", "B", 9)
        pdf.set_fill_color(220, 240, 220)
        pdf.cell(sum(cols_w[:-1]), 7, "TOTAL PENGELUARAN", border=1, fill=True)
        pdf.cell(cols_w[-1], 7, f"{total_pengeluaran:,.0f}", border=1, fill=True)
        pdf.ln(8)

        # Per kategori
        pdf.set_font("Helvetica", "B", 13)
        pdf.cell(0, 8, "Pengeluaran per Kategori", ln=True)
        pdf.set_font("Helvetica", "B", 9)
        pdf.set_fill_color(220, 240, 220)
        for h, w in zip(["Kategori", "Total (Rp)", "% Anggaran"], [80, 45, 40]):
            pdf.cell(w, 7, h, border=1, fill=True)
        pdf.ln()
        pdf.set_font("Helvetica", "", 9)
        per_kat = df_view.groupby("kategori")["nominal"].sum().sort_values(ascending=False)
        for kat, tot in per_kat.items():
            pct = (tot / budget_evaluasi * 100) if budget_evaluasi > 0 else 0
            for v, w in zip([str(kat), f"{tot:,.0f}", f"{pct:.1f}%"], [80, 45, 40]):
                pdf.cell(w, 6, v, border=1)
            pdf.ln()
        pdf.ln(6)

    # Tabel pemasukan
    if not df_pemasukan_view.empty:
        pdf.set_font("Helvetica", "B", 13)
        pdf.cell(0, 8, "Detail Pemasukan", ln=True)
        cols_ph = ["Tanggal", "Sumber", "Kategori", "Nominal (Rp)"]
        cols_pw = [28, 70, 40, 42]
        pdf.set_font("Helvetica", "B", 9)
        pdf.set_fill_color(220, 240, 220)
        for h, w in zip(cols_ph, cols_pw):
            pdf.cell(w, 7, h, border=1, fill=True)
        pdf.ln()
        pdf.set_font("Helvetica", "", 8)
        for _, row in df_pemasukan_view.iterrows():
            tgl_p = f"{int(row.get('tanggal', 0))} {str(row.get('bulan',''))[:3]}" \
                    if 'tanggal' in row else "-"
            vals = [
                tgl_p,
                str(row.get("sumber", ""))[:35],
                str(row.get("kategori", ""))[:20],
                f"{row['nominal']:,.0f}",
            ]
            for v, w in zip(vals, cols_pw):
                pdf.cell(w, 6, v, border=1)
            pdf.ln()
        pdf.set_font("Helvetica", "B", 9)
        pdf.set_fill_color(220, 240, 220)
        pdf.cell(sum(cols_pw[:-1]), 7, "TOTAL PEMASUKAN", border=1, fill=True)
        pdf.cell(cols_pw[-1], 7, f"{total_pemasukan:,.0f}", border=1, fill=True)
        pdf.ln(8)

    # Footer
    pdf.set_font("Helvetica", "I", 8)
    pdf.set_text_color(120, 120, 120)
    ts = waktu_sekarang_wib().strftime("%d %B %Y %H:%M")
    pdf.cell(0, 5, f"Dibuat oleh DanaPintar AI pada {ts} WIB", align="C", ln=True)
    pdf.cell(0, 5, "Dibangun dengan cinta oleh Hendrawan Lotanto  --  (c) 2026 DanaPintar AI",
             align="C")

    return bytes(pdf.output())


# ============================================================
# AUTH GATE
# ============================================================
if st.session_state.user_aktif is None:
    tab_login, tab_daftar = st.tabs(["🔑 Masuk", "📝 Daftar"])

    with tab_login:
        email_in = st.text_input("Email", key="log_email")
        pass_in  = st.text_input("Password", type="password", key="log_pass")
        if st.button("Masuk 🚀"):
            try:
                resp = supabase.auth.sign_in_with_password(
                    {"email": email_in, "password": pass_in}
                )
                st.session_state.user_aktif = resp.user
                muat_anggaran_dari_cloud(resp.user.id, paksa=True)
                muat_target_tabungan_dari_cloud(resp.user.id, paksa=True)
                st.session_state.toast_kondisi_ditampilkan = False
                st.rerun()
            except Exception as e:
                st.error(f"Login gagal: {e}")

    with tab_daftar:
        email_reg = st.text_input("Email Baru", key="reg_email")
        pass_reg  = st.text_input("Password (min 6 karakter)", type="password", key="reg_pass")
        if st.button("Daftar ✨"):
            try:
                supabase.auth.sign_up({"email": email_reg, "password": pass_reg})
                st.success("Akun berhasil dibuat! Silakan masuk.")
            except Exception as e:
                st.error(f"Pendaftaran gagal: {e}")

    st.stop()


# ============================================================
# DASHBOARD UTAMA — persiapan
# ============================================================
uid        = st.session_state.user_aktif.id
email_user = st.session_state.user_aktif.email

if not st.session_state.muat_anggaran_sukses:
    muat_anggaran_dari_cloud(uid, paksa=True)
if not st.session_state.muat_tabungan_sukses:
    muat_target_tabungan_dari_cloud(uid, paksa=True)

# Toast notifications
if st.session_state.simpan_sukses:
    st.toast(st.session_state.pesan_toast, icon="✅")
    st.session_state.simpan_sukses = False
if st.session_state.hapus_sukses:
    st.toast(st.session_state.pesan_toast, icon="🗑️")
    st.session_state.hapus_sukses  = False
    st.session_state.pesan_toast   = ""


# ============================================================
# SIDEBAR
# ============================================================
with st.sidebar:

    # --- Profil ---
    st.markdown(f"""
    <div class="profile-card">
        <div style="display:flex;align-items:center;gap:8px;">
            <span style="font-size:1.8rem;">👤</span>
            <div>
                <div class="label">Akun Aktif</div>
                <div class="email">{email_user}</div>
            </div>
        </div>
    </div>
    """, unsafe_allow_html=True)

    if st.button("🚪 Logout", use_container_width=True, key="logout_btn"):
        try:
            supabase.auth.sign_out()
        except Exception:
            pass
        for _k in ["user_aktif", "anggaran_terkunci", "target_tabungan",
                   "muat_anggaran_sukses", "muat_tabungan_sukses",
                   "toast_kondisi_ditampilkan", "chat_history"]:
            _default_val = _defaults.get(_k)
            st.session_state[_k] = _default_val
        st.rerun()

    st.markdown("---")

    # --- Anggaran ---
    st.subheader("🔒 Kunci Anggaran Bulanan")
    _now = waktu_sekarang_wib()
    bln_budget = st.selectbox(
        "Bulan Anggaran", list(KAMUS_BULAN.values()),
        index=_now.month - 1, key="sb_bln_budget"
    )
    thn_budget = st.selectbox(
        "Tahun Anggaran", [2025, 2026, 2027], index=1, key="sb_thn_budget"
    )
    key_budget       = f"{bln_budget}_{thn_budget}"
    anggaran_terkunci = st.session_state.anggaran_terkunci.get(key_budget)

    if anggaran_terkunci is not None:
        st.success(f"🔒 Anggaran {bln_budget} {thn_budget}\n**{format_rupiah(anggaran_terkunci)}**")
        with st.expander("⚙️ Opsi Anggaran"):
            st.write("Kunci aktif. Reset untuk mengubah nominal.")
            if st.button("🔓 Reset Anggaran", key="reset_budget"):
                with st.form("konfirmasi_reset"):
                    konfirmasi = st.text_input("Ketik RESET untuk melanjutkan")
                    if st.form_submit_button("Ya, Reset"):
                        if konfirmasi.strip().upper() == "RESET":
                            st.session_state.anggaran_terkunci.pop(key_budget, None)
                            try:
                                supabase.table("budgets").delete()\
                                    .eq("user_id", uid)\
                                    .eq("bulan_key", key_budget).execute()
                                st.success("✅ Anggaran direset!")
                                st.rerun()
                            except Exception as e:
                                st.error(f"Gagal reset: {e}")
                        else:
                            st.error("Ketik RESET dengan benar.")
    else:
        input_budget = st.number_input(
            f"Set Anggaran {bln_budget} (Rp):",
            min_value=ANGGARAN_MIN, value=ANGGARAN_DEFAULT, step=100_000
        )
        if st.button(f"🔐 KUNCI Anggaran {bln_budget}", key="kunci_budget"):
            st.session_state.anggaran_terkunci[key_budget] = input_budget
            if simpan_anggaran_ke_cloud(uid, key_budget, input_budget):
                st.success(f"✅ Anggaran {bln_budget} {thn_budget} terkunci!")
                st.rerun()
            else:
                st.session_state.anggaran_terkunci.pop(key_budget, None)

    st.markdown("---")

    # --- Target Tabungan ---
    st.subheader("💰 Target Tabungan")
    if anggaran_terkunci is not None:
        target_skrg = st.session_state.target_tabungan.get(key_budget)
        if target_skrg is not None:
            st.success(f"🎯 Target {bln_budget}: **{format_rupiah(target_skrg)}**")
            if st.button("🔄 Ubah Target", key="ubah_target"):
                st.session_state.target_tabungan.pop(key_budget, None)
                try:
                    supabase.table("savings_goals").delete()\
                        .eq("user_id", uid).eq("bulan_key", key_budget).execute()
                except Exception:
                    pass
                st.rerun()
        else:
            input_target = st.number_input(
                f"Target Tabungan {bln_budget} (Rp):",
                min_value=0, max_value=int(anggaran_terkunci),
                value=0, step=50_000
            )
            if st.button("💾 Simpan Target", key="simpan_target"):
                if input_target > anggaran_terkunci:
                    st.error("Target tidak boleh melebihi anggaran.")
                else:
                    st.session_state.target_tabungan[key_budget] = input_target
                    if simpan_target_tabungan_ke_cloud(uid, key_budget, input_target):
                        st.success("✅ Target tabungan disimpan!")
                        st.rerun()
                    else:
                        st.session_state.target_tabungan.pop(key_budget, None)
    else:
        st.info("Kunci anggaran terlebih dahulu.")

    st.markdown("---")

    # --- Form Catat Pengeluaran ---
    st.subheader("✍️ Catat Pengeluaran")
    with st.form("form_transaksi"):
        in_catatan   = st.text_input("Nama Transaksi:", placeholder="Contoh: Beli Tissue")
        in_nominal   = st.number_input("Nominal (Rp):", min_value=0, value=0, step=1_000)
        in_kategori  = st.selectbox("Kategori:", KATEGORI_PENGELUARAN)
        in_sifat     = st.radio("Sifat:", ["Wajib", "Sukarela"])
        _now_form    = waktu_sekarang_wib()
        in_tanggal   = st.date_input("Tanggal", value=_now_form.date(), format="DD/MM/YYYY")
        _cj, _cm     = st.columns(2)
        with _cj:
            jam_inp = st.number_input(
                "Jam", 0, 23, st.session_state.jam_input, 1, key="inp_jam"
            )
        with _cm:
            mnt_inp = st.number_input(
                "Menit", 0, 59, st.session_state.menit_input, 1, key="inp_mnt"
            )
        in_recurring = st.checkbox("Jadikan template berulang?")
        in_freq      = None
        if in_recurring:
            in_freq = st.selectbox("Frekuensi:", FREKUENSI_BERULANG)
        st.session_state.jam_input   = jam_inp
        st.session_state.menit_input = mnt_inp
        submitted_transaksi = st.form_submit_button("💾 Simpan Pengeluaran")

    if submitted_transaksi:
        _errors = []
        if not in_catatan.strip():
            _errors.append("Nama transaksi tidak boleh kosong.")
        if in_nominal <= 0:
            _errors.append("Nominal harus lebih dari 0.")
        if _errors:
            for _e in _errors:
                st.error(_e)
        else:
            try:
                _dt     = datetime(in_tanggal.year, in_tanggal.month, in_tanggal.day,
                                   jam_inp, mnt_inp)
                _dt_iso = TZ.localize(_dt).astimezone(pytz.UTC).isoformat()
                _resp   = supabase.table("transaksi").insert({
                    "user_id": uid, "catatan": in_catatan.strip(),
                    "nominal": in_nominal, "kategori": in_kategori,
                    "sifat": in_sifat, "waktu_transaksi": _dt_iso
                }).execute()
                if in_recurring and in_freq and _resp.data:
                    supabase.table("recurring_templates").insert({
                        "user_id": uid, "catatan": in_catatan.strip(),
                        "nominal": in_nominal, "kategori": in_kategori,
                        "sifat": in_sifat, "frekuensi": in_freq
                    }).execute()
                if _resp.data:
                    st.cache_data.clear()
                    st.session_state.simpan_sukses = True
                    st.session_state.pesan_toast   = f"✅ '{in_catatan.strip()}' berhasil dicatat!"
                    st.session_state.jam_input     = waktu_sekarang_wib().hour
                    st.session_state.menit_input   = waktu_sekarang_wib().minute
                    st.rerun()
                else:
                    st.error("Gagal menyimpan transaksi.")
            except Exception as e:
                st.error(f"Error: {e}")

    st.markdown("---")

    # --- Form Catat Pemasukan ---
    st.subheader("💵 Catat Pemasukan")
    with st.form("form_pemasukan"):
        in_sumber      = st.text_input("Sumber Pemasukan:", placeholder="Contoh: Gaji Bulanan")
        in_nom_masuk   = st.number_input("Nominal (Rp):", min_value=0, value=0,
                                          step=100_000, key="nom_masuk")
        in_kat_masuk   = st.selectbox("Kategori:", KATEGORI_PEMASUKAN)
        in_tgl_masuk   = st.date_input("Tanggal", value=waktu_sekarang_wib().date(),
                                        format="DD/MM/YYYY", key="tgl_masuk")
        submitted_pmskan = st.form_submit_button("💾 Simpan Pemasukan")

    if submitted_pmskan:
        if not in_sumber.strip():
            st.error("Sumber pemasukan tidak boleh kosong.")
        elif in_nom_masuk <= 0:
            st.error("Nominal harus lebih dari 0.")
        else:
            try:
                _dt_m   = datetime(in_tgl_masuk.year, in_tgl_masuk.month,
                                   in_tgl_masuk.day, 12, 0)
                _dt_m_i = TZ.localize(_dt_m).astimezone(pytz.UTC).isoformat()
                _resp_m = supabase.table("pemasukan").insert({
                    "user_id": uid, "sumber": in_sumber.strip(),
                    "nominal": in_nom_masuk, "kategori": in_kat_masuk,
                    "waktu_pemasukan": _dt_m_i
                }).execute()
                if _resp_m.data:
                    st.cache_data.clear()
                    st.session_state.simpan_sukses = True
                    st.session_state.pesan_toast   = f"💵 '{in_sumber.strip()}' berhasil dicatat!"
                    st.rerun()
                else:
                    st.error("Gagal menyimpan pemasukan.")
            except Exception as e:
                st.error(f"Error: {e}")

    st.markdown("---")

    # --- Recurring Templates ---
    st.subheader("🔄 Template Berulang")
    data_recurring = ambil_recurring(uid)
    if data_recurring:
        with st.expander(f"📋 {len(data_recurring)} template aktif"):
            for _rec in data_recurring:
                _c1, _c2 = st.columns([4, 1])
                with _c1:
                    st.caption(
                        f"**{_rec['catatan']}** — {format_rupiah(_rec['nominal'])} "
                        f"({_rec.get('frekuensi','?')})"
                    )
                with _c2:
                    if st.button("❌", key=f"del_rec_{_rec['id']}"):
                        supabase.table("recurring_templates").delete()\
                            .eq("id", _rec["id"]).eq("user_id", uid).execute()
                        st.cache_data.clear()
                        st.rerun()

        if st.button("⚡ Generate Transaksi Bulan Ini", key="gen_recurring"):
            _skrg  = waktu_sekarang_wib()
            _ok    = 0
            for _rec in data_recurring:
                try:
                    _wt  = datetime(_skrg.year, _skrg.month, 1, 8, 0)
                    _wti = TZ.localize(_wt).astimezone(pytz.UTC).isoformat()
                    supabase.table("transaksi").insert({
                        "user_id": uid, "catatan": _rec["catatan"],
                        "nominal": _rec["nominal"], "kategori": _rec["kategori"],
                        "sifat": _rec["sifat"], "waktu_transaksi": _wti
                    }).execute()
                    _ok += 1
                except Exception:
                    pass
            if _ok:
                st.cache_data.clear()
                st.success(f"✅ {_ok} transaksi berulang digenerate!")
                st.rerun()
    else:
        st.info("Belum ada template. Centang 'berulang' saat mencatat transaksi.")


# ============================================================
# LOAD DATA UTAMA
# ============================================================
data_mentah          = ambil_data_transaksi(uid)
data_pemasukan_mentah = ambil_data_pemasukan(uid)

if not data_mentah and not data_pemasukan_mentah:
    st.info("📭 Belum ada transaksi. Mulai catat di sidebar kiri.")
    st.stop()

# --- Proses Transaksi (Pengeluaran) ---
if data_mentah:
    df = pd.DataFrame(data_mentah)
    df["nominal"] = pd.to_numeric(df["nominal"], errors="coerce")
    df = df.dropna(subset=["nominal"])
    _inv = df["nominal"].isna().sum()
    if _inv:
        st.warning(f"⚠️ {_inv} transaksi dengan nominal tidak valid diabaikan.")
    try:
        df = parse_df_waktu(df, "waktu_transaksi")
    except Exception as e:
        st.error(f"Gagal memproses data transaksi: {e}")
        st.stop()
else:
    df = pd.DataFrame()

# --- Proses Pemasukan ---
if data_pemasukan_mentah:
    df_pemasukan = pd.DataFrame(data_pemasukan_mentah)
    df_pemasukan["nominal"] = pd.to_numeric(df_pemasukan["nominal"], errors="coerce")
    df_pemasukan = df_pemasukan.dropna(subset=["nominal"])
    try:
        df_pemasukan = parse_df_waktu(df_pemasukan, "waktu_pemasukan")
    except Exception as e:
        st.error(f"Gagal memproses data pemasukan: {e}")
        df_pemasukan = pd.DataFrame()
else:
    df_pemasukan = pd.DataFrame()


# ============================================================
# FILTER PERIODE
# ============================================================
st.markdown("### 🗓️ Filter Periode")
_c1, _c2 = st.columns(2)
daftar_tahun = (
    sorted(df["tahun"].unique().tolist())
    if not df.empty
    else [waktu_sekarang_wib().year]
)
_now_dash = waktu_sekarang_wib()
pilihan_bulan = _c1.selectbox(
    "Bulan", ["Semua Bulan"] + list(KAMUS_BULAN.values()),
    index=_now_dash.month if _now_dash.month <= 12 else 0
)
pilihan_tahun = _c2.selectbox(
    "Tahun", daftar_tahun,
    index=len(daftar_tahun) - 1 if daftar_tahun else 0
)

if pilihan_bulan == "Semua Bulan":
    df_view = (
        df[df["tahun"] == pilihan_tahun].copy() if not df.empty else pd.DataFrame()
    )
    df_pemasukan_view = (
        df_pemasukan[df_pemasukan["tahun"] == pilihan_tahun].copy()
        if not df_pemasukan.empty else pd.DataFrame()
    )
    budget_evaluasi = sum(
        v for k, v in st.session_state.anggaran_terkunci.items()
        if k.endswith(f"_{pilihan_tahun}")
    )
    target_evaluasi = sum(
        v for k, v in st.session_state.target_tabungan.items()
        if k.endswith(f"_{pilihan_tahun}")
    )
else:
    df_view = (
        df[(df["bulan"] == pilihan_bulan) & (df["tahun"] == pilihan_tahun)].copy()
        if not df.empty else pd.DataFrame()
    )
    df_pemasukan_view = (
        df_pemasukan[
            (df_pemasukan["bulan"] == pilihan_bulan) &
            (df_pemasukan["tahun"] == pilihan_tahun)
        ].copy()
        if not df_pemasukan.empty else pd.DataFrame()
    )
    _key_eval       = f"{pilihan_bulan}_{pilihan_tahun}"
    budget_evaluasi = st.session_state.anggaran_terkunci.get(_key_eval, 0)
    target_evaluasi = st.session_state.target_tabungan.get(_key_eval, 0)

# Kalkulasi utama
total_pengeluaran = df_view["nominal"].sum()       if not df_view.empty        else 0.0
total_pemasukan   = df_pemasukan_view["nominal"].sum() if not df_pemasukan_view.empty else 0.0
batas_belanja     = max(0.0, budget_evaluasi - target_evaluasi)  # [PERBAIKAN] guard negatif
sisa_anggaran     = budget_evaluasi - total_pengeluaran
net_cashflow      = total_pemasukan - total_pengeluaran
sukarela = (
    df_view[df_view["sifat"] == "Sukarela"]["nominal"].sum()
    if not df_view.empty else 0.0
)

# Toast kondisi keuangan (sekali per session)
if not st.session_state.toast_kondisi_ditampilkan and batas_belanja > 0:
    _pct = (total_pengeluaran / batas_belanja) * 100
    if _pct >= 100:
        st.toast("🚨 Target tabungan terancam! Pengeluaran melebihi batas.", icon="⚠️")
    elif _pct >= 80:
        st.toast(f"🟠 Hati-hati! Pengeluaran sudah {_pct:.0f}% dari batas.", icon="📊")
    else:
        st.toast(f"🟢 Pengeluaran aman ({_pct:.0f}%). Tabungan terlindungi.", icon="✅")
    st.session_state.toast_kondisi_ditampilkan = True


# ============================================================
# FINANCIAL HEALTH SCORE
# ============================================================
health_score, health_detail = hitung_health_score(
    total_pengeluaran, budget_evaluasi, target_evaluasi,
    sukarela, df_view, df if not df.empty else pd.DataFrame()
)
label_score, warna_score, bg_score = label_health_score(health_score)

st.markdown("### 🏅 Financial Health Score")
_hs_col1, _hs_col2 = st.columns([1, 2])
with _hs_col1:
    st.markdown(f"""
    <div style="background:{bg_score};border-radius:16px;padding:1.5rem;text-align:center;
                box-shadow:0 4px 12px rgba(0,0,0,0.08);">
        <div style="font-size:3rem;font-weight:800;color:{warna_score};">{health_score}</div>
        <div style="font-size:1rem;font-weight:600;color:{warna_score};">/100</div>
        <div style="font-size:1.05rem;margin-top:0.4rem;">{label_score}</div>
    </div>
    """, unsafe_allow_html=True)

with _hs_col2:
    _maks_map = {
        "Rasio Tabungan": 40, "Konsistensi Catat": 20,
        "Porsi Sukarela": 20, "Tren Pengeluaran": 20
    }
    for _komp, _poin in health_detail.items():
        _maks  = _maks_map[_komp]
        _pct_b = _poin / _maks
        _bc    = "#2E7D32" if _pct_b >= 0.7 else ("#F57F17" if _pct_b >= 0.4 else "#B71C1C")
        st.markdown(f"""
        <div style="margin-bottom:0.6rem;">
            <div style="display:flex;justify-content:space-between;font-size:0.85rem;">
                <span>{_komp}</span>
                <span style="color:{_bc};font-weight:600;">{_poin}/{_maks}</span>
            </div>
            <div style="background:#e0e0e0;border-radius:8px;height:8px;">
                <div style="background:{_bc};width:{_pct_b*100:.0f}%;height:8px;border-radius:8px;"></div>
            </div>
        </div>
        """, unsafe_allow_html=True)

st.markdown("---")


# ============================================================
# METRIK UTAMA
# ============================================================
st.markdown("### 💹 Ringkasan Keuangan")
_km = st.columns(4)
_km[0].metric("Anggaran",     format_rupiah(budget_evaluasi))
_km[1].metric("Pemasukan",    format_rupiah(total_pemasukan))
_km[2].metric("Pengeluaran",  format_rupiah(total_pengeluaran))
_km[3].metric(
    "Net Cash Flow", format_rupiah(net_cashflow),
    delta="Surplus" if net_cashflow >= 0 else "Defisit",
    delta_color="normal" if net_cashflow >= 0 else "inverse"
)

_km2 = st.columns(4)
_km2[0].metric("Target Tabungan", format_rupiah(target_evaluasi))
_km2[1].metric("Batas Belanja",   format_rupiah(batas_belanja))
_sisa_batas = batas_belanja - total_pengeluaran
_km2[2].metric(
    "Sisa Batas Belanja", format_rupiah(abs(_sisa_batas)),
    delta="Aman" if _sisa_batas >= 0 else "Defisit",
    delta_color="normal" if _sisa_batas >= 0 else "inverse"
)
_km2[3].metric("Sisa Anggaran", format_rupiah(sisa_anggaran))

st.markdown("---")


# ============================================================
# TAB KONTEN UTAMA
# ============================================================
tab1, tab2, tab3, tab4, tab5 = st.tabs([
    "📋 Pengeluaran", "💵 Pemasukan", "📊 Visualisasi",
    "🧠 Analisis AI",  "🤖 Chat AI"
])


# ============================================================
# TAB 1 — PENGELUARAN
# ============================================================
with tab1:
    st.markdown("#### 📋 Lembar Pengeluaran")
    if not df_view.empty:
        _dv = df_view.copy()
        _dv["Jam Catat"] = _dv.apply(
            lambda r: f"{int(r['jam']):02d}:{int(r['menit']):02d} WIB", axis=1
        )
        _dv["Tanggal Lengkap"] = _dv["waktu_transaksi"].apply(
            lambda t: f"{t.day} {KAMUS_BULAN[t.month]} {t.year}"
        )
        _df_tampil = _dv[[
            "Tanggal Lengkap", "catatan", "nominal",
            "kategori", "sifat", "Jam Catat"
        ]].copy()
        _df_tampil.columns = ["Tanggal", "Deskripsi",
                               "Nominal (Rp)", "Kategori", "Sifat", "Waktu"]

        _sel = st.dataframe(
            _df_tampil, use_container_width=True, hide_index=True,
            selection_mode="multi-row", on_select="rerun", key="tbl_transaksi"
        )

        _col_del, _col_dl = st.columns(2)
        with _col_del:
            if st.button("🗑️ Hapus Terpilih", key="hapus_transaksi"):
                _sel_idx = _sel.selection.rows
                if _sel_idx:
                    _valid = [i for i in _sel_idx if i < len(_dv)]
                    if _valid:
                        _ids = _dv.iloc[_valid]["id"].tolist()
                        try:
                            for _tid in _ids:
                                # [PERBAIKAN] Sertakan user_id pada delete
                                supabase.table("transaksi").delete()\
                                    .eq("id", _tid).eq("user_id", uid).execute()
                            st.cache_data.clear()
                            st.session_state.hapus_sukses = True
                            st.session_state.pesan_toast  = f"🗑️ {len(_ids)} transaksi dihapus."
                            st.rerun()
                        except Exception as e:
                            st.error(f"Gagal hapus: {e}")
                    else:
                        st.warning("Tidak ada baris valid.")
                else:
                    st.warning("Pilih minimal satu baris.")
        with _col_dl:
            _csv = _df_tampil.to_csv(index=False).encode("utf-8")
            st.download_button(
                "📥 Unduh CSV", _csv,
                f"pengeluaran_{pilihan_bulan}_{pilihan_tahun}.csv", "text/csv"
            )
    else:
        st.info("Tidak ada pengeluaran pada periode ini.")


# ============================================================
# TAB 2 — PEMASUKAN
# ============================================================
with tab2:
    st.markdown("#### 💵 Lembar Pemasukan")
    if not df_pemasukan_view.empty:
        _dpv = df_pemasukan_view.copy()
        _dpv["Tanggal"] = _dpv["waktu_pemasukan"].apply(
            lambda t: f"{t.day} {KAMUS_BULAN[t.month]} {t.year}"
        )
        _dfp_tampil = _dpv[["Tanggal", "sumber", "nominal", "kategori"]].copy()
        _dfp_tampil.columns = ["Tanggal", "Sumber", "Nominal (Rp)", "Kategori"]

        _sel_p = st.dataframe(
            _dfp_tampil, use_container_width=True, hide_index=True,
            selection_mode="multi-row", on_select="rerun", key="tbl_pemasukan"
        )

        _cp1, _cp2 = st.columns(2)
        with _cp1:
            if st.button("🗑️ Hapus Pemasukan Terpilih", key="hapus_pemasukan"):
                _sel_pi = _sel_p.selection.rows
                if _sel_pi:
                    _vp = [i for i in _sel_pi if i < len(_dpv)]
                    if _vp:
                        _idp = _dpv.iloc[_vp]["id"].tolist()
                        try:
                            for _pid in _idp:
                                supabase.table("pemasukan").delete()\
                                    .eq("id", _pid).eq("user_id", uid).execute()
                            st.cache_data.clear()
                            st.session_state.hapus_sukses = True
                            st.session_state.pesan_toast  = f"🗑️ {len(_idp)} pemasukan dihapus."
                            st.rerun()
                        except Exception as e:
                            st.error(f"Gagal hapus: {e}")
                else:
                    st.warning("Pilih minimal satu baris.")
        with _cp2:
            _csvp = _dfp_tampil.to_csv(index=False).encode("utf-8")
            st.download_button(
                "📥 Unduh CSV", _csvp,
                f"pemasukan_{pilihan_bulan}_{pilihan_tahun}.csv", "text/csv"
            )

        st.markdown("**Rincian per Kategori**")
        _kat_masuk = _dpv.groupby("kategori")["nominal"].sum().reset_index()
        _kat_masuk.columns = ["Kategori", "Total (Rp)"]
        st.dataframe(_kat_masuk, use_container_width=True, hide_index=True)
    else:
        st.info("Tidak ada pemasukan pada periode ini.")


# ============================================================
# TAB 3 — VISUALISASI
# ============================================================
with tab3:
    st.markdown("#### 📊 Grafik & Perbandingan")
    _vt1, _vt2, _vt3 = st.tabs(["📈 Tren", "🥧 Kategori", "↔️ Komparatif"])

    # Sub-tab Tren
    with _vt1:
        _vc1, _vc2 = st.columns(2)
        with _vc1:
            st.markdown("**Tren Pengeluaran**")
            if not df.empty:
                _dft = df.groupby(["tahun", "bulan"])["nominal"].sum().reset_index()
                st.altair_chart(
                    alt.Chart(_dft).mark_line(point=True, color="#E53935").encode(
                        x=alt.X("bulan:N", sort=list(KAMUS_BULAN.values()), title="Bulan"),
                        y=alt.Y("nominal:Q", title="Total (Rp)"),
                        tooltip=["bulan", "tahun", "nominal"]
                    ).properties(height=280),
                    use_container_width=True
                )
            else:
                st.write("Belum ada data.")
        with _vc2:
            st.markdown("**Tren Pemasukan**")
            if not df_pemasukan.empty:
                _dftp = df_pemasukan.groupby(["tahun", "bulan"])["nominal"].sum().reset_index()
                st.altair_chart(
                    alt.Chart(_dftp).mark_line(point=True, color="#2E7D32").encode(
                        x=alt.X("bulan:N", sort=list(KAMUS_BULAN.values()), title="Bulan"),
                        y=alt.Y("nominal:Q", title="Total (Rp)"),
                        tooltip=["bulan", "tahun", "nominal"]
                    ).properties(height=280),
                    use_container_width=True
                )
            else:
                st.write("Belum ada data pemasukan.")

        st.markdown("**Net Cash Flow Bulanan**")
        if not df.empty or not df_pemasukan.empty:
            _dfo = (
                df.groupby(["tahun", "bulan"])["nominal"].sum().reset_index()
                  .rename(columns={"nominal": "pengeluaran"})
                if not df.empty
                else pd.DataFrame(columns=["tahun", "bulan", "pengeluaran"])
            )
            _dfi = (
                df_pemasukan.groupby(["tahun", "bulan"])["nominal"].sum().reset_index()
                            .rename(columns={"nominal": "pemasukan"})
                if not df_pemasukan.empty
                else pd.DataFrame(columns=["tahun", "bulan", "pemasukan"])
            )
            _dfcf = pd.merge(_dfo, _dfi, on=["tahun", "bulan"], how="outer").fillna(0)
            _dfcf["net"]   = _dfcf["pemasukan"] - _dfcf["pengeluaran"]
            _dfcf["status"] = _dfcf["net"].apply(lambda x: "Surplus" if x >= 0 else "Defisit")
            st.altair_chart(
                alt.Chart(_dfcf).mark_bar().encode(
                    x=alt.X("bulan:N", sort=list(KAMUS_BULAN.values()), title="Bulan"),
                    y=alt.Y("net:Q", title="Net (Rp)"),
                    color=alt.Color("status:N", scale=alt.Scale(
                        domain=["Surplus", "Defisit"], range=["#2E7D32", "#E53935"]
                    )),
                    tooltip=["bulan", "tahun", "pemasukan", "pengeluaran", "net"]
                ).properties(height=250),
                use_container_width=True
            )

    # Sub-tab Kategori
    with _vt2:
        _vc3, _vc4 = st.columns(2)
        with _vc3:
            st.markdown("**Porsi Pengeluaran per Kategori**")
            if not df_view.empty:
                st.altair_chart(
                    alt.Chart(df_view).mark_arc(innerRadius=40).encode(
                        theta=alt.Theta(field="nominal", type="quantitative"),
                        color=alt.Color(field="kategori", type="nominal",
                                        scale=alt.Scale(scheme="accent")),
                        tooltip=["kategori", "nominal"]
                    ).properties(height=280),
                    use_container_width=True
                )
            else:
                st.write("Tidak ada data.")
        with _vc4:
            st.markdown("**Wajib vs Sukarela**")
            if not df_view.empty:
                _ds = df_view.groupby("sifat")["nominal"].sum().reset_index()
                st.altair_chart(
                    alt.Chart(_ds).mark_arc(innerRadius=40).encode(
                        theta=alt.Theta(field="nominal", type="quantitative"),
                        color=alt.Color(field="sifat", type="nominal",
                                        scale=alt.Scale(
                                            domain=["Wajib", "Sukarela"],
                                            range=["#1565C0", "#FF7043"]
                                        )),
                        tooltip=["sifat", "nominal"]
                    ).properties(height=280),
                    use_container_width=True
                )
            else:
                st.write("Tidak ada data.")

    # Sub-tab Komparatif
    with _vt3:
        st.markdown("**↔️ Perbandingan 2 Bulan**")
        if not df.empty:
            _bulan_ada = list(df["bulan"].unique())
            _thn_ada   = sorted(df["tahun"].unique().tolist())
            _cc1, _cc2 = st.columns(2)
            with _cc1:
                _bln_a = st.selectbox("Bulan A", _bulan_ada, index=0, key="cmp_a")
                _thn_a = st.selectbox("Tahun A", _thn_ada, index=0, key="cmp_ta")
            with _cc2:
                _bln_b = st.selectbox(
                    "Bulan B", _bulan_ada,
                    index=min(1, len(_bulan_ada) - 1), key="cmp_b"
                )
                _thn_b = st.selectbox("Tahun B", _thn_ada, index=0, key="cmp_tb")

            # Guard: periode harus berbeda
            if _bln_a == _bln_b and _thn_a == _thn_b:
                st.warning("⚠️ Pilih periode yang berbeda untuk membandingkan.")
            else:
                _df_a = df[(df["bulan"] == _bln_a) & (df["tahun"] == _thn_a)]
                _df_b = df[(df["bulan"] == _bln_b) & (df["tahun"] == _thn_b)]

                # Label unik mencegah kolom duplikat saat concat
                _lab_a = f"{_bln_a} {_thn_a} (A)"
                _lab_b = f"{_bln_b} {_thn_b} (B)"
                _ka    = _df_a.groupby("kategori")["nominal"].sum().rename(_lab_a)
                _kb    = _df_b.groupby("kategori")["nominal"].sum().rename(_lab_b)
                _dfcmp = pd.concat([_ka, _kb], axis=1).fillna(0).reset_index()
                _dfcmp.columns    = ["Kategori", _lab_a, _lab_b]
                _dfcmp["Selisih"] = _dfcmp[_lab_b].astype(float) - _dfcmp[_lab_a].astype(float)
                _dfcmp["Status"]  = _dfcmp["Selisih"].apply(
                    lambda x: "Naik" if x > 0 else ("Turun" if x < 0 else "Sama")
                )

                _tot_a = _df_a["nominal"].sum()
                _tot_b = _df_b["nominal"].sum()
                _mm    = st.columns(3)
                _mm[0].metric(f"Total {_bln_a} {_thn_a}", format_rupiah(_tot_a))
                _mm[1].metric(
                    f"Total {_bln_b} {_thn_b}", format_rupiah(_tot_b),
                    delta=format_rupiah(_tot_b - _tot_a),
                    delta_color="inverse"
                )
                _mm[2].metric(
                    "Perbandingan", format_rupiah(abs(_tot_b - _tot_a)),
                    delta="Lebih Hemat" if _tot_b < _tot_a else "Lebih Boros",
                    delta_color="normal" if _tot_b <= _tot_a else "inverse"
                )

                _melt = _dfcmp.melt(
                    id_vars="Kategori", value_vars=[_lab_a, _lab_b],
                    var_name="Periode", value_name="Nominal"
                )
                st.altair_chart(
                    alt.Chart(_melt).mark_bar().encode(
                        x=alt.X("Kategori:N", title=""),
                        y=alt.Y("Nominal:Q", title="Nominal (Rp)"),
                        color=alt.Color("Periode:N", scale=alt.Scale(
                            range=["#1565C0", "#FF7043"]
                        )),
                        xOffset="Periode:N",
                        tooltip=["Kategori", "Periode", "Nominal"]
                    ).properties(height=300),
                    use_container_width=True
                )
                st.markdown("**Detail per Kategori**")
                st.dataframe(_dfcmp, use_container_width=True, hide_index=True)
        else:
            st.info("Belum ada data pengeluaran untuk dibandingkan.")


# ============================================================
# TAB 4 — ANALISIS AI
# ============================================================
with tab4:
    st.markdown("#### 🧠 Analisis AI Cerdas")

    if not df_view.empty:
        # 1. Tren historis
        st.markdown("##### 📈 Tren Historis")
        if not df.empty and pilihan_bulan != "Semua Bulan":
            _df_lain = df[
                ~((df["bulan"] == pilihan_bulan) & (df["tahun"] == pilihan_tahun))
            ]
            if not _df_lain.empty:
                _rata = _df_lain.groupby(["tahun", "bulan"])["nominal"].sum().mean()
                if total_pengeluaran > _rata:
                    _sel = total_pengeluaran - _rata
                    _brs = df_view.groupby("kategori")["nominal"].sum().idxmax()
                    st.error(
                        f"📈 **Tren Memburuk:** Lebih tinggi **{format_rupiah(_sel)}** "
                        f"dari rata-rata historis. Penyumbang terbesar: **{_brs}**."
                    )
                else:
                    st.success(
                        f"📉 **Tren Membaik:** Lebih hemat "
                        f"**{format_rupiah(_rata - total_pengeluaran)}** dari rata-rata."
                    )
            else:
                st.info("Belum ada data historis sebelumnya.")
        else:
            st.info("Pilih bulan tertentu untuk melihat perbandingan historis.")

        # 2. Waktu rawan
        st.markdown("##### ⏰ Deteksi Waktu Rawan")
        if "jam" in df_view.columns:
            _malam = df_view[(df_view["jam"] >= 20) | (df_view["jam"] <= 5)]
            if not _malam.empty:
                st.warning(
                    f"🌙 **Belanja Malam/Dini Hari:** {format_rupiah(_malam['nominal'].sum())} "
                    f"— waspadai impulsive buying saat lelah."
                )
            else:
                st.success("✅ Tidak ada transaksi di jam rawan (20:00–05:00).")

        # 3. Porsi pengeluaran
        st.markdown("##### ⚖️ Porsi Pengeluaran")
        _wajib = df_view[df_view["sifat"] == "Wajib"]["nominal"].sum()
        if budget_evaluasi > 0:
            _pct_s = (sukarela / budget_evaluasi) * 100
            if _pct_s > 50:
                st.error(
                    f"💸 Porsi sukarela **{_pct_s:.1f}%** dari anggaran — terlalu besar. "
                    f"Evaluasi prioritas pengeluaran!"
                )
            else:
                st.info(
                    f"💡 Porsi sukarela terkendali ({_pct_s:.1f}% anggaran). "
                    f"Pengeluaran wajib: {format_rupiah(_wajib)}."
                )

        # 4. Evaluasi target tabungan
        st.markdown("##### 🎯 Evaluasi Target Tabungan")
        if target_evaluasi > 0:
            if total_pengeluaran <= batas_belanja:
                _lebih = batas_belanja - total_pengeluaran
                st.success(
                    f"✅ **Target Tercapai!** Masih ada ruang {format_rupiah(_lebih)} "
                    f"sebelum menyentuh batas."
                )
            else:
                _kekrg = total_pengeluaran - batas_belanja
                st.error(
                    f"🚨 **Target Terancam!** Pengeluaran melebihi batas "
                    f"sebesar **{format_rupiah(_kekrg)}**."
                )
                _df_suka = df_view[df_view["sifat"] == "Sukarela"]
                if not _df_suka.empty:
                    _kat_suka = _df_suka.groupby("kategori")["nominal"]\
                        .sum().sort_values(ascending=False)
                    st.write("**💡 Rekomendasi Penghematan:**")
                    _sisa = _kekrg
                    for _kat, _tot_kat in _kat_suka.items():
                        if _sisa <= 0:
                            break
                        _potong = min(_tot_kat, _sisa)
                        st.info(f"➖ Kurangi **{_kat}** sebesar **{format_rupiah(_potong)}**")
                        _sisa -= _potong
                    if _sisa > 0:
                        st.warning(
                            f"⚠️ Setelah memotong semua kategori sukarela, "
                            f"masih kurang {format_rupiah(_sisa)}."
                        )
                else:
                    st.warning("Tidak ada pengeluaran sukarela yang bisa dipangkas.")
        else:
            st.info("📌 Belum ada target tabungan untuk periode ini.")

        # 5. Rekomendasi umum
        st.markdown("##### 🎯 Rekomendasi Umum")
        _top_kat  = df_view.groupby("kategori")["nominal"].sum().idxmax()
        _nom_top  = df_view[df_view["kategori"] == _top_kat]["nominal"].sum()
        _pangkas  = int(_nom_top * 0.2)
        if _pangkas > 0:
            st.info(
                f"➔ Kurangi 20% dari **{_top_kat}** (~{format_rupiah(_pangkas)}) "
                f"untuk penghematan signifikan bulan depan."
            )
        if budget_evaluasi > 0 and sisa_anggaran < 0:
            st.info(
                "➔ Anggaran sudah tekor. Alokasikan dana darurat di "
                "kategori 'Wajib' di awal bulan berikutnya."
            )

        st.markdown("---")

        # 6. Badges
        st.markdown("##### 🏅 Pencapaian & Badges")
        _badges = cek_badges(
            df if not df.empty else pd.DataFrame(),
            st.session_state.anggaran_terkunci,
            st.session_state.target_tabungan
        )
        if _badges:
            _badge_html = "".join([
                f'<span style="display:inline-block;background:linear-gradient(135deg,#FFD700,#FFA500);'
                f'border-radius:50px;padding:0.3rem 0.85rem;font-size:0.88rem;font-weight:600;'
                f'margin:0.25rem;color:#1a1a1a;" title="{_desc}">{_ic} {_nm}</span>'
                for _ic, _nm, _desc in _badges
            ])
            st.markdown(_badge_html, unsafe_allow_html=True)
            for _ic, _nm, _desc in _badges:
                st.caption(f"{_ic} **{_nm}**: {_desc}")
        else:
            st.info(
                "Belum ada badge yang diraih. Terus catat transaksi secara konsisten "
                "untuk membuka pencapaian!"
            )

        st.markdown("---")

        # 7. Ekspor PDF
        st.markdown("##### 📄 Ekspor Laporan PDF")
        if PDF_AVAILABLE:
            if st.button("🖨️ Buat Laporan PDF", key="btn_pdf"):
                with st.spinner("Membuat laporan PDF..."):
                    _pdf_bytes = buat_laporan_pdf(
                        email_user, pilihan_bulan, pilihan_tahun,
                        df_view, df_pemasukan_view,
                        budget_evaluasi, target_evaluasi,
                        total_pengeluaran, total_pemasukan,
                        health_score, label_score
                    )
                    if _pdf_bytes:
                        st.download_button(
                            label="📥 Unduh Laporan PDF",
                            data=_pdf_bytes,
                            file_name=f"DanaPintar_{pilihan_bulan}_{pilihan_tahun}.pdf",
                            mime="application/pdf"
                        )
        else:
            st.warning(
                "📦 Install `fpdf2` untuk mengaktifkan ekspor PDF:\n"
                "```\npip install fpdf2\n```"
            )

    else:
        st.info("Tidak ada data transaksi untuk dianalisis pada periode ini.")


# ============================================================
# TAB 5 — CHAT AI (Google Gemini 2.5 Flash)
# ============================================================
with tab5:
    st.markdown("#### 🤖 DanaBot — AI Keuangan Pribadi")

    _ai_ready = GEMINI_AVAILABLE and GEMINI_API_KEY is not None

    if not _ai_ready:
        st.warning(
            "⚠️ **Fitur Chat AI belum aktif.** Langkah aktivasi:\n\n"
            "1. Install package: `pip install google-generativeai`\n"
            "2. Dapatkan API key **gratis** di: https://aistudio.google.com/app/apikey\n"
            "3. Tambahkan ke `.streamlit/secrets.toml`:\n"
            "   ```\n   GEMINI_API_KEY = \"AIzaSy...\"\n   ```"
        )
    else:
        # Tampilkan riwayat chat
        for _msg in st.session_state.chat_history:
            with st.chat_message(
                _msg["role"],
                avatar="🤖" if _msg["role"] == "assistant" else "👤"
            ):
                st.markdown(_msg["content"])

        if _prompt := st.chat_input(
            "Tanya soal keuanganmu... (contoh: 'Kenapa bulan ini lebih boros?')"
        ):
            st.session_state.chat_history.append(
                {"role": "user", "content": _prompt}
            )
            with st.chat_message("user", avatar="👤"):
                st.markdown(_prompt)

            # Bangun konteks keuangan untuk sistem prompt
            _kat_detail = ""
            if not df_view.empty:
                _kat_dict = df_view.groupby("kategori")["nominal"].sum().to_dict()
                _kat_detail = "\nPengeluaran per kategori:\n" + "\n".join(
                    f"  - {k}: {format_rupiah(v)}" for k, v in _kat_dict.items()
                )

            _sys = f"""Kamu adalah DanaBot, asisten keuangan pribadi yang cerdas dan empatik
dari aplikasi DanaPintar AI. Bantu pengguna Indonesia menganalisis keuangan mereka.
Gunakan bahasa Indonesia yang ramah, ringkas, dan berikan saran yang spesifik & actionable.
Jangan mengarang data — hanya gunakan data yang tersedia di bawah ini.

=== DATA KEUANGAN PENGGUNA ===
Periode        : {pilihan_bulan} {pilihan_tahun}
Anggaran       : {format_rupiah(budget_evaluasi)}
Pemasukan      : {format_rupiah(total_pemasukan)}
Pengeluaran    : {format_rupiah(total_pengeluaran)}
Target Tabungan: {format_rupiah(target_evaluasi)}
Batas Belanja  : {format_rupiah(batas_belanja)}
Sisa Batas     : {format_rupiah(_sisa_batas)}
Net Cash Flow  : {format_rupiah(net_cashflow)}
Health Score   : {health_score}/100 ({label_score})
{_kat_detail}
"""

            with st.chat_message("assistant", avatar="🤖"):
                with st.spinner("DanaBot sedang berpikir..."):
                    try:
                        genai.configure(api_key=GEMINI_API_KEY)

                        # Konversi riwayat ke format Gemini (user/model)
                        _gemini_history = []
                        for _m in st.session_state.chat_history[:-1]:
                            _role = "user" if _m["role"] == "user" else "model"
                            _gemini_history.append({
                                "role": _role,
                                "parts": [_m["content"]]
                            })

                        _model = genai.GenerativeModel(
                            model_name="gemini-2.5-flash",
                            system_instruction=_sys
                        )
                        _chat_session = _model.start_chat(
                            history=_gemini_history
                        )
                        _response = _chat_session.send_message(_prompt)
                        _jawaban  = _response.text

                        st.markdown(_jawaban)
                        st.session_state.chat_history.append(
                            {"role": "assistant", "content": _jawaban}
                        )

                    except Exception as _e:
                        _err = f"Maaf, terjadi error: {_e}"
                        st.error(_err)
                        st.session_state.chat_history.append(
                            {"role": "assistant", "content": _err}
                        )

        # Tombol reset percakapan
        if st.session_state.chat_history:
            if st.button("🗑️ Reset Percakapan", key="reset_chat"):
                st.session_state.chat_history = []
                st.rerun()


# ============================================================
# FOOTER
# ============================================================
st.markdown("---")
st.markdown(
    "<p style='text-align:center;color:#2E7D32;font-size:14px;'>"
    "🛠️ Dibangun dengan ❤️ oleh <strong>Hendrawan Lotanto</strong> "
    "— © 2026 DanaPintar AI Premium v2.0"
    "</p>",
    unsafe_allow_html=True
)

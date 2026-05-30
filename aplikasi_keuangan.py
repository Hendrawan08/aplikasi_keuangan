# ============================================================
# DanaPintar AI Premium — v4.0.0
# Author : Hendrawan Lotanto
# ============================================================
#
# SQL BARU — Jalankan di Supabase SQL Editor sebelum update:
#
# -- Financial Goals
# CREATE TABLE financial_goals (
#   id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
#   user_id UUID NOT NULL,
#   nama TEXT NOT NULL,
#   target_nominal BIGINT NOT NULL,
#   terkumpul BIGINT DEFAULT 0,
#   deadline DATE,
#   kategori TEXT DEFAULT 'Tabungan',
#   ikon TEXT DEFAULT '🎯',
#   created_at TIMESTAMPTZ DEFAULT now()
# );
# ALTER TABLE financial_goals ENABLE ROW LEVEL SECURITY;
# CREATE POLICY "fg_sel" ON financial_goals FOR SELECT USING (auth.uid()::text=user_id::text);
# CREATE POLICY "fg_ins" ON financial_goals FOR INSERT WITH CHECK (auth.uid()::text=user_id::text);
# CREATE POLICY "fg_upd" ON financial_goals FOR UPDATE USING (auth.uid()::text=user_id::text);
# CREATE POLICY "fg_del" ON financial_goals FOR DELETE USING (auth.uid()::text=user_id::text);
#
# -- Custom Kategori
# CREATE TABLE custom_kategori (
#   id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
#   user_id UUID NOT NULL,
#   nama TEXT NOT NULL,
#   tipe TEXT NOT NULL,
#   ikon TEXT DEFAULT '📌'
# );
# ALTER TABLE custom_kategori ENABLE ROW LEVEL SECURITY;
# CREATE POLICY "ck_sel" ON custom_kategori FOR SELECT USING (auth.uid()::text=user_id::text);
# CREATE POLICY "ck_ins" ON custom_kategori FOR INSERT WITH CHECK (auth.uid()::text=user_id::text);
# CREATE POLICY "ck_del" ON custom_kategori FOR DELETE USING (auth.uid()::text=user_id::text);
#
# -- Net Worth History
# CREATE TABLE networth_history (
#   id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
#   user_id UUID NOT NULL,
#   bulan_key TEXT NOT NULL,
#   total_aset BIGINT DEFAULT 0,
#   total_liabilitas BIGINT DEFAULT 0,
#   catatan_aset JSONB DEFAULT '[]',
#   catatan_liabilitas JSONB DEFAULT '[]',
#   recorded_at TIMESTAMPTZ DEFAULT now()
# );
# ALTER TABLE networth_history ENABLE ROW LEVEL SECURITY;
# CREATE POLICY "nw_sel" ON networth_history FOR SELECT USING (auth.uid()::text=user_id::text);
# CREATE POLICY "nw_ins" ON networth_history FOR INSERT WITH CHECK (auth.uid()::text=user_id::text);
# CREATE POLICY "nw_upd" ON networth_history FOR UPDATE USING (auth.uid()::text=user_id::text);
# CREATE POLICY "nw_del" ON networth_history FOR DELETE USING (auth.uid()::text=user_id::text);
#
# SECRETS — .streamlit/secrets.toml:
# SUPABASE_URL = "https://..."
# SUPABASE_KEY = "eyJ..."
# GEMINI_API_KEY = "AIzaSy..."
# ============================================================

import streamlit as st
from supabase import create_client, Client
import pandas as pd
import altair as alt
from datetime import datetime, time, date, timedelta
import calendar as cal_lib
import json
import io
import pytz, os

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
    1:"Januari",2:"Februari",3:"Maret",4:"April",
    5:"Mei",6:"Juni",7:"Juli",8:"Agustus",
    9:"September",10:"Oktober",11:"November",12:"Desember"
}
KATEGORI_PENGELUARAN_DEFAULT = [
    "Makanan","Transportasi","Hiburan/Gaya Hidup",
    "Kebutuhan Rumah/Kesehatan","Tagihan Wajib","Lain-lain"
]
KATEGORI_PEMASUKAN_DEFAULT = [
    "Gaji","Freelance","Bisnis","Investasi",
    "Hadiah/Bonus","Passive Income","Lain-lain"
]
FREKUENSI_BERULANG = ["Bulanan","Mingguan","2 Mingguan"]
TIPE_WALLET       = ["💵 Cash","🏦 Bank","📱 E-Wallet","📈 Investasi","💳 Kartu Kredit"]
ANGGARAN_MIN      = 10_000
ANGGARAN_DEFAULT  = 1_000_000
GOAL_IKON_LIST    = ["🎯","🏠","🚗","✈️","📱","💍","🎓","💊","🐾","🛒","🎸","💻","📷","⛵","🏋️"]
ASET_TIPE_LIST    = ["Tabungan Bank","Investasi","Properti","Kendaraan","Emas/Logam Mulia","Lainnya"]
LIAB_TIPE_LIST    = ["KPR","Kredit Kendaraan","Kartu Kredit","Pinjaman Personal","Hutang Usaha","Lainnya"]

CHANGELOG = [
    {
        "versi": "4.0.0", "tanggal": "Mei 2026",
        "fitur": [
            "🎯 Financial Goals — target finansial jangka pendek/panjang dengan progress bar",
            "📥 Import CSV Mutasi Bank — upload mutasi, mapping kolom, bulk import transaksi",
            "📅 Kalender Heatmap — visualisasi pengeluaran per hari dalam grid kalender",
            "🏷️ Custom Kategori — tambah kategori pengeluaran/pemasukan sendiri",
            "💎 Net Worth Tracker — pantau aset & liabilitas + tren net worth bulanan",
            "📋 Pagination Transaksi — tampil 5 dulu, tombol 'Tampilkan Lebih Banyak'",
        ],
        "perbaikan": [
            "Performa lebih baik pada list transaksi panjang",
            "UX lebih bersih pada halaman utama",
        ]
    },
    {
        "versi": "3.0.0", "tanggal": "Mei 2026",
        "fitur": [
            "✏️ Edit transaksi langsung dari tabel",
            "🗑️ Konfirmasi hapus sebelum data dihapus",
            "🔔 Notifikasi in-app cerdas saat login",
            "🔍 Search & filter transaksi (kata kunci, kategori, sifat, tanggal)",
            "🎉 Onboarding wizard untuk user baru",
            "📋 Halaman Changelog",
            "📂 Budget per kategori — alokasi anggaran per pos pengeluaran",
            "💸 Pelacakan Hutang & Piutang",
            "👛 Multi-Wallet — kelola Cash, Bank, E-Wallet, dll",
            "🌙 Dark Mode",
        ],
        "perbaikan": [
            "Guard negatif pada batas_belanja",
            "Label kolom unik pada dashboard komparatif",
            "Fix RLS policy type mismatch (UUID vs TEXT)",
        ]
    },
    {
        "versi": "2.0.0", "tanggal": "April 2026",
        "fitur": [
            "💵 Income Tracking",
            "🔄 Recurring Templates",
            "🤖 DanaBot — AI Chat keuangan (Google Gemini)",
            "🏅 Financial Health Score",
            "📄 Export laporan PDF",
            "🏆 Gamifikasi & badge",
            "↔️ Dashboard komparatif 2 bulan",
            "👤 Profil lengkap",
        ],
        "perbaikan": ["API key ke st.secrets","Fix security user_id validation"]
    },
    {
        "versi": "1.0.0", "tanggal": "Maret 2026",
        "fitur": [
            "📊 Dashboard utama keuangan",
            "✍️ Catat pengeluaran manual",
            "🔒 Kunci anggaran bulanan",
            "💰 Target tabungan",
            "📈 Visualisasi tren & kategori",
            "🧠 AI Auditor rule-based",
            "🔑 Auth — login & registrasi",
        ],
        "perbaikan": []
    },
]


# ============================================================
# CSS
# ============================================================
def inject_css():
    bg      = "0f172a"
    bg2     = "1e293b"
    bg3     = "334155"
    text    = "e2e8f0"
    text2   = "94a3b8"
    accent  = "4ade80"
    accent2 = "16a34a"
    border  = "475569"
    sidebar = "080f1e"
    card    = "1e293b"
    inp_bg  = "0f172a"
    shadow  = "rgba(0,0,0,0.4)"
    metric_bg = "1e293b"
    bal_grad  = "linear-gradient(135deg,#1a2744 0%,#0f3460 100%)"

    st.markdown(f"""
    <style>
    html,body,[data-testid="stAppViewContainer"]{{
        background:#{bg} !important; color:#{text} !important; font-size:16px;
    }}
    [data-testid="stSidebar"]{{background:#{sidebar} !important;}}
    [data-testid="stSidebar"] *{{color:#e2e8f0 !important;}}
    [data-testid="stSidebar"] .stMarkdown p{{color:#e2e8f0 !important;}}
    h1,h2,h3,h4{{color:#{text} !important; font-weight:700 !important;}}
    h1{{font-size:1.8rem !important;}}
    h4{{color:#{accent} !important;}}
    p,li,span,label{{color:#{text} !important;}}
    .stMarkdown p{{color:#{text} !important;}}
    small, .stCaption,[data-testid="stCaptionContainer"] p{{color:#{text2} !important;font-weight:500 !important;}}
    .stSelectbox label,.stRadio label,.stCheckbox label,
    .stNumberInput label,.stTextInput label,.stDateInput label,
    .stTextArea label,.stFileUploader label{{color:#{text} !important; font-weight:600 !important;}}
    [data-testid="stForm"] p,[data-testid="stForm"] span,[data-testid="stForm"] label{{color:#{text} !important;}}
    .stRadio div[data-testid="stMarkdownContainer"] p,
    .stCheckbox div[data-testid="stMarkdownContainer"] p{{color:#{text} !important; font-weight:500 !important;}}
    [data-testid="stExpander"] summary p,
    [data-testid="stExpander"] summary span{{color:#{text} !important; font-weight:600 !important;}}

    /* BALANCE CARD */
    .balance-card{{
        background:{bal_grad};
        border-radius:20px; padding:1.5rem 1.5rem 1.2rem; color:white;
        box-shadow:0 8px 32px {shadow}; margin-bottom:1rem; position:relative; overflow:hidden;
    }}
    .balance-card::before{{
        content:''; position:absolute; top:-30px; right:-30px;
        width:120px; height:120px; border-radius:50%;
        background:rgba(255,255,255,0.08);
    }}
    .balance-card .label{{font-size:0.75rem;opacity:0.75;text-transform:uppercase;letter-spacing:1px;}}
    .balance-card .amount{{font-size:2.2rem;font-weight:800;margin:0.3rem 0;}}
    .balance-card .sub-card{{background:rgba(255,255,255,0.15);border-radius:12px;padding:0.7rem 1rem;flex:1;}}
    .balance-card .sub-label{{font-size:0.78rem;opacity:0.8;}}
    .balance-card .sub-amount{{font-size:1rem;font-weight:700;}}
    .income-color{{color:#bbf7d0 !important;}}
    .expense-color{{color:#fca5a5 !important;}}

    /* COMPARISON BAR */
    .cmp-bar-wrap{{
        background:#{card}; border-radius:14px; padding:1rem 1.2rem;
        box-shadow:0 4px 16px {shadow}; margin-bottom:1rem;
        border:1.5px solid #{border};
    }}
    .cmp-bar-title{{font-size:0.85rem;font-weight:700;color:#{text};margin-bottom:0.5rem;}}
    .cmp-bar{{border-radius:8px;height:10px;overflow:hidden;display:flex;margin-bottom:0.4rem;}}
    .cmp-income{{background:#22c55e;transition:width 0.5s;}}
    .cmp-expense{{background:#ef4444;transition:width 0.5s;}}
    .cmp-labels{{display:flex;justify-content:space-between;font-size:0.78rem;}}
    .cmp-income-lbl{{color:#16a34a;font-weight:600;}}
    .cmp-expense-lbl{{color:#dc2626;font-weight:600;}}

    /* CARDS */
    .stat-card{{
        background:#{card}; border-radius:14px; padding:1rem 1.1rem;
        box-shadow:0 2px 8px {shadow}; border:1px solid #{border}; margin-bottom:0.5rem;
    }}
    .stat-card .sc-label{{font-size:0.78rem;color:#{text2};margin-bottom:0.2rem;font-weight:600;}}
    .stat-card .sc-value{{font-size:1.2rem;font-weight:700;color:#{text};}}

    /* TRANSACTION ITEM */
    .tx-item{{
        background:#{card}; border-radius:14px; padding:0.9rem 1rem;
        box-shadow:0 2px 8px {shadow}; border:1.5px solid #{border};
        display:flex; align-items:center; gap:0.8rem; margin-bottom:0.6rem;
        transition:transform 0.15s,box-shadow 0.15s;
    }}
    .tx-item:hover{{transform:translateY(-2px);box-shadow:0 6px 16px {shadow};border-color:#{accent};}}
    .tx-icon{{width:42px;height:42px;border-radius:12px;display:flex;align-items:center;
        justify-content:center;font-size:1.2rem;flex-shrink:0;background:rgba(74,222,128,0.15);}}
    .tx-icon.expense{{background:rgba(239,68,68,0.12);}}
    .tx-name{{font-size:0.9rem;font-weight:600;color:#{text};}}
    .tx-sub{{font-size:0.75rem;color:#{text2};margin-top:1px;font-weight:500;}}
    .tx-amount{{font-size:0.95rem;font-weight:700;margin-left:auto;white-space:nowrap;}}
    .tx-amount.income{{color:#16a34a;}}
    .tx-amount.expense{{color:#dc2626;}}

    /* GOAL CARD */
    .goal-card{{
        background:#{card}; border-radius:16px; padding:1.1rem 1.2rem;
        border:1.5px solid #{border}; margin-bottom:0.8rem;
        box-shadow:0 3px 12px {shadow};
    }}
    .goal-title{{font-size:1rem;font-weight:700;color:#{text};}}
    .goal-sub{{font-size:0.78rem;color:#{text2};margin-top:2px;}}
    .goal-pct{{font-size:0.85rem;font-weight:700;}}
    .goal-bar-bg{{background:#{bg3};border-radius:8px;height:10px;margin:0.5rem 0;}}
    .goal-bar-fill{{height:10px;border-radius:8px;transition:width 0.5s;}}

    /* HEATMAP CALENDAR */
    .cal-grid{{
        display:grid;grid-template-columns:repeat(7,1fr);gap:4px;
        margin-bottom:1rem;
    }}
    .cal-header{{
        text-align:center;font-size:0.72rem;font-weight:700;
        color:#{text2};padding:4px 0;
    }}
    .cal-cell{{
        border-radius:6px;aspect-ratio:1;display:flex;align-items:center;
        justify-content:center;font-size:0.72rem;font-weight:600;
        cursor:default;transition:transform 0.1s;
    }}
    .cal-cell:hover{{transform:scale(1.15);}}
    .cal-empty{{background:transparent;}}
    .cal-today{{outline:2px solid #{accent};outline-offset:1px;}}

    /* NET WORTH CARD */
    .nw-card{{
        background:linear-gradient(135deg,#1a2744,#0f3460);
        border-radius:16px;padding:1.2rem 1.4rem;color:white;
        margin-bottom:0.8rem;box-shadow:0 4px 16px {shadow};
    }}
    .nw-title{{font-size:0.75rem;opacity:0.7;text-transform:uppercase;letter-spacing:1px;}}
    .nw-amount{{font-size:2rem;font-weight:800;margin:0.3rem 0;}}

    /* METRICS */
    [data-testid="stMetricValue"]{{font-size:1.4rem !important;color:#{accent} !important;font-weight:700 !important;}}
    [data-testid="stMetricLabel"]{{font-size:0.82rem !important;color:#{text} !important;font-weight:600 !important;}}
    [data-testid="metric-container"]{{
        background:#{metric_bg} !important; border-radius:12px !important;
        border:1.5px solid #{border} !important; padding:0.8rem !important;
        box-shadow:0 3px 10px {shadow} !important;
    }}

    /* BUTTONS */
    .stButton button,.stFormSubmitButton button{{
        font-size:0.92rem !important; padding:0.55rem 1.1rem !important;
        border-radius:10px !important; transition:all 0.2s ease;
        border:1px solid #{border} !important;
        background:#{bg3} !important; color:#{text} !important;
        font-weight:500 !important;
    }}
    .stButton button:hover,.stFormSubmitButton button:hover{{
        transform:translateY(-1px); box-shadow:0 4px 12px {shadow};
        border-color:#{accent} !important; color:#{accent} !important;
    }}
    .stFormSubmitButton button[kind="primaryFormSubmit"],
    [data-testid="stFormSubmitButton"] button{{
        background:linear-gradient(135deg,#{accent},#{accent2}) !important;
        color:white !important; border:none !important; font-weight:700 !important;
        box-shadow:0 2px 8px rgba(21,128,61,0.35) !important;
    }}
    .stButton button{{
        color:#{text} !important; font-weight:600 !important;
        background:#{bg2} !important; border:1.5px solid #{border} !important;
    }}
    .stButton button:hover{{
        background:#{bg3} !important; color:#{accent} !important;
        border-color:#{accent} !important;
    }}

    /* INPUTS */
    input,textarea,.stTextInput input,.stNumberInput input,
    .stDateInput input,.stTimeInput input{{
        font-size:0.95rem !important; padding:0.55rem 0.8rem !important;
        border-radius:10px !important; background:#{inp_bg} !important;
        color:#{text} !important; border:1.5px solid #{border} !important;
        font-weight:500 !important;
    }}
    input:focus,.stTextInput input:focus,.stNumberInput input:focus,
    .stTextArea textarea:focus{{
        border-color:#{accent} !important; outline:none !important;
        box-shadow:0 0 0 3px rgba(21,128,61,0.15) !important;
    }}
    input::placeholder, textarea::placeholder{{color:#9ca3af !important;}}

    /* SELECTBOX */
    .stSelectbox > div,.stMultiSelect > div {{
        border: none !important; background: transparent !important; box-shadow: none !important;
    }}
    .stSelectbox [data-baseweb="select"] > div:nth-child(1),
    .stMultiSelect [data-baseweb="select"] > div:nth-child(1) {{
        border: 1.5px solid #{border} !important; border-radius: 10px !important;
        background-color: #{inp_bg} !important; box-shadow: none !important;
    }}
    .stSelectbox [data-baseweb="select"] > div:nth-child(1):focus-within,
    .stMultiSelect [data-baseweb="select"] > div:nth-child(1):focus-within {{
        border-color: #{accent} !important;
        box-shadow: 0 0 0 3px rgba(74,222,128,0.2) !important;
    }}
    .stSelectbox [data-baseweb="select"] input,
    .stMultiSelect [data-baseweb="select"] input {{
        background: transparent !important; border: none !important;
        outline: none !important; box-shadow: none !important;
        padding: 0 !important; margin: 0 !important;
    }}
    .stSelectbox [data-baseweb="select"] span,
    .stMultiSelect [data-baseweb="select"] span,
    .stSelectbox [data-baseweb="select"] svg,
    .stMultiSelect [data-baseweb="select"] svg,
    [data-baseweb="select"] [data-testid="stMarkdownContainer"] p,
    [data-baseweb="option"] {{color: #{text} !important;}}
    [data-testid="stSidebar"] .stSelectbox [data-baseweb="select"] > div:nth-child(1),
    [data-testid="stSidebar"] .stMultiSelect [data-baseweb="select"] > div:nth-child(1) {{
        border: 1.5px solid #{border} !important; border-radius: 10px !important;
        background-color: #{inp_bg} !important;
    }}
    [data-baseweb="tag"] {{
        background: #{bg3} !important; border: 1px solid #{border} !important;
        border-radius: 6px !important; color: #{text} !important;
    }}
    [data-baseweb="tag"] span {{ color: #{text} !important; }}
    [data-baseweb="popover"] {{border: none !important; box-shadow: 0 8px 24px rgba(0,0,0,0.4) !important;}}
    [data-baseweb="popover"] [data-baseweb="menu"] {{
        background: #{bg2} !important; border: 1.5px solid #{border} !important;
        border-radius: 10px !important; overflow: hidden !important;
    }}
    [data-baseweb="option"] {{background: #{bg2} !important; color: #{text} !important; font-size: 0.9rem !important;}}
    [data-baseweb="option"]:hover,[data-baseweb="option"][aria-selected="true"] {{
        background: #{bg3} !important; color: #{accent} !important;
    }}

    /* TABS */
    .stTabs [data-baseweb="tab-list"]{{
        background:#{bg3} !important; border-radius:12px !important;
        padding:4px !important; gap:2px !important; border:none !important;
    }}
    .stTabs [data-baseweb="tab"]{{
        border-radius:9px !important; color:#{text} !important;
        font-size:0.85rem !important; padding:0.4rem 0.7rem !important;
        border:none !important; background:transparent !important; font-weight:500 !important;
    }}
    .stTabs [aria-selected="true"]{{
        background:#{bg2} !important; color:#{accent} !important;
        font-weight:700 !important; box-shadow:0 1px 4px {shadow} !important;
    }}

    /* EXPANDER */
    [data-testid="stExpander"]{{
        background:#{card} !important; border:1px solid #{border} !important;
        border-radius:12px !important; overflow:hidden !important;
    }}
    [data-testid="stExpanderToggleIcon"]{{color:#{text2} !important;}}

    /* DATAFRAME */
    .stDataFrame{{font-size:0.88rem !important;}}
    [data-testid="stDataFrame"] th{{background:#{bg3} !important; color:#{text2} !important;}}
    [data-testid="stDataFrame"] td{{color:#{text} !important;}}

    /* PROFILE */
    .pro-card{{
        background:linear-gradient(135deg,#1B5E20,#2E7D32,#388E3C);
        border-radius:18px; padding:1.1rem 1rem 0.9rem; margin-bottom:0.5rem;
        color:white; box-shadow:0 6px 20px rgba(0,0,0,0.25);
        border:1px solid rgba(255,255,255,0.1);
    }}
    .pro-card .nama{{font-size:0.95rem;font-weight:700;margin-top:0.4rem;}}
    .pro-card .email-kecil{{font-size:0.7rem;opacity:0.7;word-break:break-all;margin-top:1px;}}
    .pro-card .bio{{font-size:0.78rem;opacity:0.8;margin-top:0.5rem;font-style:italic;
        border-top:1px solid rgba(255,255,255,0.15);padding-top:0.5rem;line-height:1.4;}}
    .pro-card .meta{{font-size:0.7rem;opacity:0.6;margin-top:0.3rem;}}
    .badge-member{{display:inline-block;background:rgba(255,255,255,0.2);
        border-radius:20px;padding:1px 8px;font-size:0.68rem;font-weight:600;}}

    /* ONBOARDING */
    .ob-card{{
        background:linear-gradient(135deg,#1B5E20,#16a34a);
        border-radius:20px;padding:1.8rem;color:white;text-align:center;
        margin-bottom:1.5rem;box-shadow:0 8px 32px rgba(22,163,74,0.25);
    }}

    /* CSV IMPORT */
    .import-preview{{
        background:#{bg2}; border-radius:10px; padding:0.8rem 1rem;
        border:1.5px solid #{border}; margin-bottom:0.5rem;
    }}

    [data-testid="stAlert"]{{border-radius:12px !important;}}
    ::-webkit-scrollbar{{width:5px;height:5px;}}
    ::-webkit-scrollbar-track{{background:#{bg3};}}
    ::-webkit-scrollbar-thumb{{background:#{border};border-radius:3px;}}
    [data-baseweb="popover"] *{{color:#{text} !important;}}
    .section-header{{
        font-size:0.72rem; font-weight:700; text-transform:uppercase;
        letter-spacing:1.5px; color:#{text2}; margin:1rem 0 0.5rem;
        padding-bottom:0.3rem; border-bottom:2px solid #{accent}; display:inline-block;
    }}
    [data-testid="stAlert"] p{{color:inherit !important;}}
    .hs-detail span{{color:#{text} !important;}}
    .stNumberInput button{{
        background:#{bg3} !important; color:#{text} !important;
        border:1px solid #{border} !important; border-radius:6px !important;
    }}

    @media(max-width:768px){{
        h1{{font-size:1.5rem !important;}}
        h2{{font-size:1.3rem !important;}}
        .stButton button,.stFormSubmitButton button{{
            min-height:44px !important; width:100%; font-size:0.95rem !important;
        }}
        [data-testid="stMetricValue"]{{font-size:1.2rem !important;}}
        [data-testid="stHorizontalBlock"]>div{{flex:1 1 100% !important;max-width:100% !important;}}
        .stTabs [data-baseweb="tab"]{{font-size:0.78rem !important;padding:0.35rem 0.5rem !important;}}
        .balance-card .amount{{font-size:1.8rem !important;}}
        .tx-name{{font-size:0.85rem !important;}}
        .tx-amount{{font-size:0.88rem !important;}}
    }}
    </style>
    """, unsafe_allow_html=True)


# ============================================================
# SECRETS & KONEKSI
# ============================================================
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

for _v in ["HTTP_PROXY","HTTPS_PROXY","http_proxy","https_proxy"]:
    os.environ.pop(_v, None)

@st.cache_resource
def init_supabase() -> Client:
    try:
        c = create_client(SUPABASE_URL, SUPABASE_KEY)
        c.auth.get_session()
        return c
    except Exception as e:
        st.error(f"❌ Gagal tersambung ke database: {e}")
        st.stop()

supabase = init_supabase()

# ============================================================
# SESSION STATE
# ============================================================
_DEF = {
    "user_aktif": None,
    "anggaran_terkunci": {},
    "muat_anggaran_sukses": False,
    "target_tabungan": {},
    "muat_tabungan_sukses": False,
    "profil": {},
    "muat_profil_sukses": False,
    "edit_profil_mode": False,
    "wallets": [],
    "muat_wallets_sukses": False,
    "budget_kategori": {},
    "muat_bk_sukses": False,
    "custom_kat_pglr": [],
    "custom_kat_msuk": [],
    "muat_custom_kat_sukses": False,
    "financial_goals": [],
    "muat_goals_sukses": False,
    "networth_history": [],
    "muat_nw_sukses": False,
    "simpan_sukses": False,
    "pesan_toast": "",
    "hapus_sukses": False,
    "hapus_konfirmasi_ids": [],
    "hapus_konfirmasi_tipe": "",
    "edit_tx_id": None,
    "edit_tx_data": {},
    "jam_input": datetime.now(TZ).hour,
    "menit_input": datetime.now(TZ).minute,
    "toast_kondisi_ditampilkan": False,
    "chat_history": [],
    "onboarding_selesai": False,
    "onboarding_step": 0,
    "tx_form_key": 0,
    "pm_form_key": 0,
    "notif_dismissed": [],
    # Pagination
    "tx_show_count": 5,
    # Import CSV
    "csv_import_df": None,
    "csv_import_mapping": {},
    "csv_import_preview": False,
}
for _k, _v in _DEF.items():
    if _k not in st.session_state:
        st.session_state[_k] = _v


# ============================================================
# HELPERS
# ============================================================
def wib() -> datetime:
    return datetime.now(TZ)

def rp(n: float) -> str:
    return f"Rp {n:,.0f}"

def parse_waktu(df: pd.DataFrame, col: str) -> pd.DataFrame:
    df[col] = pd.to_datetime(df[col], errors="coerce")
    if df[col].dt.tz is None:
        df[col] = df[col].dt.tz_localize("UTC")
    df[col] = df[col].dt.tz_convert(TZ)
    df = df.dropna(subset=[col])
    df["bulan"]   = df[col].dt.month.map(KAMUS_BULAN)
    df["tahun"]   = df[col].dt.year.astype(int)
    df["tanggal"] = df[col].dt.day.astype(int)
    df["jam"]     = df[col].dt.hour.astype(int)
    df["menit"]   = df[col].dt.minute.astype(int)
    return df

def inisial(nama: str, email: str) -> str:
    t = nama.strip() if nama and nama.strip() else email
    b = t.split()
    return (b[0][0]+b[1][0]).upper() if len(b)>=2 else t[:2].upper()

def get_kategori_pengeluaran():
    """Return default + custom kategori pengeluaran."""
    custom = [k["nama"] for k in st.session_state.custom_kat_pglr]
    return KATEGORI_PENGELUARAN_DEFAULT + [c for c in custom if c not in KATEGORI_PENGELUARAN_DEFAULT]

def get_kategori_pemasukan():
    """Return default + custom kategori pemasukan."""
    custom = [k["nama"] for k in st.session_state.custom_kat_msuk]
    return KATEGORI_PEMASUKAN_DEFAULT + [c for c in custom if c not in KATEGORI_PEMASUKAN_DEFAULT]


# ============================================================
# DB — PROFIL
# ============================================================
def muat_profil(uid, paksa=False):
    if not paksa and st.session_state.muat_profil_sukses: return
    try:
        r = supabase.table("profiles").select("*").eq("id", uid).execute()
        st.session_state.profil = r.data[0] if r.data else {}
        st.session_state.muat_profil_sukses = True
    except Exception:
        st.session_state.profil = {}
        st.session_state.muat_profil_sukses = True

def simpan_profil(uid, data):
    try:
        data["id"] = uid
        data["updated_at"] = wib().isoformat()
        supabase.table("profiles").upsert(data).execute()
        return True
    except Exception as e:
        st.error(f"Gagal simpan profil: {e}"); return False

def upload_foto(uid, fbytes, mime):
    try:
        ext  = "jpg" if "jpeg" in mime else mime.split("/")[-1]
        path = f"{uid}/avatar.{ext}"
        b    = supabase.storage.from_("profile-photos")
        try: b.remove([path])
        except Exception: pass
        b.upload(path=path, file=fbytes, file_options={"content-type": mime,"upsert":"true"})
        return f"{b.get_public_url(path)}?t={int(datetime.now().timestamp())}"
    except Exception as e:
        st.error(f"Gagal upload foto: {e}"); return None

def hapus_foto(uid):
    try:
        for ext in ["jpg","jpeg","png","webp"]:
            try: supabase.storage.from_("profile-photos").remove([f"{uid}/avatar.{ext}"])
            except Exception: pass
        supabase.table("profiles").upsert({"id":uid,"foto_url":None,"updated_at":wib().isoformat()}).execute()
        return True
    except Exception as e:
        st.error(f"Gagal hapus foto: {e}"); return False


# ============================================================
# DB — ANGGARAN & TABUNGAN
# ============================================================
def muat_anggaran(uid, paksa=False):
    if not paksa and st.session_state.muat_anggaran_sukses: return
    try:
        r = supabase.table("budgets").select("*").eq("user_id", uid).execute()
        st.session_state.anggaran_terkunci = {row["bulan_key"]:row["nominal"] for row in (r.data or [])}
        st.session_state.muat_anggaran_sukses = True
    except Exception as e: st.error(f"Gagal muat anggaran: {e}")

def simpan_anggaran(uid, bk, nominal):
    try:
        supabase.table("budgets").delete().eq("user_id",uid).eq("bulan_key",bk).execute()
        supabase.table("budgets").insert({"user_id":uid,"bulan_key":bk,"nominal":nominal,"updated_at":wib().isoformat()}).execute()
        return True
    except Exception as e:
        st.error(f"Gagal simpan anggaran: {e}"); return False

def muat_tabungan(uid, paksa=False):
    if not paksa and st.session_state.muat_tabungan_sukses: return
    try:
        r = supabase.table("savings_goals").select("*").eq("user_id", uid).execute()
        st.session_state.target_tabungan = {row["bulan_key"]:row["target_nominal"] for row in (r.data or [])}
        st.session_state.muat_tabungan_sukses = True
    except Exception as e: st.error(f"Gagal muat tabungan: {e}")

def simpan_tabungan(uid, bk, target):
    try:
        supabase.table("savings_goals").delete().eq("user_id",uid).eq("bulan_key",bk).execute()
        supabase.table("savings_goals").insert({"user_id":uid,"bulan_key":bk,"target_nominal":target,"updated_at":wib().isoformat()}).execute()
        return True
    except Exception as e:
        st.error(f"Gagal simpan target: {e}"); return False


# ============================================================
# DB — BUDGET KATEGORI
# ============================================================
def muat_bk(uid, paksa=False):
    if not paksa and st.session_state.muat_bk_sukses: return
    try:
        r = supabase.table("budget_kategori").select("*").eq("user_id", uid).execute()
        baru = {}
        for row in (r.data or []):
            baru.setdefault(row["bulan_key"], {})[row["kategori"]] = row["nominal"]
        st.session_state.budget_kategori = baru
        st.session_state.muat_bk_sukses  = True
    except Exception: st.session_state.muat_bk_sukses = True

def simpan_bk(uid, bk, kat, nominal):
    try:
        supabase.table("budget_kategori").delete().eq("user_id",uid).eq("bulan_key",bk).eq("kategori",kat).execute()
        if nominal > 0:
            supabase.table("budget_kategori").insert({"user_id":uid,"bulan_key":bk,"kategori":kat,"nominal":nominal}).execute()
        return True
    except Exception as e:
        st.error(f"Gagal simpan budget kategori: {e}"); return False


# ============================================================
# DB — CUSTOM KATEGORI
# ============================================================
def muat_custom_kat(uid, paksa=False):
    if not paksa and st.session_state.muat_custom_kat_sukses: return
    try:
        r = supabase.table("custom_kategori").select("*").eq("user_id", uid).execute()
        data = r.data or []
        st.session_state.custom_kat_pglr = [d for d in data if d["tipe"] == "pengeluaran"]
        st.session_state.custom_kat_msuk = [d for d in data if d["tipe"] == "pemasukan"]
        st.session_state.muat_custom_kat_sukses = True
    except Exception:
        st.session_state.muat_custom_kat_sukses = True

def simpan_custom_kat(uid, nama, tipe, ikon="📌"):
    try:
        supabase.table("custom_kategori").insert({
            "user_id": uid, "nama": nama, "tipe": tipe, "ikon": ikon
        }).execute()
        return True
    except Exception as e:
        st.error(f"Gagal simpan kategori: {e}"); return False

def hapus_custom_kat(uid, kid):
    try:
        supabase.table("custom_kategori").delete().eq("id", kid).eq("user_id", uid).execute()
        return True
    except Exception as e:
        st.error(f"Gagal hapus kategori: {e}"); return False


# ============================================================
# DB — WALLETS
# ============================================================
def muat_wallets(uid, paksa=False):
    if not paksa and st.session_state.muat_wallets_sukses: return
    try:
        r = supabase.table("wallets").select("*").eq("user_id", uid).execute()
        st.session_state.wallets = r.data or []
        st.session_state.muat_wallets_sukses = True
    except Exception: st.session_state.muat_wallets_sukses = True

def simpan_wallet(uid, nama, tipe, saldo_awal, warna="#2E7D32"):
    try:
        supabase.table("wallets").insert({
            "user_id":uid,"nama":nama,"tipe":tipe,
            "saldo_awal":saldo_awal,"warna":warna
        }).execute()
        return True
    except Exception as e:
        st.error(f"Gagal simpan wallet: {e}"); return False

def hapus_wallet(uid, wid):
    try:
        supabase.table("wallets").delete().eq("id",wid).eq("user_id",uid).execute()
        return True
    except Exception as e:
        st.error(f"Gagal hapus wallet: {e}"); return False


# ============================================================
# DB — FINANCIAL GOALS
# ============================================================
def muat_goals(uid, paksa=False):
    if not paksa and st.session_state.muat_goals_sukses: return
    try:
        r = supabase.table("financial_goals").select("*").eq("user_id", uid).order("created_at", desc=False).execute()
        st.session_state.financial_goals = r.data or []
        st.session_state.muat_goals_sukses = True
    except Exception:
        st.session_state.muat_goals_sukses = True

def simpan_goal(uid, nama, target, terkumpul=0, deadline=None, kategori="Tabungan", ikon="🎯"):
    try:
        payload = {
            "user_id": uid, "nama": nama, "target_nominal": int(target),
            "terkumpul": int(terkumpul), "kategori": kategori, "ikon": ikon
        }
        if deadline:
            payload["deadline"] = deadline.isoformat()
        supabase.table("financial_goals").insert(payload).execute()
        return True
    except Exception as e:
        st.error(f"Gagal simpan goal: {e}"); return False

def update_goal_terkumpul(uid, gid, terkumpul_baru):
    try:
        supabase.table("financial_goals").update({
            "terkumpul": int(terkumpul_baru)
        }).eq("id", gid).eq("user_id", uid).execute()
        return True
    except Exception as e:
        st.error(f"Gagal update goal: {e}"); return False

def hapus_goal(uid, gid):
    try:
        supabase.table("financial_goals").delete().eq("id", gid).eq("user_id", uid).execute()
        return True
    except Exception as e:
        st.error(f"Gagal hapus goal: {e}"); return False


# ============================================================
# DB — NET WORTH
# ============================================================
def muat_networth(uid, paksa=False):
    if not paksa and st.session_state.muat_nw_sukses: return
    try:
        r = supabase.table("networth_history").select("*").eq("user_id", uid).order("recorded_at", desc=False).execute()
        st.session_state.networth_history = r.data or []
        st.session_state.muat_nw_sukses = True
    except Exception:
        st.session_state.muat_nw_sukses = True

def simpan_networth(uid, bulan_key, total_aset, total_liabilitas, catatan_aset, catatan_liabilitas):
    try:
        # Hapus existing untuk bulan ini dulu
        supabase.table("networth_history").delete().eq("user_id", uid).eq("bulan_key", bulan_key).execute()
        supabase.table("networth_history").insert({
            "user_id": uid,
            "bulan_key": bulan_key,
            "total_aset": int(total_aset),
            "total_liabilitas": int(total_liabilitas),
            "catatan_aset": json.dumps(catatan_aset),
            "catatan_liabilitas": json.dumps(catatan_liabilitas),
            "recorded_at": wib().isoformat()
        }).execute()
        return True
    except Exception as e:
        st.error(f"Gagal simpan net worth: {e}"); return False


# ============================================================
# DB — TRANSAKSI
# ============================================================
@st.cache_data(ttl=5)
def ambil_transaksi(uid):
    try:
        r = supabase.table("transaksi").select("*").eq("user_id",uid).order("waktu_transaksi",desc=False).execute()
        return r.data or []
    except Exception as e:
        st.error(f"Gagal ambil transaksi: {e}"); return []

@st.cache_data(ttl=5)
def ambil_pemasukan(uid):
    try:
        r = supabase.table("pemasukan").select("*").eq("user_id",uid).order("waktu_pemasukan",desc=False).execute()
        return r.data or []
    except Exception as e:
        st.error(f"Gagal ambil pemasukan: {e}"); return []

@st.cache_data(ttl=5)
def ambil_hutang(uid):
    try:
        r = supabase.table("hutang_piutang").select("*").eq("user_id",uid).order("tanggal",desc=False).execute()
        return r.data or []
    except Exception: return []

@st.cache_data(ttl=30)
def ambil_recurring(uid):
    try:
        r = supabase.table("recurring_templates").select("*").eq("user_id",uid).execute()
        return r.data or []
    except Exception: return []


# ============================================================
# FINANCIAL HEALTH SCORE
# ============================================================
def health_score(total_pglr, budget, target, sukarela, df_view, df_all):
    s, d = 0, {}
    if budget > 0 and target > 0:
        batas = max(0, budget-target)
        s1 = 40 if total_pglr<=batas else max(0, 40-int(((total_pglr-batas)/budget)*80))
    elif budget > 0:
        s1 = max(0, int((1-total_pglr/budget)*40))
    else: s1 = 20
    s+=s1; d["Rasio Tabungan"]=s1
    if not df_view.empty and "waktu_transaksi" in df_view.columns:
        s2 = int(min(1.0, df_view["waktu_transaksi"].dt.date.nunique()/15)*20)
    else: s2=0
    s+=s2; d["Konsistensi Catat"]=s2
    if budget > 0 and not df_view.empty:
        r = sukarela/budget
        s3 = 20 if r<=0.3 else (12 if r<=0.5 else max(0,int((1-r)*20)))
    else: s3=10
    s+=s3; d["Porsi Sukarela"]=s3
    s4=10
    if not df_all.empty and not df_view.empty and "bulan" in df_view.columns:
        try:
            cb,ct = df_view["bulan"].iloc[0], int(df_view["tahun"].iloc[0])
            dp = df_all[~((df_all["bulan"]==cb)&(df_all["tahun"]==ct))]
            if not dp.empty:
                rata = dp.groupby(["tahun","bulan"])["nominal"].sum().mean()
                s4 = 20 if total_pglr<rata else max(0,int((1-(total_pglr-rata)/max(rata,1))*20))
        except Exception: pass
    s+=s4; d["Tren Pengeluaran"]=s4
    return min(100,s), d

def label_hs(s):
    if s>=80: return "💚 Excellent","#2E7D32","#E8F5E9"
    elif s>=60: return "💛 Sehat","#F57F17","#FFFDE7"
    elif s>=40: return "🟠 Perlu Perhatian","#E65100","#FFF3E0"
    else: return "🔴 Kritis","#B71C1C","#FFEBEE"


# ============================================================
# GAMIFIKASI
# ============================================================
def cek_badges(df_all, budget_dict, target_dict):
    badges = []
    if df_all.empty: return badges
    tgl = sorted(df_all["waktu_transaksi"].dt.date.unique())
    streak=mx=1
    for i in range(1,len(tgl)):
        if (tgl[i]-tgl[i-1]).days==1: streak+=1; mx=max(mx,streak)
        else: streak=1
    if mx>=7: badges.append(("🗓️","Pencatat Setia",f"Streak {mx} hari berturut-turut"))
    bh=0
    for k,bud in budget_dict.items():
        tgt=target_dict.get(k,0); bts=max(0,bud-tgt)
        try:
            bl,th=k.rsplit("_",1)
            db=df_all[(df_all["bulan"]==bl)&(df_all["tahun"]==int(th))]
            if not db.empty and db["nominal"].sum()<=bts: bh+=1
        except Exception: pass
    if bh>=2: badges.append(("🏆","Penabung Konsisten",f"{bh} bulan di bawah batas"))
    if "bulan" in df_all.columns:
        bl_t=df_all.iloc[-1]["bulan"]
        nk=df_all[df_all["bulan"]==bl_t]["kategori"].nunique()
        if nk>=5: badges.append(("🌈","Pengelola Lengkap",f"{nk} kategori berbeda"))
    for k,bud in budget_dict.items():
        tgt=target_dict.get(k,0)
        if bud>0 and tgt/bud>=0.2:
            try:
                bl,th=k.rsplit("_",1)
                db=df_all[(df_all["bulan"]==bl)&(df_all["tahun"]==int(th))]
                if not db.empty and db["nominal"].sum()<=(bud-tgt):
                    badges.append(("💎","Big Saver",f"Target ≥20% di {bl}")); break
            except Exception: pass
    return badges


# ============================================================
# PDF GENERATOR
# ============================================================
def buat_pdf(email,bln,thn,df_v,df_pv,budget,target,tot_pglr,tot_msuk,hs,ls):
    if not PDF_AVAILABLE: return None
    pdf=FPDF(); pdf.add_page(); pdf.set_auto_page_break(auto=True,margin=15)
    pdf.set_fill_color(46,125,50); pdf.rect(0,0,210,38,"F")
    pdf.set_text_color(255,255,255); pdf.set_font("Helvetica","B",18)
    pdf.set_xy(10,8); pdf.cell(0,10,"DanaPintar AI  --  Laporan Keuangan",ln=True)
    pdf.set_font("Helvetica","",11); pdf.set_xy(10,21)
    pdf.cell(0,7,f"Periode: {bln} {thn}   |   Akun: {email}",ln=True)
    pdf.set_text_color(0,0,0); pdf.set_y(48)
    pdf.set_font("Helvetica","B",13); pdf.cell(0,8,"Ringkasan Keuangan",ln=True)
    pdf.set_font("Helvetica","",11)
    for lbl,val in [("Anggaran",rp(budget)),("Pemasukan",rp(tot_msuk)),
                     ("Pengeluaran",rp(tot_pglr)),("Target Tabungan",rp(target)),
                     ("Sisa Anggaran",rp(budget-tot_pglr)),("Net Cash Flow",rp(tot_msuk-tot_pglr)),
                     ("Health Score",f"{hs}/100")]:
        pdf.cell(75,7,lbl+":",border=0); pdf.cell(0,7,val,ln=True)
    pdf.ln(4)
    if not df_v.empty:
        pdf.set_font("Helvetica","B",13); pdf.cell(0,8,"Detail Pengeluaran",ln=True)
        cw=[28,60,35,22,35]
        pdf.set_font("Helvetica","B",9); pdf.set_fill_color(220,240,220)
        for h,w in zip(["Tanggal","Deskripsi","Kategori","Sifat","Nominal (Rp)"],cw):
            pdf.cell(w,7,h,border=1,fill=True)
        pdf.ln()
        pdf.set_font("Helvetica","",8)
        for _,row in df_v.iterrows():
            for v,w in zip([f"{int(row.get('tanggal',0))} {str(row.get('bulan',''))[:3]}",
                            str(row.get("catatan",""))[:30],str(row.get("kategori",""))[:20],
                            str(row.get("sifat","")),f"{row['nominal']:,.0f}"],cw):
                pdf.cell(w,6,v,border=1)
            pdf.ln()
        pdf.set_font("Helvetica","B",9); pdf.set_fill_color(220,240,220)
        pdf.cell(sum(cw[:-1]),7,"TOTAL",border=1,fill=True)
        pdf.cell(cw[-1],7,f"{tot_pglr:,.0f}",border=1,fill=True); pdf.ln(8)
    pdf.set_font("Helvetica","I",8); pdf.set_text_color(120,120,120)
    pdf.cell(0,5,f"Dibuat {wib().strftime('%d %B %Y %H:%M')} WIB",align="C",ln=True)
    pdf.cell(0,5,"(c) 2026 DanaPintar AI  --  Hendrawan Lotanto",align="C")
    return bytes(pdf.output())


# ============================================================
# KALENDER HEATMAP RENDERER
# ============================================================
def render_heatmap(df_month, bulan_idx, tahun):
    """Render HTML kalender heatmap untuk bulan tertentu."""
    # Hitung total per tanggal
    daily = {}
    if not df_month.empty and "waktu_transaksi" in df_month.columns:
        grp = df_month.groupby(df_month["waktu_transaksi"].dt.day)["nominal"].sum()
        daily = grp.to_dict()

    max_val = max(daily.values()) if daily else 1

    def heat_color(val):
        if val == 0: return "#1e293b","#94a3b8"
        ratio = val / max_val
        if ratio < 0.25:   return "#14532d","#86efac"
        elif ratio < 0.5:  return "#166534","#4ade80"
        elif ratio < 0.75: return "#b45309","#fcd34d"
        else:              return "#991b1b","#fca5a5"

    # Nama hari
    hari = ["Sen","Sel","Rab","Kam","Jum","Sab","Min"]
    _, days_in_month = cal_lib.monthrange(tahun, bulan_idx)
    first_weekday = cal_lib.monthrange(tahun, bulan_idx)[0]  # 0=Mon
    today = wib().date()

    headers = "".join([f'<div class="cal-header">{h}</div>' for h in hari])

    cells = ""
    # Empty cells sebelum tanggal 1
    for _ in range(first_weekday):
        cells += '<div class="cal-cell cal-empty"></div>'

    for day in range(1, days_in_month + 1):
        val   = daily.get(day, 0)
        bg, fg = heat_color(val)
        is_today = (date(tahun, bulan_idx, day) == today)
        today_cls = " cal-today" if is_today else ""
        tooltip = f"Rp {val:,.0f}" if val > 0 else "Tidak ada"
        cells += (
            f'<div class="cal-cell{today_cls}" '
            f'style="background:{bg};color:{fg};" '
            f'title="{day}: {tooltip}">{day}</div>'
        )

    html = f"""
    <div style="margin-bottom:0.5rem;">
        <div class="cal-grid">{headers}{cells}</div>
        <div style="display:flex;gap:0.8rem;flex-wrap:wrap;font-size:0.72rem;color:#94a3b8;margin-top:0.3rem;">
            <span><span style="background:#14532d;color:#86efac;border-radius:4px;padding:1px 6px;">●</span> Rendah</span>
            <span><span style="background:#166534;color:#4ade80;border-radius:4px;padding:1px 6px;">●</span> Sedang</span>
            <span><span style="background:#b45309;color:#fcd34d;border-radius:4px;padding:1px 6px;">●</span> Tinggi</span>
            <span><span style="background:#991b1b;color:#fca5a5;border-radius:4px;padding:1px 6px;">●</span> Sangat Tinggi</span>
            <span>⬜ Tidak ada transaksi</span>
        </div>
    </div>
    """
    return html


# ============================================================
# PUSAT NOTIFIKASI
# ============================================================
def generate_notifikasi(uid: str) -> list:
    notifs = []
    _now    = wib()
    _kb_now = f"{KAMUS_BULAN[_now.month]}_{_now.year}"

    try:
        _tx_q = ambil_transaksi(uid)
        if _tx_q:
            _df_q = pd.DataFrame(_tx_q)
            _df_q["waktu_transaksi"] = pd.to_datetime(_df_q["waktu_transaksi"], errors="coerce")
            if _df_q["waktu_transaksi"].dt.tz is None:
                _df_q["waktu_transaksi"] = _df_q["waktu_transaksi"].dt.tz_localize("UTC")
            _df_q["waktu_transaksi"] = _df_q["waktu_transaksi"].dt.tz_convert(TZ)
            _last = _df_q["waktu_transaksi"].dropna().max()
            if pd.notna(_last):
                _gap = (_now.date() - _last.date()).days
                if _gap >= 2:
                    notifs.append({"id":f"no_tx_{_gap}","icon":"🔔","tipe":"warning",
                        "pesan":f"Belum mencatat pengeluaran selama **{_gap} hari**. Jangan lupa catat!"})
    except Exception: pass

    if _kb_now not in st.session_state.anggaran_terkunci:
        notifs.append({"id":"no_budget","icon":"💡","tipe":"info",
            "pesan":f"Anggaran bulan **{KAMUS_BULAN[_now.month]}** belum dikunci. Set di sidebar."})

    if (_kb_now in st.session_state.anggaran_terkunci
            and _kb_now not in st.session_state.target_tabungan):
        notifs.append({"id":"no_target","icon":"🎯","tipe":"info",
            "pesan":"Target tabungan bulan ini belum diset. Yuk tentukan targetmu!"})

    _ang_now = st.session_state.anggaran_terkunci.get(_kb_now, 0)
    _tgt_now = st.session_state.target_tabungan.get(_kb_now, 0)
    _bts_now = max(0, _ang_now - _tgt_now)
    if _bts_now > 0:
        try:
            _tx_q2 = ambil_transaksi(uid)
            if _tx_q2:
                _df_q2 = pd.DataFrame(_tx_q2)
                _df_q2["nominal"] = pd.to_numeric(_df_q2["nominal"], errors="coerce")
                _df_q2["waktu_transaksi"] = pd.to_datetime(_df_q2["waktu_transaksi"], errors="coerce")
                if _df_q2["waktu_transaksi"].dt.tz is None:
                    _df_q2["waktu_transaksi"] = _df_q2["waktu_transaksi"].dt.tz_localize("UTC")
                _df_q2["waktu_transaksi"] = _df_q2["waktu_transaksi"].dt.tz_convert(TZ)
                _df_q2["bulan"] = _df_q2["waktu_transaksi"].dt.month.map(KAMUS_BULAN)
                _df_q2["tahun"] = _df_q2["waktu_transaksi"].dt.year
                _df_bln = _df_q2[(_df_q2["bulan"]==KAMUS_BULAN[_now.month])&(_df_q2["tahun"]==_now.year)]
                _tot_bln = _df_bln["nominal"].sum()
                _pct_bln = (_tot_bln / _bts_now) * 100
                if _pct_bln >= 100:
                    notifs.append({"id":"over_budget","icon":"🚨","tipe":"error",
                        "pesan":f"Pengeluaran sudah **{_pct_bln:.0f}%** dari batas! Target tabungan terancam."})
                elif _pct_bln >= 80:
                    notifs.append({"id":"near_budget","icon":"⚠️","tipe":"warning",
                        "pesan":f"Pengeluaran sudah **{_pct_bln:.0f}%** dari batas belanja bulan ini."})
        except Exception: pass

    try:
        for _h in ambil_hutang(uid):
            if _h.get("status") == "belum_lunas" and _h.get("jatuh_tempo"):
                try:
                    _jt   = datetime.fromisoformat(_h["jatuh_tempo"].replace("Z","+00:00")).astimezone(TZ).date()
                    _sisa = (_jt - _now.date()).days
                    if 0 <= _sisa <= 3:
                        _jenis = "Hutang" if _h["jenis"]=="hutang" else "Piutang"
                        notifs.append({"id":f"jt_{_h['id']}","icon":"💸","tipe":"warning",
                            "pesan":(f"{_jenis} ke **{_h['nama_pihak']}** ({rp(_h['nominal'])}) "
                                     f"jatuh tempo {'hari ini!' if _sisa==0 else f'dalam **{_sisa} hari**!'}")})
                except Exception: pass
    except Exception: pass

    # Notif goal hampir tercapai
    for g in st.session_state.financial_goals:
        pct = (g.get("terkumpul",0) / g["target_nominal"] * 100) if g["target_nominal"] > 0 else 0
        if 80 <= pct < 100:
            notifs.append({"id":f"goal_{g['id']}","icon":"🎯","tipe":"info",
                "pesan":f"Goal **{g['nama']}** sudah {pct:.0f}%! Hampir tercapai."})

    return notifs


# ============================================================
# ONBOARDING WIZARD
# ============================================================
def tampilkan_onboarding(uid, email):
    st.markdown("""<style>.ob-card{background:linear-gradient(135deg,#1B5E20,#2E7D32);
    border-radius:20px;padding:2rem;color:white;text-align:center;margin-bottom:1.5rem;
    box-shadow:0 8px 32px rgba(46,125,50,0.3);}</style>""", unsafe_allow_html=True)

    step = st.session_state.onboarding_step
    total_steps = 4

    st.markdown(f"""
    <div class="ob-card">
        <div style="font-size:3rem">🎉</div>
        <h2 style="color:white;margin:0.5rem 0">Selamat Datang di DanaPintar AI!</h2>
        <p style="opacity:0.85">Halo, <strong>{email.split('@')[0].title()}</strong>!
        Yuk setup akun keuanganmu dalam {total_steps} langkah mudah.</p>
        <div style="background:rgba(255,255,255,0.2);border-radius:10px;height:8px;margin-top:1rem;">
            <div style="background:white;width:{int((step/total_steps)*100)}%;height:8px;border-radius:10px;"></div>
        </div>
        <p style="font-size:0.85rem;opacity:0.7;margin-top:0.5rem">Langkah {step+1} dari {total_steps}</p>
    </div>
    """, unsafe_allow_html=True)

    if step == 0:
        st.markdown("### 👤 Langkah 1 — Kenalkan Dirimu")
        with st.form("ob_step1"):
            ob_nama = st.text_input("Nama Lengkapmu:", placeholder="Contoh: Hendrawan Lotanto")
            ob_lokasi = st.text_input("Kota tinggal:", placeholder="Contoh: Jakarta")
            ob_pekerjaan = st.text_input("Pekerjaan:", placeholder="Contoh: Karyawan Swasta")
            if st.form_submit_button("Lanjut ➡️", use_container_width=True):
                if ob_nama.strip():
                    simpan_profil(uid, {"nama":ob_nama.strip(),"lokasi":ob_lokasi.strip(),"pekerjaan":ob_pekerjaan.strip()})
                    st.session_state.profil.update({"nama":ob_nama.strip(),"lokasi":ob_lokasi.strip()})
                    st.session_state.onboarding_step = 1; st.rerun()
                else: st.error("Nama tidak boleh kosong.")
    elif step == 1:
        st.markdown("### 💰 Langkah 2 — Set Anggaran Bulan Ini")
        _now = wib(); _bln = KAMUS_BULAN[_now.month]; _thn = _now.year
        with st.form("ob_step2"):
            ob_budget = st.number_input(f"Anggaran {_bln} {_thn} (Rp)",
                min_value=ANGGARAN_MIN, value=ANGGARAN_DEFAULT, step=100_000)
            st.caption("💡 Total uang yang boleh dibelanjakan bulan ini.")
            if st.form_submit_button("Lanjut ➡️", use_container_width=True):
                _k = f"{_bln}_{_thn}"
                if simpan_anggaran(uid, _k, ob_budget):
                    st.session_state.anggaran_terkunci[_k] = ob_budget
                    st.session_state.onboarding_step = 2; st.rerun()
    elif step == 2:
        st.markdown("### 🎯 Langkah 3 — Target Tabungan")
        _now = wib(); _bln = KAMUS_BULAN[_now.month]; _thn = _now.year
        _k = f"{_bln}_{_thn}"; _bud = st.session_state.anggaran_terkunci.get(_k, ANGGARAN_DEFAULT)
        with st.form("ob_step3"):
            ob_target = st.number_input(f"Target tabungan {_bln} (Rp)",
                min_value=0, max_value=int(_bud), value=int(_bud*0.2), step=50_000)
            st.caption(f"💡 Disarankan minimal 20% (~{rp(_bud*0.2)})")
            if st.form_submit_button("Lanjut ➡️", use_container_width=True):
                if simpan_tabungan(uid, _k, ob_target):
                    st.session_state.target_tabungan[_k] = ob_target
                    st.session_state.onboarding_step = 3; st.rerun()
    elif step == 3:
        st.markdown("### 👛 Langkah 4 — Tambah Wallet Pertama")
        with st.form("ob_step4"):
            ob_walet_nama = st.text_input("Nama wallet:", value="Dompet Utama")
            ob_walet_tipe = st.selectbox("Tipe:", TIPE_WALLET)
            ob_saldo      = st.number_input("Saldo awal (Rp):", min_value=0, value=0, step=50_000)
            c1, c2 = st.columns(2)
            skip = c1.form_submit_button("Lewati ⏭️", use_container_width=True)
            ok   = c2.form_submit_button("Selesai 🎉", use_container_width=True)
            if ok:
                if ob_walet_nama.strip():
                    simpan_wallet(uid, ob_walet_nama.strip(), ob_walet_tipe, ob_saldo)
                    st.cache_data.clear()
                st.session_state.onboarding_selesai = True
                st.session_state.onboarding_step    = 0; st.rerun()
            if skip:
                st.session_state.onboarding_selesai = True
                st.session_state.onboarding_step    = 0; st.rerun()
    st.stop()


# ============================================================
# AUTH GATE
# ============================================================
if st.session_state.user_aktif is None:
    inject_css()
    st.markdown("<h1 style='text-align:center;color:#2E7D32;'>📊 DanaPintar AI</h1>", unsafe_allow_html=True)
    st.markdown("<p style='text-align:center;color:#64748b;'>Sistem Keuangan Cerdas berbasis AI</p>", unsafe_allow_html=True)
    st.markdown("---")
    tab_l, tab_d = st.tabs(["🔑 Masuk","📝 Daftar"])
    with tab_l:
        em = st.text_input("Email", key="log_em")
        pw = st.text_input("Password", type="password", key="log_pw")
        if st.button("Masuk 🚀", use_container_width=True):
            try:
                r = supabase.auth.sign_in_with_password({"email":em,"password":pw})
                st.session_state.user_aktif = r.user
                muat_anggaran(r.user.id, True); muat_tabungan(r.user.id, True)
                muat_profil(r.user.id, True); muat_wallets(r.user.id, True)
                muat_bk(r.user.id, True); muat_custom_kat(r.user.id, True)
                muat_goals(r.user.id, True); muat_networth(r.user.id, True)
                st.session_state.toast_kondisi_ditampilkan = False; st.rerun()
            except Exception as e: st.error(f"Login gagal: {e}")
    with tab_d:
        em2 = st.text_input("Email Baru", key="reg_em")
        pw2 = st.text_input("Password (min 6 karakter)", type="password", key="reg_pw")
        if st.button("Daftar ✨", use_container_width=True):
            try:
                supabase.auth.sign_up({"email":em2,"password":pw2})
                st.success("Akun berhasil dibuat! Silakan masuk.")
            except Exception as e: st.error(f"Pendaftaran gagal: {e}")
    st.stop()

inject_css()

# ============================================================
# HEADER
# ============================================================
st.markdown("<h1 style='margin-bottom:2px;letter-spacing:-0.5px;'>📊 DanaPintar AI</h1>", unsafe_allow_html=True)
st.caption("✦ Sistem Keuangan Cerdas · AI Chat · Multi-Wallet · Goals · Net Worth")
st.markdown("---")

# ============================================================
# DASHBOARD UTAMA — persiapan
# ============================================================
uid        = st.session_state.user_aktif.id
email_user = st.session_state.user_aktif.email

if not st.session_state.muat_anggaran_sukses:    muat_anggaran(uid, True)
if not st.session_state.muat_tabungan_sukses:    muat_tabungan(uid, True)
if not st.session_state.muat_profil_sukses:      muat_profil(uid, True)
if not st.session_state.muat_wallets_sukses:     muat_wallets(uid, True)
if not st.session_state.muat_bk_sukses:          muat_bk(uid, True)
if not st.session_state.muat_custom_kat_sukses:  muat_custom_kat(uid, True)
if not st.session_state.muat_goals_sukses:       muat_goals(uid, True)
if not st.session_state.muat_nw_sukses:          muat_networth(uid, True)

# Toast
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
    _pr      = st.session_state.profil
    _nama    = _pr.get("nama","").strip() or email_user.split("@")[0].title()
    _bio     = _pr.get("bio","").strip() or "Belum ada bio."
    _lokasi  = _pr.get("lokasi","").strip()
    _foto    = _pr.get("foto_url", None)
    _ini     = inisial(_pr.get("nama",""), email_user)
    try:
        _jn = datetime.fromisoformat(st.session_state.user_aktif.created_at.replace("Z","+00:00"))\
              .astimezone(TZ).strftime("%d %b %Y")
    except Exception: _jn="-"

    _av_html = (f'<img src="{_foto}" style="width:68px;height:68px;border-radius:50%;'
                f'object-fit:cover;border:3px solid rgba(255,255,255,0.6);">'
                if _foto else
                f'<div style="width:68px;height:68px;border-radius:50%;background:rgba(255,255,255,0.25);'
                f'display:flex;align-items:center;justify-content:center;font-size:1.5rem;font-weight:700;'
                f'color:white;border:3px solid rgba(255,255,255,0.5);">{_ini}</div>')
    _lok_html = f'<div style="font-size:0.76rem;opacity:0.8;">📍 {_lokasi}</div>' if _lokasi else ""

    st.markdown(f"""
    <div class="pro-card">
        <div style="display:flex;align-items:flex-start;gap:10px;">
            {_av_html}
            <div style="flex:1;min-width:0;">
                <span class="badge-member">✦ Member</span>
                <div class="nama">{_nama}</div>
                <div class="email-kecil">✉ {email_user}</div>
                {_lok_html}
            </div>
        </div>
        <div class="bio">{_bio}</div>
        <div class="meta">🗓 Bergabung sejak {_jn}</div>
    </div>
    """, unsafe_allow_html=True)

    _all_notifs   = generate_notifikasi(uid)
    _aktif_notifs = [n for n in _all_notifs if n["id"] not in st.session_state.notif_dismissed]
    _n_count      = len(_aktif_notifs)
    _bell_label   = f"🔔 {_n_count}" if _n_count > 0 else "🔔"

    _bc0, _bc1, _bc2 = st.columns([2, 4, 4])
    with _bc0:
        with st.popover(_bell_label, help="Pusat Notifikasi"):
            st.markdown("<div style='font-size:0.95rem;font-weight:700;margin-bottom:0.6rem;'>🔔 Pusat Notifikasi</div>", unsafe_allow_html=True)
            if not _aktif_notifs:
                st.markdown("✅ Semua beres! Tidak ada notifikasi baru.")
            else:
                if st.button("🧹 Bersihkan Semua", key="notif_clear_all", use_container_width=True):
                    st.session_state.notif_dismissed = [n["id"] for n in _all_notifs]; st.rerun()
                st.markdown("---")
                for _notif in _aktif_notifs:
                    _col_msg, _col_x = st.columns([8, 1])
                    with _col_msg:
                        st.markdown(f"{_notif['icon']} {_notif['pesan']}")
                    with _col_x:
                        if st.button("✕", key=f"notif_dismiss_{_notif['id']}"):
                            if _notif["id"] not in st.session_state.notif_dismissed:
                                st.session_state.notif_dismissed.append(_notif["id"])
                            st.rerun()
    with _bc1:
        if st.button("✏️ Edit Profil", use_container_width=True, key="btn_ep"):
            st.session_state.edit_profil_mode = not st.session_state.edit_profil_mode
    with _bc2:
        if st.button("🚪 Logout", use_container_width=True, key="logout_btn"):
            try: supabase.auth.sign_out()
            except Exception: pass
            for _k,_v in _DEF.items():
                st.session_state[_k] = _v
            st.session_state.notif_dismissed = []; st.rerun()

    if st.session_state.edit_profil_mode:
        with st.expander("✏️ Edit Profil", expanded=True):
            st.markdown("**📷 Foto Profil**")
            if _foto:
                st.image(_foto, width=70)
                if st.button("🗑️ Hapus Foto", key="hps_foto"):
                    if hapus_foto(uid):
                        st.session_state.profil["foto_url"] = None; st.success("Foto dihapus."); st.rerun()
            _fu = st.file_uploader("Upload (JPG/PNG maks 2MB)", type=["jpg","jpeg","png","webp"])
            if _fu:
                if _fu.size > 2*1024*1024: st.error("❌ Maks 2MB")
                elif st.button("☁️ Upload", key="btn_up_foto"):
                    with st.spinner("Uploading..."):
                        _url = upload_foto(uid, _fu.read(), _fu.type)
                        if _url:
                            st.session_state.profil["foto_url"] = _url
                            simpan_profil(uid, {"foto_url":_url}); st.success("✅ Foto diupload!"); st.rerun()
            st.markdown("---")
            with st.form("form_profil"):
                _in_nama = st.text_input("Nama", value=_pr.get("nama",""))
                _in_bio  = st.text_area("Bio", value=_pr.get("bio",""), max_chars=160, height=80)
                _in_lok  = st.text_input("Lokasi", value=_pr.get("lokasi",""))
                _in_kerj = st.text_input("Pekerjaan", value=_pr.get("pekerjaan",""))
                _in_tf   = st.text_input("Target Finansial", value=_pr.get("target_finansial",""))
                st.markdown("**🔒 Ganti Password**")
                _pw1 = st.text_input("Password Baru (kosongkan jika tidak)", type="password")
                _pw2 = st.text_input("Konfirmasi Password Baru", type="password")
                if st.form_submit_button("💾 Simpan", use_container_width=True):
                    _dp = {"nama":_in_nama.strip(),"bio":_in_bio.strip(),"lokasi":_in_lok.strip(),
                           "pekerjaan":_in_kerj.strip(),"target_finansial":_in_tf.strip(),
                           "foto_url":_pr.get("foto_url")}
                    if simpan_profil(uid, _dp):
                        if _pw1:
                            if _pw1!=_pw2: st.error("Password tidak cocok.")
                            elif len(_pw1)<6: st.error("Min 6 karakter.")
                            else:
                                try:
                                    supabase.auth.update_user({"password":_pw1})
                                    st.success("🔒 Password diubah.")
                                except Exception as _pe: st.error(f"Gagal: {_pe}")
                        st.session_state.profil.update(_dp)
                        st.session_state.edit_profil_mode = False
                        st.success("✅ Profil disimpan!"); st.rerun()

    st.markdown("---")

    # ---- Anggaran ----
    st.subheader("🔒 Kunci Anggaran")
    _now = wib()
    _bln_bud = st.selectbox("Bulan",list(KAMUS_BULAN.values()),index=_now.month-1,key="sb_bln_bud")
    _thn_bud = st.selectbox("Tahun",[2025,2026,2027],index=1,key="sb_thn_bud")
    _kb      = f"{_bln_bud}_{_thn_bud}"
    _ang     = st.session_state.anggaran_terkunci.get(_kb)

    if _ang is not None:
        st.success(f"🔒 {_bln_bud} {_thn_bud}: **{rp(_ang)}**")
        with st.expander("⚙️ Opsi Anggaran"):
            if st.button("🔓 Reset Anggaran", key="rst_bud"):
                with st.form("frm_rst"):
                    _k = st.text_input("Ketik RESET")
                    if st.form_submit_button("Ya, Reset"):
                        if _k.strip().upper()=="RESET":
                            st.session_state.anggaran_terkunci.pop(_kb,None)
                            try:
                                supabase.table("budgets").delete().eq("user_id",uid).eq("bulan_key",_kb).execute()
                                st.success("✅ Reset!"); st.rerun()
                            except Exception as e: st.error(f"Gagal: {e}")
                        else: st.error("Ketik RESET dengan benar.")
    else:
        _inp_bud = st.number_input(f"Set Anggaran {_bln_bud} (Rp):",
            min_value=ANGGARAN_MIN,value=ANGGARAN_DEFAULT,step=100_000)
        if st.button(f"🔐 KUNCI {_bln_bud}"):
            st.session_state.anggaran_terkunci[_kb]=_inp_bud
            if not simpan_anggaran(uid,_kb,_inp_bud):
                st.session_state.anggaran_terkunci.pop(_kb,None)
            else: st.rerun()

    st.markdown("---")

    # ---- Target Tabungan ----
    st.subheader("💰 Target Tabungan")
    if _ang is not None:
        _tgt_sb = st.session_state.target_tabungan.get(_kb)
        if _tgt_sb is not None:
            st.success(f"🎯 {_bln_bud}: **{rp(_tgt_sb)}**")
            if st.button("🔄 Ubah Target", key="ubah_tgt"):
                st.session_state.target_tabungan.pop(_kb,None)
                try: supabase.table("savings_goals").delete().eq("user_id",uid).eq("bulan_key",_kb).execute()
                except Exception: pass
                st.rerun()
        else:
            _inp_tgt = st.number_input(f"Target {_bln_bud} (Rp):",
                min_value=0,max_value=int(_ang),value=0,step=50_000)
            if st.button("💾 Simpan Target"):
                st.session_state.target_tabungan[_kb]=_inp_tgt
                if not simpan_tabungan(uid,_kb,_inp_tgt):
                    st.session_state.target_tabungan.pop(_kb,None)
                else: st.rerun()
    else:
        st.info("Kunci anggaran terlebih dahulu.")

    st.markdown("---")

    # ---- Budget per Kategori ----
    st.subheader("📂 Budget per Kategori")
    if _ang is not None:
        _bk_data = st.session_state.budget_kategori.get(_kb,{})
        _kat_pglr_all = get_kategori_pengeluaran()
        with st.expander(f"Set Budget Kategori {_bln_bud}"):
            with st.form("frm_bk"):
                _bk_inputs = {}
                for _kat in _kat_pglr_all:
                    _bk_inputs[_kat] = st.number_input(
                        _kat, min_value=0, value=int(_bk_data.get(_kat,0)),
                        step=50_000, key=f"bk_{_kat}")
                if st.form_submit_button("💾 Simpan Budget Kategori", use_container_width=True):
                    _ok = True
                    for _k2,_v2 in _bk_inputs.items():
                        if not simpan_bk(uid,_kb,_k2,_v2): _ok=False
                    if _ok:
                        st.session_state.budget_kategori[_kb] = {k:v for k,v in _bk_inputs.items() if v>0}
                        st.session_state.muat_bk_sukses = False
                        st.success("✅ Budget kategori disimpan!"); st.rerun()
    else:
        st.info("Kunci anggaran terlebih dahulu.")

    st.markdown("---")

    # ---- Form Catat Pengeluaran ----
    st.subheader("✍️ Catat Pengeluaran")
    _wallets_list = st.session_state.wallets
    _wallet_opts  = ["— Tanpa Wallet —"] + [f"{w['tipe']} {w['nama']}" for w in _wallets_list]
    _kat_pglr_all = get_kategori_pengeluaran()

    with st.form(f"frm_tx_{st.session_state.tx_form_key}"):
        _in_cat   = st.text_input("Nama Transaksi:", placeholder="Contoh: Beli Tissue")
        _in_nom   = st.number_input("Nominal (Rp):", min_value=0, value=0, step=1_000)
        _in_kat   = st.selectbox("Kategori:", _kat_pglr_all)
        _in_sft   = st.radio("Sifat:", ["Wajib","Sukarela"])
        _in_wlt   = st.selectbox("Wallet:", _wallet_opts)
        _in_tgl   = st.date_input("Tanggal", value=wib().date(), format="DD/MM/YYYY")
        _cj,_cm   = st.columns(2)
        with _cj: _jin = st.number_input("Jam",0,23,st.session_state.jam_input,1,key="inp_j")
        with _cm: _min = st.number_input("Menit",0,59,st.session_state.menit_input,1,key="inp_m")
        _in_rec   = st.checkbox("Jadikan template berulang?")
        _in_freq  = st.selectbox("Frekuensi:",FREKUENSI_BERULANG) if _in_rec else None
        st.session_state.jam_input   = _jin
        st.session_state.menit_input = _min
        _sub_tx   = st.form_submit_button("💾 Simpan Pengeluaran")

    if _sub_tx:
        _errs = []
        if not _in_cat.strip(): _errs.append("Nama tidak boleh kosong.")
        if _in_nom<=0: _errs.append("Nominal harus >0.")
        for _e in _errs: st.error(_e)
        if not _errs:
            try:
                _dt  = datetime(_in_tgl.year,_in_tgl.month,_in_tgl.day,_jin,_min)
                _iso = TZ.localize(_dt).astimezone(pytz.UTC).isoformat()
                _wid = None
                if _in_wlt != "— Tanpa Wallet —":
                    _idx = _wallet_opts.index(_in_wlt)-1
                    if 0<=_idx<len(_wallets_list): _wid=_wallets_list[_idx]["id"]
                _payload = {"user_id":uid,"catatan":_in_cat.strip(),"nominal":_in_nom,
                            "kategori":_in_kat,"sifat":_in_sft,"waktu_transaksi":_iso}
                if _wid: _payload["wallet_id"]=_wid
                _r = supabase.table("transaksi").insert(_payload).execute()
                if _in_rec and _in_freq and _r.data:
                    supabase.table("recurring_templates").insert({
                        "user_id":uid,"catatan":_in_cat.strip(),"nominal":_in_nom,
                        "kategori":_in_kat,"sifat":_in_sft,"frekuensi":_in_freq
                    }).execute()
                if _r.data:
                    st.cache_data.clear()
                    st.session_state.simpan_sukses = True
                    st.session_state.pesan_toast   = f"✅ '{_in_cat.strip()}' dicatat!"
                    st.session_state.jam_input     = wib().hour
                    st.session_state.menit_input   = wib().minute
                    st.session_state.tx_form_key  += 1
                    st.session_state.tx_show_count = 5  # reset pagination
                    st.rerun()
            except Exception as _e: st.error(f"Error: {_e}")

    st.markdown("---")

    # ---- Form Catat Pemasukan ----
    st.subheader("💵 Catat Pemasukan")
    _kat_msuk_all = get_kategori_pemasukan()
    with st.form(f"frm_pm_{st.session_state.pm_form_key}"):
        _in_smb = st.text_input("Sumber:", placeholder="Contoh: Gaji Bulanan")
        _in_npm = st.number_input("Nominal (Rp):", min_value=0, value=0, step=100_000)
        _in_kpm = st.selectbox("Kategori:", _kat_msuk_all)
        _in_wpm = st.selectbox("Wallet:", _wallet_opts, key="wlt_pm")
        _in_tpm = st.date_input("Tanggal", value=wib().date(), format="DD/MM/YYYY", key="tgl_pm")
        _sub_pm = st.form_submit_button("💾 Simpan Pemasukan")

    if _sub_pm:
        if not _in_smb.strip(): st.error("Sumber tidak boleh kosong.")
        elif _in_npm<=0: st.error("Nominal harus >0.")
        else:
            try:
                _dtp   = datetime(_in_tpm.year,_in_tpm.month,_in_tpm.day,12,0)
                _iso_p = TZ.localize(_dtp).astimezone(pytz.UTC).isoformat()
                _wid_p = None
                if _in_wpm != "— Tanpa Wallet —":
                    _idx_p = _wallet_opts.index(_in_wpm)-1
                    if 0<=_idx_p<len(_wallets_list): _wid_p=_wallets_list[_idx_p]["id"]
                _pay_p = {"user_id":uid,"sumber":_in_smb.strip(),"nominal":_in_npm,
                          "kategori":_in_kpm,"waktu_pemasukan":_iso_p}
                if _wid_p: _pay_p["wallet_id"]=_wid_p
                _rp2 = supabase.table("pemasukan").insert(_pay_p).execute()
                if _rp2.data:
                    st.cache_data.clear()
                    st.session_state.simpan_sukses = True
                    st.session_state.pesan_toast   = f"💵 '{_in_smb.strip()}' dicatat!"
                    st.session_state.pm_form_key  += 1; st.rerun()
            except Exception as _e: st.error(f"Error: {_e}")

    st.markdown("---")

    # ---- Recurring Templates ----
    st.subheader("🔄 Template Berulang")
    _recs = ambil_recurring(uid)
    if _recs:
        with st.expander(f"📋 {len(_recs)} template aktif"):
            for _rc in _recs:
                _rc1,_rc2 = st.columns([4,1])
                with _rc1: st.caption(f"**{_rc['catatan']}** — {rp(_rc['nominal'])} ({_rc.get('frekuensi','?')})")
                with _rc2:
                    if st.button("❌", key=f"del_rc_{_rc['id']}"):
                        supabase.table("recurring_templates").delete()\
                            .eq("id",_rc["id"]).eq("user_id",uid).execute()
                        st.cache_data.clear(); st.rerun()
        if st.button("⚡ Generate Bulan Ini", key="gen_rc"):
            _sk = wib(); _ok_rc = 0
            for _rc in _recs:
                try:
                    _wt = TZ.localize(datetime(_sk.year,_sk.month,1,8,0)).astimezone(pytz.UTC).isoformat()
                    supabase.table("transaksi").insert({
                        "user_id":uid,"catatan":_rc["catatan"],"nominal":_rc["nominal"],
                        "kategori":_rc["kategori"],"sifat":_rc["sifat"],"waktu_transaksi":_wt
                    }).execute(); _ok_rc+=1
                except Exception: pass
            if _ok_rc: st.cache_data.clear(); st.success(f"✅ {_ok_rc} transaksi digenerate!"); st.rerun()
    else:
        st.info("Belum ada template berulang.")


# ============================================================
# LOAD DATA
# ============================================================
_raw_tx = ambil_transaksi(uid)
_raw_pm = ambil_pemasukan(uid)

df = pd.DataFrame(_raw_tx) if _raw_tx else pd.DataFrame()
if not df.empty:
    df["nominal"] = pd.to_numeric(df["nominal"], errors="coerce")
    df = df.dropna(subset=["nominal"])
    try: df = parse_waktu(df, "waktu_transaksi")
    except Exception as e: st.error(f"Error data transaksi: {e}"); st.stop()

df_pm = pd.DataFrame(_raw_pm) if _raw_pm else pd.DataFrame()
if not df_pm.empty:
    df_pm["nominal"] = pd.to_numeric(df_pm["nominal"], errors="coerce")
    df_pm = df_pm.dropna(subset=["nominal"])
    try: df_pm = parse_waktu(df_pm, "waktu_pemasukan")
    except Exception: df_pm = pd.DataFrame()

# ============================================================
# ONBOARDING CHECK
# ============================================================
_is_new = (df.empty and not st.session_state.anggaran_terkunci
           and not st.session_state.onboarding_selesai)
if _is_new:
    tampilkan_onboarding(uid, email_user)

# ============================================================
# FILTER PERIODE
# ============================================================
st.markdown("### 🗓️ Filter Periode")
_fc1,_fc2 = st.columns(2)
_thn_list = sorted(df["tahun"].unique().tolist()) if not df.empty else [wib().year]
_now_d = wib()
_pil_bln = _fc1.selectbox("Bulan",["Semua Bulan"]+list(KAMUS_BULAN.values()),index=_now_d.month)
_pil_thn = _fc2.selectbox("Tahun",_thn_list,index=len(_thn_list)-1 if _thn_list else 0)

if _pil_bln=="Semua Bulan":
    _dfv  = df[df["tahun"]==_pil_thn].copy() if not df.empty else pd.DataFrame()
    _dfpv = df_pm[df_pm["tahun"]==_pil_thn].copy() if not df_pm.empty else pd.DataFrame()
    _bud  = sum(v for k,v in st.session_state.anggaran_terkunci.items() if k.endswith(f"_{_pil_thn}"))
    _tgt  = sum(v for k,v in st.session_state.target_tabungan.items() if k.endswith(f"_{_pil_thn}"))
else:
    _dfv  = df[(df["bulan"]==_pil_bln)&(df["tahun"]==_pil_thn)].copy() if not df.empty else pd.DataFrame()
    _dfpv = df_pm[(df_pm["bulan"]==_pil_bln)&(df_pm["tahun"]==_pil_thn)].copy() if not df_pm.empty else pd.DataFrame()
    _ke   = f"{_pil_bln}_{_pil_thn}"
    _bud  = st.session_state.anggaran_terkunci.get(_ke,0)
    _tgt  = st.session_state.target_tabungan.get(_ke,0)

_tot_pglr = _dfv["nominal"].sum()    if not _dfv.empty  else 0.0
_tot_msuk = _dfpv["nominal"].sum()   if not _dfpv.empty else 0.0
_bts      = max(0.0, _bud-_tgt)
_sisa_ang = _bud-_tot_pglr
_net      = _tot_msuk-_tot_pglr
_sukarela = _dfv[_dfv["sifat"]=="Sukarela"]["nominal"].sum() if not _dfv.empty else 0.0

if not st.session_state.toast_kondisi_ditampilkan and _bts>0:
    _p = (_tot_pglr/_bts)*100
    if _p>=100: st.toast("🚨 Target tabungan terancam!", icon="⚠️")
    elif _p>=80: st.toast(f"🟠 Pengeluaran {_p:.0f}% dari batas!", icon="📊")
    else: st.toast(f"🟢 Aman ({_p:.0f}%)", icon="✅")
    st.session_state.toast_kondisi_ditampilkan = True

# ============================================================
# HEALTH SCORE
# ============================================================
_hs, _hd = health_score(_tot_pglr,_bud,_tgt,_sukarela,_dfv,df if not df.empty else pd.DataFrame())
_ls, _wc, _bc = label_hs(_hs)

st.markdown("### 🏅 Financial Health Score")
_hsc1,_hsc2 = st.columns([1,2])
with _hsc1:
    st.markdown(f"""
    <div style="background:{_bc};border-radius:16px;padding:1.5rem;text-align:center;
                box-shadow:0 4px 12px rgba(0,0,0,0.08);">
        <div style="font-size:3rem;font-weight:800;color:{_wc};">{_hs}</div>
        <div style="font-size:0.9rem;color:{_wc};">/100</div>
        <div style="font-size:1rem;margin-top:0.3rem;">{_ls}</div>
    </div>
    """, unsafe_allow_html=True)
with _hsc2:
    _mx = {"Rasio Tabungan":40,"Konsistensi Catat":20,"Porsi Sukarela":20,"Tren Pengeluaran":20}
    for _k2,_p2 in _hd.items():
        _m2=_mx[_k2]; _pct2=_p2/_m2
        _bc2="#2E7D32" if _pct2>=0.7 else ("#F57F17" if _pct2>=0.4 else "#B71C1C")
        st.markdown(f"""
        <div style="margin-bottom:0.6rem;">
            <div style="display:flex;justify-content:space-between;font-size:0.85rem;">
                <span>{_k2}</span><span style="color:{_bc2};font-weight:600;">{_p2}/{_m2}</span>
            </div>
            <div style="background:#e0e0e0;border-radius:8px;height:8px;">
                <div style="background:{_bc2};width:{_pct2*100:.0f}%;height:8px;border-radius:8px;"></div>
            </div>
        </div>""", unsafe_allow_html=True)

st.markdown("---")

# ============================================================
# BALANCE CARD
# ============================================================
_net_color  = "#bbf7d0" if _net >= 0 else "#fca5a5"
_net_label  = "Surplus" if _net >= 0 else "Defisit"
_tot_all    = _tot_msuk + _tot_pglr
_pct_msuk   = int((_tot_msuk / _tot_all * 100)) if _tot_all > 0 else 50
_pct_pglr   = 100 - _pct_msuk

st.markdown(f"""
<div class="balance-card">
    <div class="label">💹 RINGKASAN KEUANGAN — {_pil_bln} {_pil_thn}</div>
    <div class="amount">{rp(_net)}</div>
    <div style="font-size:0.8rem;opacity:0.7;margin-bottom:0.8rem;">
        Net Cash Flow &nbsp;·&nbsp;
        <span style="color:{_net_color};font-weight:600">{_net_label}</span>
    </div>
    <div style="display:flex;gap:0.6rem;">
        <div class="sub-card">
            <div class="sub-label">⬆ Pemasukan</div>
            <div class="sub-amount income-color">{rp(_tot_msuk)}</div>
        </div>
        <div class="sub-card">
            <div class="sub-label">⬇ Pengeluaran</div>
            <div class="sub-amount expense-color">{rp(_tot_pglr)}</div>
        </div>
    </div>
</div>
<div class="cmp-bar-wrap">
    <div class="cmp-bar-title">Perbandingan Pemasukan vs Pengeluaran</div>
    <div class="cmp-bar">
        <div class="cmp-income" style="width:{_pct_msuk}%;"></div>
        <div class="cmp-expense" style="width:{_pct_pglr}%;"></div>
    </div>
    <div class="cmp-labels">
        <span class="cmp-income-lbl">● Pemasukan ({_pct_msuk}%)</span>
        <span class="cmp-expense-lbl">● Pengeluaran ({_pct_pglr}%)</span>
    </div>
</div>
""", unsafe_allow_html=True)

_mc1,_mc2,_mc3,_mc4 = st.columns(4)
_mc1.metric("Anggaran",        rp(_bud))
_mc2.metric("Target Tabungan", rp(_tgt))
_mc3.metric("Batas Belanja",   rp(_bts))
_mc4.metric("Sisa Anggaran",   rp(_sisa_ang),
    delta="Aman" if _sisa_ang>=0 else "Tekor",
    delta_color="normal" if _sisa_ang>=0 else "inverse")

st.markdown("---")

# ============================================================
# TABS UTAMA
# ============================================================
_TABS = ["📋 Pengeluaran","💵 Pemasukan","💸 Hutang/Piutang","👛 Wallet",
         "🎯 Goals","💎 Net Worth","📥 Import CSV","🏷️ Kategori",
         "📊 Visualisasi","🧠 Analisis AI","🤖 Chat AI","📄 Laporan","📋 Changelog"]
_t1,_t2,_t3,_t4,_t5,_t6,_t7,_t8,_t9,_t10,_t11,_t12,_t13 = st.tabs(_TABS)


# ============================================================
# TAB 1 — PENGELUARAN (dengan pagination)
# ============================================================
with _t1:
    st.markdown("#### 📋 Lembar Pengeluaran")

    with st.expander("🔍 Search & Filter", expanded=False):
        _sf1,_sf2 = st.columns(2)
        _search  = _sf1.text_input("🔍 Cari kata kunci:", placeholder="Nama transaksi...", key="srch_tx")
        _kat_pglr_all_flt = get_kategori_pengeluaran()
        _flt_kat = _sf2.multiselect("Filter Kategori:", _kat_pglr_all_flt, key="flt_kat")
        _sf3,_sf4,_sf5 = st.columns(3)
        _flt_sft    = _sf3.selectbox("Sifat:", ["Semua","Wajib","Sukarela"], key="flt_sft")
        _flt_tgl_min = _sf4.date_input("Dari Tanggal:", value=None, key="flt_tgl1")
        _flt_tgl_max = _sf5.date_input("Sampai Tanggal:", value=None, key="flt_tgl2")
        _sort_by = st.selectbox("Urutkan:", ["Terbaru","Terlama","Nominal Terbesar","Nominal Terkecil"], key="srt_tx")

    _dfv_flt = _dfv.copy() if not _dfv.empty else pd.DataFrame()
    if not _dfv_flt.empty:
        if _search:
            _dfv_flt = _dfv_flt[_dfv_flt["catatan"].str.contains(_search, case=False, na=False)]
        if _flt_kat:
            _dfv_flt = _dfv_flt[_dfv_flt["kategori"].isin(_flt_kat)]
        if _flt_sft != "Semua":
            _dfv_flt = _dfv_flt[_dfv_flt["sifat"]==_flt_sft]
        if _flt_tgl_min:
            _dfv_flt = _dfv_flt[_dfv_flt["waktu_transaksi"].dt.date >= _flt_tgl_min]
        if _flt_tgl_max:
            _dfv_flt = _dfv_flt[_dfv_flt["waktu_transaksi"].dt.date <= _flt_tgl_max]
        _sort_map = {
            "Terbaru": ("waktu_transaksi", False), "Terlama": ("waktu_transaksi", True),
            "Nominal Terbesar": ("nominal", False), "Nominal Terkecil": ("nominal", True)
        }
        _sc,_sa = _sort_map[_sort_by]
        _dfv_flt = _dfv_flt.sort_values(_sc, ascending=_sa)

    _KAT_ICON = {
        "Makanan":"🍽️","Transportasi":"🚗","Hiburan/Gaya Hidup":"🎮",
        "Kebutuhan Rumah/Kesehatan":"🏠","Tagihan Wajib":"📋","Lain-lain":"📦"
    }

    if not _dfv_flt.empty:
        _dfv_flt["Jam Catat"] = _dfv_flt.apply(
            lambda r: f"{int(r['jam']):02d}:{int(r['menit']):02d} WIB", axis=1)
        _dfv_flt["Tanggal"] = _dfv_flt["waktu_transaksi"].apply(
            lambda t: f"{t.day} {KAMUS_BULAN[t.month]} {t.year}")

        _total_flt  = len(_dfv_flt)
        _show_count = st.session_state.tx_show_count
        _dfv_show   = _dfv_flt.head(_show_count)

        st.caption(f"Menampilkan **{min(_show_count, _total_flt)}** dari **{_total_flt}** transaksi"
                   + (f" (filter aktif)" if _search or _flt_kat else ""))

        # ── CARD LIST (paginated) ──
        for _, _row in _dfv_show.iterrows():
            _ikon   = _KAT_ICON.get(str(_row.get("kategori","")), "📌")
            _tgl_str = f"{int(_row.get('tanggal',1))} {str(_row.get('bulan',''))[:3]} · {_row['Jam Catat']}"
            st.markdown(f"""
            <div class="tx-item">
                <div class="tx-icon expense">{_ikon}</div>
                <div style="flex:1;min-width:0;">
                    <div class="tx-name">{_row.get('catatan','')}</div>
                    <div class="tx-sub">{_row.get('kategori','')} · {_row.get('sifat','')} · {_tgl_str}</div>
                </div>
                <div class="tx-amount expense">-{rp(_row['nominal'])}</div>
            </div>
            """, unsafe_allow_html=True)

        # ── Tombol Tampilkan Lebih Banyak / Sembunyikan ──
        if _total_flt > _show_count:
            _sisa = _total_flt - _show_count
            if st.button(f"⬇️ Tampilkan {min(_sisa, 10)} lagi  ({_sisa} tersisa)", use_container_width=True, key="btn_more_tx"):
                st.session_state.tx_show_count += 10; st.rerun()
        elif _show_count > 5 and _total_flt > 0:
            if st.button("⬆️ Sembunyikan", use_container_width=True, key="btn_less_tx"):
                st.session_state.tx_show_count = 5; st.rerun()

        # ── Tabel untuk edit/hapus ──
        st.markdown("---")
        st.markdown("**Pilih transaksi untuk edit/hapus:**")
        _dt_show = _dfv_flt[["Tanggal","catatan","nominal","kategori","sifat","Jam Catat"]].copy()
        _dt_show.columns = ["Tanggal","Deskripsi","Nominal (Rp)","Kategori","Sifat","Waktu"]
        _sel = st.dataframe(_dt_show, use_container_width=True, hide_index=True,
                             selection_mode="multi-row", on_select="rerun", key="tbl_tx", height=200)
        _sel_idx = _sel.selection.rows

        _ba1,_ba2,_ba3 = st.columns(3)
        with _ba1:
            if st.button("✏️ Edit Terpilih", key="btn_edit_tx"):
                if len(_sel_idx)==1:
                    _ri = _dfv_flt.iloc[_sel_idx[0]]
                    st.session_state.edit_tx_id   = _ri["id"]
                    st.session_state.edit_tx_data = _ri.to_dict()
                elif len(_sel_idx)==0: st.warning("Pilih 1 baris.")
                else: st.warning("Hanya bisa edit 1 transaksi.")
        with _ba2:
            if st.button("🗑️ Hapus Terpilih", key="btn_hps_tx"):
                if _sel_idx:
                    _valid = [i for i in _sel_idx if i<len(_dfv_flt)]
                    if _valid:
                        st.session_state.hapus_konfirmasi_ids  = _dfv_flt.iloc[_valid]["id"].tolist()
                        st.session_state.hapus_konfirmasi_tipe = "transaksi"
                else: st.warning("Pilih minimal 1 baris.")
        with _ba3:
            _csv = _dt_show.to_csv(index=False).encode("utf-8")
            st.download_button("📥 CSV", _csv, f"pengeluaran_{_pil_bln}_{_pil_thn}.csv","text/csv")

        # ── Konfirmasi Hapus ──
        if (st.session_state.hapus_konfirmasi_ids and st.session_state.hapus_konfirmasi_tipe=="transaksi"):
            _n = len(st.session_state.hapus_konfirmasi_ids)
            st.warning(f"⚠️ Kamu akan menghapus **{_n} transaksi** secara permanen. Lanjutkan?")
            _kc1,_kc2 = st.columns(2)
            if _kc1.button("✅ Ya, Hapus Sekarang", key="konfirm_ya", use_container_width=True):
                try:
                    for _tid in st.session_state.hapus_konfirmasi_ids:
                        supabase.table("transaksi").delete().eq("id",_tid).eq("user_id",uid).execute()
                    st.cache_data.clear()
                    st.session_state.hapus_sukses = True
                    st.session_state.pesan_toast  = f"🗑️ {_n} transaksi dihapus."
                    st.session_state.hapus_konfirmasi_ids  = []
                    st.session_state.hapus_konfirmasi_tipe = ""; st.rerun()
                except Exception as _e: st.error(f"Gagal hapus: {_e}")
            if _kc2.button("❌ Batal", key="konfirm_batal", use_container_width=True):
                st.session_state.hapus_konfirmasi_ids  = []
                st.session_state.hapus_konfirmasi_tipe = ""; st.rerun()

        # ── Form Edit ──
        if st.session_state.edit_tx_id:
            st.markdown("---")
            st.markdown("#### ✏️ Edit Transaksi")
            _ed = st.session_state.edit_tx_data
            _kat_pglr_all_e = get_kategori_pengeluaran()
            with st.form("frm_edit_tx"):
                _e_cat = st.text_input("Nama:", value=str(_ed.get("catatan","")))
                _e_nom = st.number_input("Nominal (Rp):", min_value=0, value=int(_ed.get("nominal",0)), step=1_000)
                _e_kat = st.selectbox("Kategori:", _kat_pglr_all_e,
                    index=_kat_pglr_all_e.index(_ed["kategori"]) if _ed.get("kategori") in _kat_pglr_all_e else 0)
                _e_sft = st.radio("Sifat:", ["Wajib","Sukarela"], index=0 if _ed.get("sifat")=="Wajib" else 1)
                _c_save,_c_cancel = st.columns(2)
                _save   = _c_save.form_submit_button("💾 Simpan", use_container_width=True)
                _cancel = _c_cancel.form_submit_button("❌ Batal", use_container_width=True)
            if _save:
                if not _e_cat.strip(): st.error("Nama tidak boleh kosong.")
                elif _e_nom<=0: st.error("Nominal harus >0.")
                else:
                    try:
                        supabase.table("transaksi").update({
                            "catatan":_e_cat.strip(),"nominal":_e_nom,"kategori":_e_kat,"sifat":_e_sft
                        }).eq("id",st.session_state.edit_tx_id).eq("user_id",uid).execute()
                        st.cache_data.clear()
                        st.session_state.edit_tx_id   = None
                        st.session_state.edit_tx_data = {}
                        st.session_state.simpan_sukses = True
                        st.session_state.pesan_toast   = "✏️ Transaksi berhasil diupdate!"; st.rerun()
                    except Exception as _e: st.error(f"Gagal update: {_e}")
            if _cancel:
                st.session_state.edit_tx_id   = None
                st.session_state.edit_tx_data = {}; st.rerun()

        # ── Budget per kategori progress ──
        _bk_now = st.session_state.budget_kategori.get(f"{_pil_bln}_{_pil_thn}",{})
        if _bk_now and not _dfv.empty:
            st.markdown("---")
            st.markdown("**📂 Progress Budget per Kategori**")
            _kat_tot = _dfv.groupby("kategori")["nominal"].sum()
            for _kat,_bk_val in _bk_now.items():
                if _bk_val>0:
                    _spent = float(_kat_tot.get(_kat,0))
                    _pct3  = min(100, (_spent/_bk_val)*100)
                    _clr3  = "#2E7D32" if _pct3<70 else ("#F57F17" if _pct3<90 else "#E53935")
                    st.markdown(f"""
                    <div style="margin-bottom:0.5rem;">
                        <div style="display:flex;justify-content:space-between;font-size:0.85rem;">
                            <span>{_kat}</span>
                            <span style="color:{_clr3}">{rp(_spent)} / {rp(_bk_val)} ({_pct3:.0f}%)</span>
                        </div>
                        <div style="background:#e0e0e0;border-radius:6px;height:7px;">
                            <div style="background:{_clr3};width:{_pct3:.0f}%;height:7px;border-radius:6px;"></div>
                        </div>
                    </div>""", unsafe_allow_html=True)
    else:
        st.info("Tidak ada pengeluaran" + (" yang sesuai filter." if _search or _flt_kat else " pada periode ini."))


# ============================================================
# TAB 2 — PEMASUKAN
# ============================================================
with _t2:
    st.markdown("#### 💵 Lembar Pemasukan")
    _KAT_ICON_PM = {
        "Gaji":"💼","Freelance":"💻","Bisnis":"🏪","Investasi":"📈",
        "Hadiah/Bonus":"🎁","Passive Income":"💰","Lain-lain":"💵"
    }
    if not _dfpv.empty:
        _dfpv2 = _dfpv.copy()
        _dfpv2["Tanggal"] = _dfpv2["waktu_pemasukan"].apply(
            lambda t: f"{t.day} {KAMUS_BULAN[t.month]} {t.year}")
        for _, _prow in _dfpv2.iterrows():
            _pikon = _KAT_ICON_PM.get(str(_prow.get("kategori","")), "💵")
            st.markdown(f"""
            <div class="tx-item">
                <div class="tx-icon">{_pikon}</div>
                <div style="flex:1;min-width:0;">
                    <div class="tx-name">{_prow.get('sumber','')}</div>
                    <div class="tx-sub">{_prow.get('kategori','')} · {_prow['Tanggal']}</div>
                </div>
                <div class="tx-amount income">+{rp(_prow['nominal'])}</div>
            </div>
            """, unsafe_allow_html=True)

        st.markdown("**Pilih untuk hapus:**")
        _dps = _dfpv2[["Tanggal","sumber","nominal","kategori"]].copy()
        _dps.columns = ["Tanggal","Sumber","Nominal (Rp)","Kategori"]
        _sp = st.dataframe(_dps, use_container_width=True, hide_index=True,
                            selection_mode="multi-row", on_select="rerun", key="tbl_pm", height=180)

        _pb1,_pb2 = st.columns(2)
        with _pb1:
            if st.button("🗑️ Hapus Pemasukan Terpilih", key="btn_hps_pm"):
                _si = _sp.selection.rows
                if _si:
                    _vp = [i for i in _si if i<len(_dfpv2)]
                    if _vp:
                        st.session_state.hapus_konfirmasi_ids  = _dfpv2.iloc[_vp]["id"].tolist()
                        st.session_state.hapus_konfirmasi_tipe = "pemasukan"
                else: st.warning("Pilih minimal 1 baris.")
        with _pb2:
            _csvp = _dps.to_csv(index=False).encode("utf-8")
            st.download_button("📥 CSV", _csvp, f"pemasukan_{_pil_bln}_{_pil_thn}.csv","text/csv")

        if (st.session_state.hapus_konfirmasi_ids and st.session_state.hapus_konfirmasi_tipe=="pemasukan"):
            _np = len(st.session_state.hapus_konfirmasi_ids)
            st.warning(f"⚠️ Hapus **{_np} pemasukan** secara permanen?")
            _kp1,_kp2 = st.columns(2)
            if _kp1.button("✅ Ya, Hapus", key="kfm_pm_ya", use_container_width=True):
                try:
                    for _pid in st.session_state.hapus_konfirmasi_ids:
                        supabase.table("pemasukan").delete().eq("id",_pid).eq("user_id",uid).execute()
                    st.cache_data.clear()
                    st.session_state.hapus_sukses = True
                    st.session_state.pesan_toast  = f"🗑️ {_np} pemasukan dihapus."
                    st.session_state.hapus_konfirmasi_ids  = []
                    st.session_state.hapus_konfirmasi_tipe = ""; st.rerun()
                except Exception as _e: st.error(f"Gagal: {_e}")
            if _kp2.button("❌ Batal", key="kfm_pm_batal", use_container_width=True):
                st.session_state.hapus_konfirmasi_ids  = []
                st.session_state.hapus_konfirmasi_tipe = ""; st.rerun()

        st.markdown("**Rincian per Kategori**")
        _kpm = _dfpv2.groupby("kategori")["nominal"].sum().reset_index()
        _kpm.columns = ["Kategori","Total (Rp)"]
        st.dataframe(_kpm, use_container_width=True, hide_index=True)
    else:
        st.info("Tidak ada pemasukan pada periode ini.")


# ============================================================
# TAB 3 — HUTANG / PIUTANG
# ============================================================
with _t3:
    st.markdown("#### 💸 Pelacakan Hutang & Piutang")
    _hp_data = ambil_hutang(uid)
    _df_hp   = pd.DataFrame(_hp_data) if _hp_data else pd.DataFrame()

    with st.expander("➕ Tambah Hutang / Piutang", expanded=False):
        with st.form("frm_hp"):
            _hp_jenis = st.radio("Jenis:", ["hutang","piutang"],
                                  format_func=lambda x:"💸 Saya Berhutang" if x=="hutang" else "💰 Orang Lain Berhutang ke Saya")
            _hp_nama  = st.text_input("Nama Pihak:", placeholder="Contoh: Budi")
            _hp_nom   = st.number_input("Nominal (Rp):", min_value=0, value=0, step=10_000)
            _hp_ket   = st.text_input("Keterangan:", placeholder="Contoh: Pinjam beli makan")
            _hp_tgl   = st.date_input("Tanggal Pinjam:", value=wib().date(), format="DD/MM/YYYY")
            _hp_jt    = st.date_input("Jatuh Tempo:", value=None, format="DD/MM/YYYY")
            _sub_hp   = st.form_submit_button("💾 Simpan", use_container_width=True)
        if _sub_hp:
            if not _hp_nama.strip(): st.error("Nama tidak boleh kosong.")
            elif _hp_nom<=0: st.error("Nominal harus >0.")
            else:
                try:
                    _tgl_iso = TZ.localize(datetime(_hp_tgl.year,_hp_tgl.month,_hp_tgl.day,12,0))\
                                .astimezone(pytz.UTC).isoformat()
                    _jt_iso  = TZ.localize(datetime(_hp_jt.year,_hp_jt.month,_hp_jt.day,23,59))\
                                .astimezone(pytz.UTC).isoformat() if _hp_jt else None
                    supabase.table("hutang_piutang").insert({
                        "user_id":uid,"jenis":_hp_jenis,"nama_pihak":_hp_nama.strip(),
                        "nominal":_hp_nom,"keterangan":_hp_ket.strip(),
                        "tanggal":_tgl_iso,"jatuh_tempo":_jt_iso,"status":"belum_lunas"
                    }).execute()
                    st.cache_data.clear(); st.success("✅ Berhasil disimpan!"); st.rerun()
                except Exception as _e: st.error(f"Error: {_e}")

    if not _df_hp.empty:
        _tot_hutang  = _df_hp[(_df_hp["jenis"]=="hutang") &(_df_hp["status"]=="belum_lunas")]["nominal"].sum()
        _tot_piutang = _df_hp[(_df_hp["jenis"]=="piutang")&(_df_hp["status"]=="belum_lunas")]["nominal"].sum()
        _mhp = st.columns(3)
        _mhp[0].metric("Total Hutang",     rp(_tot_hutang),  delta_color="inverse")
        _mhp[1].metric("Total Piutang",    rp(_tot_piutang))
        _mhp[2].metric("Net Hutang/Piutang", rp(_tot_piutang-_tot_hutang),
            delta="Surplus" if _tot_piutang>=_tot_hutang else "Defisit",
            delta_color="normal" if _tot_piutang>=_tot_hutang else "inverse")

        _hp_tab1,_hp_tab2 = st.tabs(["💸 Hutang Saya","💰 Piutang Saya"])
        for _ht,_ht_label in [(_hp_tab1,"hutang"),(_hp_tab2,"piutang")]:
            with _ht:
                _df_ht = _df_hp[_df_hp["jenis"]==_ht_label].copy()
                if not _df_ht.empty:
                    for _,_row in _df_ht.iterrows():
                        _stat_col = "#2E7D32" if _row["status"]=="lunas" else "#E53935"
                        _jt_str = ""
                        if _row.get("jatuh_tempo"):
                            try:
                                _jt_d = datetime.fromisoformat(
                                    str(_row["jatuh_tempo"]).replace("Z","+00:00")
                                ).astimezone(TZ).date()
                                _sisa_hp = (_jt_d-wib().date()).days
                                _jt_str  = f" · Jatuh tempo: {_jt_d.strftime('%d %b %Y')}"
                                if _sisa_hp<=3 and _row["status"]!="lunas":
                                    _jt_str += f" ⚠️ ({_sisa_hp}h lagi)"
                            except Exception: pass
                        _hpc = st.columns([3,1,1])
                        with _hpc[0]:
                            st.markdown(
                                f"**{_row['nama_pihak']}** — {rp(_row['nominal'])}\n\n"
                                f"<small style='color:#64748b'>{_row.get('keterangan','')}{_jt_str}</small>",
                                unsafe_allow_html=True)
                        with _hpc[1]:
                            st.markdown(
                                f"<span style='color:{_stat_col};font-weight:600;font-size:0.85rem;'>"
                                f"{'✅ Lunas' if _row['status']=='lunas' else '🔴 Belum'}</span>",
                                unsafe_allow_html=True)
                        with _hpc[2]:
                            if _row["status"]=="belum_lunas":
                                if st.button("✅ Lunas", key=f"lns_{_row['id']}"):
                                    supabase.table("hutang_piutang").update({"status":"lunas"})\
                                        .eq("id",_row["id"]).eq("user_id",uid).execute()
                                    st.cache_data.clear(); st.rerun()
                            else:
                                if st.button("🗑️", key=f"del_hp_{_row['id']}"):
                                    st.session_state.hapus_konfirmasi_ids  = [_row["id"]]
                                    st.session_state.hapus_konfirmasi_tipe = "hutang"; st.rerun()
                        st.markdown("---")
                else:
                    st.info(f"Tidak ada {'hutang' if _ht_label=='hutang' else 'piutang'}.")

        if (st.session_state.hapus_konfirmasi_ids and st.session_state.hapus_konfirmasi_tipe=="hutang"):
            st.warning("⚠️ Hapus catatan ini secara permanen?")
            _kh1,_kh2 = st.columns(2)
            if _kh1.button("✅ Ya", key="kfm_hp_ya"):
                for _hid in st.session_state.hapus_konfirmasi_ids:
                    supabase.table("hutang_piutang").delete().eq("id",_hid).eq("user_id",uid).execute()
                st.cache_data.clear()
                st.session_state.hapus_konfirmasi_ids  = []
                st.session_state.hapus_konfirmasi_tipe = ""; st.rerun()
            if _kh2.button("❌ Batal", key="kfm_hp_batal"):
                st.session_state.hapus_konfirmasi_ids  = []
                st.session_state.hapus_konfirmasi_tipe = ""; st.rerun()
    else:
        st.info("Belum ada catatan hutang/piutang.")


# ============================================================
# TAB 4 — WALLET
# ============================================================
with _t4:
    st.markdown("#### 👛 Multi-Wallet")
    _wts = st.session_state.wallets

    with st.expander("➕ Tambah Wallet Baru"):
        with st.form("frm_add_wallet"):
            _wn = st.text_input("Nama Wallet:", placeholder="Contoh: BCA Utama")
            _wt = st.selectbox("Tipe:", TIPE_WALLET)
            _ws = st.number_input("Saldo Awal (Rp):", min_value=0, value=0, step=50_000)
            _wc_input = st.color_picker("Warna:", value="#2E7D32")
            if st.form_submit_button("💾 Tambah Wallet", use_container_width=True):
                if not _wn.strip(): st.error("Nama tidak boleh kosong.")
                else:
                    if simpan_wallet(uid, _wn.strip(), _wt, _ws, _wc_input):
                        st.session_state.muat_wallets_sukses = False
                        st.cache_data.clear(); st.success("✅ Wallet ditambahkan!"); st.rerun()

    if _wts:
        for _w in _wts:
            _wid2  = _w["id"]
            _tx_w  = df[df["wallet_id"]==_wid2]["nominal"].sum() if (not df.empty and "wallet_id" in df.columns) else 0
            _pm_w  = df_pm[df_pm["wallet_id"]==_wid2]["nominal"].sum() if (not df_pm.empty and "wallet_id" in df_pm.columns) else 0
            _saldo_est = float(_w.get("saldo_awal",0)) + _pm_w - _tx_w
            _wc2 = _w.get("warna","#2E7D32")
            st.markdown(f"""
            <div style="background:linear-gradient(135deg,{_wc2}dd,{_wc2}88);border-radius:14px;
                        padding:1rem 1.2rem;margin-bottom:0.8rem;color:white;
                        box-shadow:0 4px 12px rgba(0,0,0,0.1);">
                <div style="display:flex;justify-content:space-between;align-items:center;">
                    <div>
                        <div style="font-size:1.1rem;font-weight:700;">{_w['tipe']} {_w['nama']}</div>
                        <div style="font-size:0.8rem;opacity:0.8;">Saldo Awal: {rp(_w.get('saldo_awal',0))}</div>
                    </div>
                    <div style="text-align:right;">
                        <div style="font-size:1.3rem;font-weight:800;">{rp(_saldo_est)}</div>
                        <div style="font-size:0.75rem;opacity:0.8;">Estimasi Saldo</div>
                    </div>
                </div>
            </div>
            """, unsafe_allow_html=True)
            _,_wc_col2 = st.columns([4,1])
            with _wc_col2:
                if st.button("🗑️ Hapus", key=f"del_w_{_wid2}"):
                    if hapus_wallet(uid, _wid2):
                        st.session_state.muat_wallets_sukses = False
                        muat_wallets(uid, True); st.rerun()
    else:
        st.info("Belum ada wallet.")


# ============================================================
# TAB 5 — FINANCIAL GOALS
# ============================================================
with _t5:
    st.markdown("#### 🎯 Financial Goals")
    st.caption("Tetapkan target finansial jangka pendek dan panjang, pantau progress-nya.")

    with st.expander("➕ Tambah Goal Baru", expanded=False):
        with st.form("frm_goal"):
            _gc1,_gc2 = st.columns([3,1])
            _g_nama  = _gc1.text_input("Nama Goal:", placeholder="Contoh: Beli Laptop, DP Rumah")
            _g_ikon  = _gc2.selectbox("Ikon:", GOAL_IKON_LIST)
            _g_target = st.number_input("Target Nominal (Rp):", min_value=1000, value=5_000_000, step=100_000)
            _g_terkumpul = st.number_input("Dana Terkumpul Saat Ini (Rp):", min_value=0, value=0, step=100_000)
            _g_kat   = st.selectbox("Kategori Goal:", ["Darurat","Elektronik","Properti","Kendaraan",
                                                         "Liburan","Pendidikan","Kesehatan","Lainnya"])
            _g_deadline = st.date_input("Target Tanggal Tercapai:", value=None, format="DD/MM/YYYY")
            _sub_goal = st.form_submit_button("💾 Simpan Goal", use_container_width=True)
        if _sub_goal:
            if not _g_nama.strip(): st.error("Nama tidak boleh kosong.")
            else:
                if simpan_goal(uid, _g_nama.strip(), _g_target, _g_terkumpul, _g_deadline, _g_kat, _g_ikon):
                    st.session_state.muat_goals_sukses = False
                    muat_goals(uid, True)
                    st.success("✅ Goal berhasil disimpan!"); st.rerun()

    goals = st.session_state.financial_goals
    if goals:
        # Ringkasan
        _total_goals = len(goals)
        _tercapai = sum(1 for g in goals if g.get("terkumpul",0) >= g["target_nominal"])
        _gc1,_gc2,_gc3 = st.columns(3)
        _gc1.metric("Total Goals", _total_goals)
        _gc2.metric("Sudah Tercapai", _tercapai)
        _gc3.metric("Sedang Berjalan", _total_goals-_tercapai)
        st.markdown("---")

        for _g in goals:
            _terkumpul = _g.get("terkumpul", 0)
            _target    = _g["target_nominal"]
            _pct       = min(100, (_terkumpul / _target * 100)) if _target > 0 else 0
            _sisa_goal = max(0, _target - _terkumpul)
            _pct_clr   = "#2E7D32" if _pct >= 100 else ("#3b82f6" if _pct >= 50 else "#f59e0b")
            _done_badge = ' <span style="background:#16a34a;color:white;border-radius:12px;padding:1px 8px;font-size:0.72rem;">✅ Tercapai</span>' if _pct >= 100 else ""

            # Hitung sisa hari jika ada deadline
            _deadline_str = ""
            if _g.get("deadline"):
                try:
                    _dl = date.fromisoformat(_g["deadline"])
                    _sisa_hari = (_dl - wib().date()).days
                    if _sisa_hari > 0:
                        _deadline_str = f"⏳ {_sisa_hari} hari lagi"
                    elif _sisa_hari == 0:
                        _deadline_str = "⏰ Deadline hari ini!"
                    else:
                        _deadline_str = f"⚠️ Lewat {abs(_sisa_hari)} hari"
                except Exception: pass

            st.markdown(f"""
            <div class="goal-card">
                <div style="display:flex;justify-content:space-between;align-items:flex-start;">
                    <div>
                        <div class="goal-title">{_g['ikon']} {_g['nama']}{_done_badge}</div>
                        <div class="goal-sub">{_g.get('kategori','—')} {('· ' + _deadline_str) if _deadline_str else ''}</div>
                    </div>
                    <div style="text-align:right;">
                        <div class="goal-pct" style="color:{_pct_clr};">{_pct:.1f}%</div>
                    </div>
                </div>
                <div class="goal-bar-bg">
                    <div class="goal-bar-fill" style="background:{_pct_clr};width:{_pct:.1f}%;"></div>
                </div>
                <div style="display:flex;justify-content:space-between;font-size:0.82rem;color:#94a3b8;">
                    <span>Terkumpul: <strong style="color:#e2e8f0">{rp(_terkumpul)}</strong></span>
                    <span>Target: <strong style="color:#e2e8f0">{rp(_target)}</strong></span>
                    <span>Sisa: <strong style="color:{_pct_clr}">{rp(_sisa_goal)}</strong></span>
                </div>
            </div>
            """, unsafe_allow_html=True)

            # Tombol update + hapus
            _gca, _gcb, _gcc = st.columns([3, 2, 1])
            with _gca:
                _new_terkumpul = st.number_input(
                    f"Update dana (Rp):", min_value=0, value=int(_terkumpul),
                    step=50_000, key=f"upd_goal_{_g['id']}", label_visibility="collapsed")
            with _gcb:
                if st.button("💾 Update Dana", key=f"btn_upd_goal_{_g['id']}", use_container_width=True):
                    if update_goal_terkumpul(uid, _g["id"], _new_terkumpul):
                        st.session_state.muat_goals_sukses = False
                        muat_goals(uid, True)
                        st.session_state.simpan_sukses = True
                        st.session_state.pesan_toast   = f"✅ Goal '{_g['nama']}' diupdate!"
                        st.rerun()
            with _gcc:
                if st.button("🗑️", key=f"del_goal_{_g['id']}", help="Hapus goal ini"):
                    if hapus_goal(uid, _g["id"]):
                        st.session_state.muat_goals_sukses = False
                        muat_goals(uid, True); st.rerun()

            st.markdown("")  # spacing
    else:
        st.info("Belum ada goals. Tambahkan goal finansialmu di atas!")
        st.markdown("""
        **💡 Contoh goals yang bisa kamu set:**
        - 🏠 DP Rumah (Rp 50.000.000 dalam 2 tahun)
        - 📱 Ganti HP baru (Rp 8.000.000 dalam 6 bulan)
        - ✈️ Liburan Bali (Rp 5.000.000 dalam 3 bulan)
        - 🎓 Kursus Online (Rp 2.000.000 dalam 1 bulan)
        - 💊 Dana Darurat (Rp 30.000.000 dalam 12 bulan)
        """)


# ============================================================
# TAB 6 — NET WORTH TRACKER
# ============================================================
with _t6:
    st.markdown("#### 💎 Net Worth Tracker")
    st.caption("Pantau kekayaan bersih kamu dari waktu ke waktu. Net Worth = Total Aset — Total Liabilitas.")

    _now_nw = wib()
    _kb_nw  = f"{KAMUS_BULAN[_now_nw.month]}_{_now_nw.year}"

    # ── Cari snapshot bulan ini kalau ada ──
    _nw_history = st.session_state.networth_history
    _latest_nw  = next((n for n in reversed(_nw_history) if n["bulan_key"]==_kb_nw), None)

    _aset_items  = json.loads(_latest_nw["catatan_aset"])       if _latest_nw and _latest_nw.get("catatan_aset") else []
    _liab_items  = json.loads(_latest_nw["catatan_liabilitas"]) if _latest_nw and _latest_nw.get("catatan_liabilitas") else []
    _total_aset  = _latest_nw["total_aset"]       if _latest_nw else 0
    _total_liab  = _latest_nw["total_liabilitas"] if _latest_nw else 0
    _net_worth   = _total_aset - _total_liab

    # ── Summary card ──
    _nw_clr = "#4ade80" if _net_worth >= 0 else "#f87171"
    st.markdown(f"""
    <div class="nw-card">
        <div class="nw-title">💎 NET WORTH — {KAMUS_BULAN[_now_nw.month]} {_now_nw.year}</div>
        <div class="nw-amount" style="color:{_nw_clr};">{rp(_net_worth)}</div>
        <div style="display:flex;gap:1.5rem;margin-top:0.8rem;font-size:0.85rem;">
            <div><span style="opacity:0.7;">Total Aset</span><br>
                 <strong style="color:#bbf7d0;">{rp(_total_aset)}</strong></div>
            <div><span style="opacity:0.7;">Total Liabilitas</span><br>
                 <strong style="color:#fca5a5;">{rp(_total_liab)}</strong></div>
        </div>
    </div>
    """, unsafe_allow_html=True)

    # ── Input Aset & Liabilitas ──
    with st.expander(f"📝 Update Net Worth — {KAMUS_BULAN[_now_nw.month]} {_now_nw.year}", expanded=not bool(_latest_nw)):
        st.markdown("**💰 Aset Kamu**")
        st.caption("Masukkan semua aset yang kamu miliki saat ini.")

        _aset_rows = []
        if "nw_aset_count" not in st.session_state:
            st.session_state.nw_aset_count = max(len(_aset_items), 1)
        if "nw_liab_count" not in st.session_state:
            st.session_state.nw_liab_count = max(len(_liab_items), 1)

        _nc1, _nc2 = st.columns([1, 1])
        with _nc1:
            if st.button("➕ Tambah Baris Aset", key="add_aset_row"):
                st.session_state.nw_aset_count += 1; st.rerun()
        with _nc2:
            if st.button("➕ Tambah Baris Liabilitas", key="add_liab_row"):
                st.session_state.nw_liab_count += 1; st.rerun()

        _aset_total_input = 0
        st.markdown("**Aset:**")
        for _i in range(st.session_state.nw_aset_count):
            _prev_nama = _aset_items[_i]["nama"] if _i < len(_aset_items) else ""
            _prev_nom  = _aset_items[_i]["nominal"] if _i < len(_aset_items) else 0
            _prev_tipe = _aset_items[_i].get("tipe", ASET_TIPE_LIST[0]) if _i < len(_aset_items) else ASET_TIPE_LIST[0]
            _ai1,_ai2,_ai3 = st.columns([2,2,2])
            _a_nama = _ai1.text_input("Nama Aset", value=_prev_nama, key=f"a_nama_{_i}", placeholder="Contoh: Tabungan BCA")
            _a_tipe = _ai2.selectbox("Tipe", ASET_TIPE_LIST, index=ASET_TIPE_LIST.index(_prev_tipe) if _prev_tipe in ASET_TIPE_LIST else 0, key=f"a_tipe_{_i}")
            _a_nom  = _ai3.number_input("Nilai (Rp)", min_value=0, value=int(_prev_nom), step=100_000, key=f"a_nom_{_i}")
            if _a_nama.strip() and _a_nom > 0:
                _aset_rows.append({"nama":_a_nama.strip(), "tipe":_a_tipe, "nominal":_a_nom})
                _aset_total_input += _a_nom

        st.markdown(f"**Total Aset: {rp(_aset_total_input)}**")
        st.markdown("---")

        _liab_rows  = []
        _liab_total_input = 0
        st.markdown("**Liabilitas (Hutang):**")
        for _i in range(st.session_state.nw_liab_count):
            _prev_nama = _liab_items[_i]["nama"] if _i < len(_liab_items) else ""
            _prev_nom  = _liab_items[_i]["nominal"] if _i < len(_liab_items) else 0
            _prev_tipe = _liab_items[_i].get("tipe", LIAB_TIPE_LIST[0]) if _i < len(_liab_items) else LIAB_TIPE_LIST[0]
            _li1,_li2,_li3 = st.columns([2,2,2])
            _l_nama = _li1.text_input("Nama Liabilitas", value=_prev_nama, key=f"l_nama_{_i}", placeholder="Contoh: KPR BRI")
            _l_tipe = _li2.selectbox("Tipe", LIAB_TIPE_LIST, index=LIAB_TIPE_LIST.index(_prev_tipe) if _prev_tipe in LIAB_TIPE_LIST else 0, key=f"l_tipe_{_i}")
            _l_nom  = _li3.number_input("Nilai (Rp)", min_value=0, value=int(_prev_nom), step=100_000, key=f"l_nom_{_i}")
            if _l_nama.strip() and _l_nom > 0:
                _liab_rows.append({"nama":_l_nama.strip(), "tipe":_l_tipe, "nominal":_l_nom})
                _liab_total_input += _l_nom

        st.markdown(f"**Total Liabilitas: {rp(_liab_total_input)}**")
        _nw_preview = _aset_total_input - _liab_total_input
        _nwp_clr = "#4ade80" if _nw_preview >= 0 else "#f87171"
        st.markdown(f"**Net Worth Preview: <span style='color:{_nwp_clr}'>{rp(_nw_preview)}</span>**", unsafe_allow_html=True)

        if st.button("💾 Simpan Net Worth Bulan Ini", use_container_width=True, key="btn_save_nw"):
            if simpan_networth(uid, _kb_nw, _aset_total_input, _liab_total_input, _aset_rows, _liab_rows):
                st.session_state.muat_nw_sukses = False
                muat_networth(uid, True)
                st.session_state.simpan_sukses = True
                st.session_state.pesan_toast   = "💎 Net Worth berhasil disimpan!"; st.rerun()

    # ── Grafik Tren Net Worth ──
    if len(_nw_history) >= 2:
        st.markdown("---")
        st.markdown("**📈 Tren Net Worth**")
        _nw_df = pd.DataFrame([{
            "Periode": h["bulan_key"].replace("_"," "),
            "Aset":    h["total_aset"],
            "Liabilitas": h["total_liabilitas"],
            "Net Worth": h["total_aset"] - h["total_liabilitas"]
        } for h in _nw_history])

        _nw_melt = _nw_df.melt(id_vars="Periode", value_vars=["Aset","Liabilitas","Net Worth"],
                                var_name="Tipe", value_name="Nilai")
        st.altair_chart(
            alt.Chart(_nw_melt).mark_line(point=True).encode(
                x=alt.X("Periode:N", title="Periode"),
                y=alt.Y("Nilai:Q", title="Nilai (Rp)"),
                color=alt.Color("Tipe:N", scale=alt.Scale(
                    domain=["Aset","Liabilitas","Net Worth"],
                    range=["#4ade80","#f87171","#60a5fa"])),
                tooltip=["Periode","Tipe","Nilai"]
            ).properties(height=280), use_container_width=True)

        st.dataframe(_nw_df, use_container_width=True, hide_index=True)
    elif len(_nw_history) == 1:
        st.info("Catat net worth bulan depan untuk melihat tren perkembangan.")


# ============================================================
# TAB 7 — IMPORT CSV MUTASI BANK
# ============================================================
with _t7:
    st.markdown("#### 📥 Import CSV Mutasi Bank")
    st.caption("Upload file CSV mutasi rekening bank, mapping kolom, lalu import massal ke DanaPintar.")

    with st.expander("📋 Format CSV yang Didukung", expanded=False):
        st.markdown("""
        **Format yang disarankan:**
        Kolom minimal: tanggal, deskripsi/keterangan, nominal/debit/kredit.

        **Contoh CSV BCA:**
        ```
        Tanggal,Keterangan,Cabang,Nominal,Tipe
        01/05/2026,TRANSFER KE BUDI,ATM,-50000,DB
        02/05/2026,GAJI MASUK,,5000000,CR
        ```

        **Contoh CSV Mandiri:**
        ```
        Tanggal Transaksi,Deskripsi,Debit,Kredit,Saldo
        01/05/2026,BELANJA ALFAMART,75000,,8925000
        02/05/2026,GAJI,,5000000,13925000
        ```

        💡 **Tips:** File harus `.csv`. Baris kosong di awal file akan diabaikan otomatis.
        """)

    _csv_file = st.file_uploader("📂 Upload file CSV mutasi bank:", type=["csv"], key="csv_uploader")

    if _csv_file is not None:
        try:
            # Auto-detect encoding dan separator
            _raw_bytes = _csv_file.read()
            try:
                _csv_str = _raw_bytes.decode("utf-8")
            except UnicodeDecodeError:
                try:
                    _csv_str = _raw_bytes.decode("latin-1")
                except Exception:
                    _csv_str = _raw_bytes.decode("utf-8", errors="ignore")

            # Coba berbagai separator
            _df_raw = None
            for _sep in [",", ";", "\t", "|"]:
                try:
                    _df_try = pd.read_csv(io.StringIO(_csv_str), sep=_sep, skip_blank_lines=True)
                    if len(_df_try.columns) >= 2:
                        _df_raw = _df_try; break
                except Exception: continue

            if _df_raw is None or _df_raw.empty:
                st.error("❌ Tidak bisa membaca file CSV. Pastikan format benar.")
            else:
                # Hapus baris yang semua null
                _df_raw = _df_raw.dropna(how="all")
                _df_raw.columns = [str(c).strip() for c in _df_raw.columns]

                st.success(f"✅ File berhasil dibaca: **{len(_df_raw)} baris**, **{len(_df_raw.columns)} kolom**")

                with st.expander("👀 Preview Data Mentah", expanded=True):
                    st.dataframe(_df_raw.head(10), use_container_width=True)

                st.markdown("---")
                st.markdown("### 🔗 Mapping Kolom")
                st.caption("Cocokkan kolom dari file CSV-mu ke field DanaPintar.")

                _cols_csv = ["— Pilih Kolom —"] + list(_df_raw.columns)
                _kat_all_import = get_kategori_pengeluaran()

                _im1,_im2 = st.columns(2)
                with _im1:
                    _map_tgl  = st.selectbox("📅 Kolom Tanggal:", _cols_csv, key="map_tgl")
                    _map_desk = st.selectbox("📝 Kolom Deskripsi:", _cols_csv, key="map_desk")
                    _map_nom  = st.selectbox("💰 Kolom Nominal/Debit:", _cols_csv, key="map_nom")
                with _im2:
                    _map_tipe = st.selectbox("📌 Kolom Tipe (Opsional):", _cols_csv, key="map_tipe")
                    _import_kat = st.selectbox("🏷️ Kategori Default:", _kat_all_import, key="imp_kat")
                    _import_sft = st.radio("Sifat Default:", ["Wajib","Sukarela"], key="imp_sft")
                    _import_wlt = st.selectbox("👛 Wallet:", ["— Tanpa Wallet —"] + [f"{w['tipe']} {w['nama']}" for w in st.session_state.wallets], key="imp_wlt")

                _tgl_format = st.text_input("Format Tanggal:", value="%d/%m/%Y",
                    help="Contoh: %d/%m/%Y, %Y-%m-%d, %d-%m-%Y")
                _min_nominal = st.number_input("Minimal Nominal (filter baris kecil):", min_value=0, value=1000, step=1000)
                _hanya_debit = st.checkbox("Hanya import baris debit/pengeluaran", value=True)

                if st.button("🔍 Preview Import", use_container_width=True, key="btn_preview_import"):
                    if _map_tgl == "— Pilih Kolom —" or _map_desk == "— Pilih Kolom —" or _map_nom == "— Pilih Kolom —":
                        st.error("❌ Pilih kolom Tanggal, Deskripsi, dan Nominal terlebih dahulu.")
                    else:
                        try:
                            _df_import = _df_raw.copy()
                            _df_import["_tgl"]  = pd.to_datetime(_df_import[_map_tgl], format=_tgl_format, errors="coerce")
                            _df_import["_desk"] = _df_import[_map_desk].astype(str).str.strip()
                            _df_import["_nom"]  = pd.to_numeric(
                                _df_import[_map_nom].astype(str).str.replace(r"[^0-9\.\-]","",regex=True),
                                errors="coerce"
                            ).abs()

                            # Filter
                            _df_import = _df_import.dropna(subset=["_tgl","_nom"])
                            _df_import = _df_import[_df_import["_nom"] >= _min_nominal]
                            _df_import = _df_import[_df_import["_desk"].str.len() > 0]

                            if _df_import.empty:
                                st.warning("⚠️ Tidak ada baris yang valid setelah filter.")
                            else:
                                st.session_state.csv_import_df = _df_import[["_tgl","_desk","_nom"]].copy()
                                st.session_state.csv_import_mapping = {
                                    "kat": _import_kat, "sft": _import_sft,
                                    "wlt": _import_wlt
                                }
                                st.session_state.csv_import_preview = True

                        except Exception as _ie:
                            st.error(f"❌ Error saat parsing: {_ie}")

                if st.session_state.csv_import_preview and st.session_state.csv_import_df is not None:
                    _df_prev = st.session_state.csv_import_df
                    st.markdown(f"### ✅ Preview Import — {len(_df_prev)} transaksi")

                    _prev_show = _df_prev.copy()
                    _prev_show.columns = ["Tanggal","Deskripsi","Nominal (Rp)"]
                    _prev_show["Nominal (Rp)"] = _prev_show["Nominal (Rp)"].apply(lambda x: f"Rp {x:,.0f}")
                    st.dataframe(_prev_show.head(20), use_container_width=True, hide_index=True)

                    if len(_df_prev) > 20:
                        st.caption(f"... dan {len(_df_prev)-20} baris lainnya.")

                    _total_nominal_imp = _df_prev["_nom"].sum()
                    st.markdown(f"**Total Nominal: {rp(_total_nominal_imp)}** | Kategori: `{_import_kat}` | Sifat: `{_import_sft}`")

                    _imp_col1, _imp_col2 = st.columns(2)
                    with _imp_col1:
                        if st.button("⬆️ Import Sekarang!", use_container_width=True, key="btn_do_import", type="primary"):
                            _imp_map  = st.session_state.csv_import_mapping
                            _wid_imp  = None
                            _wlt_imp  = _imp_map["wlt"]
                            if _wlt_imp != "— Tanpa Wallet —":
                                _wl_list = st.session_state.wallets
                                _wl_opts = [f"{w['tipe']} {w['nama']}" for w in _wl_list]
                                if _wlt_imp in _wl_opts:
                                    _wid_imp = _wl_list[_wl_opts.index(_wlt_imp)]["id"]

                            _ok_imp = 0; _fail_imp = 0
                            _progress = st.progress(0)
                            _total_rows = len(_df_prev)
                            for _ri, _rrow in _df_prev.iterrows():
                                try:
                                    _wt_imp = TZ.localize(
                                        datetime(_rrow["_tgl"].year, _rrow["_tgl"].month, _rrow["_tgl"].day, 12, 0)
                                    ).astimezone(pytz.UTC).isoformat()
                                    _pl_imp = {
                                        "user_id":   uid,
                                        "catatan":   str(_rrow["_desk"])[:200],
                                        "nominal":   int(_rrow["_nom"]),
                                        "kategori":  _imp_map["kat"],
                                        "sifat":     _imp_map["sft"],
                                        "waktu_transaksi": _wt_imp
                                    }
                                    if _wid_imp: _pl_imp["wallet_id"] = _wid_imp
                                    supabase.table("transaksi").insert(_pl_imp).execute()
                                    _ok_imp += 1
                                except Exception: _fail_imp += 1
                                _progress.progress((_ok_imp + _fail_imp) / _total_rows)

                            st.cache_data.clear()
                            st.session_state.csv_import_df      = None
                            st.session_state.csv_import_preview = False
                            st.session_state.tx_show_count      = 5
                            if _ok_imp > 0:
                                st.success(f"✅ **{_ok_imp} transaksi** berhasil diimport!")
                            if _fail_imp > 0:
                                st.warning(f"⚠️ {_fail_imp} baris gagal diimport.")
                            st.rerun()
                    with _imp_col2:
                        if st.button("❌ Batal Import", use_container_width=True, key="btn_cancel_import"):
                            st.session_state.csv_import_df      = None
                            st.session_state.csv_import_preview = False; st.rerun()

        except Exception as _csv_e:
            st.error(f"❌ Error membaca file: {_csv_e}")
    else:
        st.markdown("""
        <div style="background:#1e293b;border-radius:14px;padding:2rem;text-align:center;
                    border:2px dashed #475569;margin:1rem 0;">
            <div style="font-size:2.5rem;">📂</div>
            <div style="font-size:1rem;color:#94a3b8;margin-top:0.5rem;">Upload file CSV mutasi bank di atas</div>
            <div style="font-size:0.82rem;color:#64748b;margin-top:0.3rem;">
                Format didukung: CSV dari BCA, Mandiri, BNI, BRI, CIMB, dll.
            </div>
        </div>
        """, unsafe_allow_html=True)


# ============================================================
# TAB 8 — CUSTOM KATEGORI
# ============================================================
with _t8:
    st.markdown("#### 🏷️ Custom Kategori")
    st.caption("Tambah kategori pengeluaran atau pemasukan sesuai kebutuhanmu.")

    _ck_t1, _ck_t2 = st.tabs(["📤 Pengeluaran","📥 Pemasukan"])

    for _ck_tab, _ck_tipe, _ck_list_key, _ck_default in [
        (_ck_t1, "pengeluaran", "custom_kat_pglr", KATEGORI_PENGELUARAN_DEFAULT),
        (_ck_t2, "pemasukan",   "custom_kat_msuk", KATEGORI_PEMASUKAN_DEFAULT)
    ]:
        with _ck_tab:
            st.markdown(f"**Kategori Default {_ck_tipe.title()}:**")
            _def_chips = "".join([
                f'<span style="display:inline-block;background:#1e293b;border:1px solid #475569;'
                f'border-radius:20px;padding:3px 12px;font-size:0.82rem;margin:3px;">'
                f'{k}</span>' for k in _ck_default
            ])
            st.markdown(_def_chips, unsafe_allow_html=True)

            st.markdown("---")
            st.markdown(f"**Kategori Custom Kamu:**")
            _cust_list = st.session_state[_ck_list_key]
            if _cust_list:
                for _ck in _cust_list:
                    _ckc1, _ckc2 = st.columns([5,1])
                    with _ckc1:
                        st.markdown(
                            f'<span style="display:inline-block;background:#1e293b;border:1.5px solid #4ade80;'
                            f'border-radius:20px;padding:3px 12px;font-size:0.88rem;margin:3px;">'
                            f'{_ck.get("ikon","📌")} {_ck["nama"]}</span>',
                            unsafe_allow_html=True)
                    with _ckc2:
                        if st.button("🗑️", key=f"del_ck_{_ck['id']}"):
                            if hapus_custom_kat(uid, _ck["id"]):
                                st.session_state.muat_custom_kat_sukses = False
                                muat_custom_kat(uid, True); st.rerun()
            else:
                st.info(f"Belum ada kategori {_ck_tipe} custom.")

            st.markdown("---")
            with st.form(f"frm_ck_{_ck_tipe}"):
                _ck1,_ck2 = st.columns([4,1])
                _new_kat_nama = _ck1.text_input(f"Nama kategori baru ({_ck_tipe}):",
                    placeholder=f"Contoh: {'Snack Mingguan' if _ck_tipe=='pengeluaran' else 'Dividen Saham'}")
                _new_kat_ikon = _ck2.text_input("Ikon:", value="📌",
                    help="Copy paste emoji apapun")
                if st.form_submit_button(f"➕ Tambah Kategori {_ck_tipe.title()}", use_container_width=True):
                    if not _new_kat_nama.strip():
                        st.error("Nama kategori tidak boleh kosong.")
                    elif _new_kat_nama.strip() in _ck_default:
                        st.warning("Kategori ini sudah ada di daftar default.")
                    elif any(k["nama"] == _new_kat_nama.strip() for k in _cust_list):
                        st.warning("Kategori ini sudah ada.")
                    else:
                        if simpan_custom_kat(uid, _new_kat_nama.strip(), _ck_tipe, _new_kat_ikon.strip() or "📌"):
                            st.session_state.muat_custom_kat_sukses = False
                            muat_custom_kat(uid, True)
                            st.success(f"✅ Kategori '{_new_kat_nama.strip()}' ditambahkan!"); st.rerun()


# ============================================================
# TAB 9 — VISUALISASI (termasuk Heatmap Kalender)
# ============================================================
with _t9:
    st.markdown("#### 📊 Grafik & Perbandingan")
    _vt1,_vt2,_vt3,_vt4 = st.tabs(["📈 Tren","🥧 Kategori","↔️ Komparatif","📅 Kalender Heatmap"])

    with _vt1:
        _vc1,_vc2 = st.columns(2)
        with _vc1:
            st.markdown("**Tren Pengeluaran**")
            if not df.empty:
                _dft = df.groupby(["tahun","bulan"])["nominal"].sum().reset_index()
                st.altair_chart(
                    alt.Chart(_dft).mark_line(point=True,color="#E53935").encode(
                        x=alt.X("bulan:N",sort=list(KAMUS_BULAN.values()),title="Bulan"),
                        y=alt.Y("nominal:Q",title="Total (Rp)"),
                        tooltip=["bulan","tahun","nominal"]
                    ).properties(height=260), use_container_width=True)
            else: st.write("Belum ada data.")
        with _vc2:
            st.markdown("**Tren Pemasukan**")
            if not df_pm.empty:
                _dftp = df_pm.groupby(["tahun","bulan"])["nominal"].sum().reset_index()
                st.altair_chart(
                    alt.Chart(_dftp).mark_line(point=True,color="#2E7D32").encode(
                        x=alt.X("bulan:N",sort=list(KAMUS_BULAN.values()),title="Bulan"),
                        y=alt.Y("nominal:Q",title="Total (Rp)"),
                        tooltip=["bulan","tahun","nominal"]
                    ).properties(height=260), use_container_width=True)
            else: st.write("Belum ada data pemasukan.")

        st.markdown("**Net Cash Flow Bulanan**")
        if not df.empty or not df_pm.empty:
            _dfo = df.groupby(["tahun","bulan"])["nominal"].sum().reset_index().rename(columns={"nominal":"pengeluaran"}) if not df.empty else pd.DataFrame(columns=["tahun","bulan","pengeluaran"])
            _dfi = df_pm.groupby(["tahun","bulan"])["nominal"].sum().reset_index().rename(columns={"nominal":"pemasukan"}) if not df_pm.empty else pd.DataFrame(columns=["tahun","bulan","pemasukan"])
            _dfcf = pd.merge(_dfo,_dfi,on=["tahun","bulan"],how="outer").fillna(0)
            _dfcf["net"]    = _dfcf["pemasukan"]-_dfcf["pengeluaran"]
            _dfcf["status"] = _dfcf["net"].apply(lambda x:"Surplus" if x>=0 else "Defisit")
            st.altair_chart(
                alt.Chart(_dfcf).mark_bar().encode(
                    x=alt.X("bulan:N",sort=list(KAMUS_BULAN.values()),title="Bulan"),
                    y=alt.Y("net:Q",title="Net (Rp)"),
                    color=alt.Color("status:N",scale=alt.Scale(domain=["Surplus","Defisit"],range=["#2E7D32","#E53935"])),
                    tooltip=["bulan","tahun","pemasukan","pengeluaran","net"]
                ).properties(height=230), use_container_width=True)

    with _vt2:
        _vc3,_vc4 = st.columns(2)
        with _vc3:
            st.markdown("**Porsi Kategori Pengeluaran**")
            if not _dfv.empty:
                st.altair_chart(
                    alt.Chart(_dfv).mark_arc(innerRadius=40).encode(
                        theta=alt.Theta(field="nominal",type="quantitative"),
                        color=alt.Color(field="kategori",type="nominal",scale=alt.Scale(scheme="accent")),
                        tooltip=["kategori","nominal"]
                    ).properties(height=270), use_container_width=True)
            else: st.write("Tidak ada data.")
        with _vc4:
            st.markdown("**Wajib vs Sukarela**")
            if not _dfv.empty:
                _ds = _dfv.groupby("sifat")["nominal"].sum().reset_index()
                st.altair_chart(
                    alt.Chart(_ds).mark_arc(innerRadius=40).encode(
                        theta=alt.Theta(field="nominal",type="quantitative"),
                        color=alt.Color(field="sifat",type="nominal",
                                        scale=alt.Scale(domain=["Wajib","Sukarela"],range=["#1565C0","#FF7043"])),
                        tooltip=["sifat","nominal"]
                    ).properties(height=270), use_container_width=True)
            else: st.write("Tidak ada data.")

    with _vt3:
        st.markdown("**↔️ Perbandingan 2 Bulan**")
        if not df.empty:
            _ba = list(df["bulan"].unique())
            _ta = sorted(df["tahun"].unique().tolist())
            _cc1,_cc2 = st.columns(2)
            with _cc1:
                _bla = st.selectbox("Bulan A",_ba,index=0,key="cmp_a")
                _tha = st.selectbox("Tahun A",_ta,index=0,key="cmp_ta")
            with _cc2:
                _blb = st.selectbox("Bulan B",_ba,index=min(1,len(_ba)-1),key="cmp_b")
                _thb = st.selectbox("Tahun B",_ta,index=0,key="cmp_tb")
            if _bla==_blb and _tha==_thb:
                st.warning("⚠️ Pilih periode yang berbeda.")
            else:
                _dfa = df[(df["bulan"]==_bla)&(df["tahun"]==_tha)]
                _dfb = df[(df["bulan"]==_blb)&(df["tahun"]==_thb)]
                _la  = f"{_bla} {_tha} (A)"; _lb = f"{_blb} {_thb} (B)"
                _ka2 = _dfa.groupby("kategori")["nominal"].sum().rename(_la)
                _kb2 = _dfb.groupby("kategori")["nominal"].sum().rename(_lb)
                _dcmp = pd.concat([_ka2,_kb2],axis=1).fillna(0).reset_index()
                _dcmp.columns = ["Kategori",_la,_lb]
                _dcmp["Selisih"] = _dcmp[_lb].astype(float)-_dcmp[_la].astype(float)
                _ta2=_dfa["nominal"].sum(); _tb2=_dfb["nominal"].sum()
                _mm2=st.columns(3)
                _mm2[0].metric(f"Total {_bla}",rp(_ta2))
                _mm2[1].metric(f"Total {_blb}",rp(_tb2),delta=rp(_tb2-_ta2),delta_color="inverse")
                _mm2[2].metric("Selisih",rp(abs(_tb2-_ta2)),
                    delta="Lebih Hemat" if _tb2<_ta2 else "Lebih Boros",
                    delta_color="normal" if _tb2<=_ta2 else "inverse")
                _melt2 = _dcmp.melt(id_vars="Kategori",value_vars=[_la,_lb],var_name="Periode",value_name="Nominal")
                st.altair_chart(
                    alt.Chart(_melt2).mark_bar().encode(
                        x=alt.X("Kategori:N",title=""),
                        y=alt.Y("Nominal:Q",title="Nominal (Rp)"),
                        color=alt.Color("Periode:N",scale=alt.Scale(range=["#1565C0","#FF7043"])),
                        xOffset="Periode:N",tooltip=["Kategori","Periode","Nominal"]
                    ).properties(height=290), use_container_width=True)
                st.dataframe(_dcmp, use_container_width=True, hide_index=True)
        else: st.info("Belum ada data untuk dibandingkan.")

    with _vt4:
        st.markdown("**📅 Kalender Heatmap Pengeluaran**")
        st.caption("Warna menunjukkan intensitas pengeluaran per hari. Hover untuk melihat nominal.")

        if not df.empty:
            _hm_thn_list = sorted(df["tahun"].unique().tolist())
            _hm_c1, _hm_c2 = st.columns(2)
            _hm_thn  = _hm_c1.selectbox("Tahun:", _hm_thn_list, index=len(_hm_thn_list)-1, key="hm_thn")
            _hm_bulan_list = sorted(df[df["tahun"]==_hm_thn]["waktu_transaksi"].dt.month.unique().tolist())
            _hm_bln  = _hm_c2.selectbox("Bulan:", [KAMUS_BULAN[m] for m in _hm_bulan_list],
                                          index=len(_hm_bulan_list)-1, key="hm_bln")
            _hm_bln_idx = [k for k,v in KAMUS_BULAN.items() if v==_hm_bln][0]
            _df_hm   = df[(df["tahun"]==_hm_thn)&(df["waktu_transaksi"].dt.month==_hm_bln_idx)].copy()

            # Statistik bulan ini
            _hm_total  = _df_hm["nominal"].sum()
            _hm_hari   = _df_hm["waktu_transaksi"].dt.date.nunique()
            _hm_avg    = _hm_total / _hm_hari if _hm_hari > 0 else 0
            _hm_max_day = None
            if not _df_hm.empty:
                _daily_grp  = _df_hm.groupby(_df_hm["waktu_transaksi"].dt.day)["nominal"].sum()
                _hm_max_day = _daily_grp.idxmax()
                _hm_max_val = _daily_grp.max()

            _hm_mc1,_hm_mc2,_hm_mc3 = st.columns(3)
            _hm_mc1.metric("Total Bulan", rp(_hm_total))
            _hm_mc2.metric("Hari Aktif", f"{_hm_hari} hari")
            _hm_mc3.metric("Rata-rata/Hari", rp(_hm_avg))

            if _hm_max_day:
                st.caption(f"🔴 Pengeluaran tertinggi: tanggal **{_hm_max_day}** ({rp(_hm_max_val)})")

            st.markdown(f"#### {_hm_bln} {_hm_thn}")
            _hm_html = render_heatmap(_df_hm, _hm_bln_idx, _hm_thn)
            st.markdown(_hm_html, unsafe_allow_html=True)

            # Top 5 hari terboros
            if not _df_hm.empty:
                st.markdown("**Top 5 Hari Terboros:**")
                _top5 = _df_hm.groupby(_df_hm["waktu_transaksi"].dt.day)["nominal"].sum()\
                               .nlargest(5).reset_index()
                _top5.columns = ["Tanggal","Total (Rp)"]
                _top5["Tanggal"] = _top5["Tanggal"].apply(lambda d: f"{d} {_hm_bln} {_hm_thn}")
                st.dataframe(_top5, use_container_width=True, hide_index=True)
        else:
            st.info("Belum ada data transaksi untuk ditampilkan dalam kalender.")


# ============================================================
# TAB 10 — ANALISIS AI
# ============================================================
with _t10:
    st.markdown("#### 🧠 Analisis AI Cerdas")
    if not _dfv.empty:
        st.markdown("##### 📈 Tren Historis")
        if not df.empty and _pil_bln!="Semua Bulan":
            _dl = df[~((df["bulan"]==_pil_bln)&(df["tahun"]==_pil_thn))]
            if not _dl.empty:
                _rt = _dl.groupby(["tahun","bulan"])["nominal"].sum().mean()
                if _tot_pglr>_rt:
                    st.error(f"📈 Lebih tinggi {rp(_tot_pglr-_rt)} dari rata-rata historis. "
                             f"Penyumbang terbesar: **{_dfv.groupby('kategori')['nominal'].sum().idxmax()}**.")
                else:
                    st.success(f"📉 Lebih hemat {rp(_rt-_tot_pglr)} dari rata-rata historis.")
            else: st.info("Belum ada data historis.")
        else: st.info("Pilih bulan tertentu untuk perbandingan historis.")

        st.markdown("##### ⏰ Deteksi Waktu Rawan")
        if "jam" in _dfv.columns:
            _ml = _dfv[(_dfv["jam"]>=20)|(_dfv["jam"]<=5)]
            if not _ml.empty:
                st.warning(f"🌙 Belanja malam/dini hari: {rp(_ml['nominal'].sum())} — waspadai impulsive buying.")
            else:
                st.success("✅ Tidak ada transaksi di jam rawan.")

        st.markdown("##### ⚖️ Porsi Pengeluaran")
        if _bud>0:
            _ps = (_sukarela/_bud)*100
            (st.error if _ps>50 else st.info)(
                f"{'💸 Porsi sukarela terlalu besar' if _ps>50 else '💡 Porsi sukarela terkendali'} "
                f"({_ps:.1f}% anggaran).")

        st.markdown("##### 🎯 Evaluasi Target Tabungan")
        if _tgt>0:
            if _tot_pglr<=_bts:
                st.success(f"✅ Target tercapai! Masih ada ruang {rp(_bts-_tot_pglr)}.")
            else:
                _kr = _tot_pglr-_bts
                st.error(f"🚨 Target terancam! Melebihi batas {rp(_kr)}.")
                _dsuka = _dfv[_dfv["sifat"]=="Sukarela"]
                if not _dsuka.empty:
                    _sisa_k=_kr
                    for _k3,_t3 in _dsuka.groupby("kategori")["nominal"].sum().sort_values(ascending=False).items():
                        if _sisa_k<=0: break
                        _pt=min(_t3,_sisa_k)
                        st.info(f"➖ Kurangi **{_k3}** sebesar **{rp(_pt)}**")
                        _sisa_k-=_pt
        else: st.info("📌 Belum ada target tabungan.")

        st.markdown("##### 🎯 Rekomendasi Umum")
        _tp = _dfv.groupby("kategori")["nominal"].sum().idxmax()
        _np = _dfv[_dfv["kategori"]==_tp]["nominal"].sum()
        if int(_np*0.2)>0:
            st.info(f"➔ Kurangi 20% dari **{_tp}** (~{rp(_np*0.2)}) untuk penghematan signifikan.")
        if _bud>0 and _sisa_ang<0:
            st.info("➔ Anggaran tekor. Alokasikan dana darurat di awal bulan depan.")

        st.markdown("---")
        st.markdown("##### 🏅 Badges")
        _bdgs = cek_badges(df if not df.empty else pd.DataFrame(),
                            st.session_state.anggaran_terkunci,
                            st.session_state.target_tabungan)
        if _bdgs:
            _bh = "".join([f'<span style="display:inline-block;background:linear-gradient(135deg,#FFD700,#FFA500);'
                            f'border-radius:50px;padding:0.3rem 0.8rem;font-size:0.85rem;font-weight:600;'
                            f'margin:0.2rem;color:#1a1a1a;" title="{_d}">{_i} {_n}</span>'
                            for _i,_n,_d in _bdgs])
            st.markdown(_bh, unsafe_allow_html=True)
            for _i,_n,_d in _bdgs: st.caption(f"{_i} **{_n}**: {_d}")
        else:
            st.info("Belum ada badge. Terus catat transaksi!")

        st.markdown("---")
        st.markdown("##### 📄 Ekspor PDF")
        if PDF_AVAILABLE:
            if st.button("🖨️ Buat Laporan PDF"):
                with st.spinner("Membuat laporan..."):
                    _pb = buat_pdf(email_user,_pil_bln,_pil_thn,_dfv,_dfpv,
                                    _bud,_tgt,_tot_pglr,_tot_msuk,_hs,_ls)
                    if _pb:
                        st.download_button("📥 Unduh PDF", _pb,
                            f"DanaPintar_{_pil_bln}_{_pil_thn}.pdf","application/pdf")
        else:
            st.warning("Install `fpdf2` untuk PDF: `pip install fpdf2`")
    else:
        st.info("Tidak ada data transaksi untuk dianalisis.")


# ============================================================
# TAB 11 — CHAT AI
# ============================================================
with _t11:
    st.markdown("#### 🤖 DanaBot — AI Keuangan Pribadi")
    st.caption("✨ Powered by Google Gemini 2.5 Flash (Free Tier)")

    _ai_ok = GEMINI_AVAILABLE and GEMINI_API_KEY is not None
    if not _ai_ok:
        st.warning("⚠️ Tambahkan `GEMINI_API_KEY` ke `.streamlit/secrets.toml` dan install `google-generativeai`.")
    else:
        for _msg in st.session_state.chat_history:
            with st.chat_message(_msg["role"], avatar="🤖" if _msg["role"]=="assistant" else "👤"):
                st.markdown(_msg["content"])

        if _pr7 := st.chat_input("Tanya soal keuanganmu..."):
            st.session_state.chat_history.append({"role":"user","content":_pr7})
            with st.chat_message("user",avatar="👤"): st.markdown(_pr7)

            _kd7=""
            if not _dfv.empty:
                _kd7="\nPengeluaran per kategori:\n"+"".join(
                    f"  - {k}: {rp(v)}\n" for k,v in _dfv.groupby("kategori")["nominal"].sum().items())

            _goals_sum = ""
            if st.session_state.financial_goals:
                _goals_sum = "\nFinancial Goals:\n"+"".join(
                    f"  - {g['nama']}: {rp(g.get('terkumpul',0))}/{rp(g['target_nominal'])} ({g.get('terkumpul',0)/g['target_nominal']*100:.0f}%)\n"
                    for g in st.session_state.financial_goals)

            _sys7=f"""Kamu adalah DanaBot, asisten keuangan pribadi dari DanaPintar AI.
Bantu pengguna Indonesia menganalisis keuangan dengan bahasa ramah dan saran actionable.
Jangan mengarang data.

DATA KEUANGAN:
Periode: {_pil_bln} {_pil_thn}
Anggaran: {rp(_bud)} | Pemasukan: {rp(_tot_msuk)} | Pengeluaran: {rp(_tot_pglr)}
Target Tabungan: {rp(_tgt)} | Net Cash Flow: {rp(_net)}
Health Score: {_hs}/100 ({_ls}){_kd7}{_goals_sum}"""

            with st.chat_message("assistant",avatar="🤖"):
                with st.spinner("DanaBot berpikir..."):
                    try:
                        genai.configure(api_key=GEMINI_API_KEY)
                        _gh = [{"role":"user" if m["role"]=="user" else "model","parts":[m["content"]]}
                                for m in st.session_state.chat_history[:-1]]
                        _mdl = genai.GenerativeModel("gemini-2.5-flash",system_instruction=_sys7)
                        _rs  = _mdl.start_chat(history=_gh).send_message(_pr7)
                        _jaw = _rs.text
                        st.markdown(_jaw)
                        st.session_state.chat_history.append({"role":"assistant","content":_jaw})
                    except Exception as _e:
                        _em=f"Maaf, terjadi error: {_e}"
                        st.error(_em)
                        st.session_state.chat_history.append({"role":"assistant","content":_em})

        if st.session_state.chat_history:
            if st.button("🗑️ Reset Percakapan", key="rst_chat"):
                st.session_state.chat_history=[]; st.rerun()


# ============================================================
# TAB 12 — LAPORAN VISUAL (PNG / JPEG / PDF)
# ============================================================
with _t12:
    st.markdown("#### 📄 Laporan Keuangan Visual")
    st.caption("Generate laporan keuangan dalam format gambar atau PDF — siap share ke WA atau disimpan.")

    # ── Guard: require matplotlib ──
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import matplotlib.patches as _mpatches
        from matplotlib.patches import FancyBboxPatch as _FBP
        import matplotlib.patheffects as _mpe
        import matplotlib.colors as _mcolors
        from matplotlib.colors import LinearSegmentedColormap as _LSC
        import numpy as _np
        from PIL import Image as _PILImage
        import io as _io
        _REPORT_OK = True
    except ImportError:
        _REPORT_OK = False

    if not _REPORT_OK:
        st.error("❌ Install `matplotlib` dan `Pillow` untuk fitur laporan:\n`pip install matplotlib pillow`")
    else:
        # ── Pilihan periode laporan ──
        _rep_c1, _rep_c2, _rep_c3 = st.columns(3)
        _rep_bln = _rep_c1.selectbox(
            "Bulan Laporan:",
            list(KAMUS_BULAN.values()),
            index=wib().month - 1,
            key="rep_bln"
        )
        _rep_thn_opts = sorted(df["tahun"].unique().tolist()) if not df.empty else [wib().year]
        _rep_thn = _rep_c2.selectbox(
            "Tahun:",
            _rep_thn_opts,
            index=len(_rep_thn_opts) - 1,
            key="rep_thn"
        )
        _rep_fmt = _rep_c3.selectbox(
            "Format Download:",
            ["PNG (Gambar HD)", "JPEG (Foto, lebih kecil)", "PDF (Dokumen)"],
            key="rep_fmt"
        )

        # ── Ambil data periode yang dipilih ──
        _rep_ke   = f"{_rep_bln}_{_rep_thn}"
        _rep_bud  = st.session_state.anggaran_terkunci.get(_rep_ke, 0)
        _rep_tgt  = st.session_state.target_tabungan.get(_rep_ke, 0)

        if not df.empty:
            _rep_dfv = df[(df["bulan"] == _rep_bln) & (df["tahun"] == _rep_thn)].copy()
        else:
            _rep_dfv = pd.DataFrame()

        if not df_pm.empty:
            _rep_dfpv = df_pm[(df_pm["bulan"] == _rep_bln) & (df_pm["tahun"] == _rep_thn)].copy()
        else:
            _rep_dfpv = pd.DataFrame()

        _rep_tot_pglr = _rep_dfv["nominal"].sum()    if not _rep_dfv.empty  else 0.0
        _rep_tot_msuk = _rep_dfpv["nominal"].sum()   if not _rep_dfpv.empty else 0.0

        # Health score untuk periode ini
        _rep_sukarela = _rep_dfv[_rep_dfv["sifat"] == "Sukarela"]["nominal"].sum() if not _rep_dfv.empty else 0.0
        _rep_hs, _    = health_score(_rep_tot_pglr, _rep_bud, _rep_tgt, _rep_sukarela,
                                      _rep_dfv, df if not df.empty else pd.DataFrame())
        _rep_ls, _, _ = label_hs(_rep_hs)
        _rep_hs_str   = _rep_ls.replace("💚","").replace("💛","").replace("🟠","").replace("🔴","").strip()

        # Kategori data
        if not _rep_dfv.empty:
            _rep_kat_data = _rep_dfv.groupby("kategori")["nominal"].sum().to_dict()
        else:
            _rep_kat_data = {}

        # ── Preview info ──
        _ri1, _ri2, _ri3, _ri4 = st.columns(4)
        _ri1.metric("Pemasukan",    rp(_rep_tot_msuk))
        _ri2.metric("Pengeluaran",  rp(_rep_tot_pglr))
        _ri3.metric("Health Score", f"{_rep_hs}/100")
        _ri4.metric("Kategori",     f"{len(_rep_kat_data)} pos")

        if not _rep_kat_data:
            st.info(f"ℹ️ Belum ada data pengeluaran untuk **{_rep_bln} {_rep_thn}**. Coba pilih periode lain.")

        # ── RENDER FUNCTION (inline, using closure) ──
        def _build_report_figure():
            # ── Palette ──
            _BG     = '#0f172a'
            _BG2    = '#1e293b'
            _BG3    = '#334155'
            _ACC    = '#4ade80'
            _ACC2   = '#16a34a'
            _RED    = '#f87171'
            _BLUE   = '#60a5fa'
            _YEL    = '#fbbf24'
            _PUR    = '#a78bfa'
            _ORG    = '#fb923c'
            _TXT    = '#e2e8f0'
            _TXT2   = '#94a3b8'
            _KAT_C  = {
                'Makanan': _ACC, 'Transportasi': _BLUE,
                'Hiburan/Gaya Hidup': _PUR, 'Kebutuhan Rumah/Kesehatan': _ORG,
                'Tagihan Wajib': _RED, 'Lain-lain': '#64748b',
            }

            def _rp(n):  return f"Rp {n:,.0f}"
            def _ty(y):  return 1.0 - y

            def _rrect(ax, x, y, w, h, r=0.015, fc=_BG2, ec='none', lw=0, alpha=1.0, z=2):
                box = _FBP((x, y), w, h,
                    boxstyle=f"round,pad=0,rounding_size={r}",
                    facecolor=_mcolors.to_rgba(fc, alpha),
                    edgecolor=ec if ec != 'none' else 'none',
                    linewidth=lw,
                    transform=ax.transAxes, clip_on=False, zorder=z)
                ax.add_patch(box)

            def _pbar(ax, x, y, w, h, pct, fc, bc=_BG3, r=0.008, z=3):
                _rrect(ax, x, y, w, h, r=r, fc=bc, z=z)
                fw = max(0.002, min(pct / 100, 1.0)) * w
                _rrect(ax, x, y, fw, h, r=r, fc=fc, z=z + 1)

            cats   = list(_rep_kat_data.keys())
            vals   = [float(_rep_kat_data[c]) for c in cats]
            total  = sum(vals) or 1.0
            c_list = [_KAT_C.get(c, '#64748b') for c in cats]

            net_c  = _ACC if (_rep_tot_msuk - _rep_tot_pglr) >= 0 else _RED
            batas  = max(0.0, _rep_bud - _rep_tgt)
            sisa   = _rep_bud - _rep_tot_pglr
            pct_b  = min(100.0, _rep_tot_pglr / batas * 100) if batas > 0 else 0.0
            pb_clr = _ACC if pct_b < 70 else (_YEL if pct_b < 90 else _RED)
            tab_a  = max(0.0, _rep_tot_msuk - _rep_tot_pglr)
            tab_p  = min(999.0, tab_a / _rep_tgt * 100) if _rep_tgt > 0 else 0.0
            tab_c  = _ACC if tab_p >= 100 else (_YEL if tab_p >= 50 else _RED)
            hs_clr = _ACC if _rep_hs >= 80 else (_YEL if _rep_hs >= 60 else (_ORG if _rep_hs >= 40 else _RED))

            fig = plt.figure(figsize=(10, 17.78), facecolor=_BG)
            fig.patch.set_facecolor(_BG)
            ax  = fig.add_axes([0, 0, 1, 1])
            ax.set_xlim(0, 1); ax.set_ylim(0, 1)
            ax.set_facecolor(_BG); ax.axis('off')

            # ── HEADER ──
            cmap_h = _LSC.from_list('h', ['#1a3a2a', '#0d2a4a', '#0f172a'])
            grad   = _np.linspace(0, 1, 100).reshape(1, -1)
            ax.imshow(grad, aspect='auto', cmap=cmap_h, alpha=0.95,
                      extent=[0, 1, _ty(0.11), 1], transform=ax.transAxes, zorder=0)
            ax.text(0.055, _ty(0.038), 'DanaPintar AI',
                    color=_ACC, fontsize=16, fontweight='bold',
                    transform=ax.transAxes, zorder=5,
                    path_effects=[_mpe.withStroke(linewidth=3, foreground='#0a1628')])
            ax.text(0.055, _ty(0.070), 'Laporan Keuangan Bulanan',
                    color=_TXT2, fontsize=8.5, transform=ax.transAxes, zorder=5)
            ax.text(0.055, _ty(0.096), 'Dicetak otomatis oleh DanaPintar AI Premium',
                    color='#475569', fontsize=7, transform=ax.transAxes, zorder=5)
            _rrect(ax, 0.67, _ty(0.096), 0.295, 0.066, r=0.012, fc='#15803d', z=4)
            ax.text(0.815, _ty(0.061), f"{_rep_bln} {_rep_thn}",
                    color='white', fontsize=11, fontweight='bold',
                    ha='center', transform=ax.transAxes, zorder=5)
            ax.axhline(_ty(0.11), color=_ACC2, linewidth=2, alpha=0.5, zorder=3)

            # ── USER + HEALTH SCORE ──
            _pr_u  = st.session_state.profil
            _nmu   = _pr_u.get("nama","").strip() or email_user.split("@")[0].title()
            ax.text(0.055, _ty(0.118), _nmu,
                    color=_TXT, fontsize=12, fontweight='bold', transform=ax.transAxes, zorder=3)
            ax.text(0.055, _ty(0.144), email_user,
                    color=_TXT2, fontsize=8, transform=ax.transAxes, zorder=3)
            _rrect(ax, 0.62, _ty(0.166), 0.34, 0.048, r=0.014, fc=_BG2, ec=hs_clr, lw=1.5, z=3)
            ax.text(0.640, _ty(0.141), 'Health Score',
                    color=_TXT2, fontsize=7, transform=ax.transAxes, zorder=4)
            ax.text(0.850, _ty(0.138), f"{_rep_hs}/100",
                    color=hs_clr, fontsize=13, fontweight='bold',
                    ha='center', transform=ax.transAxes, zorder=4)
            ax.text(0.815, _ty(0.158), _rep_hs_str,
                    color=hs_clr, fontsize=7.5, fontweight='bold',
                    ha='center', transform=ax.transAxes, zorder=4)
            ax.axhline(_ty(0.180), color=_BG3, linewidth=1, alpha=0.7)

            # ── SUMMARY CARDS ──
            _cards = [
                ('Pemasukan',    _rp(_rep_tot_msuk),                    _ACC,  '#0d2a1a'),
                ('Pengeluaran',  _rp(_rep_tot_pglr),                    _RED,  '#2a0d0d'),
                ('Anggaran',     _rp(_rep_bud),                         _BLUE, '#0d1a2a'),
                ('Net Cashflow', _rp(_rep_tot_msuk - _rep_tot_pglr),    net_c, '#0d2a1a' if (_rep_tot_msuk - _rep_tot_pglr) >= 0 else '#2a0d0d'),
            ]
            for i, (lbl, val, clr, bg) in enumerate(_cards):
                col = i % 2; row = i // 2
                cx  = 0.05 + col * (0.435 + 0.068)
                cy  = 0.200 + row * (0.090 + 0.018)
                _rrect(ax, cx, _ty(cy + 0.090), 0.435, 0.090, r=0.016, fc=bg, ec=clr, lw=1.2, z=3)
                _rrect(ax, cx + 0.008, _ty(cy + 0.015), 0.419, 0.003, r=0.002, fc=clr, z=4)
                ax.text(cx + 0.025, _ty(cy + 0.090*0.38), lbl,
                        color=_TXT2, fontsize=7.5, transform=ax.transAxes, zorder=4)
                ax.text(cx + 0.025, _ty(cy + 0.090*0.75), val,
                        color=clr, fontsize=11.5, fontweight='bold', transform=ax.transAxes, zorder=4)

            # ── BUDGET PROGRESS BAR ──
            ax.text(0.055, _ty(0.430), 'Realisasi Anggaran Belanja',
                    color=_TXT2, fontsize=8, transform=ax.transAxes)
            ax.text(0.945, _ty(0.430), f"{pct_b:.0f}%",
                    color=pb_clr, fontsize=9, fontweight='bold',
                    ha='right', transform=ax.transAxes)
            _pbar(ax, 0.055, _ty(0.456), 0.89, 0.017, pct_b, fc=pb_clr)
            ax.text(0.055, _ty(0.474),
                    f"Batas {_rp(batas)}  ·  Sisa {_rp(sisa)}  ·  Target tabungan {_rp(_rep_tgt)}",
                    color='#64748b', fontsize=7, transform=ax.transAxes)
            ax.axhline(_ty(0.492), color=_BG3, linewidth=1, alpha=0.7)

            # ── BREAKDOWN TITLE ──
            ax.text(0.055, _ty(0.504), 'Breakdown Pengeluaran',
                    color=_TXT, fontsize=11, fontweight='bold', transform=ax.transAxes)
            ax.text(0.055, _ty(0.530), f"Total {_rp(total)} untuk {len(cats)} kategori",
                    color=_TXT2, fontsize=8, transform=ax.transAxes)

            if cats:
                # ── PIE CHART ──
                pie_ax = fig.add_axes([0.03, 1 - 0.810, 0.38, 0.26])
                pie_ax.set_facecolor(_BG)
                pie_ax.set_aspect('equal')
                wedges, _ = pie_ax.pie(
                    vals, colors=c_list,
                    wedgeprops=dict(width=0.42, edgecolor=_BG, linewidth=2.5),
                    startangle=90, counterclock=False)
                pie_ax.pie(vals,
                    colors=[c+'44' for c in c_list],
                    wedgeprops=dict(width=0.04, edgecolor='none'),
                    startangle=90, counterclock=False, radius=1.08)
                pie_ax.text(0,  0.07, _rp(total), color=_TXT, fontsize=9, fontweight='bold', ha='center')
                pie_ax.text(0, -0.14, 'Total',    color=_TXT2, fontsize=7.5, ha='center')

                # ── BAR CHART ──
                bar_ax = fig.add_axes([0.44, 1 - 0.820, 0.54, 0.27])
                bar_ax.set_facecolor(_BG)
                sidx   = _np.argsort(vals)
                sv     = [vals[i] for i in sidx]
                sc     = [c_list[i] for i in sidx]
                sn     = [cats[i] for i in sidx]
                sp     = [v / total * 100 for v in sv]
                mx_v   = max(sv) or 1
                for j, (v, clr_j, n_j, p_j) in enumerate(zip(sv, sc, sn, sp)):
                    bar_ax.barh(j, mx_v * 1.3, color=_BG3, height=0.55, alpha=0.5, edgecolor='none', zorder=1)
                    bar_ax.barh(j, v, color=clr_j, height=0.55, alpha=0.88, edgecolor='none', zorder=2)
                    bar_ax.text(v + mx_v * 0.04, j,
                                f"Rp {v/1e3:.0f}k  {p_j:.0f}%",
                                va='center', color=clr_j, fontsize=7, fontweight='bold', zorder=3)
                bar_ax.set_yticks(_np.arange(len(sn)))
                bar_ax.set_yticklabels([n.split('/')[0][:13] for n in sn], fontsize=7, color=_TXT2)
                bar_ax.tick_params(left=False, bottom=False)
                bar_ax.set_xlim(0, mx_v * 1.7)
                bar_ax.set_ylim(-0.5, len(cats) - 0.5)
                bar_ax.xaxis.set_visible(False)
                for sp_ in bar_ax.spines.values(): sp_.set_visible(False)
                bar_ax.set_facecolor(_BG)

                # ── DETAIL LIST ──
                y_list = 0.820
                ax.axhline(_ty(y_list - 0.008), color=_BG3, linewidth=1, alpha=0.6)
                ax.text(0.055, _ty(y_list + 0.012), 'Detail per Kategori',
                        color=_TXT2, fontsize=8, fontweight='bold', transform=ax.transAxes)
                sidx_d = _np.argsort(vals)[::-1]
                for j, i in enumerate(sidx_d):
                    cat_j = cats[i]; val_j = vals[i]; clr_j = c_list[i]
                    pct_j = val_j / total * 100
                    ry    = y_list + 0.038 + j * 0.046
                    _rrect(ax, 0.055, _ty(ry + 0.036), 0.89, 0.038, r=0.008, fc=_BG2, z=2)
                    dot   = plt.Circle((0.08, _ty(ry + 0.018)), 0.010,
                                       color=clr_j, transform=ax.transAxes, zorder=4, alpha=0.9)
                    ax.add_patch(dot)
                    ax.text(0.105, _ty(ry + 0.015), cat_j,
                            color=_TXT, fontsize=8, transform=ax.transAxes, zorder=4)
                    _rrect(ax, 0.53, _ty(ry + 0.030), 0.09, 0.026, r=0.006, fc=clr_j+'33', z=3)
                    ax.text(0.575, _ty(ry + 0.017), f"{pct_j:.1f}%",
                            color=clr_j, fontsize=7.5, fontweight='bold',
                            ha='center', transform=ax.transAxes, zorder=4)
                    ax.text(0.93, _ty(ry + 0.015), _rp(val_j),
                            color=_TXT, fontsize=8.5, fontweight='bold',
                            ha='right', transform=ax.transAxes, zorder=4)
                    _pbar(ax, 0.105, _ty(ry + 0.034), 0.40, 0.007, pct_j, fc=clr_j, bc=_BG3, r=0.004)

                # ── TABUNGAN CARD ──
                y_tab = y_list + 0.038 + len(cats) * 0.046 + 0.020
                ax.axhline(_ty(y_tab - 0.008), color=_BG3, linewidth=1, alpha=0.6)
                _rrect(ax, 0.055, _ty(y_tab + 0.068), 0.89, 0.068,
                       r=0.014, fc='#0d2a1a', ec=_ACC2, lw=1.2, z=3)
                _rrect(ax, 0.055, _ty(y_tab + 0.068), 0.012, 0.068, r=0.008, fc=_ACC2, z=4)
                ax.text(0.09, _ty(y_tab + 0.022), 'Tabungan Bulan Ini',
                        color=_ACC, fontsize=9, fontweight='bold', transform=ax.transAxes, zorder=4)
                ax.text(0.09, _ty(y_tab + 0.048),
                        f"{_rp(tab_a)}  dari target  {_rp(_rep_tgt)}",
                        color=_TXT2, fontsize=8, transform=ax.transAxes, zorder=4)
                ax.text(0.90, _ty(y_tab + 0.030), f"{tab_p:.0f}%",
                        color=tab_c, fontsize=18, fontweight='bold',
                        ha='right', transform=ax.transAxes, zorder=4)
                _pbar(ax, 0.09, _ty(y_tab + 0.060), 0.72, 0.010, tab_p, fc=tab_c, bc=_BG3, r=0.004)

                # ── FOOTER ──
                y_foot = y_tab + 0.090
            else:
                # No data — show empty state message
                ax.text(0.5, _ty(0.65), 'Belum ada data pengeluaran',
                        color=_TXT2, fontsize=12, ha='center', transform=ax.transAxes)
                ax.text(0.5, _ty(0.68), f'untuk periode {_rep_bln} {_rep_thn}',
                        color='#475569', fontsize=9, ha='center', transform=ax.transAxes)
                y_foot = 0.72

            ax.axhline(_ty(y_foot), color=_BG3, linewidth=1, alpha=0.6)
            ax.text(0.5, _ty(y_foot + 0.020),
                    'DanaPintar AI Premium  |  Laporan Keuangan Otomatis',
                    color=_TXT2, fontsize=7.5, ha='center', transform=ax.transAxes)
            ax.text(0.5, _ty(y_foot + 0.038),
                    'Dibuat secara otomatis  ·  Bukan pengganti saran keuangan profesional',
                    color='#475569', fontsize=6.5, ha='center', transform=ax.transAxes)
            ax.text(0.5, 0.5, 'DanaPintar AI',
                    color='white', fontsize=60, fontweight='bold',
                    ha='center', va='center', alpha=0.020,
                    rotation=30, transform=ax.transAxes, zorder=0)

            plt.subplots_adjust(left=0, right=1, top=1, bottom=0)
            return fig

        # ── GENERATE BUTTON ──
        if st.button("🎨 Generate Laporan", use_container_width=True, key="btn_gen_report", type="primary"):
            with st.spinner("Membuat laporan visual... ⏳"):
                try:
                    _fig_rep = _build_report_figure()
                    _BG_COL  = '#0f172a'

                    # Buffer untuk tiap format
                    _buf_png = _io.BytesIO()
                    _fig_rep.savefig(_buf_png, format='png', dpi=120, bbox_inches='tight',
                                     facecolor=_BG_COL, pad_inches=0.0)
                    _buf_png.seek(0)

                    _buf_jpg = _io.BytesIO()
                    _pil_img = _PILImage.open(_buf_png).convert('RGB')
                    _pil_img.save(_buf_jpg, 'JPEG', quality=95)
                    _buf_jpg.seek(0)
                    _buf_png.seek(0)  # reset for preview

                    _buf_pdf = _io.BytesIO()
                    _fig_rep.savefig(_buf_pdf, format='pdf', bbox_inches='tight',
                                     facecolor=_BG_COL, pad_inches=0.0)
                    _buf_pdf.seek(0)

                    plt.close(_fig_rep)

                    st.session_state["_report_png"] = _buf_png.read()
                    st.session_state["_report_jpg"] = _buf_jpg.read()
                    st.session_state["_report_pdf"] = _buf_pdf.read()
                    st.session_state["_report_label"] = f"{_rep_bln}_{_rep_thn}"
                    st.success("✅ Laporan berhasil dibuat!")

                except Exception as _re:
                    st.error(f"❌ Gagal generate laporan: {_re}")

        # ── PREVIEW + DOWNLOAD ──
        if st.session_state.get("_report_png"):
            _lbl = st.session_state.get("_report_label", "laporan")
            st.markdown("---")
            st.markdown("**👀 Preview Laporan:**")
            st.image(st.session_state["_report_png"], use_container_width=True,
                     caption=f"Laporan Keuangan {_lbl.replace('_',' ')}")

            st.markdown("**⬇️ Download:**")
            _dl1, _dl2, _dl3 = st.columns(3)
            with _dl1:
                st.download_button(
                    "🖼️ Download PNG",
                    data=st.session_state["_report_png"],
                    file_name=f"DanaPintar_{_lbl}.png",
                    mime="image/png",
                    use_container_width=True, key="dl_png"
                )
            with _dl2:
                st.download_button(
                    "📷 Download JPEG",
                    data=st.session_state["_report_jpg"],
                    file_name=f"DanaPintar_{_lbl}.jpg",
                    mime="image/jpeg",
                    use_container_width=True, key="dl_jpg"
                )
            with _dl3:
                st.download_button(
                    "📄 Download PDF",
                    data=st.session_state["_report_pdf"],
                    file_name=f"DanaPintar_{_lbl}.pdf",
                    mime="application/pdf",
                    use_container_width=True, key="dl_pdf"
                )

            st.caption("💡 PNG/JPEG cocok untuk share WA, Instagram Stories, atau arsip foto. PDF untuk disimpan/dicetak.")

            if st.button("🔄 Reset Laporan", key="btn_reset_report"):
                for _k in ["_report_png","_report_jpg","_report_pdf","_report_label"]:
                    st.session_state.pop(_k, None)
                st.rerun()


# ============================================================
# ============================================================
with _t13:
    st.markdown("#### 📋 Riwayat Update — DanaPintar AI")
    st.caption("Semua perubahan yang dilakukan developer pada aplikasi ini.")

    for _cl in CHANGELOG:
        _is_latest = _cl == CHANGELOG[0]
        _badge = (' <span style="background:#2E7D32;color:white;border-radius:20px;'
                  'padding:2px 10px;font-size:0.75rem;font-weight:600;">LATEST</span>'
                  if _is_latest else "")
        st.markdown(f"""
        <div style="border-left:4px solid {'#2E7D32' if _is_latest else '#94a3b8'};
                    padding:1rem 1.2rem;margin-bottom:1.2rem;border-radius:0 10px 10px 0;
                    background:{'rgba(46,125,50,0.08)' if _is_latest else 'rgba(148,163,184,0.05)'};">
            <div style="font-size:1.1rem;font-weight:700;color:{'#4ade80' if _is_latest else '#e2e8f0'};">
                v{_cl['versi']} {_badge}
            </div>
            <div style="font-size:0.82rem;color:#64748b;margin-bottom:0.6rem;">🗓 {_cl['tanggal']}</div>
        """, unsafe_allow_html=True)
        if _cl["fitur"]:
            st.markdown("**✨ Fitur Baru:**")
            for _f in _cl["fitur"]: st.markdown(f"- {_f}")
        if _cl["perbaikan"]:
            st.markdown("**🔧 Perbaikan:**")
            for _p in _cl["perbaikan"]: st.markdown(f"- {_p}")
        st.markdown("</div>", unsafe_allow_html=True)

    st.markdown("---")
    st.caption("🛠️ DanaPintar AI dikembangkan oleh **Hendrawan Lotanto**")


# ============================================================
# FOOTER
# ============================================================
st.markdown("---")
st.markdown(
    "<p style='text-align:center;color:#2E7D32;font-size:14px;'>"
    "🛠️ Dibangun dengan ❤️ oleh <strong>Hendrawan Lotanto</strong> "
    "— © 2026 DanaPintar AI Premium v4.0"
    "</p>",
    unsafe_allow_html=True
)

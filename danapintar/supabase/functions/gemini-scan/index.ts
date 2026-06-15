// Edge Function: gemini-scan
// Proxy aman ke Gemini Vision untuk membaca struk belanja.
// GEMINI_API_KEY disimpan sebagai secret di server (TIDAK di app).
// Deploy: supabase functions deploy gemini-scan --no-verify-jwt
import 'jsr:@supabase/functions-js/edge-runtime.d.ts';

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

const PROMPT = `Kamu adalah AI pembaca struk belanja Indonesia yang sangat akurat.
Baca gambar/dokumen struk ini dan kembalikan HANYA JSON murni (tanpa markdown):
{
  "berhasil": true,
  "confidence": "tinggi",
  "nama_toko": "Indomaret",
  "tanggal": "2026-05-31",
  "total": 87500,
  "items": [{"nama":"Aqua 600ml","harga":4000,"qty":2}],
  "kategori_saran": "Makanan",
  "nama_transaksi": "Indomaret - Aqua, Indomie",
  "catatan_ai": "Struk terbaca jelas",
  "gagal_alasan": ""
}
Aturan:
- "total": TOTAL AKHIR (sudah diskon & pajak), bukan subtotal.
- "tanggal": format YYYY-MM-DD; jika tidak ada, pakai tanggal hari ini.
- "kategori_saran": salah satu dari Makanan, Transportasi, Hiburan/Gaya Hidup,
  Kebutuhan Rumah/Kesehatan, Tagihan Wajib, Lain-lain.
- "items": maksimal 5 item terbesar.
- Jika gagal, "berhasil": false dan isi "gagal_alasan".
- Kembalikan HANYA JSON.`;

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors });

  try {
    const apiKey = Deno.env.get('GEMINI_API_KEY');
    if (!apiKey) {
      return json({ berhasil: false, gagal_alasan: 'GEMINI_API_KEY belum diset di server.' }, 500);
    }

    const { image_base64, mime_type } = await req.json();
    if (!image_base64 || !mime_type) {
      return json({ berhasil: false, gagal_alasan: 'image_base64 & mime_type wajib diisi.' }, 400);
    }

    const resp = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${apiKey}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [
            {
              parts: [
                { inline_data: { mime_type, data: image_base64 } },
                { text: PROMPT },
              ],
            },
          ],
          generationConfig: { temperature: 0.1 },
        }),
      },
    );

    if (!resp.ok) {
      const t = await resp.text();
      return json({ berhasil: false, gagal_alasan: `Gemini error: ${t.slice(0, 200)}` }, 502);
    }

    const data = await resp.json();
    let raw: string =
      data?.candidates?.[0]?.content?.parts?.[0]?.text?.trim() ?? '';
    if (raw.startsWith('```')) {
      raw = raw.replace(/^```(json)?/i, '').replace(/```$/, '').trim();
    }

    try {
      return json(JSON.parse(raw), 200);
    } catch (_) {
      return json(
        { berhasil: false, confidence: 'rendah', gagal_alasan: 'AI mengembalikan format tak terbaca. Coba foto ulang.' },
        200,
      );
    }
  } catch (e) {
    return json({ berhasil: false, gagal_alasan: `Error: ${String(e).slice(0, 200)}` }, 500);
  }
});

function json(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, 'Content-Type': 'application/json' },
  });
}

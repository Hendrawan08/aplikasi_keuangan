// Edge Function: gemini-chat
// Proxy aman ke Gemini untuk DanaBot (chat keuangan).
// GEMINI_API_KEY disimpan sebagai secret di server (TIDAK di app).
// Deploy: supabase functions deploy gemini-chat --no-verify-jwt
import 'jsr:@supabase/functions-js/edge-runtime.d.ts';

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors });

  try {
    const apiKey = Deno.env.get('GEMINI_API_KEY');
    if (!apiKey) return json({ error: 'GEMINI_API_KEY belum diset di server.' }, 500);

    const { messages, konteks } = await req.json();
    if (!Array.isArray(messages) || messages.length === 0) {
      return json({ error: 'messages wajib diisi.' }, 400);
    }

    const sys = `Kamu adalah DanaBot, asisten keuangan pribadi dari DanaPintar AI.
Bantu pengguna Indonesia menganalisis keuangan dengan bahasa ramah & saran
actionable. Jangan mengarang data.
${konteks ? `\nDATA KEUANGAN PENGGUNA:\n${konteks}` : ''}`;

    // Petakan riwayat ke format Gemini (role 'user' | 'model').
    const contents = (messages as Array<{ role: string; content: string }>).map(
      (m) => ({
        role: m.role === 'assistant' ? 'model' : 'user',
        parts: [{ text: m.content }],
      }),
    );

    const resp = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${apiKey}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          system_instruction: { parts: [{ text: sys }] },
          contents,
        }),
      },
    );

    if (!resp.ok) {
      const t = await resp.text();
      return json({ error: `Gemini error: ${t.slice(0, 200)}` }, 502);
    }

    const data = await resp.json();
    const reply: string =
      data?.candidates?.[0]?.content?.parts?.[0]?.text?.trim() ??
      'Maaf, tidak ada jawaban.';
    return json({ reply }, 200);
  } catch (e) {
    return json({ error: `Error: ${String(e).slice(0, 200)}` }, 500);
  }
});

function json(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, 'Content-Type': 'application/json' },
  });
}

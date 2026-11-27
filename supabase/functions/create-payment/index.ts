import { dokuSign } from "../_shared/doku.ts";

const CLIENT_ID = Deno.env.get("DOKU_CLIENT_ID")!;
const SECRET = Deno.env.get("DOKU_SECRET_KEY")!;
const BASE = Deno.env.get("DOKU_BASE_URL")!;
const cors = { "Access-Control-Allow-Origin": "*", "Access-Control-Allow-Headers": "*" };

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });

  const { invoice_number, amount, name, email } = await req.json();

  const body = JSON.stringify({
  order: {
    amount,
    invoice_number,
    callback_url: "https://example.com",   // ganti kalau sudah punya halaman web
  },
  payment: { payment_due_date: 60 },
  customer: { name, email },
  additional_info: {
    override_notification_url:
      "https://eokrqohaofdiaabpcnyg.supabase.co/functions/v1/doku-notif",
  },
});

  const requestId = crypto.randomUUID();
  const ts = new Date().toISOString().split(".")[0] + "Z";
  const signature = await dokuSign(CLIENT_ID, SECRET, requestId, ts, "/checkout/v1/payment", body);

  const res = await fetch(`${BASE}/checkout/v1/payment`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Client-Id": CLIENT_ID,
      "Request-Id": requestId,
      "Request-Timestamp": ts,
      "Signature": signature,
    },
    body,
  });

  const data = await res.json();
  return new Response(JSON.stringify(data), {
    status: res.status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
});
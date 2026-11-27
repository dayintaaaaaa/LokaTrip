import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const encoder = new TextEncoder();

async function sha512Hex(value: string) {
  const digest = await crypto.subtle.digest("SHA-512", encoder.encode(value));
  return Array.from(new Uint8Array(digest), (byte) => byte.toString(16).padStart(2, "0")).join("");
}

function constantTimeEqual(a: string, b: string) {
  if (a.length !== b.length) return false;
  let difference = 0;
  for (let i = 0; i < a.length; i++) difference |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return difference === 0;
}

Deno.serve(async (req) => {
  if (req.method !== "POST") return new Response("Method not allowed", { status: 405 });
  const serverKey = Deno.env.get("MIDTRANS_SERVER_KEY");
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!serverKey || !supabaseUrl || !serviceRoleKey) {
    console.error("Missing Midtrans webhook environment variables.");
    return new Response("Payment notification is not configured", { status: 500 });
  }

  let payload: Record<string, unknown>;
  try {
    payload = await req.json();
  } catch {
    return new Response("invalid JSON", { status: 400 });
  }

  const orderId = typeof payload.order_id === "string" ? payload.order_id : "";
  const statusCode = typeof payload.status_code === "string" ? payload.status_code : "";
  const grossAmount = typeof payload.gross_amount === "string" ? payload.gross_amount : "";
  const receivedSignature = typeof payload.signature_key === "string" ? payload.signature_key : "";
  if (!orderId || !statusCode || !grossAmount || !receivedSignature) {
    return new Response("invalid notification fields", { status: 400 });
  }

  const expectedSignature = await sha512Hex(`${orderId}${statusCode}${grossAmount}${serverKey}`);
  if (!constantTimeEqual(expectedSignature.toLowerCase(), receivedSignature.toLowerCase())) {
    return new Response("invalid signature", { status: 401 });
  }

  // Acknowledge pending/expired/failed messages; only settlement marks the order paid.
  if (payload.transaction_status !== "settlement") return new Response("OK", { status: 200 });
  if (statusCode !== "200" || (payload.fraud_status != null && payload.fraud_status !== "accept")) {
    return new Response("payment is not settled", { status: 400 });
  }
  if (payload.payment_type !== "qris") return new Response("unsupported payment type", { status: 400 });

  const amount = Number(grossAmount);
  if (!Number.isSafeInteger(amount) || amount <= 0) return new Response("invalid amount", { status: 400 });
  const supabase = createClient(supabaseUrl, serviceRoleKey);
  const { error } = await supabase.rpc("konfirmasi_pembayaran_doku", {
    p_kode_pesan: orderId,
    p_jumlah_bayar: amount,
    p_metode: "qris",
    p_penyedia: "Midtrans Sandbox",
  });
  if (error) {
    console.error("Midtrans payment confirmation failed:", error.message);
    return new Response("payment confirmation failed", { status: 500 });
  }
  return new Response("OK", { status: 200 });
});
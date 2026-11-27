import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { dokuSign } from "../_shared/doku.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const authorization = req.headers.get("Authorization");
  if (!authorization?.startsWith("Bearer ")) {
    return json({ error: "Login dibutuhkan untuk membuat pembayaran." }, 401);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const clientId = Deno.env.get("DOKU_CLIENT_ID");
  const secret = Deno.env.get("DOKU_SECRET_KEY");
  const baseUrl = Deno.env.get("DOKU_BASE_URL")?.replace(/\/$/, "");
  if (!supabaseUrl || !supabaseAnonKey || !clientId || !secret || !baseUrl) {
    console.error("Missing Supabase or DOKU function environment variables.");
    return json({ error: "Konfigurasi pembayaran belum lengkap." }, 500);
  }

  let input: Record<string, unknown>;
  try {
    input = await req.json();
  } catch {
    return json({ error: "Request pembayaran tidak valid." }, 400);
  }

  const invoiceNumber = typeof input.invoice_number === "string"
    ? input.invoice_number.trim()
    : "";
  const name = typeof input.name === "string" ? input.name.trim() : "";
  const email = typeof input.email === "string" ? input.email.trim() : "";
  if (!invoiceNumber || !name || !email) {
    return json({ error: "Nomor pesanan, nama, dan email wajib diisi." }, 400);
  }

  const userClient = createClient(supabaseUrl, supabaseAnonKey, {
    global: { headers: { Authorization: authorization } },
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const accessToken = authorization.replace(/^Bearer\s+/i, "");
  const { data: userData, error: userError } = await userClient.auth.getUser(accessToken);
  if (userError || !userData.user) {
    return json({ error: "Sesi login tidak valid." }, 401);
  }

  const { data: order, error: orderError } = await userClient
    .from("pemesanan")
    .select("kode_pesan, total_bayar, status_pesan")
    .eq("kode_pesan", invoiceNumber)
    .maybeSingle();
  if (orderError || !order) {
    return json({ error: "Pesanan tidak ditemukan atau tidak bisa diakses." }, 404);
  }
  if (order.status_pesan !== "menunggu_pembayaran") {
    return json({ error: "Pesanan ini tidak sedang menunggu pembayaran." }, 409);
  }

  const amount = Number(order.total_bayar);
  if (!Number.isSafeInteger(amount) || amount <= 0) {
    return json({ error: "Nominal pesanan tidak valid." }, 400);
  }

  const body = JSON.stringify({
    order: {
      amount,
      invoice_number: order.kode_pesan,
      auto_redirect: false,
    },
    payment: { payment_due_date: 15 },
    customer: { name, email },
    additional_info: {
      override_notification_url: `${supabaseUrl.replace(/\/$/, "")}/functions/v1/doku-notif`,
    },
  });

  const requestId = crypto.randomUUID();
  const timestamp = new Date().toISOString().replace(/\.\d{3}Z$/, "Z");
  const signature = await dokuSign(
    clientId,
    secret,
    requestId,
    timestamp,
    "/checkout/v1/payment",
    body,
  );

  try {
    const dokuResponse = await fetch(`${baseUrl}/checkout/v1/payment`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Client-Id": clientId,
        "Request-Id": requestId,
        "Request-Timestamp": timestamp,
        "Signature": signature,
      },
      body,
    });
    const responseBody = await dokuResponse.json();
    return json(responseBody, dokuResponse.status);
  } catch (error) {
    console.error("DOKU checkout request failed:", error);
    return json({ error: "Tidak bisa terhubung ke DOKU." }, 502);
  }
});
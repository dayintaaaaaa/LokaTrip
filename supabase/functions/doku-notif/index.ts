import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { dokuSign } from "../_shared/doku.ts";

const CLIENT_ID = Deno.env.get("DOKU_CLIENT_ID")!;
const SECRET = Deno.env.get("DOKU_SECRET_KEY")!;
const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

Deno.serve(async (req) => {
  if (req.method !== "POST") return new Response("Method not allowed", { status: 405 });

  const raw = await req.text();
  const h = req.headers;
  const expected = await dokuSign(
    h.get("Client-Id") ?? "", SECRET,
    h.get("Request-Id") ?? "", h.get("Request-Timestamp") ?? "",
    "/functions/v1/doku-notif", raw,
  );

  if (expected !== h.get("Signature")) {
    return new Response("invalid signature", { status: 401 });
  }

  let payload: Record<string, any>;
  try {
    payload = JSON.parse(raw);
  } catch {
    return new Response("invalid JSON", { status: 400 });
  }

  // DOKU Checkout can send FAILED while the customer is choosing a method.
  // Only SUCCESS confirms payment; acknowledge other states without changing orders.
  if (payload?.transaction?.status !== "SUCCESS") {
    return new Response("OK", { status: 200 });
  }

  const invoice = payload?.order?.invoice_number;
  const amount = Number(payload?.order?.amount);
  if (typeof invoice !== "string" || !invoice || !Number.isSafeInteger(amount) || amount <= 0) {
    return new Response("invalid payment data", { status: 400 });
  }

  const channel = payload?.channel ?? {};
  const service = payload?.service ?? {};
  const channelText = [channel.id, channel.name, service.id, service.name]
    .filter((value) => typeof value === "string")
    .join(" ")
    .toLowerCase();

  let method: string;
  if (/qris|\bqr\b/.test(channelText)) method = "qris";
  else if (/virtual.?account|\bva\b/.test(channelText)) method = "virtual_account";
  else if (/credit.?card|\bcard\b/.test(channelText)) method = "kartu_kredit";
  else if (/wallet|e.?money|ovo|gopay|dana|shopeepay|link.?aja/.test(channelText)) {
    method = "dompet_digital";
  } else {
    console.error("Unsupported DOKU channel:", channelText);
    return new Response("unsupported payment channel", { status: 400 });
  }

  const provider = [channel.name, channel.id, service.name, service.id]
    .find((value) => typeof value === "string") ?? "DOKU";
  const { error } = await supabase.rpc("konfirmasi_pembayaran_doku", {
    p_kode_pesan: invoice,
    p_jumlah_bayar: amount,
    p_metode: method,
    p_penyedia: provider,
  });

  if (error) {
    console.error("DOKU payment confirmation failed:", error.message);
    return new Response("payment confirmation failed", { status: 500 });
  }

  return new Response("OK", { status: 200 });
});
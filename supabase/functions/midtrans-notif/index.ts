/**
 * midtrans-notif – Webhook endpoint untuk notifikasi pembayaran Midtrans.
 *
 * Gunakan endpoint `midtrans-payment` yang memeriksa status dan nominal ke Midtrans.
 *
 * Function ini menerima semua metode pembayaran Snap (QRIS, VA, e-wallet,
 * kartu kredit, PayLater) dan meneruskan settlement ke midtrans_settle_payment.
 */

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const encoder = new TextEncoder();

async function sha512Hex(value: string): Promise<string> {
  const digest = await crypto.subtle.digest("SHA-512", encoder.encode(value));
  return Array.from(new Uint8Array(digest), (b) =>
    b.toString(16).padStart(2, "0")
  ).join("");
}

function constantTimeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}

/** Memetakan payment_type Midtrans ke metode_bayar_enum di LokaTrip. */
function resolveMethod(paymentType: string): string {
  if (["qris", "other_qris"].includes(paymentType)) return "qris";
  if (paymentType === "credit_card") return "kartu_kredit";
  if (["bank_transfer", "echannel"].includes(paymentType)) return "virtual_account";
  if (["gopay", "shopeepay", "dana", "ovo"].includes(paymentType)) return "dompet_digital";
  if (paymentType === "akulaku") return "paylater";
  return "virtual_account";
}

/** Mengekstrak kode_pesan LokaTrip dari midtrans_order_id (format: LT-XXXXXXXX-xxxxxxxx). */
function extractKodePesan(orderId: string): string | null {
  // Format: <kode_pesan>-<uuid-8-chars>
  // kode_pesan biasanya LT-XXXXXXXX (10 chars), jadi kita strip suffix terakhir.
  const parts = orderId.split("-");
  if (parts.length < 3) return null;
  // Ambil semua kecuali bagian terakhir (UUID suffix)
  return parts.slice(0, -1).join("-");
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const signatureSecretKey = Deno.env.get("MIDTRANS_SIGNATURE_SECRET_KEY");
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!signatureSecretKey || !supabaseUrl || !serviceRoleKey) {
    console.error("Missing environment variables for Midtrans webhook.");
    return new Response("Webhook not configured", { status: 500 });
  }

  let payload: Record<string, unknown>;
  try {
    payload = await req.json();
  } catch {
    return new Response("Invalid JSON", { status: 400 });
  }

  // --- Validasi field wajib ---
  const orderId = typeof payload.order_id === "string" ? payload.order_id : "";
  const statusCode = typeof payload.status_code === "string" ? payload.status_code : "";
  const grossAmount = typeof payload.gross_amount === "string" ? payload.gross_amount : "";
  const receivedSignature = typeof payload.signature_key === "string" ? payload.signature_key : "";

  if (!orderId || !statusCode || !grossAmount || !receivedSignature) {
    return new Response("Missing required notification fields", { status: 400 });
  }

  // --- Verifikasi signature ---
  const expectedSignature = await sha512Hex(
    `${orderId}${statusCode}${grossAmount}${signatureSecretKey}`
  );
  if (!constantTimeEqual(expectedSignature.toLowerCase(), receivedSignature.toLowerCase())) {
    console.error("Midtrans webhook: invalid signature for order", orderId);
    return new Response("Invalid signature", { status: 401 });
  }

  const transactionStatus = typeof payload.transaction_status === "string"
    ? payload.transaction_status
    : "";

  // Hanya settlement / capture yang menandai pembayaran berhasil.
  if (transactionStatus !== "settlement" && transactionStatus !== "capture") {
    // Acknowledge non-final statuses (pending, expire, deny, cancel)
    console.log(`Midtrans webhook: status=${transactionStatus} for ${orderId} – acknowledged.`);
    return new Response("OK", { status: 200 });
  }

  // Untuk capture, pastikan fraud_status accept
  if (
    transactionStatus === "capture" &&
    payload.fraud_status != null &&
    String(payload.fraud_status).toLowerCase() !== "accept"
  ) {
    console.log(`Midtrans webhook: capture denied (fraud_status=${payload.fraud_status}) for ${orderId}`);
    return new Response("Payment denied", { status: 400 });
  }

  if (statusCode !== "200") {
    return new Response("Payment not settled", { status: 400 });
  }

  // --- Resolve kode_pesan dari midtrans_order_id ---
  // Coba ambil dari midtrans_transactions dulu (lebih akurat).
  const supabase = createClient(supabaseUrl, serviceRoleKey);

  let kodePesan: string | null = null;

  const { data: txRow } = await supabase
    .from("midtrans_transactions")
    .select("id, id_pemesanan, pemesanan(kode_pesan)")
    .eq("midtrans_order_id", orderId)
    .maybeSingle();

  if (txRow) {
    const pemesanan = Array.isArray(txRow.pemesanan)
      ? txRow.pemesanan[0]
      : txRow.pemesanan;
    kodePesan = pemesanan?.kode_pesan ?? null;

    // Update status di midtrans_transactions
    await supabase
      .from("midtrans_transactions")
      .update({ transaction_status: transactionStatus, diperbarui_pada: new Date().toISOString() })
      .eq("id", txRow.id);
  }

  if (!kodePesan) {
    // Fallback: ekstrak dari format order_id
    kodePesan = extractKodePesan(orderId);
  }

  if (!kodePesan) {
    console.error("Midtrans webhook: cannot resolve kode_pesan from order_id:", orderId);
    return new Response("Order not found", { status: 404 });
  }

  // Pastikan nilai yang ditandatangani Midtrans sama dengan total order lokal.
  const { data: order, error: orderError } = await supabase
    .from("pemesanan")
    .select("total_bayar")
    .eq("kode_pesan", kodePesan)
    .maybeSingle();
  if (orderError || !order) {
    console.error("Midtrans webhook: local order not found:", kodePesan, orderError?.message);
    return new Response("Order not found", { status: 404 });
  }
  if (!Number.isFinite(Number(grossAmount)) || Number(grossAmount) !== Number(order.total_bayar)) {
    console.error("Midtrans webhook: amount mismatch for order", kodePesan);
    return new Response("Payment amount mismatch", { status: 409 });
  }

  const paymentType = typeof payload.payment_type === "string" ? payload.payment_type : "qris";
  const method = resolveMethod(paymentType);

  // Ambil provider dari respons Midtrans
  const vaNumbers = Array.isArray(payload.va_numbers) ? payload.va_numbers as Array<Record<string, unknown>> : [];
  const provider = String(
    (payload.bank ?? vaNumbers[0]?.bank ?? paymentType) || "Midtrans"
  );

  const { error } = await supabase.rpc("midtrans_settle_payment", {
    p_kode_pesan: kodePesan,
    p_metode: method,
    p_penyedia: provider,
  });

  if (error) {
    // Jika pesanan sudah aktif (idempoten), anggap sukses
    if (error.message?.includes("PESANAN_TIDAK_VALID") || error.message?.includes("already")) {
      console.log(`Midtrans webhook: order ${kodePesan} already settled – idempotent OK.`);
      return new Response("OK", { status: 200 });
    }
    console.error("Midtrans webhook: settle failed:", error.message, "order:", kodePesan);
    return new Response("Payment confirmation failed", { status: 500 });
  }

  console.log(`Midtrans webhook: order ${kodePesan} settled via ${method} (${provider}).`);
  return new Response("OK", { status: 200 });
});

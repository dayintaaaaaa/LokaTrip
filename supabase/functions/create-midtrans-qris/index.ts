import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

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

function toBase64(bytes: Uint8Array) {
  let binary = "";
  for (let offset = 0; offset < bytes.length; offset += 0x8000) {
    binary += String.fromCharCode(...bytes.subarray(offset, offset + 0x8000));
  }
  return btoa(binary);
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const authorization = req.headers.get("Authorization");
  if (!authorization?.startsWith("Bearer ")) {
    return json({ error: "Login dibutuhkan untuk membuat pembayaran." }, 401);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serverKey = Deno.env.get("MIDTRANS_SERVER_KEY");
  if (!supabaseUrl || !anonKey || !serverKey) {
    console.error("Missing Supabase or Midtrans environment variables.");
    return json({ error: "Konfigurasi Midtrans Sandbox belum lengkap." }, 500);
  }

  let input: Record<string, unknown>;
  try {
    input = await req.json();
  } catch {
    return json({ error: "Request pembayaran tidak valid." }, 400);
  }

  const invoice = typeof input.invoice_number === "string" ? input.invoice_number.trim() : "";
  const name = typeof input.name === "string" ? input.name.trim() : "";
  const email = typeof input.email === "string" ? input.email.trim() : "";
  if (!invoice || !name || !email) {
    return json({ error: "Nomor pesanan, nama, dan email wajib diisi." }, 400);
  }

  const userClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authorization } },
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const accessToken = authorization.replace(/^Bearer\s+/i, "");
  const { data: userData, error: userError } = await userClient.auth.getUser(accessToken);
  if (userError || !userData.user) return json({ error: "Sesi login tidak valid." }, 401);

  const { data: order, error: orderError } = await userClient
    .from("pemesanan")
    .select("kode_pesan, total_bayar, status_pesan")
    .eq("kode_pesan", invoice)
    .maybeSingle();
  if (orderError || !order) return json({ error: "Pesanan tidak ditemukan atau tidak bisa diakses." }, 404);
  if (order.status_pesan !== "menunggu_pembayaran") {
    return json({ error: "Pesanan ini tidak sedang menunggu pembayaran." }, 409);
  }

  const amount = Number(order.total_bayar);
  if (!Number.isSafeInteger(amount) || amount <= 0) {
    return json({ error: "Nominal pesanan tidak valid." }, 400);
  }

  const baseUrl = "https://api.sandbox.midtrans.com";
  const auth = `Basic ${btoa(`${serverKey}:`)}`;
  try {
    const charge = await fetch(`${baseUrl}/v2/charge`, {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: auth, Accept: "application/json" },
      body: JSON.stringify({
        payment_type: "qris",
        transaction_details: { order_id: order.kode_pesan, gross_amount: amount },
        customer_details: { first_name: name, email },
        qris: { acquirer: "gopay" },
        custom_expiry: { expiry_duration: 15, unit: "minute" },
      }),
    });
    const payment = await charge.json();
    if (!charge.ok) {
      console.error("Midtrans charge rejected:", payment?.status_message ?? charge.status);
      return json({ error: "Midtrans belum bisa membuat QR untuk pesanan ini." }, charge.status);
    }

    if (typeof payment.transaction_id !== "string") {
      return json({ error: "ID transaksi Midtrans tidak ditemukan." }, 502);
    }
    // Build the image URL from the sandbox host; never follow a production URL in sandbox mode.
    const qrUrl = `${baseUrl}/v2/qris/${encodeURIComponent(payment.transaction_id)}/qr-code`;
    const qrResponse = await fetch(qrUrl, { headers: { Authorization: auth } });
    if (!qrResponse.ok) {
      console.error("Midtrans QR image request failed:", qrResponse.status);
      return json({ error: "QR Midtrans gagal diambil." }, 502);
    }
    const contentType = qrResponse.headers.get("content-type") ?? "image/png";
    if (!contentType.startsWith("image/")) return json({ error: "Format QR Midtrans tidak valid." }, 502);
    const imageBase64 = toBase64(new Uint8Array(await qrResponse.arrayBuffer()));

    return json({
      qr_image_base64: imageBase64,
      qr_image_url: qrUrl,
      content_type: contentType,
      order_id: payment.order_id,
      gross_amount: payment.gross_amount,
      transaction_id: payment.transaction_id,
    });
  } catch (error) {
    console.error("Midtrans QRIS request failed:", error);
    return json({ error: "Tidak bisa terhubung ke Midtrans Sandbox." }, 502);
  }
});
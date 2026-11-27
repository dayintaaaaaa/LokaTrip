import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { dokuSign } from "../_shared/doku.ts";

const CLIENT_ID = Deno.env.get("DOKU_CLIENT_ID")!;
const SECRET = Deno.env.get("DOKU_SECRET_KEY")!;
const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

Deno.serve(async (req) => {
  const raw = await req.text();                       // body mentah, jangan di-parse dulu
  const h = req.headers;
  const expected = await dokuSign(
    h.get("Client-Id") ?? "", SECRET,
    h.get("Request-Id") ?? "", h.get("Request-Timestamp") ?? "",
    "/functions/v1/doku-notif", raw,                  // path Notification URL kamu
  );

  if (expected !== h.get("Signature")) {
    return new Response("invalid signature", { status: 401 });
  }

  const payload = JSON.parse(raw);
  const invoice = payload?.order?.invoice_number;
  const status = payload?.transaction?.status;        // "SUCCESS" kalau berhasil

  if (invoice && status === "SUCCESS") {
    await supabase.from("bookings").update({ status: "paid" }).eq("invoice_number", invoice);
  }
  return new Response("OK", { status: 200 });
});
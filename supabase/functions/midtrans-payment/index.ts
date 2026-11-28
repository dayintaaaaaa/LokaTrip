import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, apikey, content-type, x-client-info',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

const json = (body: unknown, status = 200) => new Response(JSON.stringify(body), {
  status,
  headers: { ...corsHeaders, 'Content-Type': 'application/json' },
});

const required = (name: string) => {
  const value = Deno.env.get(name)?.trim();
  if (!value) throw new Error(`Secret ${name} belum diatur.`);
  return value;
};

const midtransHosts = () => Deno.env.get('MIDTRANS_ENVIRONMENT') === 'production'
  ? { snap: 'https://app.midtrans.com', coreApi: 'https://api.midtrans.com' }
  : { snap: 'https://app.sandbox.midtrans.com', coreApi: 'https://api.sandbox.midtrans.com' };

const basicAuthorization = (serverKey: string) =>
  `Basic ${btoa(`${serverKey}:`)}`;

function qrisImageUrl(status: Record<string, unknown>) {
  const actions = Array.isArray(status.actions) ? status.actions : [];
  const action = actions.find((item) => {
    if (!item || typeof item !== 'object') return false;
    const name = String((item as Record<string, unknown>).name ?? '');
    const url = String((item as Record<string, unknown>).url ?? '');
    return /qr/i.test(name) && url.length > 0;
  }) as Record<string, unknown> | undefined;
  if (!action || typeof action.url !== 'string') return undefined;
  try {
    const url = new URL(action.url);
    if (url.protocol !== 'https:' || !['api.sandbox.midtrans.com', 'api.midtrans.com'].includes(url.hostname)) return undefined;
    return url.toString();
  } catch {
    return undefined;
  }
}

const admin = () => createClient(
  required('SUPABASE_URL'),
  required('SUPABASE_SERVICE_ROLE_KEY'),
  { auth: { persistSession: false, autoRefreshToken: false } },
);

const paymentOptions: Record<string, string[]> = {
  qris: ['other_qris'],
  virtual_account_bca: ['bca_va'],
  virtual_account_bni: ['bni_va'],
  virtual_account_bri: ['bri_va'],
  virtual_account_mandiri: ['echannel'],
  virtual_account_permata: ['permata_va'],
  virtual_account_cimb: ['cimb_va'],
  gopay: ['gopay'],
  ovo: ['ovo'],
  dana: ['dana'],
  shopeepay: ['shopeepay'],
  kartu_kredit: ['credit_card'],
  paylater: ['akulaku'],
};

async function createSnapPayment(body: Record<string, unknown>, request: Request) {
  const auth = request.headers.get('authorization') ?? '';
  const token = auth.startsWith('Bearer ') ? auth.slice(7).trim() : '';
  if (!token) return json({ error: 'Silakan login kembali.' }, 401);

  const db = admin();
  const { data: authData, error: authError } = await db.auth.getUser(token);
  if (authError || !authData.user) return json({ error: 'Sesi login tidak valid.' }, 401);

  const { data: user, error: userError } = await db.from('users')
    .select('id_user, nama_lengkap_user, email, no_telephone')
    .eq('auth_id', authData.user.id)
    .maybeSingle();
  if (userError || !user) return json({ error: 'Profil pengguna tidak ditemukan.' }, 403);

  const kodePesan = typeof body.kode_pesan === 'string' ? body.kode_pesan.trim() : '';
  const pilihan = typeof body.payment_method === 'string' ? body.payment_method : '';
  const enabledPayments = paymentOptions[pilihan];
  if (!kodePesan || !enabledPayments) return json({ error: 'Pesanan atau metode pembayaran tidak valid.' }, 400);

  const { data: order, error: orderError } = await db.from('pemesanan')
    .select('id_pemesanan, kode_pesan, total_bayar, status_pesan, dibuat_pada')
    .eq('kode_pesan', kodePesan)
    .eq('id_user', user.id_user)
    .maybeSingle();
  if (orderError || !order) return json({ error: 'Pesanan tidak ditemukan.' }, 404);
  if (order.status_pesan !== 'menunggu_pembayaran') {
    return json({ error: 'Pesanan ini sudah tidak menunggu pembayaran.' }, 409);
  }
  if (Date.now() - Date.parse(order.dibuat_pada) > 15 * 60 * 1000) {
    return json({ error: 'Waktu pembayaran pesanan sudah habis. Silakan buat pesanan baru.' }, 409);
  }

  const { data: existing } = await db.from('midtrans_transactions')
    .select('redirect_url')
    .eq('id_pemesanan', order.id_pemesanan)
    .eq('transaction_status', 'pending')
    .order('dibuat_pada', { ascending: false })
    .limit(1)
    .maybeSingle();
  if (existing?.redirect_url) return json({ redirect_url: existing.redirect_url });

  const serverKey = required('MIDTRANS_SERVER_KEY');
  const midtransOrderId = `${order.kode_pesan}-${crypto.randomUUID().slice(0, 8)}`;
  const payload = {
    transaction_details: {
      order_id: midtransOrderId,
      gross_amount: Number(order.total_bayar),
    },
    item_details: [{
      id: order.kode_pesan,
      price: Number(order.total_bayar),
      quantity: 1,
      name: `Tiket LokaTrip ${order.kode_pesan}`,
    }],
    customer_details: {
      first_name: user.nama_lengkap_user,
      email: user.email ?? authData.user.email,
      phone: user.no_telephone,
    },
    enabled_payments: enabledPayments,
    expiry: { unit: 'minute', duration: 15 },
  };

  const response = await fetch(`${midtransHosts().snap}/snap/v1/transactions`, {
    method: 'POST',
    headers: {
      Authorization: basicAuthorization(serverKey),
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
    body: JSON.stringify(payload),
  });
  const result = await response.json();
  if (!response.ok || typeof result.token !== 'string' || typeof result.redirect_url !== 'string') {
    console.error('Midtrans create transaction failed:', response.status, result);
    return json({ error: 'Midtrans gagal membuat transaksi sandbox. Periksa metode pembayaran dan kredensial sandbox.' }, 502);
  }

  const { error: saveError } = await db.from('midtrans_transactions').insert({
    id_pemesanan: order.id_pemesanan,
    midtrans_order_id: midtransOrderId,
    snap_token: result.token,
    redirect_url: result.redirect_url,
  });
  if (saveError) {
    console.error('Could not save Midtrans transaction:', saveError.message);
    return json({ error: 'Transaksi dibuat tetapi gagal disimpan. Hubungi admin sebelum mencoba membayar lagi.' }, 500);
  }

  return json({ redirect_url: result.redirect_url });
}

async function verifySignature(body: Record<string, unknown>) {
  const orderId = String(body.order_id ?? '');
  const statusCode = String(body.status_code ?? '');
  const grossAmount = String(body.gross_amount ?? '');
  const received = String(body.signature_key ?? '');
  const source = `${orderId}${statusCode}${grossAmount}${required('MIDTRANS_SIGNATURE_SECRET_KEY')}`;
  const digest = await crypto.subtle.digest('SHA-512', new TextEncoder().encode(source));
  const expected = [...new Uint8Array(digest)].map((byte) => byte.toString(16).padStart(2, '0')).join('');
  if (received.length !== expected.length) return false;
  let difference = 0;
  for (let i = 0; i < expected.length; i++) difference |= expected.charCodeAt(i) ^ received.charCodeAt(i);
  return difference === 0;
}

async function reconcileTransaction(orderId: string, force = false) {
  const db = admin();
  const { data: payment, error: paymentError } = await db.from('midtrans_transactions')
    .select('id, id_pemesanan, transaction_status, diperbarui_pada, pemesanan(kode_pesan, total_bayar)')
    .eq('midtrans_order_id', orderId)
    .maybeSingle();
  if (paymentError || !payment) throw new Error('Transaksi Midtrans tidak ditemukan di database.');

  const priorStatus = String(payment.transaction_status ?? 'pending');
  if (!force && priorStatus !== 'pending') return { status: priorStatus };
  if (!force && Date.now() - Date.parse(payment.diperbarui_pada) < 10_000) return { status: priorStatus };

  // Verify against Midtrans status API as well as the signed webhook payload.
  const statusResponse = await fetch(`${midtransHosts().coreApi}/v2/${encodeURIComponent(orderId)}/status`, {
    headers: { Authorization: basicAuthorization(required('MIDTRANS_SERVER_KEY')) },
  });
  // A new Snap transaction may not have a Core API status until the payer
  // chooses a payment channel. Keep it pending and check again later.
  if (statusResponse.status === 404) return { status: priorStatus };
  const status = await statusResponse.json();
  if (!statusResponse.ok || status.order_id !== orderId) throw new Error('Status transaksi Midtrans belum dapat diverifikasi.');
  const qrImageUrl = qrisImageUrl(status);

  const order = Array.isArray(payment.pemesanan) ? payment.pemesanan[0] : payment.pemesanan;
  if (!order || Number(status.gross_amount) !== Number(order.total_bayar)) throw new Error('Nominal transaksi tidak cocok dengan pesanan.');

  const transactionStatus = String(status.transaction_status ?? 'unknown');
  const fraudDenied = transactionStatus === 'capture' && status.fraud_status &&
    String(status.fraud_status).toLowerCase() !== 'accept';
  const savedStatus = fraudDenied ? 'deny' : transactionStatus;
  const { error: updateError } = await db.from('midtrans_transactions').update({
    transaction_status: savedStatus,
    diperbarui_pada: new Date().toISOString(),
  }).eq('id', payment.id);
  if (updateError) {
    console.error('Could not update Midtrans transaction status:', updateError.message);
    throw new Error('Status transaksi gagal disimpan.');
  }

  const successful = transactionStatus === 'settlement' ||
    (transactionStatus === 'capture' &&
      (!status.fraud_status || String(status.fraud_status).toLowerCase() === 'accept'));
  if (!successful) return { status: savedStatus, qrImageUrl };

  const paymentType = String(status.payment_type ?? '');
  const method = ['qris', 'other_qris'].includes(paymentType) ? 'qris'
    : paymentType === 'credit_card' ? 'kartu_kredit'
    : paymentType === 'bank_transfer' || paymentType === 'echannel' ? 'virtual_account'
    : ['gopay', 'shopeepay', 'dana', 'ovo'].includes(paymentType) ? 'dompet_digital'
    : paymentType === 'akulaku' ? 'paylater'
    : 'virtual_account';
  const provider = String((status.bank ?? status.va_numbers?.[0]?.bank ?? paymentType) || 'Midtrans');
  const { error: settleError } = await db.rpc('midtrans_settle_payment', {
    p_kode_pesan: order.kode_pesan,
    p_metode: method,
    p_penyedia: provider,
  });
  if (settleError) {
    console.error('Midtrans payment settlement failed:', settleError.message);
    throw new Error('Pembayaran terverifikasi tetapi pemrosesan pesanan gagal.');
  }
  return { status: 'settlement', qrImageUrl };
}

async function handleNotification(body: Record<string, unknown>) {
  if (!(await verifySignature(body))) return json({ error: 'Signature not valid.' }, 401);

  const orderId = String(body.order_id ?? '');
  try {
    const result = await reconcileTransaction(orderId, true);
    return json({ status: result.status });
  } catch (error) {
    console.error('Midtrans notification processing failed:', error);
    return json({ error: error instanceof Error ? error.message : 'Notifikasi gagal diproses.' }, 500);
  }
}

async function reconcileForAdmin(request: Request) {
  const auth = request.headers.get('authorization') ?? '';
  const token = auth.startsWith('Bearer ') ? auth.slice(7).trim() : '';
  if (!token) return json({ error: 'Sesi admin diperlukan.' }, 401);

  const db = admin();
  const { data: authData, error: authError } = await db.auth.getUser(token);
  if (authError || !authData.user) return json({ error: 'Sesi admin tidak valid.' }, 401);
  const { data: adminUser, error: adminError } = await db.from('admin_lokatrip')
    .select('id_admin')
    .eq('auth_id', authData.user.id)
    .maybeSingle();
  if (adminError || !adminUser) return json({ error: 'Akses admin ditolak.' }, 403);

  const { data: pending, error: pendingError } = await db.from('midtrans_transactions')
    .select('midtrans_order_id, transaction_status, pemesanan(status_pesan, pembayaran(status_bayar))')
    .in('transaction_status', ['pending', 'settlement', 'capture'])
    .order('diperbarui_pada', { ascending: false })
    .limit(100);
  if (pendingError) throw new Error('Transaksi Midtrans gagal dibaca.');

  let settled = 0;
  let checked = 0;
  let failed = 0;
  const candidates = (pending ?? []).filter((transaction) => {
    if (transaction.transaction_status === 'pending') return true;
    const order = Array.isArray(transaction.pemesanan)
      ? transaction.pemesanan[0]
      : transaction.pemesanan;
    const payments = order && Array.isArray(order.pembayaran)
      ? order.pembayaran
      : order?.pembayaran ? [order.pembayaran] : [];
    const alreadySettled = payments.some((payment) =>
      ['berhasil', 'dibayar', 'lunas', 'paid'].includes(String(payment.status_bayar ?? '').toLowerCase()));
    return !alreadySettled;
  }).slice(0, 20);
  for (const transaction of candidates) {
    checked++;
    try {
      const force = transaction.transaction_status !== 'pending';
      const result = await reconcileTransaction(transaction.midtrans_order_id, force);
      if (result.status === 'settlement') settled++;
    } catch (error) {
      failed++;
      console.error('Admin Midtrans reconciliation failed:', transaction.midtrans_order_id, error);
    }
  }
  const { data: latest } = await db.from('midtrans_transactions')
    .select('transaction_status, pemesanan(kode_pesan)')
    .order('dibuat_pada', { ascending: false })
    .limit(1)
    .maybeSingle();
  const latestOrder = Array.isArray(latest?.pemesanan)
    ? latest.pemesanan[0]
    : latest?.pemesanan;
  return json({
    checked,
    settled,
    failed,
    latest_status: latest?.transaction_status ?? null,
    latest_order_code: latestOrder?.kode_pesan ?? null,
  });
}

async function recoverForAdmin(body: Record<string, unknown>, request: Request) {
  const auth = request.headers.get('authorization') ?? '';
  const token = auth.startsWith('Bearer ') ? auth.slice(7).trim() : '';
  if (!token) return json({ error: 'Sesi admin diperlukan.' }, 401);

  const db = admin();
  const { data: authData, error: authError } = await db.auth.getUser(token);
  if (authError || !authData.user) return json({ error: 'Sesi admin tidak valid.' }, 401);
  const { data: adminUser, error: adminError } = await db.from('admin_lokatrip')
    .select('id_admin')
    .eq('auth_id', authData.user.id)
    .maybeSingle();
  if (adminError || !adminUser) return json({ error: 'Akses admin ditolak.' }, 403);

  const kodePesan = typeof body.kode_pesan === 'string' ? body.kode_pesan.trim() : '';
  const orderId = typeof body.midtrans_order_id === 'string' ? body.midtrans_order_id.trim() : '';
  if (!kodePesan || !orderId || !orderId.startsWith(`${kodePesan}-`)) {
    return json({ error: 'Kode pesanan dan Order ID Midtrans tidak cocok.' }, 400);
  }

  const { data: order, error: orderError } = await db.from('pemesanan')
    .select('id_pemesanan, kode_pesan, total_bayar, status_pesan')
    .eq('kode_pesan', kodePesan)
    .maybeSingle();
  if (orderError || !order) return json({ error: 'Pesanan LokaTrip tidak ditemukan.' }, 404);

  const statusResponse = await fetch(`${midtransHosts().coreApi}/v2/${encodeURIComponent(orderId)}/status`, {
    headers: { Authorization: basicAuthorization(required('MIDTRANS_SERVER_KEY')) },
  });
  if (statusResponse.status === 404) return json({ error: 'Order ID tidak ditemukan di Midtrans.' }, 404);
  const status = await statusResponse.json();
  if (!statusResponse.ok || status.order_id !== orderId) {
    return json({ error: 'Status transaksi Midtrans tidak dapat diverifikasi.' }, 502);
  }
  if (Number(status.gross_amount) !== Number(order.total_bayar)) {
    return json({ error: 'Nominal Midtrans tidak cocok dengan total pesanan LokaTrip.' }, 409);
  }

  const transactionStatus = String(status.transaction_status ?? 'unknown');
  const successful = transactionStatus === 'settlement' ||
    (transactionStatus === 'capture' &&
      (!status.fraud_status || String(status.fraud_status).toLowerCase() === 'accept'));
  if (!successful) {
    return json({ error: `Pembayaran belum berhasil di Midtrans (status: ${transactionStatus}).`, status: transactionStatus }, 409);
  }

  const paymentType = String(status.payment_type ?? '');
  const method = ['qris', 'other_qris'].includes(paymentType) ? 'qris'
    : paymentType === 'credit_card' ? 'kartu_kredit'
    : paymentType === 'bank_transfer' || paymentType === 'echannel' ? 'virtual_account'
    : ['gopay', 'shopeepay', 'dana', 'ovo'].includes(paymentType) ? 'dompet_digital'
    : paymentType === 'akulaku' ? 'paylater'
    : 'virtual_account';
  const provider = String((status.bank ?? status.va_numbers?.[0]?.bank ?? paymentType) || 'Midtrans');
  const paymentValues = {
    metode_bayar: method,
    penyedia: provider,
    jumlah_bayar: order.total_bayar,
    status_bayar: 'berhasil',
    waktu_bayar: status.settlement_time ?? status.transaction_time ?? new Date().toISOString(),
  };

  const { data: oldPayment, error: oldPaymentError } = await db.from('pembayaran')
    .select('id_pemesanan, status_bayar')
    .eq('id_pemesanan', order.id_pemesanan)
    .limit(1)
    .maybeSingle();
  if (oldPaymentError) throw new Error('Pembayaran LokaTrip gagal diperiksa.');
  const alreadyRecorded = oldPayment && ['berhasil', 'dibayar', 'lunas', 'paid']
    .includes(String(oldPayment.status_bayar).toLowerCase());

  if (!alreadyRecorded) {
    if (oldPayment) {
      const { error } = await db.from('pembayaran').update(paymentValues)
        .eq('id_pemesanan', order.id_pemesanan);
      if (error) throw new Error('Pembayaran terverifikasi tetapi gagal disimpan.');
    } else if (order.status_pesan === 'menunggu_pembayaran') {
      const { error } = await db.rpc('midtrans_settle_payment', {
        p_kode_pesan: kodePesan,
        p_metode: method,
        p_penyedia: provider,
      });
      if (error) throw new Error('Pembayaran terverifikasi tetapi pemrosesan pesanan gagal.');
    } else if (order.status_pesan === 'aktif') {
      const { error } = await db.from('pembayaran').insert({
        id_pemesanan: order.id_pemesanan,
        ...paymentValues,
      });
      if (error) throw new Error('Pembayaran terverifikasi tetapi gagal disimpan.');
    } else {
      return json({ error: `Status pesanan tidak dapat dipulihkan: ${order.status_pesan}.` }, 409);
    }
  }

  const { error: trackingError } = await db.from('midtrans_transactions').upsert({
    id_pemesanan: order.id_pemesanan,
    midtrans_order_id: orderId,
    snap_token: 'legacy-recovery',
    redirect_url: 'legacy-recovery',
    transaction_status: transactionStatus,
    diperbarui_pada: new Date().toISOString(),
  }, { onConflict: 'midtrans_order_id' });
  if (trackingError) console.error('Recovered payment tracking could not be saved:', trackingError.message);

  return json({
    status: 'settlement',
    kode_pesan: kodePesan,
    already_recorded: Boolean(alreadyRecorded),
  });
}

Deno.serve(async (request) => {
  if (request.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  if (request.method !== 'POST') return json({ error: 'Method not allowed.' }, 405);

  try {
    const body = await request.json() as Record<string, unknown>;
    if (body.action === 'create') return await createSnapPayment(body, request);
    if (body.action === 'admin_reconcile') return await reconcileForAdmin(request);
    if (body.action === 'admin_recover') return await recoverForAdmin(body, request);
    if (body.action === 'status') {
      const auth = request.headers.get('authorization') ?? '';
      const token = auth.startsWith('Bearer ') ? auth.slice(7).trim() : '';
      if (!token) return json({ error: 'Silakan login kembali.' }, 401);
      const db = admin();
      const { data: authData, error: authError } = await db.auth.getUser(token);
      if (authError || !authData.user) return json({ error: 'Sesi login tidak valid.' }, 401);
      const { data: user } = await db.from('users').select('id_user')
        .eq('auth_id', authData.user.id).maybeSingle();
      const kode = typeof body.kode_pesan === 'string' ? body.kode_pesan.trim() : '';
      const { data: order } = await db.from('pemesanan').select('id_pemesanan, status_pesan')
        .eq('kode_pesan', kode).eq('id_user', user?.id_user ?? -1).maybeSingle();
      if (!order) return json({ status: 'unknown', payment_status: 'unknown' });

      const { data: transaction } = await db.from('midtrans_transactions')
        .select('midtrans_order_id, transaction_status')
        .eq('id_pemesanan', order.id_pemesanan)
        .order('dibuat_pada', { ascending: false })
        .limit(1)
        .maybeSingle();
      let paymentStatus = String(transaction?.transaction_status ?? 'unknown');
      let qrImageUrl: string | undefined;
      if (transaction && paymentStatus === 'pending') {
        try {
          const result = await reconcileTransaction(transaction.midtrans_order_id);
          paymentStatus = result.status;
          qrImageUrl = result.qrImageUrl;
        } catch (error) {
          console.error('Payment status reconciliation failed:', error);
        }
      }

      const { data: refreshedOrder } = await db.from('pemesanan').select('status_pesan')
        .eq('id_pemesanan', order.id_pemesanan).maybeSingle();
      return json({
        status: refreshedOrder?.status_pesan ?? order.status_pesan,
        payment_status: paymentStatus,
        sandbox_qr_image_url: Deno.env.get('MIDTRANS_ENVIRONMENT') === 'sandbox'
          ? qrImageUrl ?? null
          : null,
      });
    }
    return await handleNotification(body);
  } catch (error) {
    console.error('midtrans-payment error:', error);
    return json({ error: error instanceof Error ? error.message : 'Terjadi kesalahan pada pembayaran.' }, 500);
  }
});

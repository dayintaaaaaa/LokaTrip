import cors from 'cors';
import express from 'express';
import helmet from 'helmet';
import { existsSync } from 'node:fs';
import path from 'node:path';
import { config } from './config.js';
import { requireAdmin, requireMitra, requireUser } from './auth.js';
import { adminDb, authClient } from './supabase.js';

const app = express();
app.disable('x-powered-by');
app.use(helmet());
app.use(cors({
  origin(origin, callback) {
    if (!origin || config.corsOrigins.includes(origin)) return callback(null, true);
    // With no production allowlist, omit CORS headers. Same-origin requests
    // still work; browsers block cross-origin callers from reading the response.
    if (config.corsOrigins.length === 0 && config.nodeEnv === 'production') {
      return callback(null, false);
    }
    if (config.corsOrigins.length === 0) return callback(null, true);
    return callback(new Error('Origin tidak diizinkan oleh CORS.'));
  },
}));
app.use(express.json({ limit: '1mb' }));

function asyncRoute(handler) {
  return (req, res, next) => {
    Promise.resolve(handler(req, res)).catch(next);
  };
}

function failDb(error, res) {
  return res.status(500).json({ error: error.message });
}

function parseId(value) {
  const id = Number(value);
  return Number.isSafeInteger(id) && id > 0 ? id : null;
}

function pageParams(req) {
  const page = Math.max(1, Number(req.query.page) || 1);
  const limit = Math.min(100, Math.max(1, Number(req.query.limit) || 25));
  return { page, limit, from: (page - 1) * limit, to: page * limit - 1 };
}

async function recordAdminActivity(req, action, table, id, detail = {}) {
  const { error } = await adminDb.from('riwayat_aktivitas_admin').insert({
    id_admin: req.admin.id_admin,
    aksi: action,
    target_tabel: table,
    target_id: String(id),
    detail,
  });
  if (error) console.error('Admin activity log could not be written:', error.message);
  return !error;
}

app.get('/health', (_req, res) => res.json({ status: 'ok', service: 'backend-admin' }));

app.post('/api/auth/register', asyncRoute(async (req, res) => {
  const fullName = typeof req.body?.nama_lengkap_user === 'string' ? req.body.nama_lengkap_user.trim() : '';
  const username = typeof req.body?.username === 'string' ? req.body.username.trim() : '';
  const email = typeof req.body?.email === 'string' ? req.body.email.trim().toLowerCase() : '';
  const phone = typeof req.body?.no_telephone === 'string' ? req.body.no_telephone.trim() : '';
  const password = typeof req.body?.password === 'string' ? req.body.password : '';
  if (!fullName || !username || !email || !phone || password.length < 8) {
    return res.status(400).json({ error: 'Nama, username, email, nomor telepon, dan password minimal 8 karakter wajib diisi.' });
  }

  const { data: authData, error: authError } = await authClient.auth.signUp({
    email,
    password,
    options: { data: { nama_lengkap_user: fullName, username, no_telephone: phone } },
  });
  if (authError) return res.status(409).json({ error: authError.message });
  const authUser = authData.user;
  if (!authUser) return res.status(500).json({ error: 'Akun Supabase Auth tidak berhasil dibuat.' });
  if (authUser.identities && authUser.identities.length === 0) {
    return res.status(409).json({ error: 'Email sudah terdaftar.' });
  }

  const { data: user, error } = await adminDb.from('users').insert({
    nama_lengkap_user: fullName,
    username,
    email,
    no_telephone: phone,
    total_poin: 0,
    status_verif: 'N',
    auth_id: authUser.id,
  }).select('id_user, nama_lengkap_user, username, email, no_telephone, total_poin, status_verif').single();
  if (error) {
    await adminDb.auth.admin.deleteUser(authUser.id);
    return res.status(409).json({ error: 'Profil gagal disimpan. Periksa apakah username atau nomor telepon sudah digunakan.' });
  }
  return res.status(201).json({
    user,
    access_token: authData.session?.access_token ?? null,
    refresh_token: authData.session?.refresh_token ?? null,
    email_confirmation_required: !authData.session,
  });
}));

app.post('/api/auth/login', asyncRoute(async (req, res) => {
  const identifier = typeof req.body?.identifier === 'string' ? req.body.identifier.trim() : '';
  const password = typeof req.body?.password === 'string' ? req.body.password : '';
  if (!identifier || !password) return res.status(400).json({ error: 'Email/nomor telepon dan password wajib diisi.' });
  const projection = 'id_user, nama_lengkap_user, username, email, no_telephone, tgl_lahir, jenis_kelamin, foto_profil, total_poin, status_verif, auth_id';
  let userQuery = adminDb.from('users').select(projection);
  let user;
  if (identifier.includes('@')) {
    userQuery = userQuery.ilike('email', identifier);
    const result = await userQuery.maybeSingle();
    if (result.error) return failDb(result.error, res);
    user = result.data;
  } else {
    let result = await userQuery.eq('no_telephone', identifier).maybeSingle();
    if (result.error) return failDb(result.error, res);
    if (!result.data) {
      result = await adminDb.from('users').select(projection).eq('username', identifier).maybeSingle();
    }
    if (result.error) return failDb(result.error, res);
    user = result.data;
  }
  if (!user?.email) return res.status(401).json({ error: 'Akun atau password salah.' });
  const { data, error } = await authClient.auth.signInWithPassword({ email: user.email, password });
  if (error || !data.session || data.user.id !== user.auth_id) {
    return res.status(401).json({ error: 'Akun atau password salah.' });
  }
  return res.json({
    user: { ...user, auth_id: undefined },
    access_token: data.session.access_token,
    refresh_token: data.session.refresh_token,
    expires_at: data.session.expires_at,
  });
}));

app.post('/api/auth/refresh', asyncRoute(async (req, res) => {
  const refreshToken = typeof req.body?.refresh_token === 'string' ? req.body.refresh_token : '';
  if (!refreshToken) return res.status(400).json({ error: 'Refresh token wajib diisi.' });
  const { data, error } = await authClient.auth.refreshSession({ refresh_token: refreshToken });
  if (error || !data.session || !data.user) return res.status(401).json({ error: 'Sesi pengguna tidak dapat diperbarui.' });
  const { data: user, error: userError } = await adminDb.from('users')
    .select('id_user').eq('auth_id', data.user.id).maybeSingle();
  if (userError) return failDb(userError, res);
  if (!user) return res.status(403).json({ error: 'Akun pengguna tidak ditemukan.' });
  return res.json({
    access_token: data.session.access_token,
    refresh_token: data.session.refresh_token,
    expires_at: data.session.expires_at,
  });
}));

app.post('/api/mitra/auth/login', asyncRoute(async (req, res) => {
  const identifier = typeof req.body?.identifier === 'string' ? req.body.identifier.trim() : '';
  const password = typeof req.body?.password === 'string' ? req.body.password : '';
  if (!identifier || !password) return res.status(400).json({ error: 'Email/username dan password wajib diisi.' });
  let query = adminDb.from('admin_wisata')
    .select('id_mitra, id_admin, username, nama_lengkap_admin, email, no_telephone');
  query = identifier.includes('@') ? query.ilike('email', identifier) : query.eq('username', identifier);
  const { data: mitra, error: lookupError } = await query.maybeSingle();
  if (lookupError) return failDb(lookupError, res);
  if (!mitra?.email) return res.status(401).json({ error: 'Akun mitra atau password salah.' });
  const { data, error } = await authClient.auth.signInWithPassword({ email: mitra.email, password });
  if (error || !data.session || !data.user?.email) {
    return res.status(401).json({ error: 'Akun mitra atau password salah.' });
  }
  if (data.user.email?.toLowerCase() !== mitra.email.toLowerCase()) {
    await adminDb.auth.admin.signOut(data.session.access_token);
    return res.status(403).json({ error: 'Akun Auth tidak cocok dengan data mitra.' });
  }
  return res.json({
    mitra,
    access_token: data.session.access_token,
    refresh_token: data.session.refresh_token,
    expires_at: data.session.expires_at,
  });
}));

app.post('/api/mitra/auth/refresh', asyncRoute(async (req, res) => {
  const refreshToken = typeof req.body?.refresh_token === 'string' ? req.body.refresh_token : '';
  if (!refreshToken) return res.status(400).json({ error: 'Refresh token wajib diisi.' });
  const { data, error } = await authClient.auth.refreshSession({ refresh_token: refreshToken });
  if (error || !data.session || !data.user.email) return res.status(401).json({ error: 'Sesi mitra tidak dapat diperbarui.' });
  const { data: mitra, error: mitraError } = await adminDb.from('admin_wisata')
    .select('id_mitra').ilike('email', data.user.email).maybeSingle();
  if (mitraError) return failDb(mitraError, res);
  if (!mitra) return res.status(403).json({ error: 'Akun bukan mitra LokaTrip.' });
  return res.json({ access_token: data.session.access_token, refresh_token: data.session.refresh_token, expires_at: data.session.expires_at });
}));

app.use('/api/mitra', requireMitra);

app.get('/api/mitra/profile', (req, res) => res.json({ mitra: req.mitra }));

app.patch('/api/mitra/profile', asyncRoute(async (req, res) => {
  const allowed = ['username', 'nama_lengkap_admin', 'no_telephone'];
  const values = {};
  for (const field of allowed) {
    if (field in (req.body ?? {})) {
      const value = req.body[field];
      if (value !== null && typeof value !== 'string') return res.status(400).json({ error: `${field} harus berupa teks.` });
      values[field] = typeof value === 'string' ? value.trim() : null;
    }
  }
  if (!Object.keys(values).length) return res.status(400).json({ error: 'Tidak ada field profil yang dapat diperbarui.' });
  const { data, error } = await adminDb.from('admin_wisata').update(values)
    .eq('id_mitra', req.mitra.id_mitra)
    .select('id_mitra, id_admin, username, nama_lengkap_admin, email, no_telephone').single();
  if (error) return failDb(error, res);
  return res.json({ mitra: data });
}));

app.post('/api/mitra/auth/logout', asyncRoute(async (req, res) => {
  const { error } = await adminDb.auth.admin.signOut(req.bearerToken);
  if (error) return res.status(500).json({ error: 'Gagal mengakhiri sesi mitra.' });
  return res.status(204).end();
}));

app.get('/api/mitra/wisata', asyncRoute(async (req, res) => {
  const { data, error } = await adminDb.from('wisata')
    .select('id_wisata, id_mitra, id_kategori, nama_wisata, lokasi, kota, jam_buka, jam_tutup, deskripsi, jenis, subkategori, rata_rating, jml_ulasan, status_approve, kategori(nama_kategori), foto_wisata(id_foto, url_foto, urutan), paket_wisata(id_paket, nama_paket, tipe_paket, status_aktif, detail_paket(id_detail_paket, tipe_pengunjung, harga))')
    .eq('id_mitra', req.mitra.id_mitra).order('id_wisata', { ascending: false });
  if (error) return failDb(error, res);
  return res.json({ data: data ?? [] });
}));

app.get('/api/mitra/dokumen', asyncRoute(async (req, res) => {
  const { data, error } = await adminDb.from('dokumen')
    .select('id_dokumen, id_mitra, jenis_dokumen, nomor_dokumen, file_dokumen, status_approve, masa_berlaku_sampai, catatan_admin, diperiksa_pada')
    .eq('id_mitra', req.mitra.id_mitra).order('id_dokumen', { ascending: false });
  if (error) return failDb(error, res);
  return res.json({ data: data ?? [] });
}));

app.use('/api/user', requireUser);

app.get('/api/user/profile', (req, res) => {
  const { auth_id: _authId, ...user } = req.user;
  return res.json({ user });
});

app.get('/api/user/summary', asyncRoute(async (req, res) => {
  const [wishlist, reviews, tickets] = await Promise.all([
    adminDb.from('wishlist').select('id_wishlist', { count: 'exact', head: true }).eq('id_user', req.user.id_user),
    adminDb.from('ulasan').select('id_ulasan', { count: 'exact', head: true }).eq('id_user', req.user.id_user),
    adminDb.from('e_tiket').select('id_tiket, pemesanan!inner(id_user)', { count: 'exact', head: true }).eq('pemesanan.id_user', req.user.id_user).eq('status_tiket', 'aktif'),
  ]);
  const failed = [wishlist, reviews, tickets].find((item) => item.error);
  if (failed?.error) return failDb(failed.error, res);
  const { auth_id: _authId, ...user } = req.user;
  return res.json({
    user,
    jumlah_wishlist: wishlist.count ?? 0,
    jumlah_ulasan: reviews.count ?? 0,
    etiket_aktif: tickets.count ?? 0,
  });
}));

app.patch('/api/user/profile', asyncRoute(async (req, res) => {
  const allowed = ['nama_lengkap_user', 'username', 'no_telephone', 'tgl_lahir', 'jenis_kelamin', 'foto_profil'];
  const values = {};
  for (const field of allowed) {
    if (field in (req.body ?? {})) values[field] = req.body[field];
  }
  if (!Object.keys(values).length) return res.status(400).json({ error: 'Tidak ada data profil yang dapat diperbarui.' });
  if (Object.values(values).some((value) => value !== null && typeof value !== 'string')) {
    return res.status(400).json({ error: 'Data profil harus berupa teks atau null.' });
  }
  const { data, error } = await adminDb.from('users').update(values)
    .eq('id_user', req.user.id_user)
    .select('id_user, nama_lengkap_user, username, email, no_telephone, tgl_lahir, jenis_kelamin, foto_profil, total_poin, status_verif')
    .single();
  if (error) return failDb(error, res);
  return res.json({ user: data });
}));

app.post('/api/user/logout', asyncRoute(async (req, res) => {
  const { error } = await adminDb.auth.admin.signOut(req.bearerToken);
  if (error) return res.status(500).json({ error: 'Gagal mengakhiri sesi pengguna.' });
  return res.status(204).end();
}));

app.get('/api/user/wishlist', asyncRoute(async (req, res) => {
  const { data, error } = await adminDb.from('wishlist')
    .select('id_wishlist, id_wisata, wisata(id_wisata, nama_wisata, lokasi, kota, rata_rating, jml_ulasan, kategori(nama_kategori), paket_wisata(id_paket, nama_paket, tipe_paket, detail_paket(harga, tipe_pengunjung)), foto_wisata(url_foto, urutan))')
    .eq('id_user', req.user.id_user).order('id_wishlist', { ascending: false });
  if (error) return failDb(error, res);
  return res.json({ data: data ?? [] });
}));

app.post('/api/user/wishlist/:wisataId', asyncRoute(async (req, res) => {
  const id = parseId(req.params.wisataId);
  if (!id) return res.status(400).json({ error: 'ID wisata tidak valid.' });
  const existing = await adminDb.from('wishlist').select('id_wishlist, id_wisata')
    .eq('id_user', req.user.id_user).eq('id_wisata', id).maybeSingle();
  if (existing.error) return failDb(existing.error, res);
  if (existing.data) return res.json({ data: existing.data });
  const { data, error } = await adminDb.from('wishlist')
    .insert({ id_user: req.user.id_user, id_wisata: id })
    .select('id_wishlist, id_wisata').single();
  if (error) return failDb(error, res);
  return res.status(201).json({ data });
}));

app.delete('/api/user/wishlist/:wisataId', asyncRoute(async (req, res) => {
  const id = parseId(req.params.wisataId);
  if (!id) return res.status(400).json({ error: 'ID wisata tidak valid.' });
  const { error } = await adminDb.from('wishlist').delete()
    .eq('id_user', req.user.id_user).eq('id_wisata', id);
  if (error) return failDb(error, res);
  return res.status(204).end();
}));

app.get('/api/user/orders', asyncRoute(async (req, res) => {
  const { data, error } = await adminDb.from('pemesanan')
    .select('id_pemesanan, kode_pesan, tgl_pesan, subtotal, diskon, biaya_layanan, total_bayar, status_pesan, pembayaran(status_bayar, metode_bayar, jumlah_bayar, waktu_bayar), kuota_harian(tanggal), e_tiket(kode_qr, status_tiket), detail_pemesanan(jumlah, harga_satuan, subtotal_harga_tiket, tipe_pengunjung, detail_paket(paket_wisata(nama_paket, wisata(id_wisata, nama_wisata, lokasi, foto_wisata(url_foto, urutan)))))')
    .eq('id_user', req.user.id_user).order('tgl_pesan', { ascending: false }).limit(100);
  if (error) return failDb(error, res);
  return res.json({ data: data ?? [] });
}));

app.get('/api/user/notifications', asyncRoute(async (req, res) => {
  const { page, limit, from, to } = pageParams(req);
  let query = adminDb.from('notifikasi').select('id_notifikasi, judul, isi, jenis, status_baca, tanggal', { count: 'exact' })
    .eq('id_user', req.user.id_user);
  if (req.query.belum_dibaca === 'true') query = query.eq('status_baca', false);
  const { data, error, count } = await query.order('tanggal', { ascending: false }).range(from, to);
  if (error) return failDb(error, res);
  return res.json({ data: data ?? [], page, limit, total: count ?? 0 });
}));

app.patch('/api/user/notifications/:id/read', asyncRoute(async (req, res) => {
  const id = parseId(req.params.id);
  const isRead = req.body?.status_baca ?? true;
  if (!id) return res.status(400).json({ error: 'ID notifikasi tidak valid.' });
  if (typeof isRead !== 'boolean') return res.status(400).json({ error: 'status_baca harus berupa boolean.' });
  const { data, error } = await adminDb.from('notifikasi').update({ status_baca: isRead })
    .eq('id_notifikasi', id).eq('id_user', req.user.id_user)
    .select('id_notifikasi, status_baca').maybeSingle();
  if (error) return failDb(error, res);
  if (!data) return res.status(404).json({ error: 'Notifikasi tidak ditemukan.' });
  return res.json({ data });
}));

app.get('/api/user/points', asyncRoute(async (req, res) => {
  const { data, error } = await adminDb.from('riwayat_poin')
    .select('id_riwayat, jenis, jumlah_poin, keterangan, tanggal')
    .eq('id_user', req.user.id_user).order('tanggal', { ascending: false }).limit(100);
  if (error) return failDb(error, res);
  return res.json({ saldo: req.user.total_poin, data: data ?? [] });
}));

app.get('/api/user/reviews', asyncRoute(async (req, res) => {
  const { data, error } = await adminDb.from('ulasan')
    .select('id_ulasan, id_wisata, id_pemesanan, rating, komentar, tanggal_ulasan, wisata(nama_wisata, lokasi, foto_wisata(url_foto, urutan))')
    .eq('id_user', req.user.id_user).order('tanggal_ulasan', { ascending: false }).limit(100);
  if (error) return failDb(error, res);
  return res.json({ data: data ?? [] });
}));

app.post('/api/user/reviews', asyncRoute(async (req, res) => {
  const orderId = parseId(req.body?.id_pemesanan);
  const wisataId = parseId(req.body?.id_wisata);
  const rating = Number(req.body?.rating);
  const comment = typeof req.body?.komentar === 'string' ? req.body.komentar.trim() : null;
  if (!orderId || !wisataId || !Number.isInteger(rating) || rating < 1 || rating > 5) {
    return res.status(400).json({ error: 'Pesanan, wisata, dan rating 1 sampai 5 wajib diisi.' });
  }
  const { data: order, error: orderError } = await adminDb.from('pemesanan')
    .select('id_pemesanan, pembayaran(status_bayar), detail_pemesanan(detail_paket(paket_wisata(id_wisata)))')
    .eq('id_pemesanan', orderId).eq('id_user', req.user.id_user).maybeSingle();
  if (orderError) return failDb(orderError, res);
  if (!order) return res.status(404).json({ error: 'Pesanan tidak ditemukan.' });
  const payments = Array.isArray(order.pembayaran) ? order.pembayaran : [order.pembayaran];
  const paid = payments.some((payment) => ['berhasil', 'dibayar', 'lunas', 'paid'].includes(String(payment?.status_bayar ?? '').toLowerCase()));
  const details = order.detail_pemesanan ?? [];
  const belongsToWisata = details.some((detail) => {
    const packages = detail.detail_paket?.paket_wisata;
    return (Array.isArray(packages) ? packages : [packages]).some((pack) => Number(pack?.id_wisata) === wisataId);
  });
  if (!paid || !belongsToWisata) return res.status(403).json({ error: 'Ulasan hanya dapat diberikan untuk wisata yang sudah dibayar dalam pesanan ini.' });
  const { data, error } = await adminDb.from('ulasan').insert({
    id_user: req.user.id_user,
    id_wisata: wisataId,
    id_pemesanan: orderId,
    rating,
    komentar: comment,
    tanggal_ulasan: new Date().toISOString().slice(0, 10),
  }).select('id_ulasan, id_wisata, id_pemesanan, rating, komentar, tanggal_ulasan').single();
  if (error) return failDb(error, res);
  return res.status(201).json({ data });
}));

app.get('/api/public/wisata', asyncRoute(async (req, res) => {
  const { page, limit, from, to } = pageParams(req);
  let query = adminDb.from('wisata')
    .select('id_wisata, nama_wisata, lokasi, kota, deskripsi, jenis, subkategori, rata_rating, jml_ulasan, id_kategori, kategori(nama_kategori), paket_wisata!inner(id_paket, nama_paket, tipe_paket, status_aktif, detail_paket(id_detail_paket, harga, tipe_pengunjung)), foto_wisata(url_foto, urutan)', { count: 'exact' })
    .eq('status_approve', config.approvedApproval)
    .eq('paket_wisata.status_aktif', true);
  const search = typeof req.query.search === 'string' ? req.query.search.trim() : '';
  const city = typeof req.query.kota === 'string' ? req.query.kota.trim() : '';
  const category = parseId(req.query.kategori);
  if (search) query = query.ilike('nama_wisata', `%${search.replace(/[%_,]/g, ' ')}%`);
  if (city) query = query.ilike('kota', `%${city.replace(/[%_,]/g, ' ')}%`);
  if (category) query = query.eq('id_kategori', category);
  const { data, error, count } = await query.order('id_wisata', { ascending: true }).range(from, to);
  if (error) return failDb(error, res);
  return res.json({ data: data ?? [], page, limit, total: count ?? 0 });
}));

app.get('/api/public/kategori', asyncRoute(async (_req, res) => {
  const { data, error } = await adminDb.from('kategori').select('id_kategori, nama_kategori').order('nama_kategori');
  if (error) return failDb(error, res);
  return res.json({ data: data ?? [] });
}));

// Public entry is intentionally login-only: admin account creation is provisioned
// by project operators and is not exposed as an API for users or partners.
app.post('/api/admin/auth/login', asyncRoute(async (req, res) => {
  const username = typeof req.body?.username === 'string' ? req.body.username.trim() : '';
  const emailInput = typeof req.body?.email === 'string' ? req.body.email.trim() : '';
  const password = typeof req.body?.password === 'string' ? req.body.password : '';
  const loginName = username || emailInput;
  if (!loginName || !password) return res.status(400).json({ error: 'Username dan password wajib diisi.' });

  let adminQuery = adminDb
    .from('admin_lokatrip')
    .select('id_admin, username, nama_lengkap_admin, email, no_telephone');
  adminQuery = loginName.includes('@')
    ? adminQuery.ilike('email', loginName)
    : adminQuery.eq('username', loginName);
  const { data: admin, error: adminError } = await adminQuery.maybeSingle();
  if (adminError) return failDb(adminError, res);
  if (!admin) return res.status(401).json({ error: 'Username atau password admin salah.' });

  // Resolve username to the admin's Auth email; never compare the legacy
  // admin_lokatrip.password column directly.
  const { data, error } = await authClient.auth.signInWithPassword({ email: admin.email, password });
  if (error || !data.session || !data.user.email) {
    return res.status(401).json({ error: 'Username atau password admin salah.' });
  }

  if (data.user.email.toLowerCase() !== admin.email.toLowerCase()) {
    await adminDb.auth.admin.signOut(data.session.access_token);
    return res.status(403).json({ error: 'Akun Auth tidak cocok dengan data admin.' });
  }

  return res.json({
    access_token: data.session.access_token,
    refresh_token: data.session.refresh_token,
    expires_at: data.session.expires_at,
    admin,
  });
}));

// Refresh is public because an expired access token cannot pass requireAdmin.
app.post('/api/admin/auth/refresh', asyncRoute(async (req, res) => {
  const refreshToken = typeof req.body?.refresh_token === 'string' ? req.body.refresh_token : '';
  if (!refreshToken) return res.status(400).json({ error: 'Refresh token wajib diisi.' });
  const { data, error } = await authClient.auth.refreshSession({ refresh_token: refreshToken });
  if (error || !data.session || !data.user.email) return res.status(401).json({ error: 'Sesi admin tidak dapat diperbarui.' });
  const { data: admin, error: adminError } = await adminDb
    .from('admin_lokatrip')
    .select('id_admin, username, nama_lengkap_admin, email, no_telephone')
    .ilike('email', data.user.email)
    .maybeSingle();
  if (adminError) return failDb(adminError, res);
  if (!admin) return res.status(403).json({ error: 'Akun bukan admin LokaTrip.' });
  return res.json({ access_token: data.session.access_token, refresh_token: data.session.refresh_token, expires_at: data.session.expires_at, admin });
}));

app.use('/api/admin', requireAdmin);

app.get('/api/admin/auth/me', (req, res) => res.json({ admin: req.admin }));

app.post('/api/admin/auth/logout', asyncRoute(async (req, res) => {
  const { error } = await adminDb.auth.admin.signOut(req.bearerToken);
  if (error) return res.status(500).json({ error: 'Gagal mengakhiri sesi admin.' });
  return res.status(204).end();
}));

app.get('/api/admin/dashboard', asyncRoute(async (_req, res) => {
  const pending = config.pendingApproval;
  const approved = config.approvedApproval;
  const today = new Date().toISOString().slice(0, 10);
  const expiryLimit = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().slice(0, 10);
  const [mitra, attractions, pendingAttractions, pendingDocuments, approvedDocuments, expiringDocuments, expiredDocuments, orders, tickets] = await Promise.all([
    adminDb.from('admin_wisata').select('id_mitra', { count: 'exact', head: true }),
    adminDb.from('wisata').select('id_wisata', { count: 'exact', head: true }).eq('status_approve', approved),
    adminDb.from('wisata').select('id_wisata', { count: 'exact', head: true }).eq('status_approve', pending),
    adminDb.from('dokumen').select('id_dokumen', { count: 'exact', head: true }).eq('status_approve', pending),
    adminDb.from('dokumen').select('id_dokumen', { count: 'exact', head: true }).eq('status_approve', approved),
    adminDb.from('dokumen').select('id_dokumen', { count: 'exact', head: true }).eq('status_approve', approved).gte('masa_berlaku_sampai', today).lte('masa_berlaku_sampai', expiryLimit),
    adminDb.from('dokumen').select('id_dokumen', { count: 'exact', head: true }).eq('status_approve', approved).lt('masa_berlaku_sampai', today),
    adminDb.from('pemesanan').select('id_pemesanan, total_bayar, status_pesan', { count: 'exact' }).limit(10000),
    adminDb.from('detail_pemesanan').select('jumlah'),
  ]);
  const errors = [mitra, attractions, pendingAttractions, pendingDocuments, approvedDocuments, expiringDocuments, expiredDocuments, orders, tickets].find((item) => item.error);
  if (errors?.error) return failDb(errors.error, res);
  const paidStatuses = new Set(['berhasil', 'dibayar', 'lunas', 'paid']);
  const paidOrders = (orders.data ?? []).filter((row) => paidStatuses.has(String(row.status_pesan).toLowerCase()));
  return res.json({
    total_mitra: mitra.count ?? 0,
    wisata_aktif: attractions.count ?? 0,
    wisata_menunggu_verifikasi: pendingAttractions.count ?? 0,
    dokumen_menunggu_verifikasi: pendingDocuments.count ?? 0,
    total_pesanan: orders.count ?? 0,
    tiket_terjual: (tickets.data ?? []).reduce((sum, row) => sum + Number(row.jumlah || 0), 0),
    nilai_transaksi_bruto: paidOrders.reduce((sum, row) => sum + Number(row.total_bayar || 0), 0),
    dokumen_disetujui: approvedDocuments.count ?? 0,
    dokumen_segera_kedaluwarsa: expiringDocuments.count ?? 0,
    dokumen_kedaluwarsa: expiredDocuments.count ?? 0,
    catatan: 'Nilai transaksi dashboard dihitung dari maksimal 10.000 pesanan terbaru.',
  });
}));

app.get('/api/admin/mitras', asyncRoute(async (req, res) => {
  const { page, limit, from, to } = pageParams(req);
  let query = adminDb
    .from('admin_wisata')
    .select('id_mitra, id_admin, username, nama_lengkap_admin, email, no_telephone, wisata(id_wisata, nama_wisata, lokasi, kota, status_approve, kategori(nama_kategori)), dokumen(id_dokumen, jenis_dokumen, nomor_dokumen, file_dokumen, status_approve, masa_berlaku_sampai), status_mitra_admin(status_mitra, ditampilkan_di_beranda, catatan_admin, diperbarui_pada)', { count: 'exact' });
  const search = String(req.query.search ?? '').trim();
  if (search) {
    const safeSearch = search.replace(/[,.()]/g, ' ').trim();
    if (safeSearch) query = query.or(`username.ilike.%${safeSearch}%,nama_lengkap_admin.ilike.%${safeSearch}%,email.ilike.%${safeSearch}%`);
  }
  const { data, error, count } = await query.order('id_mitra', { ascending: false }).range(from, to);
  if (error) return failDb(error, res);
  return res.json({ data, page, limit, total: count ?? 0 });
}));

app.patch('/api/admin/mitras/:id/status', asyncRoute(async (req, res) => {
  const id = parseId(req.params.id);
  const { status_mitra, catatan_admin, ditampilkan_di_beranda } = req.body ?? {};
  const allowedStatuses = ['menunggu_verifikasi', 'aktif', 'ditolak', 'ditangguhkan'];
  if (!id) return res.status(400).json({ error: 'ID mitra tidak valid.' });
  if (!allowedStatuses.includes(status_mitra)) return res.status(400).json({ error: 'Status mitra tidak valid.' });
  if (catatan_admin !== undefined && catatan_admin !== null && typeof catatan_admin !== 'string') {
    return res.status(400).json({ error: 'catatan_admin harus berupa teks.' });
  }
  if (ditampilkan_di_beranda !== undefined && typeof ditampilkan_di_beranda !== 'boolean') {
    return res.status(400).json({ error: 'ditampilkan_di_beranda harus berupa boolean.' });
  }
  const { data: partner, error: partnerError } = await adminDb.from('admin_wisata')
    .select('id_mitra').eq('id_mitra', id).maybeSingle();
  if (partnerError) return failDb(partnerError, res);
  if (!partner) return res.status(404).json({ error: 'Mitra tidak ditemukan.' });
  const statusUpdate = {
    id_mitra: id,
    status_mitra,
    diperbarui_oleh: req.admin.id_admin,
    diperbarui_pada: new Date().toISOString(),
  };
  if (catatan_admin !== undefined) statusUpdate.catatan_admin = catatan_admin?.trim() ?? null;
  if (ditampilkan_di_beranda !== undefined) statusUpdate.ditampilkan_di_beranda = ditampilkan_di_beranda;
  const { data, error } = await adminDb.from('status_mitra_admin').upsert(statusUpdate).select().single();
  if (error) return failDb(error, res);
  const auditRecorded = await recordAdminActivity(req, 'ubah_status_mitra', 'admin_wisata', id, { status_mitra });
  return res.json({ data, audit_recorded: auditRecorded });
}));

app.get('/api/admin/dokumen', asyncRoute(async (req, res) => {
  const { page, limit, from, to } = pageParams(req);
  const status = String(req.query.status ?? '');
  let query = adminDb
    .from('dokumen')
    .select('id_dokumen, id_mitra, id_admin, jenis_dokumen, nomor_dokumen, file_dokumen, status_approve, masa_berlaku_sampai, catatan_admin, diperiksa_pada, admin_wisata(id_mitra, username, nama_lengkap_admin, email)', { count: 'exact' });
  if (status) query = query.eq('status_approve', status);
  const { data, error, count } = await query.order('id_dokumen', { ascending: false }).range(from, to);
  if (error) return failDb(error, res);
  return res.json({ data, page, limit, total: count ?? 0 });
}));

app.patch('/api/admin/dokumen/:id/decision', asyncRoute(async (req, res) => {
  const id = parseId(req.params.id);
  const decision = req.body?.decision;
  if (!id) return res.status(400).json({ error: 'ID dokumen tidak valid.' });
  if (!['approve', 'reject', 'pending'].includes(decision)) return res.status(400).json({ error: 'decision harus approve, reject, atau pending.' });
  if (decision === 'reject' && !config.rejectedApproval) {
    return res.status(409).json({ error: 'Skema belum menyediakan status penolakan. Tambahkan nilai rejected pada enum status_approve_enum lalu atur STATUS_APPROVE_REJECTED.' });
  }
  const status = decision === 'approve'
    ? config.approvedApproval
    : decision === 'reject'
      ? config.rejectedApproval
      : config.pendingApproval;
  const update = { status_approve: status, id_admin: req.admin.id_admin, diperiksa_pada: new Date().toISOString() };
  if (typeof req.body?.catatan_admin === 'string') update.catatan_admin = req.body.catatan_admin.trim();
  if (req.body?.masa_berlaku_sampai !== undefined) {
    const expiry = req.body.masa_berlaku_sampai;
    if (expiry !== null && (typeof expiry !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(expiry))) {
      return res.status(400).json({ error: 'masa_berlaku_sampai harus berformat YYYY-MM-DD atau null.' });
    }
    update.masa_berlaku_sampai = expiry;
  }
  const { data, error } = await adminDb
    .from('dokumen')
    .update(update)
    .eq('id_dokumen', id)
    .select('id_dokumen, id_mitra, id_admin, jenis_dokumen, nomor_dokumen, file_dokumen, status_approve, masa_berlaku_sampai, catatan_admin, diperiksa_pada')
    .maybeSingle();
  if (error) return failDb(error, res);
  if (!data) return res.status(404).json({ error: 'Dokumen tidak ditemukan.' });
  const auditRecorded = await recordAdminActivity(req, `dokumen_${decision}`, 'dokumen', id, { status_approve: status });
  return res.json({ data, audit_recorded: auditRecorded });
}));

app.get('/api/admin/wisata', asyncRoute(async (req, res) => {
  const { page, limit, from, to } = pageParams(req);
  const status = String(req.query.status ?? '');
  let query = adminDb
    .from('wisata')
    .select('id_wisata, id_mitra, id_kategori, id_admin, nama_wisata, lokasi, kota, deskripsi, jenis, subkategori, rata_rating, jml_ulasan, status_approve, admin_wisata(id_mitra, username, nama_lengkap_admin, email), kategori(id_kategori, nama_kategori), foto_wisata(id_foto, url_foto, urutan)', { count: 'exact' });
  if (status) query = query.eq('status_approve', status);
  const { data, error, count } = await query.order('id_wisata', { ascending: false }).range(from, to);
  if (error) return failDb(error, res);
  return res.json({ data, page, limit, total: count ?? 0 });
}));

app.patch('/api/admin/wisata/:id/decision', asyncRoute(async (req, res) => {
  const id = parseId(req.params.id);
  const decision = req.body?.decision;
  if (!id) return res.status(400).json({ error: 'ID wisata tidak valid.' });
  if (!['approve', 'reject', 'pending'].includes(decision)) return res.status(400).json({ error: 'decision harus approve, reject, atau pending.' });
  if (decision === 'reject' && !config.rejectedApproval) {
    return res.status(409).json({ error: 'Skema belum menyediakan status penolakan. Tambahkan nilai rejected pada enum status_approve_enum lalu atur STATUS_APPROVE_REJECTED.' });
  }
  const status = decision === 'approve'
    ? config.approvedApproval
    : decision === 'reject'
      ? config.rejectedApproval
      : config.pendingApproval;
  const { data, error } = await adminDb
    .from('wisata')
    .update({ status_approve: status, id_admin: req.admin.id_admin })
    .eq('id_wisata', id)
    .select('id_wisata, id_mitra, id_admin, nama_wisata, status_approve')
    .maybeSingle();
  if (error) return failDb(error, res);
  if (!data) return res.status(404).json({ error: 'Wisata tidak ditemukan.' });
  const auditRecorded = await recordAdminActivity(req, `wisata_${decision}`, 'wisata', id, { status_approve: status });
  return res.json({ data, audit_recorded: auditRecorded });
}));

app.get('/api/admin/notifikasi', asyncRoute(async (req, res) => {
  const { page, limit, from, to } = pageParams(req);
  let query = adminDb.from('admin_notifikasi').select('*', { count: 'exact' })
    .eq('id_admin', req.admin.id_admin);
  if (req.query.belum_dibaca === 'true') query = query.eq('status_baca', false);
  const { data, error, count } = await query.order('dibuat_pada', { ascending: false }).range(from, to);
  if (error) return failDb(error, res);
  return res.json({ data, page, limit, total: count ?? 0 });
}));

app.patch('/api/admin/notifikasi/:id/read', asyncRoute(async (req, res) => {
  const id = parseId(req.params.id);
  if (!id) return res.status(400).json({ error: 'ID notifikasi tidak valid.' });
  const isRead = req.body?.status_baca ?? true;
  if (typeof isRead !== 'boolean') return res.status(400).json({ error: 'status_baca harus berupa boolean.' });
  const { data, error } = await adminDb.from('admin_notifikasi')
    .update({ status_baca: isRead }).eq('id_notifikasi_admin', id)
    .eq('id_admin', req.admin.id_admin).select().maybeSingle();
  if (error) return failDb(error, res);
  if (!data) return res.status(404).json({ error: 'Notifikasi tidak ditemukan.' });
  return res.json({ data });
}));

app.get('/api/admin/preferensi', asyncRoute(async (req, res) => {
  const { data, error } = await adminDb.from('preferensi_admin').select('*')
    .eq('id_admin', req.admin.id_admin).maybeSingle();
  if (error) return failDb(error, res);
  return res.json({ data: data ?? {
    id_admin: req.admin.id_admin,
    bahasa: 'id',
    zona_waktu: 'Asia/Jakarta',
    preferensi: { push_notification: true, eskalasi_perizinan: true, ringkasan_aktivitas: true },
  } });
}));

app.put('/api/admin/preferensi', asyncRoute(async (req, res) => {
  const { bahasa, zona_waktu, preferensi } = req.body ?? {};
  if (bahasa !== undefined && typeof bahasa !== 'string') return res.status(400).json({ error: 'bahasa harus berupa teks.' });
  if (zona_waktu !== undefined && typeof zona_waktu !== 'string') return res.status(400).json({ error: 'zona_waktu harus berupa teks.' });
  if (preferensi !== undefined && (!preferensi || Array.isArray(preferensi) || typeof preferensi !== 'object')) {
    return res.status(400).json({ error: 'preferensi harus berupa object JSON.' });
  }
  const { data, error } = await adminDb.from('preferensi_admin').upsert({
    id_admin: req.admin.id_admin,
    bahasa: bahasa ?? 'id',
    zona_waktu: zona_waktu ?? 'Asia/Jakarta',
    preferensi: preferensi ?? {},
    diperbarui_pada: new Date().toISOString(),
  }).select().single();
  if (error) return failDb(error, res);
  return res.json({ data });
}));

app.get('/api/admin/aktivitas', asyncRoute(async (req, res) => {
  const { page, limit, from, to } = pageParams(req);
  const { data, error, count } = await adminDb.from('riwayat_aktivitas_admin')
    .select('id_aktivitas_admin, id_admin, aksi, target_tabel, target_id, detail, dibuat_pada, admin_lokatrip(nama_lengkap_admin, email)', { count: 'exact' })
    .order('dibuat_pada', { ascending: false }).range(from, to);
  if (error) return failDb(error, res);
  return res.json({ data, page, limit, total: count ?? 0 });
}));

app.get('/api/admin/laporan', asyncRoute(async (req, res) => {
  const start = typeof req.query.start === 'string' ? req.query.start : undefined;
  const end = typeof req.query.end === 'string' ? req.query.end : undefined;
  let query = adminDb
    .from('pemesanan')
    .select('id_pemesanan, kode_pesan, id_user, tgl_pesan, subtotal, diskon, biaya_layanan, total_bayar, status_pesan, pembayaran(status_bayar, jumlah_bayar), detail_pemesanan(jumlah)');
  if (start) query = query.gte('tgl_pesan', start);
  if (end) query = query.lte('tgl_pesan', end);
  const { data, error } = await query.order('tgl_pesan', { ascending: false }).limit(10000);
  if (error) return failDb(error, res);
  const rows = data ?? [];
  const paid = rows.filter((row) => {
    const payment = Array.isArray(row.pembayaran) ? row.pembayaran[0] : row.pembayaran;
    return ['berhasil', 'dibayar', 'lunas', 'paid'].includes(String(payment?.status_bayar ?? '').toLowerCase());
  });
  return res.json({
    periode: { start: start ?? null, end: end ?? null },
    ringkasan: {
      total_pesanan: rows.length,
      pesanan_terbayar: paid.length,
      tiket_terjual: rows.reduce((sum, row) => sum + (row.detail_pemesanan ?? []).reduce((part, detail) => part + Number(detail.jumlah || 0), 0), 0),
      nilai_transaksi_bruto: paid.reduce((sum, row) => sum + Number(row.total_bayar || 0), 0),
    },
    data: rows,
  });
}));

app.get('/api/admin/profil', (req, res) => res.json({ admin: req.admin }));

app.patch('/api/admin/profil', asyncRoute(async (req, res) => {
  const allowed = ['username', 'nama_lengkap_admin', 'no_telephone'];
  const values = {};
  for (const field of allowed) {
    if (field in (req.body ?? {})) {
      const value = req.body[field];
      if (value !== null && typeof value !== 'string') return res.status(400).json({ error: `${field} harus berupa teks.` });
      values[field] = typeof value === 'string' ? value.trim() : null;
    }
  }
  if (!Object.keys(values).length) return res.status(400).json({ error: 'Tidak ada field profil yang dapat diperbarui.' });
  const { data, error } = await adminDb.from('admin_lokatrip')
    .update(values).eq('id_admin', req.admin.id_admin)
    .select('id_admin, username, nama_lengkap_admin, email, no_telephone').single();
  if (error) return failDb(error, res);
  return res.json({ admin: data });
}));

// In the production container, the same process serves the Flutter Web build
// and the admin API. Local API-only development still works without a web build.
const webBuildDir = path.resolve(process.cwd(), '../build/web');
const webIndex = path.join(webBuildDir, 'index.html');
if (existsSync(webIndex)) {
  app.use(express.static(webBuildDir, { index: false }));
  app.use((req, res, next) => {
    if (req.path === '/health' || req.path.startsWith('/api/')) return next();
    res.sendFile(webIndex, (error) => {
      if (error) next(error);
    });
  });
}

app.use((err, _req, res, _next) => {
  if (config.nodeEnv !== 'production') console.error(err);
  return res.status(500).json({ error: 'Terjadi kesalahan pada backend admin.' });
});

app.listen(config.port, () => {
  console.log(`LokaTrip backend-admin listening on port ${config.port}`);
});

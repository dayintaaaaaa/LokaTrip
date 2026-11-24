import { adminDb, authClient } from './supabase.js';

export async function requireAdmin(req, res, next) {
  const header = req.header('authorization');
  const token = header?.startsWith('Bearer ') ? header.slice(7).trim() : '';
  if (!token) return res.status(401).json({ error: 'Token admin diperlukan.' });

  const { data: authData, error: authError } = await authClient.auth.getUser(token);
  const email = authData.user?.email?.trim().toLowerCase();
  if (authError || !email) {
    return res.status(401).json({ error: 'Sesi tidak valid atau sudah berakhir.' });
  }

  const { data, error } = await adminDb
    .from('admin_lokatrip')
    .select('id_admin, username, nama_lengkap_admin, email, no_telephone')
    .ilike('email', email)
    .maybeSingle();
  if (error) return res.status(500).json({ error: 'Gagal memeriksa akses admin.' });
  if (!data) return res.status(403).json({ error: 'Akun ini tidak terdaftar sebagai admin LokaTrip.' });

  req.admin = data;
  req.bearerToken = token;
  next();
}

export async function requireUser(req, res, next) {
  const header = req.header('authorization');
  const token = header?.startsWith('Bearer ') ? header.slice(7).trim() : '';
  if (!token) return res.status(401).json({ error: 'Token pengguna diperlukan.' });

  const { data: authData, error: authError } = await authClient.auth.getUser(token);
  const authId = authData.user?.id;
  if (authError || !authId) {
    return res.status(401).json({ error: 'Sesi tidak valid atau sudah berakhir.' });
  }

  const { data, error } = await adminDb
    .from('users')
    .select('id_user, nama_lengkap_user, username, email, no_telephone, tgl_lahir, jenis_kelamin, foto_profil, total_poin, status_verif, auth_id')
    .eq('auth_id', authId)
    .maybeSingle();
  if (error) return res.status(500).json({ error: 'Gagal memeriksa profil pengguna.' });
  if (!data) return res.status(403).json({ error: 'Profil pengguna tidak ditemukan.' });

  req.user = data;
  req.authUser = authData.user;
  req.bearerToken = token;
  next();
}

export async function requireMitra(req, res, next) {
  const header = req.header('authorization');
  const token = header?.startsWith('Bearer ') ? header.slice(7).trim() : '';
  if (!token) return res.status(401).json({ error: 'Token mitra diperlukan.' });

  const { data: authData, error: authError } = await authClient.auth.getUser(token);
  const email = authData.user?.email?.trim().toLowerCase();
  if (authError || !email) return res.status(401).json({ error: 'Sesi mitra tidak valid atau sudah berakhir.' });

  const { data, error } = await adminDb.from('admin_wisata')
    .select('id_mitra, id_admin, username, nama_lengkap_admin, email, no_telephone')
    .ilike('email', email).maybeSingle();
  if (error) return res.status(500).json({ error: 'Gagal memeriksa akses mitra.' });
  if (!data) return res.status(403).json({ error: 'Akun ini tidak terdaftar sebagai mitra LokaTrip.' });

  req.mitra = data;
  req.bearerToken = token;
  next();
}

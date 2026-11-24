import { createClient } from 'jsr:@supabase/supabase-js@2'

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

const failure = { error: 'Email/username atau password salah.' }
const respond = (body: unknown, status = 200) =>
  Response.json(body, { status, headers: cors })

function normalizePhone(input: string): string {
  const phone = input.replace(/[\s\-()]/g, '')
  if (phone.startsWith('+62')) return phone
  if (phone.startsWith('62')) return `+${phone}`
  if (phone.startsWith('0')) return `+62${phone.slice(1)}`
  return phone
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors })
  if (req.method !== 'POST') return respond(failure, 405)

  try {
    const body = await req.json()
    const action = String(body.action ?? '')
    const identifier = String(body.identifier ?? body.phone ?? '').trim()
    const password = String(body.password ?? '')

    const url = Deno.env.get('SUPABASE_URL')!
    const service = createClient(
      url,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
      { auth: { persistSession: false, autoRefreshToken: false } },
    )

    if (action === 'provision_mitra_auth') {
      const bearer = req.headers.get('Authorization') ?? ''
      const token = bearer.startsWith('Bearer ') ? bearer.slice(7) : ''
      if (!token) return respond({ error: 'Sesi admin diperlukan.' }, 401)

      const { data: authData, error: authError } = await service.auth.getUser(token)
      if (authError || !authData.user) {
        return respond({ error: 'Sesi admin tidak valid.' }, 401)
      }
      const { data: admin } = await service
        .from('admin_lokatrip')
        .select('id_admin')
        .eq('auth_id', authData.user.id)
        .maybeSingle()
      if (!admin) return respond({ error: 'Hanya admin yang dapat membuat akun mitra.' }, 403)

      const mitraId = Number(body.id_mitra)
      const email = String(body.email ?? '').trim().toLowerCase()
      const mitraPassword = String(body.password ?? '')
      if (!Number.isInteger(mitraId) || !email.includes('@') || mitraPassword.length < 8) {
        return respond({ error: 'ID mitra, email valid, dan password minimal 8 karakter wajib diisi.' }, 400)
      }
      const { data: mitra } = await service
        .from('admin_wisata')
        .select('id_mitra')
        .eq('id_mitra', mitraId)
        .maybeSingle()
      if (!mitra) return respond({ error: 'Data mitra tidak ditemukan.' }, 404)

      const { data: created, error: createError } = await service.auth.admin.createUser({
        email,
        password: mitraPassword,
        email_confirm: true,
        user_metadata: { account_role: 'mitra' },
      })
      if (createError || !created.user) {
        return respond({ error: createError?.message ?? 'Akun Auth mitra gagal dibuat.' }, 400)
      }

      const { error: updateError } = await service
        .from('admin_wisata')
        .update({ email, password: null })
        .eq('id_mitra', mitraId)
      if (updateError) {
        await service.auth.admin.deleteUser(created.user.id)
        return respond({ error: `Akun Auth dibuat, tetapi profil mitra gagal diperbarui: ${updateError.message}` }, 400)
      }
      return respond({ success: true, email })
    }

    if (!identifier || !password) return respond(failure, 400)

    const auth = createClient(
      url,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { auth: { persistSession: false, autoRefreshToken: false } },
    )

    const candidates: Array<{ role: string; email: string; authId?: string }> = []
    const isEmail = identifier.includes('@')
    const isPhone = /^[+\d\s()-]+$/.test(identifier)

    if (isEmail) {
      const [admin, mitra, user] = await Promise.all([
        service.from('admin_lokatrip').select('email, auth_id').ilike('email', identifier).maybeSingle(),
        service.from('admin_wisata').select('email').ilike('email', identifier).maybeSingle(),
        service.from('users').select('email, auth_id').ilike('email', identifier).maybeSingle(),
      ])
      if (admin.data?.email && admin.data.auth_id) candidates.push({ role: 'admin', email: admin.data.email, authId: admin.data.auth_id })
      if (mitra.data?.email) candidates.push({ role: 'mitra', email: mitra.data.email })
      if (user.data?.email && user.data.auth_id) candidates.push({ role: 'wisatawan', email: user.data.email, authId: user.data.auth_id })
    } else {
      if (isPhone) {
        const phone = normalizePhone(identifier)
        const { data } = await service.from('users').select('email, auth_id').eq('no_telephone', phone).maybeSingle()
        if (data?.email && data.auth_id) candidates.push({ role: 'wisatawan', email: data.email, authId: data.auth_id })
      }
      const [admin, mitra, user] = await Promise.all([
        service.from('admin_lokatrip').select('email, auth_id').eq('username', identifier).maybeSingle(),
        service.from('admin_wisata').select('email').eq('username', identifier).maybeSingle(),
        service.from('users').select('email, auth_id').eq('username', identifier).maybeSingle(),
      ])
      if (admin.data?.email && admin.data.auth_id) candidates.push({ role: 'admin', email: admin.data.email, authId: admin.data.auth_id })
      if (mitra.data?.email) candidates.push({ role: 'mitra', email: mitra.data.email })
      if (user.data?.email && user.data.auth_id) candidates.push({ role: 'wisatawan', email: user.data.email, authId: user.data.auth_id })
    }

    for (const candidate of candidates) {
      const { data, error } = await auth.auth.signInWithPassword({
        email: candidate.email,
        password,
      })
      if (error || !data.session || !data.user) continue
      if (candidate.authId && candidate.authId !== data.user.id) continue
      return respond({
        role: candidate.role,
        session: {
          access_token: data.session.access_token,
          refresh_token: data.session.refresh_token,
        },
      })
    }

    return respond(failure, 401)
  } catch {
    return respond(failure, 400)
  }
})

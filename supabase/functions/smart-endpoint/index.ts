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

const passwordIterations = 150_000

function hex(bytes: Uint8Array): string {
  return Array.from(bytes, (value) => value.toString(16).padStart(2, '0')).join('')
}

function base64(bytes: Uint8Array): string {
  return btoa(String.fromCharCode(...bytes))
}

async function passwordHash(password: string, salt: Uint8Array): Promise<string> {
  const key = await crypto.subtle.importKey(
    'raw', new TextEncoder().encode(password), 'PBKDF2', false, ['deriveBits'],
  )
  const bits = await crypto.subtle.deriveBits({
    name: 'PBKDF2', hash: 'SHA-256', salt, iterations: passwordIterations,
  }, key, 256)
  return hex(new Uint8Array(bits))
}

async function passwordMatches(password: string, storedHash: string | undefined): Promise<boolean> {
  const [scheme, iterations, saltText, expected] = storedHash?.split('$') ?? []
  if (scheme !== 'pbkdf2_sha256' || !saltText || !expected || !iterations || Number(iterations) !== passwordIterations) {
    return false
  }
  const salt = Uint8Array.from(atob(saltText), (char) => char.charCodeAt(0))
  const actual = await passwordHash(password, salt)
  if (actual.length !== expected.length) return false
  let difference = 0
  for (let index = 0; index < actual.length; index++) {
    difference |= actual.charCodeAt(index) ^ expected.charCodeAt(index)
  }
  return difference === 0
}

async function sha256(value: string): Promise<string> {
  return hex(new Uint8Array(await crypto.subtle.digest('SHA-256', new TextEncoder().encode(value))))
}

async function readMitraSession(service: ReturnType<typeof createClient>, token: string) {
  if (token.length < 32) return null
  const { data } = await service.from('mitra_login_sessions')
    .select('id_mitra').eq('token_hash', await sha256(token))
    .gt('expires_at', new Date().toISOString()).maybeSingle()
  return (data?.id_mitra as number | undefined) ?? null
}

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

    if (action === 'provision_mitra_account') {
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
      if (!Number.isInteger(mitraId) || !/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email) || mitraPassword.length < 8) {
        return respond({ error: 'ID mitra, email valid, dan password minimal 8 karakter wajib diisi.' }, 400)
      }
      const { data: mitra } = await service
        .from('admin_wisata')
        .select('id_mitra')
        .eq('id_mitra', mitraId)
        .maybeSingle()
      if (!mitra) return respond({ error: 'Data mitra tidak ditemukan.' }, 404)

      const [duplicateMitra, duplicateAdmin, duplicateUser] = await Promise.all([
        service.from('admin_wisata').select('id_mitra')
          .ilike('email', email).neq('id_mitra', mitraId).maybeSingle(),
        service.from('admin_lokatrip').select('id_admin').ilike('email', email).maybeSingle(),
        service.from('users').select('id_user').ilike('email', email).maybeSingle(),
      ])
      if (duplicateMitra.error || duplicateAdmin.error || duplicateUser.error) {
        return respond({ error: 'Email akun tidak dapat diverifikasi.' }, 500)
      }
      if (duplicateMitra.data || duplicateAdmin.data || duplicateUser.data) {
        return respond({ error: 'Email sudah dipakai akun lain.' }, 409)
      }

      const { error: updateError } = await service
        .from('admin_wisata')
        .update({ email, password: null })
        .eq('id_mitra', mitraId)
      if (updateError) {
        return respond({ error: `Profil mitra gagal diperbarui: ${updateError.message}` }, 400)
      }
      const salt = crypto.getRandomValues(new Uint8Array(16))
      const hash = await passwordHash(mitraPassword, salt)
      const { error: credentialError } = await service
        .from('mitra_login_credentials')
        .upsert({
          id_mitra: mitraId,
          password_hash: `pbkdf2_sha256$${passwordIterations}$${base64(salt)}$${hash}`,
          diperbarui_pada: new Date().toISOString(),
        })
      if (credentialError) {
        return respond({ error: `Password akun mitra gagal disimpan: ${credentialError.message}` }, 400)
      }
      await service.from('mitra_login_sessions').delete().eq('id_mitra', mitraId)
      return respond({ success: true, email, username: body.username ?? null })
    }

    if (action === 'mitra_login') {
      const loginIdentifier = identifier.toLowerCase()
      const isEmail = loginIdentifier.includes('@')
      const { data: mitra, error: mitraError } = await service
        .from('admin_wisata')
        .select('id_mitra, id_admin, username, nama_lengkap_admin, email, no_telephone, password')
        .ilike(isEmail ? 'email' : 'username', loginIdentifier)
        .maybeSingle()
      if (mitraError || !mitra) return respond(failure, 401)
      let { data: credential } = await service.from('mitra_login_credentials')
        .select('password_hash').eq('id_mitra', mitra.id_mitra).maybeSingle()
      let validPassword = await passwordMatches(
        password,
        credential?.password_hash as string | undefined,
      )
      // Upgrade a legacy password stored on admin_wisata at the first successful
      // login, then erase the old value from the profile row.
      if (!validPassword && !credential?.password_hash &&
        typeof mitra.password === 'string' && mitra.password === password && password.length >= 8) {
        const salt = crypto.getRandomValues(new Uint8Array(16))
        const hash = await passwordHash(password, salt)
        const { data: migrated, error: migrateError } = await service
          .from('mitra_login_credentials')
          .upsert({
            id_mitra: mitra.id_mitra,
            password_hash: `pbkdf2_sha256$${passwordIterations}$${base64(salt)}$${hash}`,
            diperbarui_pada: new Date().toISOString(),
          })
          .select('password_hash')
          .single()
        if (!migrateError && migrated) {
          credential = migrated
          validPassword = true
        }
      }
      if (!validPassword) {
        return respond(failure, 401)
      }
      if (typeof mitra.password === 'string' && mitra.password.length > 0) {
        const { error: clearLegacyError } = await service
          .from('admin_wisata').update({ password: null })
          .eq('id_mitra', mitra.id_mitra)
        if (clearLegacyError) return respond({ error: 'Kredensial lama gagal diamankan.' }, 500)
      }
      const tokenBytes = crypto.getRandomValues(new Uint8Array(32))
      const token = hex(tokenBytes)
      const now = new Date()
      const expiresAt = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000).toISOString()
      await service.from('mitra_login_sessions').delete().lt('expires_at', now.toISOString())
      const { error: sessionError } = await service.from('mitra_login_sessions').insert({
        token_hash: await sha256(token),
        id_mitra: mitra.id_mitra,
        expires_at: expiresAt,
      })
      if (sessionError) return respond({ error: 'Sesi login mitra gagal dibuat.' }, 500)
      const { password: _legacyPassword, ...safeMitra } = mitra
      return respond({ role: 'mitra', mitra: safeMitra, mitra_session: token, expires_at: expiresAt })
    }

    if (action === 'mitra_logout') {
      const token = String(body.mitra_session ?? '')
      if (token.length >= 32) {
        await service.from('mitra_login_sessions').delete().eq('token_hash', await sha256(token))
      }
      return respond({ success: true })
    }

    if (action === 'mitra_session_check') {
      const mitraId = await readMitraSession(service, String(body.mitra_session ?? ''))
      return mitraId == null
        ? respond({ error: 'Sesi mitra sudah berakhir.' }, 401)
        : respond({ success: true })
    }

    if (action === 'mitra_change_password' || action === 'mitra_change_email') {
      const token = String(body.mitra_session ?? '')
      const mitraId = await readMitraSession(service, token)
      if (mitraId == null) return respond({ error: 'Sesi mitra tidak valid atau sudah berakhir.' }, 401)
      const { data: credential } = await service.from('mitra_login_credentials')
        .select('password_hash').eq('id_mitra', mitraId).maybeSingle()
      const currentPassword = String(body.current_password ?? '')
      if (!(await passwordMatches(currentPassword, credential?.password_hash as string | undefined))) {
        return respond({ error: 'Password saat ini salah.' }, 401)
      }

      if (action === 'mitra_change_password') {
        const newPassword = String(body.new_password ?? '')
        if (newPassword.length < 8) return respond({ error: 'Password baru minimal 8 karakter.' }, 400)
        const salt = crypto.getRandomValues(new Uint8Array(16))
        const hash = await passwordHash(newPassword, salt)
        const { error } = await service.from('mitra_login_credentials').update({
          password_hash: `pbkdf2_sha256$${passwordIterations}$${base64(salt)}$${hash}`,
          diperbarui_pada: new Date().toISOString(),
        }).eq('id_mitra', mitraId)
        if (error) return respond({ error: 'Password baru gagal disimpan.' }, 500)
        await service.from('mitra_login_sessions').delete()
          .eq('id_mitra', mitraId)
          .neq('token_hash', await sha256(token))
        return respond({ success: true })
      }

      const newEmail = String(body.new_email ?? '').trim().toLowerCase()
      if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(newEmail)) {
        return respond({ error: 'Email baru tidak valid.' }, 400)
      }
      const [duplicateMitra, duplicateAdmin, duplicateUser] = await Promise.all([
        service.from('admin_wisata').select('id_mitra')
          .ilike('email', newEmail).neq('id_mitra', mitraId).maybeSingle(),
        service.from('admin_lokatrip').select('id_admin').ilike('email', newEmail).maybeSingle(),
        service.from('users').select('id_user').ilike('email', newEmail).maybeSingle(),
      ])
      if (duplicateMitra.error || duplicateAdmin.error || duplicateUser.error) {
        return respond({ error: 'Email akun tidak dapat diverifikasi.' }, 500)
      }
      if (duplicateMitra.data || duplicateAdmin.data || duplicateUser.data) {
        return respond({ error: 'Email sudah dipakai akun lain.' }, 409)
      }
      const { data: updated, error } = await service.from('admin_wisata')
        .update({ email: newEmail }).eq('id_mitra', mitraId)
        .select('id_mitra, id_admin, username, nama_lengkap_admin, email, no_telephone')
        .single()
      if (error || !updated) return respond({ error: 'Email login gagal diperbarui.' }, 400)
      return respond({ success: true, mitra: updated, mitra_session: token })
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
      const [admin, user] = await Promise.all([
        service.from('admin_lokatrip').select('email, auth_id').ilike('email', identifier).maybeSingle(),
        service.from('users').select('email, auth_id').ilike('email', identifier).maybeSingle(),
      ])
      if (admin.data?.email && admin.data.auth_id) candidates.push({ role: 'admin', email: admin.data.email, authId: admin.data.auth_id })
      if (user.data?.email && user.data.auth_id) candidates.push({ role: 'wisatawan', email: user.data.email, authId: user.data.auth_id })
    } else {
      if (isPhone) {
        const phone = normalizePhone(identifier)
        const { data } = await service.from('users').select('email, auth_id').eq('no_telephone', phone).maybeSingle()
        if (data?.email && data.auth_id) candidates.push({ role: 'wisatawan', email: data.email, authId: data.auth_id })
      }
      const [admin, user] = await Promise.all([
        service.from('admin_lokatrip').select('email, auth_id').eq('username', identifier).maybeSingle(),
        service.from('users').select('email, auth_id').eq('username', identifier).maybeSingle(),
      ])
      if (admin.data?.email && admin.data.auth_id) candidates.push({ role: 'admin', email: admin.data.email, authId: admin.data.auth_id })
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

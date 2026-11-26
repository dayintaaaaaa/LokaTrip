begin;

create schema if not exists extensions;
create extension if not exists pgcrypto with schema extensions;

create table if not exists public.mitra_login_credentials (
  id_mitra integer primary key references public.admin_wisata(id_mitra) on delete cascade,
  password_hash text not null,
  dibuat_pada timestamptz not null default now(),
  diperbarui_pada timestamptz not null default now()
);

create table if not exists public.mitra_login_sessions (
  token_hash text primary key,
  id_mitra integer not null references public.admin_wisata(id_mitra) on delete cascade,
  expires_at timestamptz not null,
  dibuat_pada timestamptz not null default now()
);

create index if not exists mitra_login_sessions_mitra_id_idx
  on public.mitra_login_sessions (id_mitra);
create index if not exists mitra_login_sessions_expires_at_idx
  on public.mitra_login_sessions (expires_at);

comment on table public.mitra_login_credentials is
  'Server-only PBKDF2 password hashes for database-backed mitra login.';
comment on table public.mitra_login_sessions is
  'Server-only opaque mitra sessions; clients receive only the random token.';

alter table public.mitra_login_credentials enable row level security;
alter table public.mitra_login_sessions enable row level security;
revoke all on public.mitra_login_credentials, public.mitra_login_sessions
  from public, anon, authenticated;
grant all on public.mitra_login_credentials, public.mitra_login_sessions
  to service_role;

create or replace function private.current_mitra_id()
returns integer
language sql
stable
security definer
set search_path = ''
as $$
  select s.id_mitra
  from public.mitra_login_sessions s
  where s.token_hash = encode(
    extensions.digest(
      coalesce(
        nullif(substring(
          current_setting('request.headers', true)::jsonb ->> 'x-client-info'
          from '^lokatrip-mitra-session/([0-9a-f]{64})$'
        ), ''),
        ''
      ),
      'sha256'
    ),
    'hex'
  )
    and s.expires_at > now()
  limit 1;
$$;

revoke all on function private.current_mitra_id() from public;
grant execute on function private.current_mitra_id() to anon, authenticated;

-- Mitra sessions use the anon PostgREST role and are narrowed to one partner.
grant select (id_mitra, id_admin, username, nama_lengkap_admin, email, no_telephone)
  on public.admin_wisata to anon;
grant update (username, nama_lengkap_admin, no_telephone)
  on public.admin_wisata to anon;
grant select, delete on public.wisata to anon;
grant insert (id_mitra, id_kategori, nama_wisata, lokasi, kota, jam_buka,
  jam_tutup, deskripsi, jenis, subkategori, status_approve)
  on public.wisata to anon;
grant update (nama_wisata, lokasi, kota, jam_buka, jam_tutup, deskripsi,
  jenis, subkategori, id_kategori) on public.wisata to anon;
grant select, delete on public.paket_wisata,
  public.detail_paket, public.kuota_harian, public.foto_wisata to anon;
grant insert (id_wisata, nama_paket, tipe_paket, deskripsi, status_aktif)
  on public.paket_wisata to anon;
grant insert (id_paket, tipe_pengunjung, harga)
  on public.detail_paket to anon;
grant insert (id_paket, tanggal, kuota_total, kuota_terpakai)
  on public.kuota_harian to anon;
grant insert (id_wisata, url_foto, urutan) on public.foto_wisata to anon;
grant select on public.dokumen to anon;
grant insert (id_mitra, jenis_dokumen, nomor_dokumen, file_dokumen,
  masa_berlaku_sampai) on public.dokumen to anon;
grant select on public.status_mitra_admin to anon;
grant delete on public.dokumen to anon;
grant update (nama_paket) on public.paket_wisata to anon;
grant update (harga) on public.detail_paket to anon;
grant execute on function public.mitra_ringkasan_pembayaran() to anon;
do $$
declare
  table_name text;
  sequence_name text;
begin
  foreach table_name in array array[
    'dokumen', 'wisata', 'paket_wisata', 'detail_paket', 'foto_wisata', 'kuota_harian'
  ] loop
    for sequence_name in
      select pg_get_serial_sequence('public.' || table_name, a.attname)
      from pg_attribute a
      where a.attrelid = ('public.' || table_name)::regclass
        and a.attnum > 0 and not a.attisdropped
    loop
      if sequence_name is not null then
        execute format('grant usage, select on sequence %s to anon', sequence_name);
      end if;
    end loop;
  end loop;
end;
$$;

revoke select on public.admin_wisata from authenticated;
grant select (id_mitra, id_admin, username, nama_lengkap_admin, email, no_telephone)
  on public.admin_wisata to authenticated;

drop policy if exists mitra_read_self_or_admin on public.admin_wisata;
create policy mitra_read_self_or_admin on public.admin_wisata
  for select to anon, authenticated
  using (id_mitra = private.current_mitra_id() or private.is_admin());
drop policy if exists mitra_update_self_or_admin on public.admin_wisata;
create policy mitra_update_self_or_admin on public.admin_wisata
  for update to anon, authenticated
  using (id_mitra = private.current_mitra_id() or private.is_admin())
  with check (id_mitra = private.current_mitra_id() or private.is_admin());

drop policy if exists wisata_read_approved_or_owner_or_admin on public.wisata;
create policy wisata_read_approved_or_owner_or_admin on public.wisata
  for select to anon, authenticated
  using (status_approve = 'Y' or private.is_admin()
    or id_mitra = private.current_mitra_id());
drop policy if exists wisata_insert_mitra_or_admin on public.wisata;
create policy wisata_insert_mitra_or_admin on public.wisata
  for insert to anon, authenticated
  with check (private.is_admin() or (
    id_mitra = private.current_mitra_id() and status_approve = 'N'
  ));
drop policy if exists wisata_update_mitra_or_admin on public.wisata;
create policy wisata_update_mitra_or_admin on public.wisata
  for update to anon, authenticated
  using (private.is_admin() or id_mitra = private.current_mitra_id())
  with check (private.is_admin() or id_mitra = private.current_mitra_id());

drop policy if exists paket_wisata_read_catalog on public.paket_wisata;
create policy paket_wisata_read_catalog on public.paket_wisata
  for select to anon, authenticated
  using (status_aktif or private.is_admin()
    or exists (select 1 from public.wisata w
      where w.id_wisata = paket_wisata.id_wisata
        and w.id_mitra = private.current_mitra_id()));
drop policy if exists dokumen_read_owner_or_admin on public.dokumen;
create policy dokumen_read_owner_or_admin on public.dokumen
  for select to anon, authenticated
  using (private.is_admin() or id_mitra = private.current_mitra_id());
drop policy if exists dokumen_insert_mitra on public.dokumen;
create policy dokumen_insert_mitra on public.dokumen
  for insert to anon, authenticated
  with check (id_mitra = private.current_mitra_id() and id_admin is null);
drop policy if exists wisata_delete_pending_owner on public.wisata;
create policy wisata_delete_pending_owner on public.wisata
  for delete to anon, authenticated
  using (id_mitra = private.current_mitra_id() and status_approve = 'N');
drop policy if exists foto_wisata_insert_pending_owner on public.foto_wisata;
create policy foto_wisata_insert_pending_owner on public.foto_wisata
  for insert to anon, authenticated
  with check (exists (select 1 from public.wisata w
    where w.id_wisata = foto_wisata.id_wisata
      and w.id_mitra = private.current_mitra_id()
      and w.status_approve = 'N'));
drop policy if exists foto_wisata_delete_pending_owner on public.foto_wisata;
create policy foto_wisata_delete_pending_owner on public.foto_wisata
  for delete to anon, authenticated
  using (exists (select 1 from public.wisata w
    where w.id_wisata = foto_wisata.id_wisata
      and w.id_mitra = private.current_mitra_id()
      and w.status_approve = 'N'));
drop policy if exists paket_wisata_insert_pending_owner on public.paket_wisata;
create policy paket_wisata_insert_pending_owner on public.paket_wisata
  for insert to anon, authenticated
  with check (exists (select 1 from public.wisata w
    where w.id_wisata = paket_wisata.id_wisata
      and w.id_mitra = private.current_mitra_id()
      and w.status_approve = 'N'));
drop policy if exists paket_wisata_delete_pending_owner on public.paket_wisata;
create policy paket_wisata_delete_pending_owner on public.paket_wisata
  for delete to anon, authenticated
  using (exists (select 1 from public.wisata w
    where w.id_wisata = paket_wisata.id_wisata
      and w.id_mitra = private.current_mitra_id()
      and w.status_approve = 'N'));
drop policy if exists paket_wisata_update_owner on public.paket_wisata;
create policy paket_wisata_update_owner on public.paket_wisata
  for update to anon, authenticated
  using (exists (select 1 from public.wisata w
    where w.id_wisata = paket_wisata.id_wisata
      and w.id_mitra = private.current_mitra_id()))
  with check (exists (select 1 from public.wisata w
    where w.id_wisata = paket_wisata.id_wisata
      and w.id_mitra = private.current_mitra_id()));
drop policy if exists detail_paket_insert_pending_owner on public.detail_paket;
create policy detail_paket_insert_pending_owner on public.detail_paket
  for insert to anon, authenticated
  with check (exists (select 1 from public.paket_wisata p
    join public.wisata w on w.id_wisata = p.id_wisata
    where p.id_paket = detail_paket.id_paket
      and w.id_mitra = private.current_mitra_id()
      and w.status_approve = 'N'));
drop policy if exists detail_paket_delete_pending_owner on public.detail_paket;
create policy detail_paket_delete_pending_owner on public.detail_paket
  for delete to anon, authenticated
  using (exists (select 1 from public.paket_wisata p
    join public.wisata w on w.id_wisata = p.id_wisata
    where p.id_paket = detail_paket.id_paket
      and w.id_mitra = private.current_mitra_id()
      and w.status_approve = 'N'));
drop policy if exists detail_paket_update_owner on public.detail_paket;
create policy detail_paket_update_owner on public.detail_paket
  for update to anon, authenticated
  using (exists (select 1 from public.paket_wisata p
    join public.wisata w on w.id_wisata = p.id_wisata
    where p.id_paket = detail_paket.id_paket
      and w.id_mitra = private.current_mitra_id()))
  with check (exists (select 1 from public.paket_wisata p
    join public.wisata w on w.id_wisata = p.id_wisata
    where p.id_paket = detail_paket.id_paket
      and w.id_mitra = private.current_mitra_id()));
drop policy if exists kuota_harian_insert_pending_owner on public.kuota_harian;
create policy kuota_harian_insert_pending_owner on public.kuota_harian
  for insert to anon, authenticated
  with check (exists (select 1 from public.paket_wisata p
    join public.wisata w on w.id_wisata = p.id_wisata
    where p.id_paket = kuota_harian.id_paket
      and w.id_mitra = private.current_mitra_id()
      and w.status_approve = 'N'));
drop policy if exists kuota_harian_delete_pending_owner on public.kuota_harian;
create policy kuota_harian_delete_pending_owner on public.kuota_harian
  for delete to anon, authenticated
  using (exists (select 1 from public.paket_wisata p
    join public.wisata w on w.id_wisata = p.id_wisata
    where p.id_paket = kuota_harian.id_paket
      and w.id_mitra = private.current_mitra_id()
      and w.status_approve = 'N'));
drop policy if exists dokumen_delete_pending_owner on public.dokumen;
create policy dokumen_delete_pending_owner on public.dokumen
  for delete to anon, authenticated
  using (id_mitra = private.current_mitra_id() and status_approve = 'N');
drop policy if exists status_mitra_read_owner_or_admin on public.status_mitra_admin;
create policy status_mitra_read_owner_or_admin on public.status_mitra_admin
  for select to anon, authenticated
  using (private.is_admin() or id_mitra = private.current_mitra_id());

drop policy if exists mitra_storage_upload on storage.objects;
create policy mitra_storage_upload on storage.objects
  for insert to anon, authenticated
  with check (
    bucket_id in ('lokatrip-legalitas', 'lokatrip-wisata')
    and (storage.foldername(name))[1] = private.current_mitra_id()::text
  );
drop policy if exists mitra_storage_read_legalitas on storage.objects;
create policy mitra_storage_read_legalitas on storage.objects
  for select to anon, authenticated
  using (
    (bucket_id = 'lokatrip-legalitas'
      and (storage.foldername(name))[1] = private.current_mitra_id()::text)
    or (bucket_id = 'lokatrip-legalitas' and private.is_admin())
  );
drop policy if exists mitra_storage_delete_own on storage.objects;
create policy mitra_storage_delete_own on storage.objects
  for delete to anon, authenticated
  using (bucket_id in ('lokatrip-legalitas', 'lokatrip-wisata')
    and (storage.foldername(name))[1] = private.current_mitra_id()::text);
drop policy if exists mitra_storage_read_wisata on storage.objects;
create policy mitra_storage_read_wisata on storage.objects
  for select to anon, authenticated
  using (bucket_id = 'lokatrip-wisata'
    and (storage.foldername(name))[1] = private.current_mitra_id()::text);

commit;

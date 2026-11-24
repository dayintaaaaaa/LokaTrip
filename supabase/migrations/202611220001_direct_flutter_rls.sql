-- Direct Flutter access replaces the Express service. Keep every write scoped
-- to the authenticated profile and reserve admin-only records for admins.

begin;

create schema if not exists private;
revoke all on schema private from public;
grant usage on schema private to anon, authenticated;

create or replace function private.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.admin_lokatrip a
    where a.auth_id = (select auth.uid())
  );
$$;

create or replace function private.current_admin_id()
returns integer
language sql
stable
security definer
set search_path = ''
as $$
  select a.id_admin from public.admin_lokatrip a
  where a.auth_id = (select auth.uid())
  limit 1;
$$;

create or replace function private.current_user_id()
returns integer
language sql
stable
security definer
set search_path = ''
as $$
  select u.id_user from public.users u
  where u.auth_id = (select auth.uid())
  limit 1;
$$;

create or replace function private.current_mitra_id()
returns integer
language sql
stable
security definer
set search_path = ''
as $$
  select m.id_mitra from public.admin_wisata m
  where lower(m.email) = lower((select auth.jwt() ->> 'email'))
  limit 1;
$$;

revoke all on function private.is_admin() from public;
revoke all on function private.current_admin_id() from public;
revoke all on function private.current_user_id() from public;
revoke all on function private.current_mitra_id() from public;
grant execute on function private.is_admin() to anon, authenticated;
grant execute on function private.current_admin_id() to authenticated;
grant execute on function private.current_user_id() to authenticated;
grant execute on function private.current_mitra_id() to anon, authenticated;

grant select on public.kategori, public.fasilitas, public.tag_ulasan to anon, authenticated;
grant select on public.wisata, public.foto_wisata, public.paket_wisata,
  public.detail_paket, public.detail_fasilitas, public.kuota_harian to anon, authenticated;
grant select, insert, delete on public.wishlist to authenticated;
grant select, update on public.notifikasi to authenticated;
grant select on public.riwayat_poin, public.ulasan, public.pemesanan,
  public.detail_pemesanan, public.pembayaran, public.e_tiket to authenticated;
grant insert on public.ulasan to authenticated;
grant select on public.users to authenticated;
revoke insert, update, delete on public.users from authenticated;
grant update (nama_lengkap_user, username, no_telephone, tgl_lahir,
  jenis_kelamin, foto_profil, pin_transaksi) on public.users to authenticated;
grant select on public.admin_lokatrip to authenticated;
revoke update on public.admin_lokatrip from authenticated;
grant update (username, nama_lengkap_admin, no_telephone)
  on public.admin_lokatrip to authenticated;
grant select on public.admin_wisata to authenticated;
revoke update on public.admin_wisata from authenticated;
grant update (username, nama_lengkap_admin, no_telephone)
  on public.admin_wisata to authenticated;
grant select on public.dokumen to authenticated;
revoke insert, update, delete on public.dokumen from authenticated;
grant insert (id_mitra, jenis_dokumen, nomor_dokumen, file_dokumen,
  masa_berlaku_sampai) on public.dokumen to authenticated;
grant select on public.wisata to authenticated;
revoke insert, update on public.wisata from authenticated;
grant update (nama_wisata, lokasi, kota, jam_buka, jam_tutup, deskripsi,
  jenis, subkategori, id_kategori) on public.wisata to authenticated;
grant select, update on public.admin_notifikasi to authenticated;
revoke insert, delete on public.admin_notifikasi from authenticated;
revoke update on public.admin_notifikasi from authenticated;
grant update (status_baca) on public.admin_notifikasi to authenticated;
grant select, insert, update on public.preferensi_admin,
  public.riwayat_aktivitas_admin,
  public.status_mitra_admin to authenticated;
revoke update, delete on public.riwayat_aktivitas_admin from authenticated;
revoke delete on public.status_mitra_admin, public.preferensi_admin from authenticated;
grant select on public.admin_notifikasi to authenticated;
grant usage, select on sequence public.wishlist_id_wishlist_seq,
  public.ulasan_id_ulasan_seq to authenticated;

-- Keep approval fields writable only through admin-checked database functions.
revoke update on public.wisata, public.dokumen from authenticated;
grant update (nama_wisata, lokasi, kota, jam_buka, jam_tutup, deskripsi,
  jenis, subkategori, id_kategori) on public.wisata to authenticated;

create or replace function public.admin_decide_wisata(
  p_id_wisata integer,
  p_decision text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_status public.status_approve_enum;
  v_admin_id integer;
  v_row jsonb;
begin
  if not private.is_admin() then raise exception 'AKSES_DITOLAK'; end if;
  v_admin_id := private.current_admin_id();
  v_status := case p_decision
    when 'approve' then 'Y'::public.status_approve_enum
    when 'pending' then 'N'::public.status_approve_enum
    else null
  end;
  if v_status is null then raise exception 'KEPUTUSAN_TIDAK_VALID'; end if;
  update public.wisata as w
    set status_approve = v_status, id_admin = v_admin_id
    where w.id_wisata = p_id_wisata
    returning to_jsonb(w) into v_row;
  if v_row is null then raise exception 'WISATA_TIDAK_DITEMUKAN'; end if;
  insert into public.riwayat_aktivitas_admin
    (id_admin, aksi, target_tabel, target_id, detail)
    values (v_admin_id, 'wisata_' || p_decision, 'wisata',
      p_id_wisata::text, jsonb_build_object('status_approve', v_status::text));
  return v_row;
end;
$$;

create or replace function public.admin_decide_dokumen(
  p_id_dokumen integer,
  p_decision text,
  p_note text default null,
  p_expiry date default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_status public.status_approve_enum;
  v_admin_id integer;
  v_row jsonb;
begin
  if not private.is_admin() then raise exception 'AKSES_DITOLAK'; end if;
  v_admin_id := private.current_admin_id();
  v_status := case p_decision
    when 'approve' then 'Y'::public.status_approve_enum
    when 'pending' then 'N'::public.status_approve_enum
    else null
  end;
  if v_status is null then raise exception 'KEPUTUSAN_TIDAK_VALID'; end if;
  update public.dokumen as d
    set status_approve = v_status,
        id_admin = v_admin_id,
        diperiksa_pada = now(),
        catatan_admin = coalesce(p_note, d.catatan_admin),
        masa_berlaku_sampai = coalesce(p_expiry, d.masa_berlaku_sampai)
    where d.id_dokumen = p_id_dokumen
    returning to_jsonb(d) into v_row;
  if v_row is null then raise exception 'DOKUMEN_TIDAK_DITEMUKAN'; end if;
  insert into public.riwayat_aktivitas_admin
    (id_admin, aksi, target_tabel, target_id, detail)
    values (v_admin_id, 'dokumen_' || p_decision, 'dokumen',
      p_id_dokumen::text, jsonb_build_object('status_approve', v_status::text));
  return v_row;
end;
$$;

create or replace function public.admin_set_mitra_status(
  p_id_mitra integer,
  p_status text,
  p_note text default null,
  p_featured boolean default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_admin_id integer;
  v_row jsonb;
begin
  if not private.is_admin() then raise exception 'AKSES_DITOLAK'; end if;
  if p_status not in ('menunggu_verifikasi', 'aktif', 'ditolak', 'ditangguhkan') then
    raise exception 'STATUS_MITRA_TIDAK_VALID';
  end if;
  v_admin_id := private.current_admin_id();
  insert into public.status_mitra_admin as s
    (id_mitra, status_mitra, catatan_admin, ditampilkan_di_beranda,
     diperbarui_oleh, diperbarui_pada)
    values (p_id_mitra, p_status, p_note, coalesce(p_featured, false),
      v_admin_id, now())
    on conflict (id_mitra) do update set
      status_mitra = excluded.status_mitra,
      catatan_admin = coalesce(p_note, s.catatan_admin),
      ditampilkan_di_beranda = coalesce(p_featured, s.ditampilkan_di_beranda),
      diperbarui_oleh = v_admin_id,
      diperbarui_pada = now()
    returning to_jsonb(s) into v_row;
  insert into public.riwayat_aktivitas_admin
    (id_admin, aksi, target_tabel, target_id, detail)
    values (v_admin_id, 'ubah_status_mitra', 'admin_wisata',
      p_id_mitra::text, jsonb_build_object('status_mitra', p_status));
  return v_row;
end;
$$;

revoke all on function public.admin_decide_wisata(integer, text) from public, anon;
revoke all on function public.admin_decide_dokumen(integer, text, text, date) from public, anon;
revoke all on function public.admin_set_mitra_status(integer, text, text, boolean) from public, anon;
grant execute on function public.admin_decide_wisata(integer, text) to authenticated;
grant execute on function public.admin_decide_dokumen(integer, text, text, date) to authenticated;
grant execute on function public.admin_set_mitra_status(integer, text, text, boolean) to authenticated;

commit;

create unique index if not exists wishlist_user_wisata_unique
  on public.wishlist (id_user, id_wisata);

-- Admin accounts see their own profile and may edit only ordinary profile fields.
drop policy if exists admin_profile_update_self on public.admin_lokatrip;
create policy admin_profile_update_self on public.admin_lokatrip
  for update to authenticated
  using (auth_id = (select auth.uid()))
  with check (auth_id = (select auth.uid()));

-- Mitra accounts authenticate using the email already linked to Supabase Auth.
drop policy if exists mitra_read_self_or_admin on public.admin_wisata;
create policy mitra_read_self_or_admin on public.admin_wisata
  for select to authenticated
  using (lower(email) = lower((select auth.jwt() ->> 'email')) or private.is_admin());
drop policy if exists mitra_update_self_or_admin on public.admin_wisata;
create policy mitra_update_self_or_admin on public.admin_wisata
  for update to authenticated
  using (lower(email) = lower((select auth.jwt() ->> 'email')) or private.is_admin())
  with check (lower(email) = lower((select auth.jwt() ->> 'email')) or private.is_admin());

-- Public catalogue data. The relation filters also keep unapproved attractions
-- and inactive packages out of guest queries.
drop policy if exists wisata_read_approved_or_owner_or_admin on public.wisata;
create policy wisata_read_approved_or_owner_or_admin on public.wisata
  for select to anon, authenticated
  using (status_approve = 'Y' or private.is_admin()
    or id_mitra = private.current_mitra_id());
drop policy if exists wisata_insert_mitra_or_admin on public.wisata;
create policy wisata_insert_mitra_or_admin on public.wisata
  for insert to authenticated
  with check (private.is_admin() or id_mitra = private.current_mitra_id());
drop policy if exists wisata_update_mitra_or_admin on public.wisata;
create policy wisata_update_mitra_or_admin on public.wisata
  for update to authenticated
  using (private.is_admin() or id_mitra = private.current_mitra_id())
  with check (private.is_admin() or id_mitra = private.current_mitra_id());

drop policy if exists foto_wisata_read_catalog on public.foto_wisata;
create policy foto_wisata_read_catalog on public.foto_wisata
  for select to anon, authenticated using (true);
drop policy if exists kategori_read_catalog on public.kategori;
create policy kategori_read_catalog on public.kategori
  for select to anon, authenticated using (true);
drop policy if exists paket_wisata_read_catalog on public.paket_wisata;
create policy paket_wisata_read_catalog on public.paket_wisata
  for select to anon, authenticated
  using (status_aktif or private.is_admin()
    or exists (select 1 from public.wisata w
      where w.id_wisata = paket_wisata.id_wisata
        and w.id_mitra = private.current_mitra_id()));
drop policy if exists detail_paket_read_catalog on public.detail_paket;
create policy detail_paket_read_catalog on public.detail_paket
  for select to anon, authenticated using (true);
drop policy if exists fasilitas_read_catalog on public.fasilitas;
create policy fasilitas_read_catalog on public.fasilitas
  for select to anon, authenticated using (true);
drop policy if exists detail_fasilitas_read_catalog on public.detail_fasilitas;
create policy detail_fasilitas_read_catalog on public.detail_fasilitas
  for select to anon, authenticated using (true);
drop policy if exists kuota_read_catalog on public.kuota_harian;
create policy kuota_read_catalog on public.kuota_harian
  for select to anon, authenticated using (tanggal >= current_date);

-- Admin queue and mitra-owned legal documents.
drop policy if exists dokumen_read_owner_or_admin on public.dokumen;
create policy dokumen_read_owner_or_admin on public.dokumen
  for select to authenticated
  using (private.is_admin() or id_mitra = private.current_mitra_id());
drop policy if exists dokumen_insert_mitra on public.dokumen;
create policy dokumen_insert_mitra on public.dokumen
  for insert to authenticated
  with check (id_mitra = private.current_mitra_id() and id_admin is null);
drop policy if exists dokumen_update_admin on public.dokumen;
create policy dokumen_update_admin on public.dokumen
  for update to authenticated
  using (private.is_admin()) with check (private.is_admin());

drop policy if exists status_mitra_admin_all_admin on public.status_mitra_admin;
create policy status_mitra_admin_all_admin on public.status_mitra_admin
  for all to authenticated using (private.is_admin()) with check (private.is_admin());
drop policy if exists admin_notifikasi_self on public.admin_notifikasi;
create policy admin_notifikasi_self on public.admin_notifikasi
  for all to authenticated
  using (id_admin = private.current_admin_id())
  with check (id_admin = private.current_admin_id());
drop policy if exists preferensi_admin_self on public.preferensi_admin;
create policy preferensi_admin_self on public.preferensi_admin
  for all to authenticated
  using (id_admin = private.current_admin_id())
  with check (id_admin = private.current_admin_id());
drop policy if exists riwayat_admin_read_admin on public.riwayat_aktivitas_admin;
create policy riwayat_admin_read_admin on public.riwayat_aktivitas_admin
  for select to authenticated using (private.is_admin());
drop policy if exists riwayat_admin_insert_admin on public.riwayat_aktivitas_admin;
create policy riwayat_admin_insert_admin on public.riwayat_aktivitas_admin
  for insert to authenticated
  with check (id_admin = private.current_admin_id());

-- User-owned profile, wishlist, notifications, orders, points and reviews.
drop policy if exists users_insert_self on public.users;
drop policy if exists users_admin_read on public.users;
create policy users_admin_read on public.users
  for select to authenticated using (private.is_admin());
drop policy if exists users_admin_update on public.users;
create policy users_admin_update on public.users
  for update to authenticated using (private.is_admin()) with check (private.is_admin());

drop policy if exists wishlist_owner_all on public.wishlist;
create policy wishlist_owner_all on public.wishlist
  for all to authenticated
  using (id_user = private.current_user_id())
  with check (id_user = private.current_user_id());
drop policy if exists wishlist_admin_read on public.wishlist;
create policy wishlist_admin_read on public.wishlist
  for select to authenticated using (private.is_admin());

drop policy if exists notifikasi_owner_all on public.notifikasi;
create policy notifikasi_owner_all on public.notifikasi
  for all to authenticated
  using (id_user = private.current_user_id())
  with check (id_user = private.current_user_id());
drop policy if exists notifikasi_admin_read on public.notifikasi;
create policy notifikasi_admin_read on public.notifikasi
  for select to authenticated using (private.is_admin());
drop policy if exists riwayat_poin_owner_read on public.riwayat_poin;
create policy riwayat_poin_owner_read on public.riwayat_poin
  for select to authenticated
  using (id_user = private.current_user_id() or private.is_admin());

drop policy if exists pemesanan_owner_or_admin_read on public.pemesanan;
create policy pemesanan_owner_or_admin_read on public.pemesanan
  for select to authenticated
  using (id_user = private.current_user_id() or private.is_admin());
drop policy if exists detail_pemesanan_owner_or_admin_read on public.detail_pemesanan;
create policy detail_pemesanan_owner_or_admin_read on public.detail_pemesanan
  for select to authenticated
  using (private.is_admin() or exists (
    select 1 from public.pemesanan p
    where p.id_pemesanan = detail_pemesanan.id_pemesanan
      and p.id_user = private.current_user_id()
  ));
drop policy if exists pembayaran_owner_or_admin_read on public.pembayaran;
create policy pembayaran_owner_or_admin_read on public.pembayaran
  for select to authenticated
  using (private.is_admin() or exists (
    select 1 from public.pemesanan p
    where p.id_pemesanan = pembayaran.id_pemesanan
      and p.id_user = private.current_user_id()
  ));
drop policy if exists tiket_owner_or_admin_read on public.e_tiket;
create policy tiket_owner_or_admin_read on public.e_tiket
  for select to authenticated
  using (private.is_admin() or exists (
    select 1 from public.pemesanan p
    where p.id_pemesanan = e_tiket.id_pemesanan
      and p.id_user = private.current_user_id()
  ));

drop policy if exists ulasan_read_own_or_admin on public.ulasan;
create policy ulasan_read_own_or_admin on public.ulasan
  for select to authenticated
  using (id_user = private.current_user_id() or private.is_admin());
drop policy if exists ulasan_read_public on public.ulasan;
create policy ulasan_read_public on public.ulasan
  for select to anon using (true);
drop policy if exists ulasan_insert_paid_order on public.ulasan;
create policy ulasan_insert_paid_order on public.ulasan
  for insert to authenticated
  with check (
    id_user = private.current_user_id()
    and exists (
      select 1 from public.pemesanan p
      join public.pembayaran b on b.id_pemesanan = p.id_pemesanan
      join public.detail_pemesanan dp on dp.id_pemesanan = p.id_pemesanan
      join public.detail_paket dpk on dpk.id_detail_paket = dp.id_detail_paket
      join public.paket_wisata pw on pw.id_paket = dpk.id_paket
      where p.id_pemesanan = ulasan.id_pemesanan
        and p.id_user = private.current_user_id()
        and pw.id_wisata = ulasan.id_wisata
        and b.status_bayar::text in ('berhasil', 'dibayar', 'lunas', 'paid')
    )
  );

grant select on public.admin_wisata, public.dokumen to authenticated;
grant select on public.admin_notifikasi, public.preferensi_admin,
  public.riwayat_aktivitas_admin, public.status_mitra_admin to authenticated;
grant select, insert, update on public.wisata to authenticated;

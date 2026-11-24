-- Complete the direct Flutter mitra portal writes. Every record and object is
-- scoped to the authenticated mitra and remains reviewable by admins.
begin;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('lokatrip-legalitas', 'lokatrip-legalitas', false, 8388608,
    array['application/pdf', 'image/jpeg', 'image/png', 'image/webp']),
  ('lokatrip-wisata', 'lokatrip-wisata', true, 8388608,
    array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

grant select, delete on public.wisata to authenticated;
grant insert (id_mitra, id_kategori, nama_wisata, lokasi, kota,
  jam_buka, jam_tutup, deskripsi, jenis, subkategori, status_approve)
  on public.wisata to authenticated;
grant select, insert, delete on public.foto_wisata to authenticated;
grant select, insert, delete on public.paket_wisata to authenticated;
grant select, insert, delete on public.detail_paket to authenticated;
grant select, insert, delete on public.kuota_harian to authenticated;
grant select, delete on public.dokumen to authenticated;

-- A mitra can only create a pending destination or document. Approval state
-- remains controlled by the admin decision functions.
drop policy if exists wisata_insert_mitra_or_admin on public.wisata;
create policy wisata_insert_mitra_or_admin on public.wisata
  for insert to authenticated
  with check (private.is_admin() or (
    id_mitra = private.current_mitra_id() and status_approve = 'N'
  ));
drop policy if exists dokumen_insert_mitra on public.dokumen;
create policy dokumen_insert_mitra on public.dokumen
  for insert to authenticated
  with check (
    id_mitra = private.current_mitra_id()
    and id_admin is null
    and status_approve = 'N'
  );

drop policy if exists status_mitra_read_owner_or_admin on public.status_mitra_admin;
create policy status_mitra_read_owner_or_admin on public.status_mitra_admin
  for select to authenticated
  using (private.is_admin() or id_mitra = private.current_mitra_id());

create or replace function public.mitra_ringkasan_pembayaran()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  with paid_orders as (
    select distinct on (b.id_pemesanan)
      b.id_pemesanan, b.jumlah_bayar
    from public.pembayaran b
    where b.status_bayar::text in ('berhasil', 'dibayar', 'lunas', 'paid')
      and exists (
        select 1
        from public.detail_pemesanan dp
        join public.detail_paket d on d.id_detail_paket = dp.id_detail_paket
        join public.paket_wisata p on p.id_paket = d.id_paket
        join public.wisata w on w.id_wisata = p.id_wisata
        where dp.id_pemesanan = b.id_pemesanan
          and w.id_mitra = private.current_mitra_id()
      )
    order by b.id_pemesanan, b.waktu_bayar desc nulls last
  )
  select jsonb_build_object(
    'pesanan_terbayar', count(*),
    'nilai_pembayaran_berhasil', coalesce(sum(jumlah_bayar), 0)
  )
  from paid_orders;
$$;
revoke all on function public.mitra_ringkasan_pembayaran() from public, anon;
grant execute on function public.mitra_ringkasan_pembayaran() to authenticated;

drop policy if exists wisata_delete_pending_owner on public.wisata;
create policy wisata_delete_pending_owner on public.wisata
  for delete to authenticated
  using (id_mitra = private.current_mitra_id() and status_approve = 'N');

drop policy if exists foto_wisata_insert_pending_owner on public.foto_wisata;
create policy foto_wisata_insert_pending_owner on public.foto_wisata
  for insert to authenticated
  with check (exists (
    select 1 from public.wisata w
    where w.id_wisata = foto_wisata.id_wisata
      and w.id_mitra = private.current_mitra_id()
      and w.status_approve = 'N'
  ));
drop policy if exists foto_wisata_delete_pending_owner on public.foto_wisata;
create policy foto_wisata_delete_pending_owner on public.foto_wisata
  for delete to authenticated
  using (exists (
    select 1 from public.wisata w
    where w.id_wisata = foto_wisata.id_wisata
      and w.id_mitra = private.current_mitra_id()
      and w.status_approve = 'N'
  ));

drop policy if exists paket_wisata_insert_pending_owner on public.paket_wisata;
create policy paket_wisata_insert_pending_owner on public.paket_wisata
  for insert to authenticated
  with check (exists (
    select 1 from public.wisata w
    where w.id_wisata = paket_wisata.id_wisata
      and w.id_mitra = private.current_mitra_id()
      and w.status_approve = 'N'
  ));
drop policy if exists paket_wisata_delete_pending_owner on public.paket_wisata;
create policy paket_wisata_delete_pending_owner on public.paket_wisata
  for delete to authenticated
  using (exists (
    select 1 from public.wisata w
    where w.id_wisata = paket_wisata.id_wisata
      and w.id_mitra = private.current_mitra_id()
      and w.status_approve = 'N'
  ));

drop policy if exists detail_paket_insert_pending_owner on public.detail_paket;
create policy detail_paket_insert_pending_owner on public.detail_paket
  for insert to authenticated
  with check (exists (
    select 1 from public.paket_wisata p
    join public.wisata w on w.id_wisata = p.id_wisata
    where p.id_paket = detail_paket.id_paket
      and w.id_mitra = private.current_mitra_id()
      and w.status_approve = 'N'
  ));
drop policy if exists detail_paket_delete_pending_owner on public.detail_paket;
create policy detail_paket_delete_pending_owner on public.detail_paket
  for delete to authenticated
  using (exists (
    select 1 from public.paket_wisata p
    join public.wisata w on w.id_wisata = p.id_wisata
    where p.id_paket = detail_paket.id_paket
      and w.id_mitra = private.current_mitra_id()
      and w.status_approve = 'N'
  ));

drop policy if exists kuota_harian_insert_pending_owner on public.kuota_harian;
create policy kuota_harian_insert_pending_owner on public.kuota_harian
  for insert to authenticated
  with check (exists (
    select 1 from public.paket_wisata p
    join public.wisata w on w.id_wisata = p.id_wisata
    where p.id_paket = kuota_harian.id_paket
      and w.id_mitra = private.current_mitra_id()
      and w.status_approve = 'N'
  ));
drop policy if exists kuota_harian_delete_pending_owner on public.kuota_harian;
create policy kuota_harian_delete_pending_owner on public.kuota_harian
  for delete to authenticated
  using (exists (
    select 1 from public.paket_wisata p
    join public.wisata w on w.id_wisata = p.id_wisata
    where p.id_paket = kuota_harian.id_paket
      and w.id_mitra = private.current_mitra_id()
      and w.status_approve = 'N'
  ));

drop policy if exists dokumen_delete_pending_owner on public.dokumen;
create policy dokumen_delete_pending_owner on public.dokumen
  for delete to authenticated
  using (id_mitra = private.current_mitra_id() and status_approve = 'N');

drop policy if exists mitra_storage_upload on storage.objects;
create policy mitra_storage_upload on storage.objects
  for insert to authenticated
  with check (
    bucket_id in ('lokatrip-legalitas', 'lokatrip-wisata')
    and (storage.foldername(name))[1] = private.current_mitra_id()::text
  );
drop policy if exists mitra_storage_read_legalitas on storage.objects;
create policy mitra_storage_read_legalitas on storage.objects
  for select to authenticated
  using (
    (bucket_id = 'lokatrip-legalitas'
      and (storage.foldername(name))[1] = private.current_mitra_id()::text)
    or (bucket_id = 'lokatrip-legalitas' and private.is_admin())
  );
drop policy if exists mitra_storage_read_wisata on storage.objects;
create policy mitra_storage_read_wisata on storage.objects
  for select to authenticated
  using (
    bucket_id = 'lokatrip-wisata'
    and (storage.foldername(name))[1] = private.current_mitra_id()::text
  );
drop policy if exists mitra_storage_delete_own on storage.objects;
create policy mitra_storage_delete_own on storage.objects
  for delete to authenticated
  using (
    bucket_id in ('lokatrip-legalitas', 'lokatrip-wisata')
    and (storage.foldername(name))[1] = private.current_mitra_id()::text
  );
drop policy if exists public_wisata_photo_read on storage.objects;
create policy public_wisata_photo_read on storage.objects
  for select to anon, authenticated
  using (bucket_id = 'lokatrip-wisata');

commit;

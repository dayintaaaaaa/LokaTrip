-- Let a mitra edit only the package names and ticket prices attached to their
-- own destinations. Approval state and unrelated package fields stay admin-only.
begin;

grant update (nama_paket) on public.paket_wisata to authenticated;
grant update (harga) on public.detail_paket to authenticated;

drop policy if exists paket_wisata_update_owner on public.paket_wisata;
create policy paket_wisata_update_owner on public.paket_wisata
  for update to authenticated
  using (exists (
    select 1 from public.wisata w
    where w.id_wisata = paket_wisata.id_wisata
      and w.id_mitra = private.current_mitra_id()
  ))
  with check (exists (
    select 1 from public.wisata w
    where w.id_wisata = paket_wisata.id_wisata
      and w.id_mitra = private.current_mitra_id()
  ));

drop policy if exists detail_paket_update_owner on public.detail_paket;
create policy detail_paket_update_owner on public.detail_paket
  for update to authenticated
  using (exists (
    select 1 from public.paket_wisata p
    join public.wisata w on w.id_wisata = p.id_wisata
    where p.id_paket = detail_paket.id_paket
      and w.id_mitra = private.current_mitra_id()
  ))
  with check (exists (
    select 1 from public.paket_wisata p
    join public.wisata w on w.id_wisata = p.id_wisata
    where p.id_paket = detail_paket.id_paket
      and w.id_mitra = private.current_mitra_id()
  ));

commit;

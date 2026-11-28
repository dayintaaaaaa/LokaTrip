-- Infrastruktur foto katalog Malang Raya.
-- Proyek sudah memakai bucket publik lokatrip-wisata; jalankan ulang aman.
begin;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'lokatrip-wisata',
  'lokatrip-wisata',
  true,
  8388608,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists public_wisata_photo_read on storage.objects;
create policy public_wisata_photo_read on storage.objects
  for select to anon, authenticated
  using (bucket_id = 'lokatrip-wisata');

notify pgrst, 'reload schema';
commit;

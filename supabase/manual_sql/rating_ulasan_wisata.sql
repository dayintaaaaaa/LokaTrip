-- Jalankan manual di Supabase SQL Editor. Tidak perlu mengubah UI atau RLS
-- tabel users: RPC publik hanya mengembalikan agregat dan isi ulasan.

begin;

-- Jaga rata_rating dan jml_ulasan agar semua kartu katalog ikut terbarui
-- ketika ulasan dibuat, diedit, atau dihapus.
create or replace function public.sinkronkan_rating_wisata()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_id_wisata integer;
  v_ids integer[];
begin
  if tg_op = 'INSERT' then
    v_ids := array[new.id_wisata];
  elsif tg_op = 'DELETE' then
    v_ids := array[old.id_wisata];
  else
    v_ids := array[new.id_wisata, old.id_wisata];
  end if;

  for v_id_wisata in
    select distinct x.id_wisata
    from unnest(v_ids) as x(id_wisata)
    where x.id_wisata is not null
  loop
    update public.wisata w
    set rata_rating = coalesce(a.rata_rating, 0),
        jml_ulasan = coalesce(a.jml_ulasan, 0)
    from (
      select coalesce(avg(u.rating), 0) as rata_rating,
             count(u.id_ulasan)::integer as jml_ulasan
      from public.ulasan u
      where u.id_wisata = v_id_wisata
    ) a
    where w.id_wisata = v_id_wisata;
  end loop;

  if tg_op = 'DELETE' then
    return old;
  end if;
  return new;
end
$function$;

drop trigger if exists sinkronkan_rating_wisata_setelah_ulasan
  on public.ulasan;
create trigger sinkronkan_rating_wisata_setelah_ulasan
after insert or update or delete on public.ulasan
for each row execute function public.sinkronkan_rating_wisata();

-- Hitung ulang nilai yang sudah ada agar kartu lama konsisten.
update public.wisata w
set rata_rating = coalesce(a.rata_rating, 0),
    jml_ulasan = coalesce(a.jml_ulasan, 0)
from (
  select w2.id_wisata,
         coalesce(avg(u.rating), 0) as rata_rating,
         count(u.id_ulasan)::integer as jml_ulasan
  from public.wisata w2
  left join public.ulasan u on u.id_wisata = w2.id_wisata
  group by w2.id_wisata
) a
where w.id_wisata = a.id_wisata;

-- RPC publik hanya mengembalikan nama/avatar tampilan dan isi ulasan;
-- id_user dan id_pemesanan tetap privat.
create or replace function public.ulasan_wisata_detail(p_id_wisata integer)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $function$
  select jsonb_build_object(
    'rata_rating', coalesce(avg(u.rating), 0),
    'jml_ulasan', count(u.id_ulasan)::integer,
    'ulasan', coalesce(
      (
        select jsonb_agg(
          jsonb_build_object(
            'id_ulasan', r.id_ulasan,
            'nama', r.nama,
            'username', r.username,
            'foto_profil', r.foto_profil,
            'rating', r.rating,
            'komentar', r.komentar,
            'tanggal_ulasan', r.tanggal_ulasan
          ) order by r.tanggal_ulasan desc
        )
        from (
          select ul.id_ulasan,
                 coalesce(nullif(btrim(u.nama_lengkap_user), ''),
                          nullif(btrim(u.username), ''),
                          'Wisatawan LokaTrip') as nama,
                 u.username,
                 u.foto_profil,
                 ul.rating,
                 ul.komentar,
                 ul.tanggal_ulasan
          from public.ulasan ul
          left join public.users u on u.id_user = ul.id_user
          where ul.id_wisata = p_id_wisata
          order by ul.tanggal_ulasan desc
          limit 10
        ) r
      ),
      '[]'::jsonb
    )
  )
  from public.ulasan u
  where u.id_wisata = p_id_wisata;
$function$;

-- Semua ulasan untuk aksi "Lihat Semua". Data profil dibatasi ke nama,
-- username, dan foto profil; tidak mengirim id pengguna atau pesanan.
create or replace function public.ulasan_wisata_semua(p_id_wisata integer)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $function$
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'id_ulasan', ul.id_ulasan,
        'nama', coalesce(nullif(btrim(u.nama_lengkap_user), ''),
                         nullif(btrim(u.username), ''),
                         'Wisatawan LokaTrip'),
        'username', u.username,
        'foto_profil', u.foto_profil,
        'rating', ul.rating,
        'komentar', ul.komentar,
        'tanggal_ulasan', ul.tanggal_ulasan
      ) order by ul.tanggal_ulasan desc
    ),
    '[]'::jsonb
  )
  from public.ulasan ul
  left join public.users u on u.id_user = ul.id_user
  where ul.id_wisata = p_id_wisata;
$function$;

revoke all on function public.sinkronkan_rating_wisata() from public, anon, authenticated;
revoke all on function public.ulasan_wisata_detail(integer) from public, anon;
revoke all on function public.ulasan_wisata_semua(integer) from public, anon;
grant execute on function public.ulasan_wisata_detail(integer)
  to anon, authenticated;
grant execute on function public.ulasan_wisata_semua(integer)
  to anon, authenticated;

-- Pastikan RPC baru langsung dikenali PostgREST.
notify pgrst, 'reload schema';

commit;

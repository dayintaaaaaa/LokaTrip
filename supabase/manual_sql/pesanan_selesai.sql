-- BLOK A: jalankan sendiri terlebih dahulu, lalu tunggu transaksi selesai.
alter type public.status_pesan_enum add value if not exists 'selesai';

-- BLOK A2: karena status_tiket adalah enum dan belum memiliki 'digunakan',
-- jalankan blok ini sendiri lalu tunggu transaksi selesai sebelum mengetes RPC.
alter type public.status_tiket_enum add value if not exists 'digunakan';

-- BLOK B0: izinkan pemilik pesanan membaca kuota yang sudah dipesan,
-- termasuk kuota tanggal lampau yang tidak dibuka oleh policy katalog.
drop policy if exists kuota_read_order_owner on public.kuota_harian;
create policy kuota_read_order_owner on public.kuota_harian
  for select to authenticated
  using (
    exists (
      select 1
      from public.pemesanan p
      where p.id_kuota = kuota_harian.id_kuota
        and p.id_user = private.current_user_id()
    )
  );

-- BLOK B: id_pemesanan adalah integer sesuai kolom public.pemesanan.
create or replace function public.tandai_selesai(p_id_pemesanan integer)
returns void
language plpgsql
security definer
set search_path = public
as $function$
declare
  v_id_user public.pemesanan.id_user%type;
  v_status text;
  v_tanggal date;
  v_ticket_type_kind "char";
  v_ticket_has_digunakan boolean := false;
begin
  select p.id_user, p.status_pesan::text, q.tanggal
    into v_id_user, v_status, v_tanggal
  from public.pemesanan p
  left join public.kuota_harian q on q.id_kuota = p.id_kuota
  where p.id_pemesanan = p_id_pemesanan
  for update of p;

  if not found then
    raise exception 'Pesanan tidak ditemukan';
  end if;
  if v_id_user is distinct from id_user_saya() then
    raise exception 'Pesanan ini bukan milik akun Anda';
  end if;
  if v_status = 'selesai' then
    raise exception 'Pesanan sudah selesai';
  end if;
  if v_status <> 'aktif' then
    raise exception 'Hanya pesanan aktif yang dapat ditandai selesai';
  end if;
  if v_tanggal is null then
    raise exception 'Jadwal kunjungan pesanan tidak ditemukan';
  end if;
  if v_tanggal <> (now() at time zone 'Asia/Jakarta')::date then
    raise exception 'Pesanan hanya dapat ditandai selesai pada hari kunjungan (WIB)';
  end if;
  if not exists (
    select 1
    from public.e_tiket t
    where t.id_pemesanan = p_id_pemesanan
      and t.status_tiket::text = 'aktif'
  ) then
    raise exception 'E-tiket aktif untuk pesanan ini tidak ditemukan';
  end if;

  update public.pemesanan
  set status_pesan = 'selesai'
  where id_pemesanan = p_id_pemesanan;

  -- Ubah seluruh e-tiket jika tipenya mengizinkan status 'digunakan'.
  select t.typtype into v_ticket_type_kind
  from pg_catalog.pg_attribute a
  join pg_catalog.pg_type t on t.oid = a.atttypid
  where a.attrelid = 'public.e_tiket'::regclass
    and a.attname = 'status_tiket'
    and not a.attisdropped;

  if v_ticket_type_kind = 'e' then
    select exists (
      select 1
      from pg_catalog.pg_type t
      join pg_catalog.pg_enum e on e.enumtypid = t.oid
      join pg_catalog.pg_attribute a on a.atttypid = t.oid
      where a.attrelid = 'public.e_tiket'::regclass
        and a.attname = 'status_tiket'
        and not a.attisdropped
        and e.enumlabel = 'digunakan'
    ) into v_ticket_has_digunakan;
  else
    select v_ticket_type_kind is not null and not exists (
      select 1
      from pg_catalog.pg_constraint c
      where c.conrelid = 'public.e_tiket'::regclass
        and c.contype = 'c'
        and pg_catalog.pg_get_constraintdef(c.oid) ilike '%status_tiket%'
        and pg_catalog.pg_get_constraintdef(c.oid) not ilike '%digunakan%'
    ) into v_ticket_has_digunakan;
  end if;

  if v_ticket_has_digunakan then
    update public.e_tiket
    set status_tiket = 'digunakan'
    where id_pemesanan = p_id_pemesanan;
  end if;
end
$function$;

-- BLOK C
revoke all on function public.tandai_selesai(integer) from public, anon;
grant execute on function public.tandai_selesai(integer) to authenticated;

-- BLOK D: muat ulang schema cache PostgREST.
notify pgrst, 'reload schema';

-- QUERY VERIFIKASI (jalankan setelah Blok A-D):
select to_regprocedure('public.id_user_saya()') as helper_user_login;

select column_name, data_type, udt_name
from information_schema.columns
where table_schema = 'public'
  and table_name = 'kuota_harian'
order by ordinal_position;

select column_name, data_type, udt_name
from information_schema.columns
where table_schema = 'public'
  and table_name = 'e_tiket'
  and column_name = 'status_tiket';

select p.oid::regprocedure as fungsi,
       pg_catalog.pg_get_function_identity_arguments(p.oid) as argumen,
       pg_catalog.pg_get_function_result(p.oid) as hasil
from pg_catalog.pg_proc p
where p.oid = to_regprocedure('public.tandai_selesai(integer)');

-- Tes mutasi hanya dengan ID pesanan milik akun yang login,
-- berstatus aktif, bertanggal kunjungan hari ini WIB, dan memiliki e-tiket aktif:
-- select public.tandai_selesai(123);

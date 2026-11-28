-- Migration: laporan pendapatan mitra per periode (mingguan, bulanan, tahunan)
-- Digunakan untuk menggantikan data dummy di grafik halaman mitra.

begin;

-- ============================================================
-- Function: mitra_laporan_pendapatan
-- Returns: jsonb dengan ringkasan dan bucket chart
-- ============================================================
create or replace function public.mitra_laporan_pendapatan(
  p_periode text default 'bulan'   -- 'minggu' | 'bulan' | 'tahun'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_mitra_id  integer;
  v_start     timestamptz;
  v_end       timestamptz;
  v_prev_start timestamptz;
  v_prev_end  timestamptz;
  v_now       timestamptz := now();
  v_today     date        := current_date;
begin
  -- Resolve mitra saat ini (via private.current_mitra_id yang sudah ada)
  v_mitra_id := private.current_mitra_id();

  -- Hitung rentang waktu berdasarkan periode
  case p_periode
    when 'minggu' then
      v_start      := date_trunc('week', v_today::timestamptz);
      v_end        := v_start + interval '7 days';
      v_prev_start := v_start - interval '7 days';
      v_prev_end   := v_start;
    when 'tahun' then
      v_start      := date_trunc('year', v_today::timestamptz);
      v_end        := v_start + interval '1 year';
      v_prev_start := v_start - interval '1 year';
      v_prev_end   := v_start;
    else -- default: bulan
      v_start      := date_trunc('month', v_today::timestamptz);
      v_end        := v_start + interval '1 month';
      v_prev_start := v_start - interval '1 month';
      v_prev_end   := v_start;
  end case;

  return (
    with paid_orders as (
      -- Hanya pembayaran lunas dalam rentang periode
      select
        b.waktu_bayar,
        greatest(
          sum(coalesce(dp.subtotal_harga_tiket, 0)) filter (
            where w.id_mitra = v_mitra_id
          ) -
          case
            when sum(coalesce(dp.subtotal_harga_tiket, 0)) > 0
              then round(
                coalesce(o.diskon, 0)::numeric
                * sum(coalesce(dp.subtotal_harga_tiket, 0)) filter (where w.id_mitra = v_mitra_id)
                / sum(coalesce(dp.subtotal_harga_tiket, 0))
              )
            else 0
          end,
          0
        ) as nilai_tiket,
        b.id_pemesanan
      from public.pembayaran b
      join public.pemesanan o on o.id_pemesanan = b.id_pemesanan
      join public.detail_pemesanan dp on dp.id_pemesanan = b.id_pemesanan
      join public.detail_paket d on d.id_detail_paket = dp.id_detail_paket
      join public.paket_wisata p on p.id_paket = d.id_paket
      join public.wisata w on w.id_wisata = p.id_wisata
      where b.status_bayar::text in ('berhasil', 'dibayar', 'lunas', 'paid')
        and w.id_mitra = v_mitra_id
      group by b.id_pemesanan, b.waktu_bayar, o.diskon
    ),
    periode as (
      select coalesce(sum(nilai_tiket), 0)::numeric as total,
             count(*)::integer                       as jumlah
      from paid_orders
      where waktu_bayar >= v_start and waktu_bayar < v_end
    ),
    periode_lalu as (
      select coalesce(sum(nilai_tiket), 0)::numeric as total
      from paid_orders
      where waktu_bayar >= v_prev_start and waktu_bayar < v_prev_end
    ),
    -- Bucket chart: hitung per slot sesuai periode
    chart_data as (
      select
        case p_periode
          when 'minggu' then extract(isodow from waktu_bayar)::integer - 1  -- 0=Sen..6=Min
          when 'tahun'  then extract(month from waktu_bayar)::integer - 1    -- 0=Jan..11=Des
          else                -- bulan: bagi per pekan (0..4)
            least(((extract(day from waktu_bayar)::integer - 1) / 7), 4)
        end as bucket_index,
        coalesce(sum(nilai_tiket), 0)::numeric as bucket_total
      from paid_orders
      where waktu_bayar >= v_start and waktu_bayar < v_end
      group by 1
    ),
    chart_full as (
      select gs.i,
             coalesce(cd.bucket_total, 0) as val
      from generate_series(
        0,
        case p_periode
          when 'minggu' then 6
          when 'tahun'  then 11
          else 4
        end
      ) gs(i)
      left join chart_data cd on cd.bucket_index = gs.i
    )
    select jsonb_build_object(
      'periode',          p_periode,
      'total',            (select total from periode),
      'jumlah_pesanan',   (select jumlah from periode),
      'total_lalu',       (select total from periode_lalu),
      'chart_values',     (select jsonb_agg(val order by i) from chart_full)
    )
  );
end;
$$;

-- Hanya mitra yang terautentikasi (via database session) yang bisa memanggil ini.
revoke all on function public.mitra_laporan_pendapatan(text) from public, anon;
grant execute on function public.mitra_laporan_pendapatan(text) to authenticated;

notify pgrst, 'reload schema';

commit;

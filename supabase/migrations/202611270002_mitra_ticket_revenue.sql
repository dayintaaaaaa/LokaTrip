-- Mitra receives the ticket portion only; the fixed service fee belongs to LokaTrip.
create or replace function public.mitra_ringkasan_pembayaran()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  with latest_payment as (
    select distinct on (b.id_pemesanan) b.id_pemesanan
    from public.pembayaran b
    where b.status_bayar::text in ('berhasil', 'dibayar', 'lunas', 'paid')
    order by b.id_pemesanan, b.waktu_bayar desc nulls last
  ), partner_ticket as (
    select dp.id_pemesanan, w.id_mitra,
      sum(coalesce(dp.subtotal_harga_tiket, 0))::numeric as subtotal_tiket
    from public.detail_pemesanan dp
    join public.detail_paket d on d.id_detail_paket = dp.id_detail_paket
    join public.paket_wisata p on p.id_paket = d.id_paket
    join public.wisata w on w.id_wisata = p.id_wisata
    where w.id_mitra = private.current_mitra_id()
    group by dp.id_pemesanan, w.id_mitra
  ), order_ticket_total as (
    select dp.id_pemesanan, sum(coalesce(dp.subtotal_harga_tiket, 0))::numeric as subtotal_tiket
    from public.detail_pemesanan dp
    group by dp.id_pemesanan
  ), paid_orders as (
    select lp.id_pemesanan,
      greatest(pt.subtotal_tiket - case
        when ott.subtotal_tiket > 0 then round(coalesce(o.diskon, 0)::numeric * pt.subtotal_tiket / ott.subtotal_tiket)
        else 0
      end, 0) as nilai_tiket
    from latest_payment lp
    join public.pemesanan o on o.id_pemesanan = lp.id_pemesanan
    join partner_ticket pt on pt.id_pemesanan = lp.id_pemesanan
    join order_ticket_total ott on ott.id_pemesanan = lp.id_pemesanan
  )
  select jsonb_build_object(
    'pesanan_terbayar', count(*),
    'nilai_pembayaran_berhasil', coalesce(sum(nilai_tiket), 0)
  )
  from paid_orders;
$$;
revoke all on function public.mitra_ringkasan_pembayaran() from public, anon;
grant execute on function public.mitra_ringkasan_pembayaran() to authenticated;
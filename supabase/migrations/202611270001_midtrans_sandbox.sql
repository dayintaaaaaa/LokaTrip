begin;

create table if not exists public.midtrans_transactions (
  id bigint generated always as identity primary key,
  id_pemesanan integer not null references public.pemesanan(id_pemesanan) on delete cascade,
  midtrans_order_id text not null unique,
  snap_token text not null,
  redirect_url text not null,
  transaction_status text not null default 'pending',
  dibuat_pada timestamptz not null default now(),
  diperbarui_pada timestamptz not null default now()
);

create index if not exists midtrans_transactions_pemesanan_idx
  on public.midtrans_transactions (id_pemesanan, dibuat_pada desc);

alter table public.midtrans_transactions enable row level security;
revoke all on public.midtrans_transactions from public, anon, authenticated;
grant all on public.midtrans_transactions to service_role;
grant usage, select on sequence public.midtrans_transactions_id_seq to service_role;

create or replace function public.midtrans_settle_payment(
  p_kode_pesan text,
  p_metode text,
  p_penyedia text default null
)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_order public.pemesanan%rowtype;
  v_metode public.metode_bayar_enum;
  v_ticket_count integer;
  v_existing_tickets integer;
begin
  select * into v_order
  from public.pemesanan
  where kode_pesan = p_kode_pesan
  for update;

  if not found then
    raise exception 'PESANAN_TIDAK_DITEMUKAN';
  end if;

  -- A repeated Midtrans notification must not issue a second payment or tickets.
  if v_order.status_pesan::text = 'aktif' then
    return;
  end if;

  if v_order.status_pesan::text <> 'menunggu_pembayaran' then
    raise exception 'PESANAN_TIDAK_VALID';
  end if;

  begin
    v_metode := p_metode::public.metode_bayar_enum;
  exception when invalid_text_representation then
    raise exception 'METODE_TIDAK_VALID';
  end;

  insert into public.pembayaran (
    id_pemesanan, metode_bayar, penyedia, jumlah_bayar,
    status_bayar, waktu_bayar
  ) values (
    v_order.id_pemesanan, v_metode, p_penyedia, v_order.total_bayar,
    'berhasil', now()
  );

  update public.pemesanan
  set status_pesan = 'aktif'
  where id_pemesanan = v_order.id_pemesanan;

  select coalesce(sum(jumlah), 0)::integer into v_ticket_count
  from public.detail_pemesanan
  where id_pemesanan = v_order.id_pemesanan
    and tipe_pengunjung::text <> 'balita';

  select count(*)::integer into v_existing_tickets
  from public.e_tiket
  where id_pemesanan = v_order.id_pemesanan;

  insert into public.e_tiket (id_pemesanan, kode_qr)
  select v_order.id_pemesanan,
    'TKT-' || upper(substr(md5(random()::text || clock_timestamp()::text || g::text), 1, 12))
  from generate_series(1, greatest(v_ticket_count - v_existing_tickets, 0)) as g;
end;
$function$;

revoke all on function public.midtrans_settle_payment(text, text, text)
  from public, anon, authenticated;
grant execute on function public.midtrans_settle_payment(text, text, text)
  to service_role;

-- Disable the development shortcut so an authenticated client cannot mark
-- an order paid without a verified Midtrans notification.
revoke all on function public.simulasi_bayar(text, text, text)
  from public, anon, authenticated;

commit;

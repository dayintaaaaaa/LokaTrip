BEGIN;

CREATE OR REPLACE FUNCTION public.konfirmasi_pembayaran_doku(
  p_kode_pesan text,
  p_jumlah_bayar integer,
  p_metode text,
  p_penyedia text
)
RETURNS TABLE (
  o_id_pemesanan integer,
  o_kode_pesan text,
  o_total_bayar integer,
  o_kode_tiket text[]
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_p record;
  v_metode metode_bayar_enum;
  v_jumlah_tiket integer;
  v_tiket_lama integer;
  v_kode_tiket text[];
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN
    RAISE EXCEPTION 'AKSES_DITOLAK';
  END IF;

  SELECT *
  INTO v_p
  FROM pemesanan
  WHERE kode_pesan = p_kode_pesan
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'PESANAN_TIDAK_DITEMUKAN';
  END IF;

  IF v_p.total_bayar <> p_jumlah_bayar THEN
    RAISE EXCEPTION 'JUMLAH_PEMBAYARAN_TIDAK_COCOK';
  END IF;

  IF v_p.status_pesan = 'aktif' THEN
    RETURN QUERY
    SELECT v_p.id_pemesanan, v_p.kode_pesan::text, v_p.total_bayar,
      ARRAY(
        SELECT t.kode_qr::text
        FROM e_tiket t
        WHERE t.id_pemesanan = v_p.id_pemesanan
        ORDER BY t.id_tiket
      );
    RETURN;
  END IF;

  IF v_p.status_pesan <> 'menunggu_pembayaran' THEN
    RAISE EXCEPTION 'PESANAN_TIDAK_VALID';
  END IF;

  v_metode := p_metode::metode_bayar_enum;

  INSERT INTO pembayaran (
    id_pemesanan, metode_bayar, penyedia, jumlah_bayar, status_bayar, waktu_bayar
  )
  VALUES (
    v_p.id_pemesanan, v_metode, p_penyedia, v_p.total_bayar, 'berhasil', now()
  );

  UPDATE pemesanan
  SET status_pesan = 'aktif'
  WHERE id_pemesanan = v_p.id_pemesanan;

  SELECT COALESCE(SUM(jumlah), 0)
  INTO v_jumlah_tiket
  FROM detail_pemesanan
  WHERE id_pemesanan = v_p.id_pemesanan
    AND tipe_pengunjung::text <> 'balita';

  SELECT COUNT(*)
  INTO v_tiket_lama
  FROM e_tiket
  WHERE id_pemesanan = v_p.id_pemesanan;

  INSERT INTO e_tiket (id_pemesanan, kode_qr)
  SELECT
    v_p.id_pemesanan,
    'TKT-' || upper(substr(md5(random()::text || clock_timestamp()::text || g::text), 1, 12))
  FROM generate_series(1, GREATEST(v_jumlah_tiket - v_tiket_lama, 0)) AS g;

  SELECT COALESCE(
    array_agg(t.kode_qr::text ORDER BY t.id_tiket),
    ARRAY[]::text[]
  )
  INTO v_kode_tiket
  FROM e_tiket t
  WHERE t.id_pemesanan = v_p.id_pemesanan;

  RETURN QUERY
  SELECT v_p.id_pemesanan, v_p.kode_pesan::text, v_p.total_bayar, v_kode_tiket;
END;
$function$;

REVOKE ALL ON FUNCTION public.konfirmasi_pembayaran_doku(text, integer, text, text)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.konfirmasi_pembayaran_doku(text, integer, text, text)
  TO service_role;

COMMIT;
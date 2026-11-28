-- Seed tahap 2: melengkapi kategori yang pada audit awal belum mencapai
-- enam wisata Malang Raya. Data harga/jam adalah contoh, verifikasi sebelum
-- dipakai untuk penjualan nyata.
-- Jalankan manual di Supabase SQL Editor. Tidak menghapus/mengubah pesanan.
-- Kolom dan relasi mengikuti insert/query yang dipakai aplikasi.

begin;

do $seed$
declare
  v_id_admin integer;
  v_id_mitra integer;
  v_id_wisata integer;
  v_id_paket integer;
  v_data record;
  v_tipe text;
  v_harga integer;
  v_tanggal date;
  v_hari_ini date := (now() at time zone 'Asia/Jakarta')::date;
  v_jumlah integer;
  v_kategori integer;
begin
  select min(id_admin) into v_id_admin from public.admin_lokatrip;
  select min(id_mitra) into v_id_mitra from public.admin_wisata;

  if v_id_admin is null or v_id_mitra is null then
    raise exception 'Seed dihentikan: admin_lokatrip/admin_wisata belum memiliki ID yang dapat dipakai.';
  end if;

  for v_data in
    select * from (values
      (5, 'Malang Smart Arena - Tiket Playground Indoor',
       'Karanglo, Singosari, Kabupaten Malang', 'Kabupaten Malang',
       time '09:00', time '17:00',
       'Arena bermain dalam ruangan dengan beragam wahana interaktif untuk keluarga. Pilihan tiket reguler ini merupakan data contoh dan perlu dicocokkan dengan paket resmi pengelola.',
       'Indoor Playground', 'Wahana Indoor', 90000, 90000, 0, 120),
      (6, 'Melah Sauna Jambuluwuk Resort Batu - Relaksasi',
       'Jl. Trunojoyo 99, Kota Batu', 'Kota Batu',
       time '10:00', time '21:00',
       'Pengalaman relaksasi sauna di kawasan pegunungan Batu. Paket kunjungan ini merupakan data contoh; pastikan akses publik, durasi, dan fasilitas spa yang termasuk langsung kepada pengelola.',
       'Sauna & Relaksasi', 'Spa & Sauna', 150000, 150000, 0, 40)
    ) as d(id_kategori, nama_wisata, lokasi, kota, jam_buka, jam_tutup,
           deskripsi, jenis, subkategori, harga_dewasa, harga_anak,
           harga_balita, kuota_total)
  loop
    -- Tidak menggandakan wisata dengan nama dan kota yang sama.
    select w.id_wisata into v_id_wisata
    from public.wisata w
    where lower(w.nama_wisata) = lower(v_data.nama_wisata)
      and w.kota = v_data.kota
    order by w.id_wisata
    limit 1;

    if v_id_wisata is null then
      insert into public.wisata (
        id_mitra, id_admin, id_kategori, nama_wisata, lokasi, kota,
        jam_buka, jam_tutup, deskripsi, jenis, subkategori,
        rata_rating, jml_ulasan, status_approve, aktif_katalog
      ) values (
        v_id_mitra, v_id_admin, v_data.id_kategori, v_data.nama_wisata,
        v_data.lokasi, v_data.kota, v_data.jam_buka, v_data.jam_tutup,
        v_data.deskripsi, v_data.jenis, v_data.subkategori,
        0, 0, 'Y', true
      ) returning id_wisata into v_id_wisata;
    end if;

    select p.id_paket into v_id_paket
    from public.paket_wisata p
    where p.id_wisata = v_id_wisata
      and p.tipe_paket::text = 'reguler'
      and p.status_aktif = true
    order by p.id_paket
    limit 1;

    if v_id_paket is null then
      insert into public.paket_wisata (
        id_wisata, nama_paket, tipe_paket, deskripsi, status_aktif
      ) values (
        v_id_wisata, 'Tiket Reguler', 'reguler', v_data.deskripsi, true
      ) returning id_paket into v_id_paket;
    end if;

    for v_tipe, v_harga in
      select x.tipe, x.harga from (values
        ('dewasa'::text, v_data.harga_dewasa),
        ('anak_anak'::text, v_data.harga_anak),
        ('balita'::text, v_data.harga_balita)
      ) as x(tipe, harga)
    loop
      if not exists (
        select 1 from public.detail_paket d
        where d.id_paket = v_id_paket
          and d.tipe_pengunjung::text = v_tipe
      ) then
        insert into public.detail_paket (id_paket, tipe_pengunjung, harga)
        values (
          v_id_paket,
          v_tipe::public.tipe_pengunjung_enum,
          v_harga
        );
      end if;
    end loop;

    -- Pola sama dengan aplikasi: kuota harian 60 hari, mulai hari ini.
    for v_tanggal in
      select v_hari_ini + g.n
      from generate_series(0, 59) as g(n)
    loop
      if not exists (
        select 1 from public.kuota_harian q
        where q.id_paket = v_id_paket and q.tanggal = v_tanggal
      ) then
        insert into public.kuota_harian (
          id_paket, tanggal, kuota_total, kuota_terpakai
        ) values (v_id_paket, v_tanggal, v_data.kuota_total, 0);
      end if;
    end loop;

    select count(*) into v_jumlah
    from public.wisata w
    where w.id_wisata = v_id_wisata
      and w.id_kategori = v_data.id_kategori
      and w.kota in ('Kota Malang', 'Kabupaten Malang', 'Kota Batu')
      and w.status_approve = 'Y'
      and w.aktif_katalog = true;
    if v_jumlah = 0 then
      raise exception 'Wisata % tidak lolos cek kategori/lokasi/katalog.', v_data.nama_wisata;
    end if;
  end loop;

  -- Validasi database terakhir, supaya seed gagal dan rollback bila data awal
  -- berubah sehingga salah satu dari tujuh kategori masih kurang dari enam.
  for v_kategori in select generate_series(1, 7)
  loop
    select count(*) into v_jumlah
    from public.wisata w
    where w.id_kategori = v_kategori
      and w.kota in ('Kota Malang', 'Kabupaten Malang', 'Kota Batu')
      and w.status_approve = 'Y'
      and w.aktif_katalog = true;
    if v_jumlah < 6 then
      raise exception 'Kategori % baru memiliki % wisata aktif Malang Raya; minimal 6 diperlukan.',
        v_kategori, v_jumlah;
    end if;
  end loop;
end
$seed$;

commit;

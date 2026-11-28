-- Jumlah wisata tayang per kota dan kategori.
select w.kota, w.id_kategori, k.nama_kategori, count(*) as jumlah_wisata
from public.wisata w
join public.kategori k on k.id_kategori = w.id_kategori
where w.status_approve = 'Y'
  and w.aktif_katalog = true
  and w.kota in ('Kota Malang', 'Kabupaten Malang', 'Kota Batu')
group by w.kota, w.id_kategori, k.nama_kategori
order by w.kota, w.id_kategori;

-- Admin dan mitra yang akan dipilih oleh seed (ID tidak di-hardcode).
select (select min(id_admin) from public.admin_lokatrip) as id_admin_seed,
       (select min(id_mitra) from public.admin_wisata) as id_mitra_seed;

-- Wisata katalog yang belum memiliki satu pun foto.
select w.id_wisata, w.nama_wisata, w.kota, w.id_kategori
from public.wisata w
where w.status_approve = 'Y'
  and w.aktif_katalog = true
  and w.kota in ('Kota Malang', 'Kabupaten Malang', 'Kota Batu')
  and not exists (
    select 1 from public.foto_wisata f where f.id_wisata = w.id_wisata
  )
order by w.id_kategori, w.kota, w.nama_wisata;

-- Tipe harga dan kuota yang tersedia untuk dua item seed.
select w.nama_wisata, p.id_paket, p.tipe_paket, p.status_aktif,
       d.tipe_pengunjung, d.harga,
       count(q.id_kuota) as jumlah_hari_berkuota,
       min(q.tanggal) as kuota_mulai, max(q.tanggal) as kuota_sampai
from public.wisata w
join public.paket_wisata p on p.id_wisata = w.id_wisata
left join public.detail_paket d on d.id_paket = p.id_paket
left join public.kuota_harian q on q.id_paket = p.id_paket
where w.nama_wisata in (
  'Malang Smart Arena - Tiket Playground Indoor',
  'Melah Sauna Jambuluwuk Resort Batu - Relaksasi'
)
group by w.nama_wisata, p.id_paket, p.tipe_paket, p.status_aktif,
         d.tipe_pengunjung, d.harga
order by w.nama_wisata, d.tipe_pengunjung;

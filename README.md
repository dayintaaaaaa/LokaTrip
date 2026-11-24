# LokaTrip

LokaTrip adalah aplikasi Flutter yang menggunakan Supabase Auth dan Database secara langsung. Aplikasi tidak menjalankan API Express terpisah. Untuk Flutter Web, Docker hanya menyajikan file statis dengan Nginx; aplikasi mobile terhubung langsung ke Supabase.

## Menjalankan Flutter

Pasang dependency lalu jalankan aplikasi dari root repository:

```sh
flutter pub get
flutter run
```

URL proyek dan publishable key Supabase sudah disiapkan untuk proyek LokaTrip. Publishable key aman dipakai di aplikasi client selama akses database dibatasi dengan RLS. Jangan pernah memasukkan secret/service-role key ke Flutter.

Login admin dan mitra menggunakan email. Akun wisatawan mendukung email dan nomor telepon. Login nomor telepon memakai Supabase Edge Function `smart-endpoint` yang sudah ada di proyek.

## Menyiapkan akses database

Sebelum mencoba alur langsung dari Flutter, jalankan migration berikut pada proyek Supabase:

`supabase/migrations/202611220001_direct_flutter_rls.sql`

Migration ini menambahkan policy per peran serta RPC admin untuk keputusan wisata, dokumen, dan status mitra. Fungsi tersebut memeriksa identitas admin di database dan mencatat aktivitas audit.

## Flutter Web dengan Docker

Docker membangun Flutter Web dan melayani hasilnya dengan Nginx. Tidak ada Node.js atau Express di container.

```sh
docker build -t lokatrip .
docker run --rm -p 8080:80 lokatrip
```

Supabase tetap menjadi layanan hosted untuk Auth dan database. Tidak perlu men-deploy server Express terpisah.

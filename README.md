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

## Pembayaran Midtrans Sandbox

Alur pembayaran menggunakan Snap redirect. Server key hanya disimpan sebagai Supabase Edge Function secret; status lunas dan tiket hanya diproses setelah webhook diverifikasi.

1. Masuk ke direktori proyek, autentikasi dan hubungkan Supabase CLI ke project yang sama dengan `supabase/config.toml`:

   ```sh
   supabase login
   supabase link --project-ref eokrqohaofdiaabpcnyg
   ```

2. Pada project development yang benar, buka **Supabase Dashboard > SQL Editor** dan jalankan isi file `supabase/migrations/202611270001_midtrans_sandbox.sql`. Migration membuat tabel transaksi Midtrans, RPC settlement khusus server, dan menonaktifkan RPC pembayaran simulasi. Untuk mengaktifkan metode Akulaku/PayLater, jalankan juga `supabase/migrations/202611280001_midtrans_paylater.sql`.

3. Di Supabase Dashboard, buka **Edge Function Secrets** lalu tambahkan `MIDTRANS_SERVER_KEY`, `MIDTRANS_SIGNATURE_SECRET_KEY`, dan `MIDTRANS_ENVIRONMENT` dengan nilai `sandbox`. Ambil dua key dari **Sandbox** dashboard Midtrans. Jangan masukkan secret ke Flutter atau Git. Supabase juga menerima secrets melalui file env yang diabaikan Git.

4. Deploy Edge Function:

   ```sh
   supabase functions deploy midtrans-payment
   ```

5. Di dashboard **Sandbox Midtrans**, atur HTTP Notification URL ke:

   `https://eokrqohaofdiaabpcnyg.supabase.co/functions/v1/midtrans-payment`

   Di dashboard Sandbox Midtrans, buka **Settings > Configuration** lalu isi **Payment Notification URL**. Notifikasi harus mengarah ke endpoint HTTPS yang sudah live.

6. Jalankan Flutter dan buat pesanan paket sungguhan dari database. Pilih metode, lanjutkan ke halaman Midtrans Sandbox, lalu bayar dengan data uji yang disediakan Midtrans. Setelah webhook berhasil diproses, status pesanan menjadi aktif dan e-tiket diterbitkan.

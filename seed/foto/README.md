# Foto wisata seed

Folder gambar mengikuti slug pada `manifest.json`, lalu nomor urut menjadi
thumbnail utama: `seed/foto/<slug>/1.jpg`, `2.jpg`, `3.jpg` (boleh `.png` atau
`.webp`). Buat folder hanya saat foto berlisensi/berizin sudah siap.

Untuk upload dan sinkronisasi ke bucket `lokatrip-wisata` serta tabel
`foto_wisata`, isi foto lalu jalankan `node
backend-admin/scripts/upload-wisata-foto.mjs` dengan environment
`SUPABASE_URL` dan `SUPABASE_SERVICE_ROLE_KEY`. Jangan simpan service-role key
di file proyek. Skrip menggunakan public URL Storage dan nomor file sebagai
kolom `urutan`; urutan 1 menjadi thumbnail utama.

Seed tahap 2 saat ini menambahkan dua wisata untuk kategori yang kekurangan
jumlah. Belum ada foto yang disertakan. Catatan sumber dan atribusi dicatat di
`SUMBER.md` sebelum foto diunggah.

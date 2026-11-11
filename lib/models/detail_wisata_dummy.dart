import 'package:flutter/material.dart';
import 'detail_wisata.dart';
import 'wisata.dart';

class DetailDummy {
  // id wisata Borobudur di WisataDummy yang memakai detail lengkap
  static const _idBorobudur = {2, 301, 501};

  // wisata lain otomatis dibuatkan dari data Wisata-nya
  static DetailWisata untuk(Wisata w) {
    if (_idBorobudur.contains(w.id)) return _borobudur(w);
    return DetailWisata.dariWisata(w);
  }

  static DetailWisata _borobudur(Wisata w) {
    return DetailWisata(
      wisataId: w.id,
      judul: 'Candi Borobudur Sunrise & Heritage Experience',
      gambar: w.gambar,
      jumlahFoto: 8,
      virtualTour: true,
      badge: const ['WARISAN BUDAYA UNESCO', 'TERLARIS DI JAWA TENGAH'],
      rating: 4.9,
      jumlahUlasan: 2418,
      lokasi: 'Borobudur, Magelang',
      wilayah: 'Jawa Tengah, Indonesia',
      keunggulan: const [
        (Icons.bolt, 'Konfirmasi Instan', 'Langsung dapat e-tiket'),
        (Icons.update, 'Bebas Reschedule', 'Maksimal H-1'),
        (Icons.event_available_outlined, 'Gratis Batal', 'Pengembalian 100%'),
        (Icons.badge_outlined, 'Pemandu Resmi', 'Edukator Berlisensi'),
      ],
      grup: const [
        // ---------- WNI ----------
        GrupTiket(
          nama: 'WNI (Domestik)',
          paket: [
            PaketTiket(
              nama: 'Sunrise Tour + VW Safari Antik Kampung Seni',
              namaPendek: 'Sunrise + VW Safari',
              label: 'PALING POPULER',
              populer: true,
              durasi: '5 - 6 Jam',
              deskripsi:
                  'Menikmati fajar dari Bukit Dagi / Pelataran Candi, akses '
                  'naik ke struktur utama, sarapan tradisional prasmanan, dan '
                  'tur desa wisata VW Safari antik.',
              fitur: [
                'Akses Naik Stupa',
                'Sarapan & Kopi Tubruk',
                'Sandal Upanat Khusus',
              ],
              harga: 375000,
              hargaAsli: 450000,
            ),
            PaketTiket(
              nama: 'Reguler Sunset & Borobudur Walking Tour',
              namaPendek: 'Sunset Walking Tour',
              label: 'STANDAR HERITAGE',
              durasi: '2.5 Jam',
              deskripsi:
                  'Tiket pelataran candi waktu sore, pemandu arkeologi '
                  'informatif, payung peneduh, serta akses museum '
                  'Karmawibhangga & Samudra Raksa.',
              fitur: ['Tiket Masuk Pelataran', 'Pemandu Lokal Borobudur'],
              harga: 220000,
            ),
          ],
          termasuk: [
            'Tiket resmi masuk Candi Borobudur & pemeliharaan monumen',
            'Alas kaki ramah batu candi (Sandal Upanat) & pouch souvenir',
            'Pemandu wisata bersertifikasi HPI (Bahasa Indonesia & Inggris)',
            'Perjalanan VW Safari klasik & kunjungan perajin gerabah',
          ],
          tidakTermasuk: [
            'Antar-jemput hotel luar area Magelang/Yogyakarta',
            'Tip sukarela untuk pengemudi VW & pemandu wisata',
          ],
        ),

        // ---------- WNA ----------
        GrupTiket(
          nama: 'WNA (Mancanegara)',
          catatan:
              'Perhatian: Paspor / KITAS wajib ditunjukkan saat penukaran '
              'gelang & verifikasi di Gate Khusus WNA.',
          paket: [
            PaketTiket(
              nama: 'Borobudur Sunrise & Temple Structure (Foreigner Ticket)',
              namaPendek: 'Borobudur Sunrise WNA',
              label: 'PALING POPULER',
              populer: true,
              durasi: '5 - 6 Jam',
              deskripsi:
                  'Akses naik ke struktur utama stupa saat fajar, pemandu '
                  'resmi berlisensi (English Guide bersertifikasi), Sandal '
                  'Upanat khusus ramah monumen + goodie bag, sarapan '
                  'prasmanan Bukit Dagi, dan akses museum Samudra Raksa.',
              fitur: [
                'Akses Naik Stupa Utama',
                'Pemandu Berbahasa Inggris',
                'Sandal Upanat + Tas Kain',
                'Sarapan Dagi Hill',
              ],
              harga: 500000,
              hargaAsli: 650000,
              hargaUsd: '(~USD \$32.50)',
            ),
            PaketTiket(
              nama: 'Temple Ground Access & Sunset Walk (Foreigner Ticket)',
              namaPendek: 'Sunset Walk WNA',
              label: 'STANDAR HERITAGE',
              durasi: '2.5 Jam',
              deskripsi:
                  'Tiket pelataran candi sore hari bagi turis internasional, '
                  'fasilitas audio guide multispeaker (tersedia 6 bahasa: EN, '
                  'FR, DE, NL, JA, ZH), pemandu lokal, dan bebas keliling '
                  'pelataran.',
              fitur: [
                'Tiket Masuk Pelataran',
                'Audio Guide 6 Bahasa',
                'Akses 2 Museum Heritage',
              ],
              harga: 380000,
              hargaUsd: '(~USD \$24.80)',
            ),
          ],
          termasuk: [
            'Tiket resmi masuk Candi Borobudur & pemeliharaan monumen',
            'Jalur antrean prioritas (Fast-Track Gate WNA)',
            'Sandal Upanat resmi Borobudur & pouch souvenir',
            'Pemandu wisata dwibahasa berlisensi internasional',
          ],
          tidakTermasuk: [
            'Antar-jemput hotel luar area Magelang/Yogyakarta',
            'Biaya visa / administrasi paspor',
            'Tip sukarela untuk pemandu wisata',
          ],
        ),
      ],
      ulasan: const [
        UlasanDetail(
          nama: 'Nadira Prasasti',
          asal: 'Wisatawan Domestik',
          waktu: '3 hari lalu',
          rating: 5.0,
          teks: 'Sunrise di Dagi Hill magis banget! Sandal upanat sangat '
              'nyaman dan edukasi pemandunya detail tentang relief '
              'Karmawibhangga. VW safarinya bikin seru keliling desa gerabah.',
        ),
        UlasanDetail(
          nama: 'Liam Henderson',
          asal: 'Wisatawan Mancanegara',
          waktu: '1 minggu lalu',
          rating: 4.9,
          teks: 'Very seamless redemption with Lokatrip app. The licensed '
              'guide spoke fluent English and made the ancient history feel '
              'alive. Truly a bucket list memory!',
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'wisata.dart';

// Satu opsi paket / tiket yang bisa dipilih di halaman detail.
class PaketTiket {
  final String nama;
  final String namaPendek; // tampil di bar bawah, contoh: 'Sunrise + VW Safari'
  final String? label; // contoh: 'PALING POPULER'
  final bool populer; // true = label biru dengan ikon bintang
  final String? durasi; // contoh: '5 - 6 Jam'
  final String deskripsi;
  final List<String> fitur; // chip centang di dalam kartu
  final int harga;
  final int? hargaAsli; // harga coret (null = tidak ada diskon)
  final String? hargaUsd; // contoh: '(~USD $32.50)', untuk tiket WNA
  final String satuan; // contoh: '/orang'

  const PaketTiket({
    required this.nama,
    required this.namaPendek,
    required this.deskripsi,
    required this.harga,
    this.label,
    this.populer = false,
    this.durasi,
    this.fitur = const [],
    this.hargaAsli,
    this.hargaUsd,
    this.satuan = '/orang',
  });
}

// Kelompok pengunjung (WNI / WNA) beserta paket dan fasilitasnya.
// Kalau hanya ada 1 kelompok, tombol WNI/WNA tidak ditampilkan.
class GrupTiket {
  final String nama; // contoh: 'WNI (Domestik)'
  final String? catatan; // kotak info biru di atas paket
  final List<PaketTiket> paket;
  final List<String> termasuk;
  final List<String> tidakTermasuk;

  const GrupTiket({
    required this.nama,
    required this.paket,
    this.catatan,
    this.termasuk = const [],
    this.tidakTermasuk = const [],
  });
}

class UlasanDetail {
  final String nama;
  final String asal; // contoh: 'Wisatawan Domestik'
  final String waktu; // contoh: '3 hari lalu'
  final double rating;
  final String teks;

  const UlasanDetail({
    required this.nama,
    required this.asal,
    required this.waktu,
    required this.rating,
    required this.teks,
  });
}

// Semua isi halaman Destination Detail.
// ganti dengan data dari backend kalau API sudah ada.
class DetailWisata {
  final int wisataId; // untuk tombol favorit
  final String judul;
  final String? gambar;
  final int jumlahFoto;
  final bool virtualTour;
  final List<String> badge; // chip biru di bawah gambar
  final double? rating;
  final int? jumlahUlasan;
  final String lokasi;
  final String wilayah;
  final List<(IconData, String, String)> keunggulan; // ikon, judul, keterangan
  final List<GrupTiket> grup;
  final List<UlasanDetail> ulasan;

  const DetailWisata({
    required this.wisataId,
    required this.judul,
    required this.lokasi,
    required this.wilayah,
    required this.grup,
    this.gambar,
    this.jumlahFoto = 1,
    this.virtualTour = false,
    this.badge = const [],
    this.rating,
    this.jumlahUlasan,
    this.keunggulan = keunggulanUmum,
    this.ulasan = const [],
  });

  // persen puas dihitung dari rating (4.9 dari 5 -> 98%)
  int? get persenPuas {
    final r = rating;
    return r == null ? null : (r / 5 * 100).round();
  }

  static const List<(IconData, String, String)> keunggulanUmum = [
    (Icons.bolt, 'Konfirmasi Instan', 'Langsung dapat e-tiket'),
    (Icons.update, 'Bebas Reschedule', 'Maksimal H-1'),
    (Icons.event_available_outlined, 'Gratis Batal', 'Pengembalian 100%'),
    (Icons.confirmation_number_outlined, 'Tiket Resmi', 'Langsung masuk via scan'),
  ];

    // Dipakai untuk wisata yang belum punya data detail lengkap.
  // DUMMY: harga WNA & paket reguler diturunkan dari harga wisata,
  // ganti dengan data asli dari backend kalau API sudah ada.
  factory DetailWisata.dariWisata(Wisata w) {
    const kurs = 15400; // perkiraan rupiah per USD
    int bulat(num x) => (x / 1000).round() * 1000;
    String usd(int rp) => '(~USD \$${(rp / kurs).toStringAsFixed(2)})';

    final satuan = w.satuanHarga ?? '/orang';

    final fitur = <String>[
      if (w.termasuk != null) w.termasuk!,
      ...w.fitur,
    ];
    final fiturUtama = fitur.isNotEmpty
        ? fitur
        : const ['Tiket Masuk Resmi', 'Bebas Antre', 'Bisa Reschedule'];

    final deskripsi = w.deskripsi ??
        'E-tiket dikirim langsung setelah pembayaran. '
            'Tunjukkan kode QR di pintu masuk tanpa antre panjang.';

    final hargaWni = w.harga;
    final hargaWniReguler = bulat(hargaWni * 0.6);
    final hargaWna = bulat(hargaWni * 1.5);
    final hargaWnaReguler = bulat(hargaWna * 0.6);
    final hargaAsliWna =
        w.hargaAsli == null ? null : bulat(w.hargaAsli! * 1.5);

    return DetailWisata(
      wisataId: w.id,
      judul: w.nama,
      gambar: w.gambar,
      badge: [
        if (w.labelGambar != null) w.labelGambar!.toUpperCase(),
        if (w.tipe != null) w.tipe!.toUpperCase(),
      ],
      rating: w.rating,
      jumlahUlasan: w.jumlahUlasan,
      lokasi: w.lokasi,
      wilayah: w.kota == null ? 'Indonesia' : '${w.kota}, Indonesia',
      grup: [
        // ---------- WNI ----------
        GrupTiket(
          nama: 'WNI (Domestik)',
          paket: [
            PaketTiket(
              nama: w.nama,
              namaPendek: 'Paket Populer',
              label: 'PALING POPULER',
              populer: true,
              deskripsi: deskripsi,
              fitur: fiturUtama,
              harga: hargaWni,
              hargaAsli: w.hargaAsli,
              satuan: satuan,
            ),
            PaketTiket(
              nama: 'Tiket Masuk Reguler',
              namaPendek: 'Tiket Reguler',
              label: 'STANDAR',
              deskripsi:
                  'Tiket masuk standar tanpa tambahan fasilitas. '
                  'E-tiket dikirim langsung setelah pembayaran.',
              fitur: const ['Tiket Masuk Resmi', 'E-Tiket Instan'],
              harga: hargaWniReguler,
              satuan: satuan,
            ),
          ],
          termasuk: [
            ...fiturUtama,
            'E-tiket resmi dikirim setelah pembayaran',
          ],
          tidakTermasuk: const [
            'Transportasi menuju lokasi',
            'Pengeluaran pribadi & tip sukarela',
          ],
        ),

        // ---------- WNA ----------
        GrupTiket(
          nama: 'WNA (Mancanegara)',
          catatan:
              'Perhatian: Paspor / KITAS wajib ditunjukkan saat penukaran '
              'tiket & verifikasi di lokasi.',
          paket: [
            PaketTiket(
              nama: '${w.nama} (Foreigner Ticket)',
              namaPendek: 'Paket Populer WNA',
              label: 'PALING POPULER',
              populer: true,
              deskripsi:
                  'Tiket untuk wisatawan mancanegara. Tunjukkan paspor dan '
                  'kode QR saat verifikasi di pintu masuk.',
              fitur: [...fiturUtama, 'Jalur Prioritas WNA'],
              harga: hargaWna,
              hargaAsli: hargaAsliWna,
              hargaUsd: usd(hargaWna),
              satuan: satuan,
            ),
            PaketTiket(
              nama: 'Regular Entry (Foreigner Ticket)',
              namaPendek: 'Tiket Reguler WNA',
              label: 'STANDAR',
              deskripsi:
                  'Tiket masuk standar bagi turis internasional tanpa '
                  'tambahan fasilitas.',
              fitur: const ['Tiket Masuk Resmi', 'E-Tiket Instan'],
              harga: hargaWnaReguler,
              hargaUsd: usd(hargaWnaReguler),
              satuan: satuan,
            ),
          ],
          termasuk: [
            ...fiturUtama,
            'Jalur antrean prioritas (Fast-Track Gate WNA)',
            'E-tiket resmi dikirim setelah pembayaran',
          ],
          tidakTermasuk: const [
            'Transportasi menuju lokasi',
            'Biaya visa / administrasi paspor',
            'Tip sukarela untuk pemandu wisata',
          ],
        ),
      ],
      // DUMMY: ganti dengan ulasan asli dari backend
      ulasan: const [
        UlasanDetail(
          nama: 'Nadira Prasasti',
          asal: 'Wisatawan Domestik',
          waktu: '3 hari lalu',
          rating: 5.0,
          teks: 'Tempatnya bagus dan e-tiketnya langsung bisa discan, '
              'tidak perlu antre lama. Recommended buat liburan keluarga!',
        ),
        UlasanDetail(
          nama: 'Liam Henderson',
          asal: 'Wisatawan Mancanegara',
          waktu: '1 minggu lalu',
          rating: 4.9,
          teks: 'Very smooth redemption with the Lokatrip app. Scanned the '
              'e-ticket at the gate and walked straight in. Great value!',
        ),
      ],
    );
  }
}
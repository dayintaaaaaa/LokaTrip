import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/api_client.dart';
import '../../core/app_color.dart';
import '../../core/favorite_store.dart';
import '../../core/format_rupiah.dart';
import '../../core/navigasi_wisata.dart';
import '../../core/session_manager.dart';
import '../../models/wisata.dart';
import '../../services/wisata_service.dart';
import '../../widgets/badge_rating.dart';
import '../../widgets/tombol_kartu.dart';
import '../../widgets/gambar_wisata.dart';
import '../../widgets/sub_app_bar.dart';
import '../../widgets/tombol_favorit.dart';

class WishlistScreens extends StatefulWidget {
  const WishlistScreens({super.key});

  @override
  State<WishlistScreens> createState() => _WishlistScreensState();
}

class _WishlistScreensState extends State<WishlistScreens> {
  // Data wishlist dimuat sekali saat halaman dibuka.
  late final Future<List<Wisata>> _daftar;

  @override
  void initState() {
    super.initState();
    _daftar = _ambilWishlist();
  }

  Future<List<Wisata>> _ambilWishlist() async {
    final token = await SessionManager.currentUserToken();
    if (token == null || token.isEmpty) return const [];

    final rows = await UserApi.wishlist(token);
    final ids = rows
        .map((row) => (row['id_wisata'] as num?)?.toInt())
        .whereType<int>()
        .toList();

    FavoritStore.ids.value = ids.toSet();
    if (ids.isEmpty) return const [];

    // Ambil data wisata lengkap lewat query yang sama dengan katalog, termasuk foto dan harga paket.
    final lengkap = await WisataService().getByIds(ids);
    final berdasarkanId = {for (final wisata in lengkap) wisata.id: wisata};
    return ids.map((id) => berdasarkanId[id]).whereType<Wisata>().toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.putih,
      body: Column(
        children: [
          const SubAppBar(title: 'Wishlist Saya', showAvatar: false),
          Expanded(
            child: FutureBuilder<List<Wisata>>(
              future: _daftar,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final daftar = snapshot.data ?? const <Wisata>[];

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    Row(
                      children: [
                        Text(
                          'Koleksi Pilihan',
                          style: GoogleFonts.manrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColor.hitam,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.auto_awesome,
                          size: 12,
                          color: AppColor.kuning,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    ValueListenableBuilder<Set<int>>(
                      valueListenable: FavoritStore.ids,
                      builder: (context, ids, _) {
                        final tersimpan = daftar
                            .where((w) => ids.contains(w.id))
                            .length;

                        return Text(
                          '$tersimpan Wisata Tersimpan',
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            color: AppColor.abu,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<Set<int>>(
                      valueListenable: FavoritStore.ids,
                      builder: (context, ids, _) {
                        final tersimpan = daftar
                            .where((w) => ids.contains(w.id))
                            .toList();
                        return Column(
                          children: tersimpan.isEmpty
                              ? [_kosong()]
                              : tersimpan
                                    .map((wisata) => _kartu(context, wisata))
                                    .toList(),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _kosong() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          const Icon(Icons.favorite_border, size: 40, color: AppColor.abu),
          const SizedBox(height: 8),
          Text(
            'Belum ada wisata tersimpan',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColor.abu,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tekan ikon hati di kartu wisata untuk menyimpannya',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(fontSize: 10, color: AppColor.abu),
          ),
        ],
      ),
    );
  }

  Widget _kartu(BuildContext context, Wisata w) {
    return GestureDetector(
      onTap: () => bukaDetailWisata(context, w),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColor.putih,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColor.abu.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 115,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  GambarWisata(path: w.gambar),
                  if (w.rating != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: BadgeRating(
                        rating: w.rating!,
                        ulasan: w.jumlahUlasan == null
                            ? null
                            : '${ringkasAngka(w.jumlahUlasan!)} ulasan',
                      ),
                    ),
                  Positioned(
                    top: 4,
                    right: 6,
                    child: TombolFavorit(wisataId: w.id),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: w.lokasi,
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColor.ungu,
                          ),
                        ),
                        if (w.subkategori != null)
                          TextSpan(
                            text: '  |  ${w.subkategori}',
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              color: AppColor.abu,
                            ),
                          ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    w.nama,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColor.hitam,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Mulai dari ',
                                style: GoogleFonts.manrope(
                                  fontSize: 10,
                                  color: AppColor.abu,
                                ),
                              ),
                              TextSpan(
                                text: formatRupiah(w.harga),
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.ungu,
                                ),
                              ),
                              if (w.satuanHarga != null)
                                TextSpan(
                                  text: ' ${w.satuanHarga}',
                                  style: GoogleFonts.manrope(
                                    fontSize: 10,
                                    color: AppColor.abu,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      TombolKartu(
                        label: 'Pilih Paket',
                        onPressed: () => bukaDetailWisata(context, w),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

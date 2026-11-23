// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../../core/app_color.dart';
// import '../../../core/format_rupiah.dart';
// import '../../../models/data_checkout.dart';

// // Kartu tambahan "Lokatrip Care Extra" dengan kotak centang.
// class KartuCareExtra extends StatelessWidget {
//   final bool aktif;
//   final ValueChanged<bool> onUbah;

//   const KartuCareExtra({super.key, required this.aktif, required this.onUbah});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       behavior: HitTestBehavior.opaque,
//       onTap: () => onUbah(!aktif),
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: AppColor.putih,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: aktif
//                 ? AppColor.ungu.withValues(alpha: 0.4)
//                 : AppColor.abu.withValues(alpha: 0.2),
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: 36,
//                   height: 36,
//                   decoration: BoxDecoration(
//                     color: AppColor.biru.withValues(alpha: 0.2),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: const Icon(
//                     Icons.shield_outlined,
//                     size: 18,
//                     color: AppColor.ungu,
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Lokatrip Care Extra',
//                         style: GoogleFonts.outfit(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w700,
//                           color: AppColor.hitam,
//                         ),
//                       ),
//                       Text(
//                         '+${formatRupiah(RincianHarga.hargaCareExtra)} / tiket',
//                         style: GoogleFonts.manrope(
//                           fontSize: 10.5,
//                           fontWeight: FontWeight.w700,
//                           color: AppColor.biru,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 _kotakCentang(),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF0F3F8),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Column(
//                 children: [
//                   _poin('Kompensasi pembatalan akibat cuaca ekstrem atau sakit mendadak'),
//                   const SizedBox(height: 8),
//                   _poin('Santunan medis darurat selama kunjungan berlangsung'),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _kotakCentang() {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 150),
//       width: 22,
//       height: 22,
//       decoration: BoxDecoration(
//         color: aktif ? AppColor.ungu : Colors.transparent,
//         borderRadius: BorderRadius.circular(6),
//         border: Border.all(
//           color: aktif ? AppColor.ungu : AppColor.hitam.withValues(alpha: 0.6),
//           width: 1.5,
//         ),
//       ),
//       child: aktif
//           ? const Icon(Icons.check, size: 15, color: AppColor.putih)
//           : null,
//     );
//   }

//   Widget _poin(String teks) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Padding(
//           padding: EdgeInsets.only(top: 1),
//           child: Icon(Icons.check_circle_outline, size: 14, color: AppColor.biru),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Text(
//             teks,
//             style: GoogleFonts.manrope(
//               fontSize: 10.5,
//               color: AppColor.hitam.withValues(alpha: 0.75),
//               height: 1.4,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
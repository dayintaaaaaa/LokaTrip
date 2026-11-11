import 'package:flutter/material.dart';
import '../models/wisata.dart';

void bukaDetailWisata(BuildContext context, Wisata w) {
  // sementara tampil pesan; nanti ganti dengan Navigator.push ke halaman Detail
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Detail: ${w.nama}'),
      duration: const Duration(seconds: 1),
    ),
  );
}
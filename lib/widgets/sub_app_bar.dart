import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_color.dart';

// app bar untuk halaman turunan (Edit Profile, Tukar Poin, Riwayat Poin, dst)
class SubAppBar extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SubAppBar({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColor.latar,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: AppColor.hitam),
              ),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColor.hitam,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: trailing ??
                    const CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColor.ungu,
                      child: Icon(Icons.person, size: 16, color: AppColor.putih),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
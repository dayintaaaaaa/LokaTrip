import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_color.dart';

class TopNavigator extends StatelessWidget {
  final VoidCallback? onNotifTap;
  final VoidCallback? onProfilTap;

  const TopNavigator({
    super.key,
    this.onNotifTap,
    this.onProfilTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // logo
          Image.asset('assets/images/LokaTrip-logo-no-van.png', height: 20),

          Spacer(),

          // notifikasi
          IconButton(
            onPressed: onNotifTap, 
            icon: Icon(
              Icons.notifications_none,
              color: AppColor.ungu,
              size: 22,
            ),
          ),

          // avatar profile
          GestureDetector(
            onTap: onProfilTap,
            child: CircleAvatar(
              radius: 14,
              backgroundColor: AppColor.biru,
              child: Icon(Icons.person, size: 16, color: AppColor.putih),
            ),
          ),
        ],
      ),
    );
  }
}
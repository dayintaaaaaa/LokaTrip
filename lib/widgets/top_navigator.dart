import 'package:flutter/material.dart';
import '../core/app_color.dart';
import '../features/user/akun_screens.dart';
import '../features/user/notifikasi_screens.dart';

class TopNavigator extends StatelessWidget {
  final bool adaNotif; // titik kuning di lonceng (belum dipakai di halaman mana pun)

  const TopNavigator({super.key, this.adaNotif = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColor.latar,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // logo
              Image.asset(
                'assets/images/LokaTrip-logo-no-van.png',
                height: 20,
              ),

              const Spacer(),

              // notifikasi -> halaman Notifikasi
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotifikasiScreens(),
                    ),
                  );
                },
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      color: AppColor.ungu,
                      size: 22,
                    ),
                    if (adaNotif)
                      Positioned(
                        right: 1,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColor.kuning,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColor.latar,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // avatar profile -> halaman Akun
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const AkunScreens(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColor.biru,
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
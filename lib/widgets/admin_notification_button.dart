import 'package:flutter/material.dart';

class AdminNotificationButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color color;

  const AdminNotificationButton({
    super.key,
    required this.onPressed,
    this.color = const Color(0xFF0F172A),
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Buka notifikasi',
      onPressed: onPressed,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 22,
              color: color,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFDC2626),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

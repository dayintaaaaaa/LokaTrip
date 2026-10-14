import 'package:flutter/material.dart';
import '../../core/session_manager.dart';
import '../../features/login_screens.dart';

class HomeScreens extends StatelessWidget {
  const HomeScreens({super.key});

  Future<void> _logout(BuildContext context) async {
    await SessionManager.logout();

    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreens()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Home LokaTrip'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _logout(context),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
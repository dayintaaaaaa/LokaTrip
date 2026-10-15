import 'package:flutter/material.dart';
import '../../widgets/bottom_navigator.dart';
import '../../widgets/top_navigator.dart';

class HomeScreens extends StatelessWidget {
  const HomeScreens({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TopNavigator(),
            Expanded(child: Center(child: Text('Home LokaTrip'))),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigator(currentIndex: 0),
    );
  }
}
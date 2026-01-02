import 'package:flutter/material.dart';
import 'package:next_destination/core/utils/colors.dart';
import 'package:next_destination/features/dashboard/presentation/pages/bottom_screen/explore_screen.dart';
import 'package:next_destination/features/dashboard/presentation/pages/bottom_screen/home_screen.dart';
import 'package:next_destination/features/dashboard/presentation/pages/bottom_screen/setting_screen.dart';
import 'package:next_destination/features/dashboard/presentation/pages/bottom_screen/wallet_screen.dart';

class BottomScreenLayout extends StatefulWidget {
  const BottomScreenLayout({super.key});

  @override
  State<BottomScreenLayout> createState() => _BottomScreenLayoutState();
}

class _BottomScreenLayoutState extends State<BottomScreenLayout> {
  int _selectedIndex = 0;

  final List<Widget> _bottomScreens = const [
    HomeScreen(),
    ExploreScreen(),
    WalletScreen(),
    SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _bottomScreens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        // Set the bar background to your primary red
        backgroundColor: primaryRed,
        // Set selected icon/label to white
        selectedItemColor: Colors.white,
        // Set unselected to a faded white for contrast
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore, size: 30),
            label: "Explore",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet, size: 30),
            label: "Wallet",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, size: 30),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}

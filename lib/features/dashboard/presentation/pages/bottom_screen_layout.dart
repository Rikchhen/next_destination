import 'package:flutter/material.dart';
import 'package:next_destination/core/utils/colors.dart';
import 'package:next_destination/features/auth/presentation/pages/profile_page.dart';
import 'package:next_destination/features/booking/presentation/pages/my_bookings_screen.dart';
import 'package:next_destination/features/dashboard/presentation/pages/bottom_screen/home_screen.dart';
import 'package:next_destination/features/trip/presentation/pages/trip_search_screen.dart';

class BottomScreenLayout extends StatefulWidget {
  const BottomScreenLayout({super.key});

  @override
  State<BottomScreenLayout> createState() => _BottomScreenLayoutState();
}

class _BottomScreenLayoutState extends State<BottomScreenLayout> {
  int _selectedIndex = 0;

  final List<Widget> _bottomScreens = const [
    HomeScreen(),
    TripSearchScreen(),
    MyBookingsScreen(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: _bottomScreens[_selectedIndex],
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(14, 6, 14, 12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [primaryRedDark, primaryRed],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryRed.withOpacity(0.28),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              height: 74,
              backgroundColor: Colors.transparent,
              indicatorColor: Colors.white.withOpacity(0.2),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                final isSelected = states.contains(WidgetState.selected);
                return IconThemeData(
                  color: isSelected ? Colors.white : Colors.white70,
                  size: isSelected ? 28 : 24,
                );
              }),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                final isSelected = states.contains(WidgetState.selected);
                return theme.textTheme.bodyMedium!.copyWith(
                  fontFamily: 'OpenSans SemiBold',
                  color: isSelected ? Colors.white : Colors.white70,
                );
              }),
            ),
            child: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_rounded),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.explore_rounded),
                  selectedIcon: Icon(Icons.explore_rounded),
                  label: 'Trips',
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_long_rounded),
                  selectedIcon: Icon(Icons.receipt_long_rounded),
                  label: 'Bookings',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


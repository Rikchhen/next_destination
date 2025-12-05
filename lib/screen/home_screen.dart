import 'package:flutter/material.dart';
import 'package:next_destination/utils/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [gradientStartColor, gradientEndColor],
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildHeader(),
                  const SizedBox(height: 20),

                  _buildSearchBar(),
                  const SizedBox(height: 30),

                  _buildTicketSection(
                    title: 'Airplane Tickets',
                    icon: Icons.flight,
                    items: [
                      _buildFlightCard(
                        airline: 'Buddha Air',
                        price: 'NPR 6647',
                      ),
                      _buildFlightCard(
                        airline: 'Yeti Airlines',
                        price: 'NPR 6647',
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  _buildTicketSection(
                    title: 'Bus Tickets',
                    icon: Icons.directions_bus,
                    items: [
                      _buildBusCard(
                        service: 'Golden Super Delux',
                        price: 'NPR 1200',
                      ),
                      _buildBusCard(
                        service: 'Nepal Travels',
                        price: 'NPR 1400',
                      ),
                    ],
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),

      bottomNavigationBar: _buildCustomBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person_outline, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hello Hari Bahadur!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Where you want go',
                  style: TextStyle(fontSize: 14, color: secondaryText),
                ),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
            ],
          ),
          child: const Icon(Icons.notifications_none, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: secondaryText),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search destinations...',
                hintStyle: TextStyle(color: secondaryText),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketSection({
    required String title,
    required IconData icon,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Row(
                  children: [
                    Text('See all', style: TextStyle(color: primaryRed)),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: primaryRed,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        ...items,
      ],
    );
  }

  Widget _buildFlightCard({required String airline, required String price}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15.0),
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade100, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_airport, color: primaryRed, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    airline,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryRed,
                    ),
                  ),
                  const Text(
                    '25 Min',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NPT 07:30 25min NPT 07:55',
                    style: TextStyle(color: secondaryText),
                  ),
                  Text(
                    'Class Y | ATR | 25KG',
                    style: TextStyle(color: secondaryText, fontSize: 12),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'FLIGHT DETAILS',
                      style: TextStyle(color: primaryRed, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const Text(
                'Refundable',
                style: TextStyle(color: Colors.green, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBusCard({required String service, required String price}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15.0),
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade100, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.directions_bus_filled,
                    color: primaryRed,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    service,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryRed,
                    ),
                  ),
                  const Text(
                    '45 Min',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'A/C Sleeper (2+2)',
                    style: TextStyle(color: secondaryText),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '9:00 AM - 9:45 AM',
                        style: TextStyle(color: secondaryText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    '15 Seats left',
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ],
              ),
              Row(
                children: const [
                  Icon(Icons.wifi, size: 20, color: Colors.blue),
                  SizedBox(width: 5),
                  Icon(Icons.refresh, size: 20, color: Colors.blue),
                  SizedBox(width: 5),
                  Icon(Icons.restaurant, size: 20, color: Colors.blue),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomBottomNavBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: primaryRed,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.zero,
          topRight: Radius.zero,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavBarItem(0, Icons.home, 'Home'),
          _buildNavBarItem(1, Icons.explore, 'Explore'),
          _buildNavBarItem(2, Icons.wallet, 'Wallet'),
          _buildNavBarItem(3, Icons.settings, 'Settings'),
        ],
      ),
    );
  }

  Widget _buildNavBarItem(int index, IconData icon, String label) {
    bool isSelected = index == _selectedIndex;
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.white70,
            size: 28,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:next_destination/utils/colors.dart';
import 'package:next_destination/widgets/home_header.dart';
import 'package:next_destination/widgets/search_bar_custom.dart';
import 'package:next_destination/widgets/flight_card.dart';
import 'package:next_destination/widgets/bus_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                  const HomeHeader(userName: "Hari Bahadur"),
                  const SizedBox(height: 20),
                  const SearchBarCustom(),
                  const SizedBox(height: 30),

                  _buildSectionTitle('Airplane Tickets'),
                  const FlightCard(airline: 'Buddha Air', price: 'NPR 6647'),
                  const FlightCard(airline: 'Yeti Airlines', price: 'NPR 6647'),

                  const SizedBox(height: 30),

                  _buildSectionTitle('Bus Tickets'),
                  const BusCard(
                    service: 'Golden Super Delux',
                    price: 'NPR 1200',
                  ),
                  const BusCard(service: 'Nepal Travels', price: 'NPR 1400'),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
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
    );
  }
}

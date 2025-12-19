import 'package:flutter/material.dart';
import 'package:next_destination/utils/colors.dart';

class BusCard extends StatelessWidget {
  final String service;
  final String price;

  const BusCard({super.key, required this.service, required this.price});

  @override
  Widget build(BuildContext context) {
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
}

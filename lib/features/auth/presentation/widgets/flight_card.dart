import 'package:flutter/material.dart';
import 'package:next_destination/core/utils/colors.dart';

class FlightCard extends StatelessWidget {
  final String airline;
  final String price;

  const FlightCard({super.key, required this.airline, required this.price});

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
}

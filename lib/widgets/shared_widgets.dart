import 'package:flutter/material.dart';
import 'package:next_destination/utils/colors.dart';

class CustomNextDestinationLogo extends StatelessWidget {
  final double size;

  const CustomNextDestinationLogo({required this.size, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: primaryRed,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.airplane_ticket, color: Colors.white, size: 28),

            const SizedBox(height: 4),

            const Text(
              'NEXT DESTINATION',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.flight, color: Colors.white, size: 30),
                SizedBox(width: 8),
                Icon(Icons.arrow_upward, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Icon(Icons.directions_bus, color: Colors.white, size: 30),
                SizedBox(width: 8),
                Icon(Icons.airport_shuttle, color: Colors.white, size: 30),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DotIndicator extends StatelessWidget {
  final int currentIndex;
  final int totalDots;

  const DotIndicator({
    required this.currentIndex,
    required this.totalDots,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalDots, (index) {
        return Container(
          width: 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentIndex == index ? primaryRed : Colors.grey.shade300,
          ),
        );
      }),
    );
  }
}

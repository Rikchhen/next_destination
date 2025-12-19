import 'package:flutter/material.dart';

class CustomPasswordField extends StatelessWidget {
  final String hint;

  const CustomPasswordField({super.key, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: TextField(
        obscureText: true,
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: const Icon(Icons.remove_red_eye, color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}

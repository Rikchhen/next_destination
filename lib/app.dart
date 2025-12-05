import 'package:flutter/material.dart';
import 'package:next_destination/utils/colors.dart';
import 'package:next_destination/screen/splash_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Next Destination',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryRed,
        primarySwatch: Colors.red,
        fontFamily: 'Roboto',

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide(color: primaryRed, width: 2),
          ),
        ),
      ),

      home: const SplashScreen(),
    );
  }
}

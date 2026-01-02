import 'package:flutter/material.dart';
import 'package:next_destination/app/theme/theme_data.dart';

import 'package:next_destination/core/utils/colors.dart';

import 'package:next_destination/features/splash/presentation/pages/splash_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Next Destination',
      debugShowCheckedModeBanner: false,
      theme: getApplicationTheme(),
      home: const SplashScreen(),
    );
  }
}

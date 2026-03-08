import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/app/theme/theme_data.dart';
import 'package:next_destination/app/theme/theme_mode_controller.dart';
import 'package:next_destination/features/splash/presentation/pages/splash_screen.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(activeThemeModeProvider);

    return MaterialApp(
      title: 'Next Destination',
      debugShowCheckedModeBanner: false,
      theme: getApplicationTheme(),
      darkTheme: getDarkApplicationTheme(),
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}

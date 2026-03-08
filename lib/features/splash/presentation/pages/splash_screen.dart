import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/app/routes/app_routes.dart';
import 'package:next_destination/core/services/storage/user_session_storage.dart';
import 'package:next_destination/features/auth/presentation/pages/login_screen.dart';
import 'package:next_destination/features/business/presentation/pages/business_bottom_layout.dart';
import 'package:next_destination/features/dashboard/presentation/pages/bottom_screen_layout.dart';

import 'package:next_destination/core/utils/colors.dart';
import 'package:next_destination/features/onboarding/presentation/pages/onboarding_screen_wrapper.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateBySession();
  }

  Future<void> _navigateBySession() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final sessionService = ref.read(userSessionServiceProvider);
    final isLoggedIn = sessionService.isLoggedIn();
    final role = sessionService.getCurrentUserRole();

    if (isLoggedIn) {
      if (role == 'business') {
        AppRoutes.pushReplacement(context, const BusinessBottomLayout());
      } else {
        AppRoutes.pushReplacement(context, const BottomScreenLayout());
      }
      return;
    }

    AppRoutes.pushReplacement(context, const OnboardingWrapper());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryRed,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'Next Destination',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:next_destination/screen/login_screen.dart';
import 'package:next_destination/utils/colors.dart';
import 'package:next_destination/widgets/shared_widgets.dart';

class OnboardingContent {
  final String title;
  final String description;
  final IconData icon;

  OnboardingContent({
    required this.title,
    required this.description,
    required this.icon,
  });
}

final List<OnboardingContent> pages = [
  OnboardingContent(
    title: 'Welcome to the Next Destination',
    description:
        'An app for convenient bus seat booking, schedules, payments, and travel updates in Nepal.',
    icon: Icons.directions_bus,
  ),

  OnboardingContent(
    title: 'Book Your Seats Easily',
    description:
        'Browse schedules, view seat layouts, and book your preferred seat in just a few taps.',
    icon: Icons.event_seat,
  ),

  OnboardingContent(
    title: 'Secure Payments & Updates',
    description:
        'Pay securely and get real-time updates on your trip status and travel alerts.',
    icon: Icons.payment,
  ),
  OnboardingContent(
    title: 'Start Your Journey Today',
    description:
        'Ready to travel? Create an account or log in to begin exploring destinations.',
    icon: Icons.check_circle_outline,
  ),
];

class OnboardingWrapper extends StatefulWidget {
  const OnboardingWrapper({super.key});

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _onGetStartedPressed() {
    if (_currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeIn,
      );
    } else {
      _navigateToLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: screenHeight * 0.05),

              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    final page = pages[index];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        index == 0
                            ? const CustomNextDestinationLogo(size: 200.0)
                            : Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: primaryRed.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  page.icon,
                                  size: 80,
                                  color: primaryRed,
                                ),
                              ),

                        SizedBox(height: screenHeight * 0.05),

                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 16.0),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            page.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16.0,
                              height: 1.5,
                              color: secondaryText,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              DotIndicator(currentIndex: _currentPage, totalDots: pages.length),

              SizedBox(height: screenHeight * 0.05),

              SizedBox(
                width: double.infinity,
                height: 60.0,
                child: ElevatedButton(
                  onPressed: _onGetStartedPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    _currentPage < pages.length - 1 ? 'Next' : 'Get Started',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20.0),

              TextButton(
                onPressed: _navigateToLogin,
                child: Text(
                  _currentPage < pages.length - 1
                      ? 'Skip'
                      : 'Create an account',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: primaryRed,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

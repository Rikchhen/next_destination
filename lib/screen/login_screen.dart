import 'package:flutter/material.dart';
import 'package:next_destination/screen/bottom_screen_layout.dart';
import 'package:next_destination/screen/register_screen.dart';
import 'package:next_destination/utils/colors.dart';

// Import your new separate widget files here
import 'package:next_destination/widgets/custom_text_field.dart';
import 'package:next_destination/widgets/custom_password_field.dart';
import 'package:next_destination/widgets/social_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Login', style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Login',
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              'Welcome back to the app',
              style: TextStyle(fontSize: 16.0, color: secondaryText),
            ),
            const SizedBox(height: 40.0),

            const Text(
              'Enter your Phone Number',
              style: TextStyle(fontSize: 14, color: secondaryText),
            ),
            const SizedBox(height: 8.0),
            // Replaced with Custom Widget
            const CustomTextField(hint: '9*********9'),

            const SizedBox(height: 20.0),

            const Text(
              'Password',
              style: TextStyle(fontSize: 14, color: secondaryText),
            ),
            const SizedBox(height: 8.0),
            // Replaced with Custom Widget
            const CustomPasswordField(hint: '••••••••••'),

            const SizedBox(height: 10.0),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: true,
                      onChanged: (bool? value) {},
                      activeColor: primaryRed,
                    ),
                    const Text(
                      'Keep me signed in',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(color: primaryRed, fontSize: 14),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20.0),

            SizedBox(
              height: 60.0,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BottomScreenLayout(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30.0),

            const Center(
              child: Text(
                'or sign in with',
                style: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 30.0),

            // Replaced with SocialButton Widgets
            SocialButton(text: 'Continue with Google', onPressed: () {}),
            const SizedBox(height: 15.0),
            SocialButton(text: 'Continue with Facebook', onPressed: () {}),
            const SizedBox(height: 15.0),
            SocialButton(text: 'Continue with Apple ID', onPressed: () {}),

            const SizedBox(height: 30.0),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterScreen(),
                  ),
                );
              },
              child: Text(
                'Create an account',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: primaryRed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

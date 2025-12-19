import 'package:flutter/material.dart';
import 'package:next_destination/screen/login_screen.dart';
import 'package:next_destination/utils/colors.dart';

// Import your reusable widgets
import 'package:next_destination/widgets/custom_text_field.dart';
import 'package:next_destination/widgets/custom_password_field.dart';
import 'package:next_destination/widgets/social_button.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Register', style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Create an account',
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
              'Name',
              style: TextStyle(fontSize: 14, color: secondaryText),
            ),
            const SizedBox(height: 8.0),
            // Reusing CustomTextField
            const CustomTextField(
              hint: 'Enter Your Name',
              keyboardType: TextInputType.text,
            ),

            const SizedBox(height: 20.0),

            const Text(
              'Email or Phone Number',
              style: TextStyle(fontSize: 14, color: secondaryText),
            ),
            const SizedBox(height: 8.0),
            // Reusing CustomTextField
            const CustomTextField(hint: '9*********9'),

            const SizedBox(height: 20.0),

            const Text(
              'Password',
              style: TextStyle(fontSize: 14, color: secondaryText),
            ),
            const SizedBox(height: 8.0),
            // Reusing CustomPasswordField
            const CustomPasswordField(hint: '••••••••••'),

            const SizedBox(height: 10.0),

            Center(
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'By continuing, you agree to our terms of service.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: primaryRed, fontSize: 14),
                ),
              ),
            ),

            const SizedBox(height: 20.0),

            SizedBox(
              height: 60.0,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
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
                  'Sign up',
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
                'or sign up with',
                style: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 30.0),

            // Reusing SocialButton
            SocialButton(text: 'Continue with Google', onPressed: () {}),
            const SizedBox(height: 15.0),
            SocialButton(text: 'Continue with Facebook', onPressed: () {}),
            const SizedBox(height: 15.0),
            SocialButton(text: 'Continue with Apple ID', onPressed: () {}),

            const SizedBox(height: 30.0),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account?',
                  style: TextStyle(color: Colors.black54),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Sign in here',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: primaryRed,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:next_destination/screen/login_screen.dart';
import 'package:next_destination/utils/colors.dart';

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
            _buildTextField(hint: 'Enter Your Name'),

            const SizedBox(height: 20.0),

            const Text(
              'Email or Phone Number',
              style: TextStyle(fontSize: 14, color: secondaryText),
            ),
            const SizedBox(height: 8.0),
            _buildTextField(hint: '9*********9'),

            const SizedBox(height: 20.0),

            const Text(
              'Password',
              style: TextStyle(fontSize: 14, color: secondaryText),
            ),
            const SizedBox(height: 8.0),
            _buildPasswordField(hint: '••••••••••'),

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

            _buildSocialButton(text: 'Continue with Google', onPressed: () {}),
            const SizedBox(height: 15.0),
            _buildSocialButton(
              text: 'Continue with Facebook',
              onPressed: () {},
            ),
            const SizedBox(height: 15.0),
            _buildSocialButton(
              text: 'Continue with Apple ID',
              onPressed: () {},
            ),

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

  Widget _buildTextField({required String hint}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: TextField(
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
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

  Widget _buildPasswordField({required String hint}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: const TextField(
        obscureText: true,
        decoration: InputDecoration(
          hintText: '••••••••••',
          suffixIcon: Icon(Icons.remove_red_eye, color: Colors.grey),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    IconData socialIcon = Icons.error;
    if (text.contains('Google')) socialIcon = Icons.search;
    if (text.contains('Facebook')) socialIcon = Icons.facebook;
    if (text.contains('Apple')) socialIcon = Icons.apple;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.grey.shade200,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide.none,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(socialIcon, color: Colors.black, size: 24),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

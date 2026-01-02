import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/utils/snackbar_utils.dart';
import 'package:next_destination/features/auth/presentation/pages/login_screen.dart';
import 'package:next_destination/core/utils/colors.dart';

// Import your reusable widgets
import 'package:next_destination/core/widgets/custom_text_field.dart';
import 'package:next_destination/core/widgets/custom_password_field.dart';
import 'package:next_destination/features/auth/presentation/state/user_state.dart';
import 'package:next_destination/features/auth/presentation/viewmodels/user_view_model.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> _handleSignup() async {
    ref
        .read(userViewModelProvider.notifier)
        .register(
          fullName: _fullNameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          phoneNumber: _phoneNumberController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to user state changes
    ref.listen<UserState>(userViewModelProvider, (previous, next) {
      if (next.status == UserStatus.registered) {
        SnackbarUtils.showSuccess(
          context,
          'Registration successful! Please login.',
        );
        Navigator.of(context).pop();
      } else if (next.status == UserStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });
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
            CustomTextField(
              hint: 'Enter Your Name',
              controller: _fullNameController,
              keyboardType: TextInputType.text,
            ),

            const SizedBox(height: 20.0),

            const Text(
              'Phone Number',
              style: TextStyle(fontSize: 14, color: secondaryText),
            ),
            const SizedBox(height: 8.0),
            // Reusing CustomTextField
            CustomTextField(
              controller: _phoneNumberController,
              hint: '9********0',
            ),

            const SizedBox(height: 20.0),

            const Text(
              'Email',
              style: TextStyle(fontSize: 14, color: secondaryText),
            ),
            const SizedBox(height: 8.0),
            // Reusing CustomTextField
            CustomTextField(
              controller: _emailController,
              hint: 'email@gmail.com',
            ),
            const SizedBox(height: 20.0),

            const Text(
              'Password',
              style: TextStyle(fontSize: 14, color: secondaryText),
            ),
            const SizedBox(height: 8.0),
            // Reusing CustomPasswordField
            CustomPasswordField(
              hint: '••••••••••',
              controller: _passwordController,
            ),

            const SizedBox(height: 20.0),

            const Text(
              'ConfirmPassword',
              style: TextStyle(fontSize: 14, color: secondaryText),
            ),
            const SizedBox(height: 8.0),
            // Reusing CustomPasswordField
            CustomPasswordField(
              hint: '••••••••••',
              controller: _confirmPasswordController,
            ),

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
                  if (_passwordController.text !=
                      _confirmPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Passwords do not match")),
                    );
                    return;
                  }
                  _handleSignup();
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/app/routes/app_routes.dart';
import 'package:next_destination/core/utils/snackbar_utils.dart';
import 'package:next_destination/features/auth/presentation/pages/register_screen.dart';
import 'package:next_destination/features/auth/presentation/state/user_state.dart';
import 'package:next_destination/features/auth/presentation/viewmodels/user_view_model.dart';
import 'package:next_destination/core/utils/colors.dart';
import 'package:next_destination/core/widgets/custom_text_field.dart';
import 'package:next_destination/core/widgets/custom_password_field.dart';
import 'package:next_destination/features/dashboard/presentation/pages/bottom_screen/home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(userViewModelProvider.notifier)
          .login(
            phoneNumber: _phoneController.text,
            password: _passwordController.text,
          );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<UserState>(userViewModelProvider, (previous, next) {
      if (next.status == UserStatus.authenticated) {
        AppRoutes.pushReplacement(context, HomeScreen());
        SnackbarUtils.showSuccess(context, "Login SuccessFull");
      } else if (next.status == UserStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage ?? "Login Failed");
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Login', style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
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
              CustomTextField(
                hint: '9*********9',
                controller: _phoneController,
              ),

              const SizedBox(height: 20.0),

              const Text(
                'Password',
                style: TextStyle(fontSize: 14, color: secondaryText),
              ),
              const SizedBox(height: 8.0),
              // Replaced with Custom Widget
              CustomPasswordField(
                hint: '••••••••••',
                controller: _passwordController,
              ),

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
                  onPressed: _handleLogin,
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
                  'New To The App?',
                  style: TextStyle(color: Colors.grey),
                ),
              ),

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
      ),
    );
  }
}

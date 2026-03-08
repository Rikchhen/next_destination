import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/app/routes/app_routes.dart';
import 'package:next_destination/core/utils/colors.dart';
import 'package:next_destination/core/utils/snackbar_utils.dart';
import 'package:next_destination/core/widgets/custom_password_field.dart';
import 'package:next_destination/core/widgets/custom_text_field.dart';
import 'package:next_destination/features/business/presentation/pages/business_bottom_layout.dart';
import 'package:next_destination/features/business/presentation/pages/business_register_screen.dart';
import 'package:next_destination/features/business/presentation/state/business_state.dart';
import 'package:next_destination/features/business/presentation/viewmodel/business_view_model.dart';

class BusinessLoginScreen extends ConsumerStatefulWidget {
  const BusinessLoginScreen({super.key});

  @override
  ConsumerState<BusinessLoginScreen> createState() =>
      _BusinessLoginScreenState();
}

class _BusinessLoginScreenState extends ConsumerState<BusinessLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      SnackbarUtils.showError(context, "Please enter a valid email");
      return;
    }
    if (password.isEmpty) {
      SnackbarUtils.showError(context, "Please enter password");
      return;
    }

    await ref
        .read(businessViewModelProvider.notifier)
        .loginBusiness(email: email, password: password);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(businessViewModelProvider);
    final isLoading = state.status == BusinessStatus.loading;

    ref.listen<BusinessState>(businessViewModelProvider, (previous, next) {
      if (next.status == BusinessStatus.authenticated) {
        AppRoutes.pushReplacement(context, const BusinessBottomLayout());
        SnackbarUtils.showSuccess(context, "Business Login Successful");
      } else if (next.status == BusinessStatus.error &&
          next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Business Login',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Business Login',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              'Login to manage your business account',
              style: TextStyle(fontSize: 16, color: secondaryText),
            ),
            const SizedBox(height: 40),
            const Text(
              'Enter your Email',
              style: TextStyle(fontSize: 14, color: secondaryText),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              hint: 'business@example.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            const Text(
              'Password',
              style: TextStyle(fontSize: 14, color: secondaryText),
            ),
            const SizedBox(height: 8),
            CustomPasswordField(
              hint: '**********',
              controller: _passwordController,
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 60,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 30),
            const Center(
              child: Text(
                'New Business?',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () {
                      AppRoutes.pushReplacement(
                        context,
                        const BusinessRegisterScreen(),
                      );
                    },
              child: Text(
                'Create business account',
                style: TextStyle(
                  fontSize: 16,
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

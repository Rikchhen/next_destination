import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:next_destination/core/utils/colors.dart';
import 'package:next_destination/core/utils/snackbar_utils.dart';
import 'package:next_destination/core/widgets/custom_password_field.dart';
import 'package:next_destination/core/widgets/custom_text_field.dart';
import 'package:next_destination/features/business/presentation/pages/business_document_upload_screen.dart';
import 'package:next_destination/features/business/presentation/state/business_state.dart';
import 'package:next_destination/features/business/presentation/viewmodel/business_view_model.dart';

class BusinessRegisterScreen extends ConsumerStatefulWidget {
  const BusinessRegisterScreen({super.key});

  @override
  ConsumerState<BusinessRegisterScreen> createState() =>
      _BusinessRegisterScreenState();
}

class _BusinessRegisterScreenState
    extends ConsumerState<BusinessRegisterScreen> {
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? _profilePicturePath;

  Future<void> _pickProfilePicture() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      setState(() {
        _profilePicturePath = pickedImage.path;
      });
    }
  }

  Future<void> _handleRegister() async {
    final businessName = _businessNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final address = _addressController.text.trim();

    if (businessName.isEmpty) {
      SnackbarUtils.showError(context, "Please enter business name");
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      SnackbarUtils.showError(context, "Please enter a valid email");
      return;
    }
    if (phone.isEmpty || phone.length < 7) {
      SnackbarUtils.showError(context, "Please enter a valid phone number");
      return;
    }
    if (password.length < 6) {
      SnackbarUtils.showError(
        context,
        "Password must be at least 6 characters",
      );
      return;
    }
    if (_profilePicturePath == null) {
      SnackbarUtils.showError(context, "Please select profile picture");
      return;
    }

    await ref
        .read(businessViewModelProvider.notifier)
        .registerBusiness(
          businessName: businessName,
          email: email,
          phoneNumber: phone,
          password: password,
          address: address.isEmpty ? null : address,
          profilePicture: _profilePicturePath!,
        );
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(businessViewModelProvider);
    final isLoading = state.status == BusinessStatus.loading;

    ref.listen<BusinessState>(businessViewModelProvider, (previous, next) {
      if (next.status == BusinessStatus.registered) {
        SnackbarUtils.showSuccess(context, "Business registered successfully");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const BusinessDocumentUploadScreen(),
          ),
        );
      } else if (next.status == BusinessStatus.error &&
          next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Business Register")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: isLoading ? null : _pickProfilePicture,
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: _profilePicturePath != null
                    ? FileImage(File(_profilePicturePath!))
                    : null,
                child: _profilePicturePath == null
                    ? const Icon(Icons.camera_alt)
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _profilePicturePath == null
                  ? "Tap to select profile picture"
                  : "Profile picture selected",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hint: "Business Name",
              controller: _businessNameController,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hint: "Email",
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hint: "Phone Number",
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            CustomPasswordField(
              hint: "********",
              controller: _passwordController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hint: "Address",
              controller: _addressController,
              keyboardType: TextInputType.streetAddress,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 55,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(backgroundColor: primaryRed),
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.3,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Register Business",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

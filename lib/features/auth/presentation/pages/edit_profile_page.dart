import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:next_destination/core/api/api_endpoint.dart';
import 'package:next_destination/core/utils/snackbar_utils.dart';
import 'package:next_destination/features/auth/presentation/viewmodels/user_view_model.dart';
import 'package:next_destination/features/auth/presentation/state/user_state.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isEditing = false;

  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final user = ref.read(userViewModelProvider).userEntity;
      if (user != null) {
        _fullNameController.text = user.fullName;
        _emailController.text = user.email;
        _phoneController.text = user.phoneNumber;
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ---------------- IMAGE PICK ----------------

  Future<void> _pickImage(ImageSource source) async {
    final permission = source == ImageSource.camera
        ? Permission.camera
        : Permission.photos;

    final status = await permission.request();
    if (!status.isGranted) return;

    final image = await _imagePicker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() => _selectedImage = image);

      await ref
          .read(userViewModelProvider.notifier)
          .editProfile(profilePicture: image.path);
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  String? _avatarToUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http')) return raw;

    return '${ApiEndpoints.profileImages}/$raw';
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userViewModelProvider);
    final user = state.userEntity;

    ref.listen(userViewModelProvider, (_, next) {
      if (next.status == UserStatus.edited) {
        setState(() => _isEditing = false);
        SnackbarUtils.showSuccess(context, "Profile updated");
      }

      if (next.status == UserStatus.error) {
        SnackbarUtils.showError(
          context,
          next.errorMessage ?? "Something went wrong",
        );
      }
    });

    ImageProvider avatarProvider;

    if (_selectedImage != null) {
      avatarProvider = FileImage(File(_selectedImage!.path));
    } else {
      final url = _avatarToUrl(user?.profilePicture);
      avatarProvider = url != null
          ? NetworkImage(url)
          : const AssetImage("assets/images/avatar_placeholder.png");
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ---------------- AVATAR ----------------
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(radius: 55, backgroundImage: avatarProvider),
                GestureDetector(
                  onTap: _showImagePicker,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            _ProfileField(
              label: "Full Name",
              controller: _fullNameController,
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),

            // ✅ EMAIL EDITABLE
            _ProfileField(
              label: "Email",
              controller: _emailController,
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),

            // 🔒 PHONE LOCKED WITH ICON
            _ProfileField(
              label: "Phone Number",
              controller: _phoneController,
              enabled: false,
              showLock: true,
            ),

            const SizedBox(height: 40),

            state.status == UserStatus.loading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_isEditing) {
                          ref
                              .read(userViewModelProvider.notifier)
                              .editProfile(
                                fullName: _fullNameController.text.trim(),
                                email: _emailController.text.trim(),
                              );
                        } else {
                          setState(() => _isEditing = true);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        _isEditing ? "Save Profile" : "Edit Profile",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

// ---------------- FIELD WIDGET ----------------

class _ProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final bool showLock;

  const _ProfileField({
    required this.label,
    required this.controller,
    required this.enabled,
    this.showLock = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: showLock
            ? const Icon(Icons.lock, color: Colors.black54)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

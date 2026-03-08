import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/app/routes/app_routes.dart';
import 'package:next_destination/app/theme/theme_mode_controller.dart';
import 'package:next_destination/core/api/api_endpoint.dart';
import 'package:next_destination/core/utils/colors.dart';
import 'package:next_destination/core/utils/snackbar_utils.dart';
import 'package:next_destination/features/auth/presentation/pages/edit_profile_page.dart';
import 'package:next_destination/features/auth/presentation/pages/login_screen.dart';
import 'package:next_destination/features/auth/presentation/state/user_state.dart';
import 'package:next_destination/features/auth/presentation/viewmodels/user_view_model.dart';
import 'package:next_destination/features/booking/presentation/pages/my_bookings_screen.dart';
import 'package:next_destination/features/trip/presentation/pages/trip_search_screen.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(userViewModelProvider.notifier).getProfile());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userViewModelProvider);
    final user = state.userEntity;
    final themeSettings = ref.watch(themeModeControllerProvider);

    ref.listen<UserState>(userViewModelProvider, (previous, next) {
      if (next.status == UserStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      } else if (next.status == UserStatus.loggedOut) {
        AppRoutes.pushAndRemoveUntil(context, const LoginScreen());
        SnackbarUtils.showSuccess(context, 'Logged out successfully');
      }
    });

    final isLoading = state.status == UserStatus.loading && user == null;

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final profilePicture = user?.profilePicture;
    final avatarUrl = (profilePicture == null || profilePicture.trim().isEmpty)
        ? null
        : ApiEndpoints.resolveUploadUrl(
            profilePicture,
            defaultFolder: 'profile-pictures',
          );

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 128,
              height: 128,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              clipBehavior: Clip.antiAlias,
              child: ColoredBox(
                color: Colors.grey.shade300,
                child: avatarUrl != null
                    ? Image.network(
                        avatarUrl,
                        fit: BoxFit.contain,
                        width: 128,
                        height: 128,
                      )
                    : const Icon(Icons.person, size: 58),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.fullName ?? 'Unknown User',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '-',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Phone Number'),
              subtitle: Text(user?.phoneNumber ?? '-'),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text('Auto Dark Mode'),
              subtitle: const Text('Use ambient light sensor to switch theme'),
              value: themeSettings.autoDarkModeEnabled,
              onChanged: (value) {
                ref
                    .read(themeModeControllerProvider.notifier)
                    .setAutoDarkModeEnabled(value);
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfilePage()),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: primaryRed),
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TripSearchScreen()),
                  );
                },
                icon: const Icon(Icons.search),
                label: const Text('Search Trips'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
                  );
                },
                icon: const Icon(Icons.receipt_long),
                label: const Text('My Bookings'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(userViewModelProvider.notifier).logout();
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Logout', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

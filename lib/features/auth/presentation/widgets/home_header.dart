import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/app/routes/app_routes.dart';
import 'package:next_destination/core/api/api_endpoint.dart';
import 'package:next_destination/core/utils/colors.dart';
import 'package:next_destination/features/auth/presentation/pages/edit_profile_page.dart';
import 'package:next_destination/features/auth/presentation/viewmodels/user_view_model.dart';

class HomeHeader extends ConsumerStatefulWidget {
  const HomeHeader({super.key});

  @override
  ConsumerState<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends ConsumerState<HomeHeader> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(userViewModelProvider.notifier).getProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_ProfileHeader()],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
            ],
          ),
          child: const Icon(Icons.notifications_none, color: Colors.black54),
        ),
      ],
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userViewModelProvider).userEntity!;

    final profilePicture = user.profilePicture;
    final String? avatarUrl =
        (profilePicture == null || profilePicture.trim().isEmpty)
        ? null
        : (profilePicture.startsWith('http://') ||
              profilePicture.startsWith('https://'))
        ? profilePicture
        : '${ApiEndpoints.profileImages}/${profilePicture.split('/').last}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null
                ? const Icon(Icons.person, size: 40)
                : null,
          ),

          const SizedBox(width: 24),

          TextButton(
            onPressed: () {
              AppRoutes.push(context, EditProfilePage());
            },
            child: Text(
              "Hello ${user.fullName}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

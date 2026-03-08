import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/app/routes/app_routes.dart';
import 'package:next_destination/core/api/api_endpoint.dart';
import 'package:next_destination/core/utils/colors.dart';
import 'package:next_destination/features/auth/presentation/pages/edit_profile_page.dart';
import 'package:next_destination/features/auth/presentation/pages/profile_page.dart';
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_ProfileHeader()],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderSoft),
            boxShadow: [
              BoxShadow(
                color: primaryRed.withOpacity(0.09),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.notifications_none_rounded, color: primaryRed),
        ),
      ],
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(userViewModelProvider).userEntity;

    if (user == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello',
            style: theme.textTheme.titleLarge?.copyWith(color: primaryRed),
          ),
          const SizedBox(height: 4),
          Text(
            'Find your next destination',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      );
    }

    final profilePicture = user.profilePicture;
    final String? avatarUrl =
        (profilePicture == null || profilePicture.trim().isEmpty)
        ? null
        : ApiEndpoints.resolveUploadUrl(
            profilePicture,
            defaultFolder: 'profile-pictures',
          );

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        AppRoutes.push(context, EditProfilePage());
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(42),
              gradient: const LinearGradient(
                colors: [primaryRedDark, primaryRed],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null
                  ? const Icon(Icons.person_rounded, size: 28)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: theme.textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  user.fullName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontFamily: 'OpenSans Bold',
                    color: primaryRedDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Open profile',
            onPressed: () {
              AppRoutes.push(context, const ProfilePage());
            },
            icon: const Icon(Icons.chevron_right_rounded, color: primaryRed),
          ),
        ],
      ),
    );
  }
}


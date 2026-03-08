import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/api/api_endpoint.dart';
import 'package:next_destination/core/utils/snackbar_utils.dart';
import 'package:next_destination/features/business/presentation/state/business_state.dart';
import 'package:next_destination/features/business/presentation/viewmodel/business_view_model.dart';
import 'package:next_destination/features/ticket/presentation/pages/ticket_scan_screen.dart';
import 'package:next_destination/features/trip/presentation/pages/business_trip_list_screen.dart';

class BusinessProfileScreen extends ConsumerStatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  ConsumerState<BusinessProfileScreen> createState() =>
      _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends ConsumerState<BusinessProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(businessViewModelProvider.notifier).getBusinessProfile(),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<BusinessState>(businessViewModelProvider, (previous, next) {
      if (next.status == BusinessStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    final state = ref.watch(businessViewModelProvider);
    final business = state.businessEntity;

    return Scaffold(
      appBar: AppBar(title: const Text("Business Profile")),
      body: state.status == BusinessStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : business == null
          ? const Center(child: Text("No business profile found"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: business.profilePicture != null
                        ? NetworkImage(
                            ApiEndpoints.resolveUploadUrl(
                              business.profilePicture!,
                              defaultFolder: 'business-profile-pictures',
                            ),
                          )
                        : null,
                    child: business.profilePicture == null
                        ? const Icon(Icons.business, size: 35)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    business.businessName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    title: const Text("Email"),
                    subtitle: Text(business.email),
                  ),
                  ListTile(
                    title: const Text("Phone"),
                    subtitle: Text(business.phoneNumber),
                  ),
                  ListTile(
                    title: const Text("Address"),
                    subtitle: Text(business.address ?? "N/A"),
                  ),
                  ListTile(
                    title: const Text("Status"),
                    subtitle: Text(business.businessStatus),
                  ),
                  ListTile(
                    title: const Text("Verified"),
                    subtitle: Text(business.businessVerified ? "Yes" : "No"),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BusinessTripListScreen(),
                          ),
                        );
                      },
                      child: const Text("Manage Trips"),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TicketScanScreen(),
                          ),
                        );
                      },
                      child: const Text("Scan Ticket"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/app/routes/app_routes.dart';
import 'package:next_destination/core/services/storage/token_service.dart';
import 'package:next_destination/core/services/storage/user_session_storage.dart';
import 'package:next_destination/core/utils/colors.dart';
import 'package:next_destination/core/utils/snackbar_utils.dart';
import 'package:next_destination/features/auth/presentation/pages/login_screen.dart';
import 'package:next_destination/features/business/presentation/pages/business_profile_screen.dart';
import 'package:next_destination/features/ticket/presentation/pages/ticket_scan_screen.dart';
import 'package:next_destination/features/trip/presentation/pages/business_trip_list_screen.dart';
import 'package:next_destination/features/wallet/presentation/pages/business_wallet_screen.dart';

class BusinessBottomLayout extends ConsumerStatefulWidget {
  const BusinessBottomLayout({super.key});

  @override
  ConsumerState<BusinessBottomLayout> createState() => _BusinessBottomLayoutState();
}

class _BusinessBottomLayoutState extends ConsumerState<BusinessBottomLayout> {
  int _selectedIndex = 0;
  bool _isLoggingOut = false;

  Future<void> _logout() async {
    if (_isLoggingOut) return;
    setState(() {
      _isLoggingOut = true;
    });

    try {
      await ref.read(tokenServiceProvider).removeToken();
      await ref.read(userSessionServiceProvider).clearSession();

      if (!mounted) return;
      AppRoutes.pushAndRemoveUntil(context, const LoginScreen());
      SnackbarUtils.showSuccess(context, 'Logged out successfully');
    } catch (_) {
      if (!mounted) return;
      SnackbarUtils.showError(context, 'Logout failed');
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const BusinessProfileScreen(),
      const BusinessTripListScreen(),
      const TicketScanScreen(),
      const BusinessWalletScreen(),
      _BusinessAccountTab(isLoggingOut: _isLoggingOut, onLogout: _logout),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: primaryRed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.route), label: 'Trips'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Account'),
        ],
      ),
    );
  }
}

class _BusinessAccountTab extends StatelessWidget {
  final bool isLoggingOut;
  final VoidCallback onLogout;

  const _BusinessAccountTab({required this.isLoggingOut, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Business Account')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            const Text(
              'Session',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text('Use logout to end your business session on this device.'),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isLoggingOut ? null : onLogout,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                icon: isLoggingOut
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

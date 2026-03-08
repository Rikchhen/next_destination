import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/services/connectivity/network_info.dart';
import 'package:next_destination/core/services/hive/hive_service.dart';
import 'package:next_destination/core/services/storage/user_session_storage.dart';
import 'package:next_destination/core/utils/colors.dart';
import 'package:next_destination/core/utils/snackbar_utils.dart';
import 'package:next_destination/features/auth/presentation/widgets/home_header.dart';
import 'package:next_destination/features/auth/presentation/widgets/search_bar_custom.dart';
import 'package:next_destination/features/booking/presentation/pages/booking_create_screen.dart';
import 'package:next_destination/features/ticket/domain/entity/ticket_entity.dart'
    as ticket_domain;
import 'package:next_destination/features/ticket/presentation/pages/ticket_detail_screen.dart';
import 'package:next_destination/features/trip/domain/entity/trip_entity.dart';
import 'package:next_destination/features/trip/presentation/pages/trip_search_screen.dart';
import 'package:next_destination/features/trip/presentation/state/trip_state.dart';
import 'package:next_destination/features/trip/presentation/viewmodel/trip_view_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _destinationController = TextEditingController();
  bool _isOffline = false;
  List<ticket_domain.TicketEntity> _recentCachedTickets =
      const <ticket_domain.TicketEntity>[];

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadTrips);
    Future.microtask(_loadOfflineSnapshot);
  }

  Future<void> _loadTrips() async {
    await ref.read(tripViewModelProvider.notifier).searchTrips(
      status: 'active',
      page: 1,
      limit: 30,
    );
  }

  Future<void> _loadOfflineSnapshot() async {
    final isConnected = await ref.read(networkInfoProvider).isConnected;
    final userId = ref.read(userSessionServiceProvider).getCurrentUserId() ?? 'default';
    final cachedTickets = ref.read(hiveServiceProvider).getRecentCachedTickets(
      userScope: userId,
      limit: 10,
    );

    if (!mounted) return;
    setState(() {
      _isOffline = !isConnected;
      _recentCachedTickets = cachedTickets.map(_cachedTicketFromMap).toList();
    });
  }

  Future<void> _searchByDestination(String query) async {
    final destination = query.trim();

    if (destination.isEmpty) {
      await _loadTrips();
      return;
    }

    await ref.read(tripViewModelProvider.notifier).searchTrips(
      to: destination,
      status: 'active',
      page: 1,
      limit: 30,
    );
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tripState = ref.watch(tripViewModelProvider);
    final isLoading = tripState.status == TripStatus.loading;
    final trips = tripState.searchedTrips;
    final busTrips = trips.where((t) => t.type.toLowerCase() == 'bus').toList();
    final planeTrips = trips
        .where((t) => t.type.toLowerCase() == 'plane')
        .toList();

    ref.listen<TripState>(tripViewModelProvider, (previous, next) {
      if (next.status == TripStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [gradientStartColor, gradientMidColor, gradientEndColor],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const HomeHeader(),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [primaryRedDark, primaryRed],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryRed.withOpacity(0.3),
                          blurRadius: 26,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ready for your next trip?',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontFamily: 'OpenSans Bold',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Book bus and airplane journeys in seconds.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.86),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SearchBarCustom(
                    controller: _destinationController,
                    onSubmitted: _searchByDestination,
                    onChanged: (value) {
                      if (value.trim().isEmpty) {
                        _loadTrips();
                      }
                    },
                    hintText: 'Search destination (To)',
                  ),
                  const SizedBox(height: 24),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  _buildSectionTitle('Airplane Trips'),
                  _buildTripSection(
                    trips: planeTrips,
                    emptyText: 'No airplane trips available',
                  ),
                  if (_isOffline && _recentCachedTickets.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    _buildSectionTitle('Recent Tickets (Offline)'),
                    _buildRecentTicketSection(),
                  ],

                  const SizedBox(height: 18),

                  _buildSectionTitle('Bus Trips'),
                  _buildTripSection(
                    trips: busTrips,
                    emptyText: 'No bus trips available',
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontFamily: 'OpenSans Bold',
              color: primaryRedDark,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TripSearchScreen()),
              );
            },
            child: Row(
              children: [
                Text(
                  'See all',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: primaryRed,
                    fontFamily: 'OpenSans SemiBold',
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: primaryRed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripSection({
    required List<TripEntity> trips,
    required String emptyText,
  }) {
    final theme = Theme.of(context);

    if (trips.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          emptyText,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: primaryRedDark,
            fontFamily: 'OpenSans SemiBold',
          ),
        ),
      );
    }

    return Column(
      children: trips
          .map(
            (trip) => _TripHomeCard(
              trip: trip,
              onBook: trip.status != 'active' || trip.availableSeats < 1
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingCreateScreen(trip: trip),
                        ),
                      );
                    },
            ),
          )
          .toList(),
    );
  }

  Widget _buildRecentTicketSection() {
    if (_recentCachedTickets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: _recentCachedTickets
          .map(
            (ticket) => Card(
              child: ListTile(
                title: Text('${ticket.passengerName} (${ticket.seatNumber})'),
                subtitle: Text('Status: ${ticket.status.toUpperCase()}'),
                trailing: const Icon(Icons.qr_code),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TicketDetailScreen(
                        ticketId: ticket.ticketId,
                        initialTicket: ticket,
                      ),
                    ),
                  );
                },
              ),
            ),
          )
          .toList(),
    );
  }

  ticket_domain.TicketEntity _cachedTicketFromMap(Map<String, dynamic> json) {
    return ticket_domain.TicketEntity(
      ticketId: json['ticketId']?.toString(),
      booking: (json['booking'] ?? '').toString(),
      trip: (json['trip'] ?? '').toString(),
      bookedBy: (json['bookedBy'] ?? '').toString(),
      passengerName: (json['passengerName'] ?? '').toString(),
      seatNumber: (json['seatNumber'] ?? '').toString(),
      qrToken: (json['qrToken'] ?? '').toString(),
      status: (json['status'] ?? 'issued').toString(),
      issuedAt: json['issuedAt'] == null
          ? null
          : DateTime.tryParse(json['issuedAt'].toString()),
      usedAt: json['usedAt'] == null
          ? null
          : DateTime.tryParse(json['usedAt'].toString()),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.tryParse(json['expiresAt'].toString()),
      voidReason: json['voidReason']?.toString(),
    );
  }
}

class _TripHomeCard extends StatelessWidget {
  final TripEntity trip;
  final VoidCallback? onBook;

  const _TripHomeCard({required this.trip, required this.onBook});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canBook = onBook != null;
    final status = trip.status.toLowerCase();
    final statusColor = status == 'active' ? successGreen : primaryRed;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.white.withOpacity(0.95),
          border: Border.all(color: borderSoft),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onBook,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: primaryRed.withOpacity(0.11),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        trip.type == 'plane'
                            ? Icons.flight_takeoff_rounded
                            : Icons.directions_bus_filled_rounded,
                        color: primaryRed,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${trip.from} -> ${trip.to}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontFamily: 'OpenSans SemiBold',
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      'NPR ${trip.price.toStringAsFixed(0)}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: primaryRedDark,
                        fontFamily: 'OpenSans Bold',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _MetaChip(
                      icon: Icons.event_seat_rounded,
                      label: '${trip.availableSeats}/${trip.totalSeats} seats',
                    ),
                    const SizedBox(width: 8),
                    _MetaChip(
                      icon: Icons.fiber_manual_record_rounded,
                      label: trip.status.toUpperCase(),
                      textColor: statusColor,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onBook,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canBook ? primaryRed : Colors.grey.shade400,
                    ),
                    child: Text(canBook ? 'Book now' : 'Unavailable'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? textColor;

  const _MetaChip({required this.icon, required this.label, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.black.withOpacity(0.04),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor ?? Colors.black54),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: textColor ?? Colors.black54,
              fontSize: 12,
              fontFamily: 'OpenSans Medium',
            ),
          ),
        ],
      ),
    );
  }
}


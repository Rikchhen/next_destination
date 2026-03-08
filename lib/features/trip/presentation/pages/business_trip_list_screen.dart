import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/services/connectivity/network_info.dart';
import 'package:next_destination/core/services/hive/hive_service.dart';
import 'package:next_destination/core/services/storage/user_session_storage.dart';
import 'package:next_destination/core/utils/colors.dart';
import 'package:next_destination/core/utils/snackbar_utils.dart';
import 'package:next_destination/features/ticket/domain/entity/ticket_entity.dart';
import 'package:next_destination/features/ticket/presentation/pages/ticket_detail_screen.dart';
import 'package:next_destination/features/trip/domain/entity/trip_entity.dart';
import 'package:next_destination/features/trip/presentation/pages/business_trip_form_screen.dart';
import 'package:next_destination/features/trip/presentation/state/trip_state.dart';
import 'package:next_destination/features/trip/presentation/viewmodel/trip_view_model.dart';

class BusinessTripListScreen extends ConsumerStatefulWidget {
  const BusinessTripListScreen({super.key});

  @override
  ConsumerState<BusinessTripListScreen> createState() =>
      _BusinessTripListScreenState();
}

class _BusinessTripListScreenState extends ConsumerState<BusinessTripListScreen> {
  bool _isOnline = true;
  late final String _userScope;

  @override
  void initState() {
    super.initState();
    _userScope = ref.read(userSessionServiceProvider).getCurrentUserId() ?? 'default';
    Future.microtask(_loadPageData);
  }

  Future<void> _loadPageData() async {
    final connected = await ref.read(networkInfoProvider).isConnected;
    if (!mounted) return;

    setState(() {
      _isOnline = connected;
    });

    await ref.read(tripViewModelProvider.notifier).getMyTrips();
  }

  String _formatDateTime(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.year}-$month-$day $hour:$minute';
  }

  Future<void> _openCreate() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const BusinessTripFormScreen()),
    );

    if (result == true && mounted) {
      await _loadPageData();
    }
  }

  Future<void> _openEdit(TripEntity trip) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => BusinessTripFormScreen(trip: trip)),
    );

    if (result == true && mounted) {
      await _loadPageData();
    }
  }

  Future<void> _confirmDelete(TripEntity trip) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Trip'),
          content: Text('Are you sure to delete ${trip.from} to ${trip.to}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && trip.tripId != null) {
      await ref.read(tripViewModelProvider.notifier).deleteTrip(trip.tripId!);
    }
  }

  List<TicketEntity> _cachedTicketsForTrip(String? tripId) {
    if (tripId == null || tripId.isEmpty) {
      return const <TicketEntity>[];
    }

    final rawTickets = ref.read(hiveServiceProvider).getCachedTicketsByTrip(
      userScope: _userScope,
      tripId: tripId,
    );

    return rawTickets.map(_ticketFromMap).toList();
  }

  TicketEntity _ticketFromMap(Map<String, dynamic> json) {
    return TicketEntity(
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

  Future<void> _openTripTickets(TripEntity trip) async {
    final tickets = _cachedTicketsForTrip(trip.tripId);

    if (tickets.isEmpty) {
      SnackbarUtils.showError(context, 'No cached tickets for this trip yet');
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Cached Tickets (${tickets.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: tickets.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final ticket = tickets[index];
                      return Card(
                        child: ListTile(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              this.context,
                              MaterialPageRoute(
                                builder: (_) => TicketDetailScreen(
                                  ticketId: ticket.ticketId,
                                  initialTicket: ticket,
                                ),
                              ),
                            );
                          },
                          title: Text('${ticket.passengerName} (${ticket.seatNumber})'),
                          subtitle: Text('Status: ${ticket.status.toUpperCase()}'),
                          trailing: const Icon(Icons.qr_code),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tripViewModelProvider);
    final isLoading = state.status == TripStatus.loading;

    ref.listen<TripState>(tripViewModelProvider, (previous, next) {
      if (next.status == TripStatus.deleted) {
        SnackbarUtils.showSuccess(context, 'Trip deleted successfully');
      } else if (next.status == TripStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        actions: [
          IconButton(
            onPressed: isLoading
                ? null
                : _loadPageData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryRed,
        onPressed: isLoading ? null : _openCreate,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: isLoading && state.myTrips.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.myTrips.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No trips created yet'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _openCreate,
                    style: ElevatedButton.styleFrom(backgroundColor: primaryRed),
                    child: const Text(
                      'Create your first trip',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.myTrips.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final trip = state.myTrips[index];
                final cachedTickets = _cachedTicketsForTrip(trip.tripId);
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: primaryRed.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                trip.type.toUpperCase(),
                                style: TextStyle(
                                  color: primaryRed,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              trip.status.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${trip.from} -> ${trip.to}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Departure: ${_formatDateTime(trip.departureAt)}'),
                        if (trip.arrivalAt != null)
                          Text('Arrival: ${_formatDateTime(trip.arrivalAt!)}'),
                        const SizedBox(height: 4),
                        Text('Price: NPR ${trip.price.toStringAsFixed(2)}'),
                        Text(
                          'Seats: ${trip.availableSeats}/${trip.totalSeats} available',
                        ),
                        const SizedBox(height: 4),
                        Text('Cached tickets: ${cachedTickets.length}'),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _openTripTickets(trip),
                              icon: const Icon(Icons.confirmation_num_outlined),
                              label: const Text('Tickets'),
                            ),
                            const Spacer(),
                            OutlinedButton.icon(
                              onPressed: isLoading || !_isOnline
                                  ? null
                                  : () => _openEdit(trip),
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: isLoading || !_isOnline
                                  ? null
                                  : () => _confirmDelete(trip),
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

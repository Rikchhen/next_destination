import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/features/booking/presentation/pages/booking_create_screen.dart';
import 'package:next_destination/features/booking/presentation/pages/my_bookings_screen.dart';
import 'package:next_destination/core/utils/colors.dart';
import 'package:next_destination/core/utils/snackbar_utils.dart';
import 'package:next_destination/core/widgets/custom_text_field.dart';
import 'package:next_destination/features/trip/presentation/state/trip_state.dart';
import 'package:next_destination/features/trip/presentation/viewmodel/trip_view_model.dart';

class TripSearchScreen extends ConsumerStatefulWidget {
  const TripSearchScreen({super.key});

  @override
  ConsumerState<TripSearchScreen> createState() => _TripSearchScreenState();
}

class _TripSearchScreenState extends ConsumerState<TripSearchScreen> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  String? _type;
  String? _status;
  DateTime? _departureDate;

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Future<void> _pickDepartureDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _departureDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (selected != null) {
      setState(() {
        _departureDate = DateTime(selected.year, selected.month, selected.day);
      });
    }
  }

  String _formatDate(DateTime? value) {
    if (value == null) return 'Any date';
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  Future<void> _search() async {
    await ref
        .read(tripViewModelProvider.notifier)
        .searchTrips(
          type: _type,
          status: _status,
          from: _fromController.text.trim().isEmpty
              ? null
              : _fromController.text.trim(),
          to: _toController.text.trim().isEmpty
              ? null
              : _toController.text.trim(),
          departureFrom: _departureDate,
          departureTo: _departureDate != null
              ? DateTime(
                  _departureDate!.year,
                  _departureDate!.month,
                  _departureDate!.day,
                  23,
                  59,
                  59,
                )
              : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(tripViewModelProvider);
    final isLoading = state.status == TripStatus.loading;

    ref.listen<TripState>(tripViewModelProvider, (previous, next) {
      if (next.status == TripStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Trips'),
        actions: [
          IconButton(
            tooltip: 'My Bookings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
              );
            },
            icon: const Icon(Icons.receipt_long_rounded),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [gradientStartColor, gradientMidColor, gradientEndColor],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.88),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _type,
                            decoration: const InputDecoration(labelText: 'Type'),
                            items: const [
                              DropdownMenuItem(value: 'bus', child: Text('Bus')),
                              DropdownMenuItem(
                                value: 'plane',
                                child: Text('Plane'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _type = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _status,
                            decoration: const InputDecoration(labelText: 'Status'),
                            items: const [
                              DropdownMenuItem(
                                value: 'active',
                                child: Text('Active'),
                              ),
                              DropdownMenuItem(
                                value: 'cancelled',
                                child: Text('Cancelled'),
                              ),
                              DropdownMenuItem(
                                value: 'delayed',
                                child: Text('Delayed'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _status = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      hint: 'From (e.g. Kathmandu)',
                      controller: _fromController,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      hint: 'To (e.g. Pokhara)',
                      controller: _toController,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _pickDepartureDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                          border: Border.all(color: Colors.red.shade100),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              color: primaryRed,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Departure: ${_formatDate(_departureDate)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _search,
                        child: isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Search Trips'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: state.searchedTrips.isEmpty
                  ? Center(
                      child: Text('No trips found', style: theme.textTheme.bodyLarge),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: state.searchedTrips.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final trip = state.searchedTrips[index];
                        final canBook =
                            trip.status == 'active' && trip.availableSeats > 0;

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.red.shade100),
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: primaryRed.withOpacity(0.12),
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${trip.from} -> ${trip.to}',
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        fontFamily: 'OpenSans SemiBold',
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${trip.type.toUpperCase()} | ${trip.status.toUpperCase()} | Seats ${trip.availableSeats}/${trip.totalSeats}',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'NPR ${trip.price.toStringAsFixed(0)}',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: primaryRedDark,
                                      fontFamily: 'OpenSans Bold',
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  SizedBox(
                                    height: 34,
                                    child: ElevatedButton(
                                      onPressed: !canBook
                                          ? null
                                          : () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      BookingCreateScreen(
                                                        trip: trip,
                                                      ),
                                                ),
                                              );
                                            },
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(68, 34),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                      ),
                                      child: Text(canBook ? 'Book' : 'Closed'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}


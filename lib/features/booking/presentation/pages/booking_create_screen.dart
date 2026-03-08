import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/services/storage/user_session_storage.dart';
import 'package:next_destination/core/utils/colors.dart';
import 'package:next_destination/core/utils/snackbar_utils.dart';
import 'package:next_destination/core/widgets/custom_text_field.dart';
import 'package:next_destination/features/booking/presentation/pages/booking_detail_screen.dart';
import 'package:next_destination/features/booking/presentation/state/booking_state.dart';
import 'package:next_destination/features/booking/presentation/viewmodel/booking_view_model.dart';
import 'package:next_destination/features/trip/domain/entity/trip_entity.dart';

class BookingCreateScreen extends ConsumerStatefulWidget {
  final TripEntity trip;

  const BookingCreateScreen({super.key, required this.trip});

  @override
  ConsumerState<BookingCreateScreen> createState() => _BookingCreateScreenState();
}

class _BookingCreateScreenState extends ConsumerState<BookingCreateScreen> {
  final TextEditingController _contactEmailController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();
  final List<_PassengerFormData> _passengers = [];

  @override
  void initState() {
    super.initState();

    final session = ref.read(userSessionServiceProvider);
    _contactEmailController.text = session.getCurrentUserEmail() ?? '';
    _contactPhoneController.text = session.getCurrentUserPhoneNumber() ?? '';

    _addPassenger();
  }

  void _addPassenger() {
    setState(() {
      _passengers.add(_PassengerFormData());
    });
  }

  void _removePassenger(int index) {
    if (_passengers.length <= 1) return;
    setState(() {
      final item = _passengers.removeAt(index);
      item.dispose();
    });
  }

  Future<void> _submit() async {
    if (widget.trip.tripId == null || widget.trip.tripId!.isEmpty) {
      SnackbarUtils.showError(context, 'Invalid trip id');
      return;
    }

    final contactEmail = _contactEmailController.text.trim();
    final contactPhone = _contactPhoneController.text.trim();

    if (!contactEmail.contains('@')) {
      SnackbarUtils.showError(context, 'Valid email required');
      return;
    }

    if (contactPhone.length < 6) {
      SnackbarUtils.showError(context, 'Valid phone required');
      return;
    }

    if (_passengers.isEmpty) {
      SnackbarUtils.showError(context, 'At least 1 passenger required');
      return;
    }

    if (_passengers.length > widget.trip.availableSeats) {
      SnackbarUtils.showError(context, 'Not enough available seats');
      return;
    }

    final parsedPassengers = <PassengerBookingInput>[];
    final seenSeats = <String>{};

    for (final p in _passengers) {
      final fullName = p.fullNameController.text.trim();
      final age = int.tryParse(p.ageController.text.trim());
      final seat = p.seatController.text.trim().toUpperCase();

      if (fullName.length < 2) {
        SnackbarUtils.showError(context, 'Passenger name required');
        return;
      }

      if (age == null || age < 0) {
        SnackbarUtils.showError(context, 'Age must be >= 0');
        return;
      }

      if (seat.isEmpty) {
        SnackbarUtils.showError(context, 'Seat number required');
        return;
      }

      if (seenSeats.contains(seat.toLowerCase())) {
        SnackbarUtils.showError(context, 'Duplicate seat numbers in passengers');
        return;
      }

      seenSeats.add(seat.toLowerCase());

      parsedPassengers.add(
        PassengerBookingInput(
          fullName: fullName,
          age: age,
          gender: p.gender,
          seatNumber: seat,
        ),
      );
    }

    await ref
        .read(bookingViewModelProvider.notifier)
        .createBooking(
          trip: widget.trip.tripId!,
          passengers: parsedPassengers,
          contactEmail: contactEmail,
          contactPhone: contactPhone,
        );
  }

  @override
  void dispose() {
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    for (final p in _passengers) {
      p.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingViewModelProvider);
    final isLoading = state.status == BookingStatus.loading;

    ref.listen<BookingState>(bookingViewModelProvider, (previous, next) {
      if (next.status == BookingStatus.created && next.bookingDetail != null) {
        SnackbarUtils.showSuccess(context, 'Booking created successfully');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BookingDetailScreen(
              initialDetail: next.bookingDetail!,
              autoStartPayment: true,
            ),
          ),
        );
      } else if (next.status == BookingStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Book Trip')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.trip.from} -> ${widget.trip.to}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 6),
                    Text('Type: ${widget.trip.type.toUpperCase()}'),
                    Text('Available seats: ${widget.trip.availableSeats}'),
                    Text('Price per seat: NPR ${widget.trip.price.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text('Contact Details', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            CustomTextField(
              hint: 'Contact Email',
              controller: _contactEmailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              hint: 'Contact Phone',
              controller: _contactPhoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Passengers', style: TextStyle(fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: isLoading ? null : _addPassenger,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Passenger'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._passengers.asMap().entries.map((entry) {
              final index = entry.key;
              final p = entry.value;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Passenger ${index + 1}'),
                          const Spacer(),
                          IconButton(
                            onPressed: isLoading ? null : () => _removePassenger(index),
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                          ),
                        ],
                      ),
                      CustomTextField(
                        hint: 'Full Name',
                        controller: p.fullNameController,
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              hint: 'Age',
                              controller: p.ageController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: p.gender,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'male', child: Text('Male')),
                                DropdownMenuItem(value: 'female', child: Text('Female')),
                              ],
                              onChanged: isLoading
                                  ? null
                                  : (value) {
                                      if (value != null) {
                                        setState(() {
                                          p.gender = value;
                                        });
                                      }
                                    },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hint: 'Seat Number (e.g. A1)',
                        controller: p.seatController,
                        keyboardType: TextInputType.text,
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: primaryRed),
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Confirm Booking (NPR ${(widget.trip.price * _passengers.length).toStringAsFixed(2)})',
                        style: const TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PassengerFormData {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController seatController = TextEditingController();
  String gender = 'male';

  void dispose() {
    fullNameController.dispose();
    ageController.dispose();
    seatController.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/utils/colors.dart';
import 'package:next_destination/core/utils/snackbar_utils.dart';
import 'package:next_destination/core/widgets/custom_text_field.dart';
import 'package:next_destination/features/trip/domain/entity/trip_entity.dart';
import 'package:next_destination/features/trip/presentation/state/trip_state.dart';
import 'package:next_destination/features/trip/presentation/viewmodel/trip_view_model.dart';

class BusinessTripFormScreen extends ConsumerStatefulWidget {
  final TripEntity? trip;

  const BusinessTripFormScreen({super.key, this.trip});

  @override
  ConsumerState<BusinessTripFormScreen> createState() =>
      _BusinessTripFormScreenState();
}

class _BusinessTripFormScreenState extends ConsumerState<BusinessTripFormScreen> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _totalSeatsController = TextEditingController();

  String _type = 'bus';
  String _status = 'active';
  DateTime? _departureAt;
  DateTime? _arrivalAt;

  bool get _isEdit => widget.trip != null;

  @override
  void initState() {
    super.initState();

    final trip = widget.trip;
    if (trip != null) {
      _type = trip.type;
      _status = trip.status;
      _fromController.text = trip.from;
      _toController.text = trip.to;
      _priceController.text = trip.price.toStringAsFixed(2);
      _totalSeatsController.text = trip.totalSeats.toString();
      _departureAt = trip.departureAt;
      _arrivalAt = trip.arrivalAt;
    }
  }

  Future<void> _pickDateTime({required bool isDeparture}) async {
    final now = DateTime.now();
    final current = isDeparture
        ? (_departureAt ?? now)
        : (_arrivalAt ?? _departureAt ?? now);

    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );

    if (time == null) return;

    final picked = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isDeparture) {
        _departureAt = picked;
        if (_arrivalAt != null && _arrivalAt!.isBefore(_departureAt!)) {
          _arrivalAt = null;
        }
      } else {
        _arrivalAt = picked;
      }
    });
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return 'Select date & time';

    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.year}-$month-$day $hour:$minute';
  }

  Future<void> _submit() async {
    final from = _fromController.text.trim();
    final to = _toController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    final totalSeats = int.tryParse(_totalSeatsController.text.trim());

    if (from.length < 2) {
      SnackbarUtils.showError(context, 'Please enter valid `from` location');
      return;
    }

    if (to.length < 2) {
      SnackbarUtils.showError(context, 'Please enter valid `to` location');
      return;
    }

    if (from.toLowerCase() == to.toLowerCase()) {
      SnackbarUtils.showError(context, '`from` and `to` cannot be same');
      return;
    }

    if (_departureAt == null) {
      SnackbarUtils.showError(context, 'Please select departure date time');
      return;
    }

    if (_arrivalAt != null && !_arrivalAt!.isAfter(_departureAt!)) {
      SnackbarUtils.showError(
        context,
        '`arrivalAt` must be after `departureAt`',
      );
      return;
    }

    if (price == null || price < 0) {
      SnackbarUtils.showError(context, 'Price must be >= 0');
      return;
    }

    if (totalSeats == null || totalSeats < 1) {
      SnackbarUtils.showError(context, 'Total seats must be at least 1');
      return;
    }

    if (_isEdit) {
      final currentTrip = widget.trip!;
      await ref
          .read(tripViewModelProvider.notifier)
          .updateTrip(
            tripId: currentTrip.tripId!,
            type: _type,
            from: from,
            to: to,
            departureAt: _departureAt!,
            arrivalAt: _arrivalAt,
            price: price,
            totalSeats: totalSeats,
            availableSeats: currentTrip.availableSeats,
            status: _status,
          );
      return;
    }

    await ref
        .read(tripViewModelProvider.notifier)
        .createTrip(
          type: _type,
          from: from,
          to: to,
          departureAt: _departureAt!,
          arrivalAt: _arrivalAt,
          price: price,
          totalSeats: totalSeats,
          status: _status,
        );
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _priceController.dispose();
    _totalSeatsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tripViewModelProvider);
    final isLoading = state.status == TripStatus.loading;

    ref.listen<TripState>(tripViewModelProvider, (previous, next) {
      if (!_isEdit && next.status == TripStatus.created) {
        SnackbarUtils.showSuccess(context, 'Trip created successfully');
        Navigator.pop(context, true);
      } else if (_isEdit && next.status == TripStatus.updated) {
        SnackbarUtils.showSuccess(context, 'Trip updated successfully');
        Navigator.pop(context, true);
      } else if (next.status == TripStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Trip' : 'Create Trip')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Type', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'bus', child: Text('Bus')),
                DropdownMenuItem(value: 'plane', child: Text('Plane')),
              ],
              onChanged: isLoading
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _type = value;
                        });
                      }
                    },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hint: 'From',
              controller: _fromController,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hint: 'To',
              controller: _toController,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: isLoading ? null : () => _pickDateTime(isDeparture: true),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade500),
                ),
                child: Text('Departure: ${_formatDateTime(_departureAt)}'),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: isLoading ? null : () => _pickDateTime(isDeparture: false),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade500),
                ),
                child: Text('Arrival (optional): ${_formatDateTime(_arrivalAt)}'),
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hint: 'Price',
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hint: 'Total Seats',
              controller: _totalSeatsController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'active', child: Text('Active')),
                DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                DropdownMenuItem(value: 'delayed', child: Text('Delayed')),
              ],
              onChanged: isLoading
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _status = value;
                        });
                      }
                    },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
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
                        _isEdit ? 'Update Trip' : 'Create Trip',
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

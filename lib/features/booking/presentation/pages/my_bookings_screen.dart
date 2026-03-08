import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/utils/colors.dart';
import 'package:next_destination/core/utils/snackbar_utils.dart';
import 'package:next_destination/features/booking/domain/entity/booking_detail_entity.dart';
import 'package:next_destination/features/booking/presentation/pages/booking_detail_screen.dart';
import 'package:next_destination/features/booking/presentation/state/booking_state.dart';
import 'package:next_destination/features/booking/presentation/viewmodel/booking_view_model.dart';
import 'package:shake/shake.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> {
  final TextEditingController _refController = TextEditingController();
  ShakeDetector? _shakeDetector;
  DateTime _lastShakeAt = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(bookingViewModelProvider.notifier).getMyBookings(),
    );
    _startShakeListener();
  }

  void _startShakeListener() {
    _shakeDetector = ShakeDetector.autoStart(
      shakeThresholdGravity: 1.4,
      minimumShakeCount: 1,
      shakeSlopTimeMS: 500,
      shakeCountResetTime: 1800,
      onPhoneShake: (_) {
        final now = DateTime.now();
        if (now.difference(_lastShakeAt).inMilliseconds < 2000) return;
        _lastShakeAt = now;

        _handleShakeDelete();
      },
    );
  }

  Future<void> _handleShakeDelete() async {
    final cancelledCount = ref
        .read(bookingViewModelProvider)
        .myBookings
        .where((b) => b.status == 'cancelled')
        .length;

    if (cancelledCount == 0) {
      if (!mounted) return;
      SnackbarUtils.showError(context, 'No cancelled bookings to delete');
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Cancelled Bookings'),
        content: Text(
          'Detected phone shake. Delete all $cancelledCount cancelled bookings?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) return;

    final removed = ref
        .read(bookingViewModelProvider.notifier)
        .removeAllCancelledBookingsFromList();

    if (removed > 0) {
      SnackbarUtils.showSuccess(context, 'Deleted $removed cancelled bookings');
    }
  }

  String _fmtDate(DateTime? value) {
    if (value == null) return 'N/A';
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  Future<void> _searchByRef() async {
    final refCode = _refController.text.trim();
    if (refCode.isEmpty) {
      SnackbarUtils.showError(context, 'Enter booking reference');
      return;
    }

    await ref.read(bookingViewModelProvider.notifier).getBookingByRef(refCode);
    final state = ref.read(bookingViewModelProvider);

    if (!mounted) return;

    if (state.bookingDetail != null &&
        state.status == BookingStatus.fetchedDetail) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              BookingDetailScreen(initialDetail: state.bookingDetail!),
        ),
      );
    }
  }

  @override
  void dispose() {
    _shakeDetector?.stopListening();
    _refController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingViewModelProvider);
    final isLoading = state.status == BookingStatus.loading;

    ref.listen<BookingState>(bookingViewModelProvider, (previous, next) {
      if (next.status == BookingStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        actions: [
          IconButton(
            onPressed: isLoading
                ? null
                : () => ref
                      .read(bookingViewModelProvider.notifier)
                      .getMyBookings(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _refController,
                    decoration: const InputDecoration(
                      hintText: 'Search by booking ref (e.g. ND-XXXXXX)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 86,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _searchByRef,
                    style: ElevatedButton.styleFrom(backgroundColor: primaryRed),
                    child: const Text(
                      'Find',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading && state.myBookings.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.myBookings.isEmpty
                ? const Center(child: Text('No bookings found'))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: state.myBookings.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final booking = state.myBookings[index];
                      final canSwipeDelete =
                          booking.status == 'cancelled' &&
                          booking.bookingId != null;

                      final bookingTile = Card(
                        child: ListTile(
                          onTap: booking.bookingId == null
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BookingDetailScreen(
                                        bookingId: booking.bookingId,
                                        initialDetail: BookingDetailEntity(
                                          booking: booking,
                                          tickets: const [],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                          title: Text(
                            booking.bookingRef,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${booking.passengers.length} passenger(s) | ${_fmtDate(booking.createdAt)}',
                          ),
                          trailing: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                booking.status.toUpperCase(),
                                style: TextStyle(
                                  color: booking.status == 'cancelled'
                                      ? Colors.red
                                      : Colors.green,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'NPR ${booking.totalAmount.toStringAsFixed(0)}',
                              ),
                            ],
                          ),
                        ),
                      );

                      if (!canSwipeDelete) {
                        return bookingTile;
                      }

                      return Dismissible(
                        key: ValueKey(
                          '${booking.bookingId}_${booking.bookingRef}_$index',
                        ),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          ref
                              .read(bookingViewModelProvider.notifier)
                              .removeCancelledBookingFromList(
                                booking.bookingId!,
                              );
                          SnackbarUtils.showSuccess(
                            context,
                            'Cancelled booking removed',
                          );
                        },
                        child: bookingTile,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}


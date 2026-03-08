import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/services/connectivity/network_info.dart';
import 'package:next_destination/core/utils/colors.dart';
import 'package:next_destination/core/utils/snackbar_utils.dart';
import 'package:next_destination/core/api/api_endpoint.dart';
import 'package:next_destination/features/booking/domain/entity/booking_detail_entity.dart';
import 'package:next_destination/features/booking/domain/entity/ticket_entity.dart'
    as booking_domain;
import 'package:next_destination/features/booking/presentation/state/booking_state.dart';
import 'package:next_destination/features/booking/presentation/viewmodel/booking_view_model.dart';
import 'package:next_destination/features/payment/presentation/pages/payment_webview_screen.dart';
import 'package:next_destination/features/payment/presentation/state/payment_state.dart';
import 'package:next_destination/features/payment/presentation/viewmodel/payment_view_model.dart';
import 'package:next_destination/features/ticket/domain/entity/ticket_entity.dart'
    as ticket_domain;
import 'package:next_destination/features/ticket/presentation/pages/booking_tickets_screen.dart';
import 'package:next_destination/features/ticket/presentation/pages/ticket_detail_screen.dart';

class BookingDetailScreen extends ConsumerStatefulWidget {
  final String? bookingId;
  final BookingDetailEntity? initialDetail;
  final bool autoStartPayment;

  const BookingDetailScreen({
    super.key,
    this.bookingId,
    this.initialDetail,
    this.autoStartPayment = false,
  });

  @override
  ConsumerState<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends ConsumerState<BookingDetailScreen> {
  bool _paymentWebViewOpened = false;

  @override
  void initState() {
    super.initState();
    if (widget.bookingId != null) {
      Future.microtask(() => _maybeFetchBooking(widget.bookingId!));
    }

    final id = widget.bookingId ?? widget.initialDetail?.booking.bookingId;
    if (id != null && id.isNotEmpty) {
      if (widget.autoStartPayment) {
        Future.microtask(
          () => ref.read(paymentViewModelProvider.notifier).initiatePayment(
                bookingId: id,
                returnUrl: '${ApiEndpoints.serverUrl}/payment-return',
              ),
        );
      } else {
        Future.microtask(() => _maybeFetchPayment(id));
      }
    }
  }

  Future<void> _maybeFetchPayment(String bookingId) async {
    final isConnected = await ref.read(networkInfoProvider).isConnected;
    if (!isConnected) {
      return;
    }

    await ref.read(paymentViewModelProvider.notifier).getPaymentByBookingId(bookingId);
  }

  Future<void> _maybeFetchBooking(String bookingId) async {
    final isConnected = await ref.read(networkInfoProvider).isConnected;
    if (!isConnected) {
      return;
    }

    await ref.read(bookingViewModelProvider.notifier).getBookingById(bookingId);
  }

  String _fmtDate(DateTime? value) {
    if (value == null) return 'N/A';
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.year}-$month-$day $hour:$minute';
  }

  Future<void> _cancelBooking(String bookingId) async {
    final reasonController = TextEditingController();

    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Booking'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              hintText: 'Cancellation reason (optional)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes, cancel'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (shouldCancel == true) {
      await ref
          .read(bookingViewModelProvider.notifier)
          .cancelBooking(bookingId, reason: reasonController.text.trim());
    }

    reasonController.dispose();
  }

  Future<void> _openPaymentWebView({
    required String paymentUrl,
    required String bookingId,
    required String pidx,
  }) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentWebViewScreen(
          paymentUrl: paymentUrl,
          bookingId: bookingId,
          pidx: pidx,
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      await ref.read(bookingViewModelProvider.notifier).getBookingById(bookingId);
      await ref.read(paymentViewModelProvider.notifier).getPaymentByBookingId(bookingId);
    } else {
      SnackbarUtils.showError(
        context,
        'Payment not completed yet. You can try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingViewModelProvider);
    final paymentState = ref.watch(paymentViewModelProvider);
    final isLoading = state.status == BookingStatus.loading;
    final isPaymentLoading = paymentState.status == PaymentStatus.loading;

    ref.listen<BookingState>(bookingViewModelProvider, (previous, next) {
      if (next.status == BookingStatus.cancelled) {
        SnackbarUtils.showSuccess(context, 'Booking cancelled');
      } else if (next.status == BookingStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    ref.listen<PaymentState>(paymentViewModelProvider, (previous, next) {
      if (next.status == PaymentStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      } else if (next.status == PaymentStatus.initiated &&
          next.paymentUrl != null &&
          next.paymentUrl!.isNotEmpty) {
        final bookingId = (state.bookingDetail ?? widget.initialDetail)
            ?.booking
            .bookingId;
        final pidx = next.pidx;
        if (bookingId == null || pidx == null || pidx.isEmpty) return;
        if (_paymentWebViewOpened) return;
        _paymentWebViewOpened = true;
        _openPaymentWebView(
          paymentUrl: next.paymentUrl!,
          bookingId: bookingId,
          pidx: pidx,
        ).whenComplete(() => _paymentWebViewOpened = false);
      } else if (next.status == PaymentStatus.verified) {
        SnackbarUtils.showSuccess(context, 'Payment verified successfully');
        final bookingId = (state.bookingDetail ?? widget.initialDetail)
            ?.booking
            .bookingId;
        if (bookingId != null && bookingId.isNotEmpty) {
          ref.read(bookingViewModelProvider.notifier).getBookingById(bookingId);
        }
      }
    });

    final detail = state.bookingDetail ?? widget.initialDetail;

    if (isLoading && detail == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (detail == null) {
      return const Scaffold(body: Center(child: Text('Booking detail not found')));
    }

    final booking = detail.booking;
    final bookingId = booking.bookingId;
    final payment = paymentState.payment;
    final paymentStatus = payment?.status ?? 'unpaid';
    final isPaid = paymentStatus == 'completed';
    final pidx = paymentState.pidx ?? payment?.pidx;
    final hasCachedTickets = detail.tickets.isNotEmpty;
    final canShowTickets = isPaid || hasCachedTickets;

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Detail')),
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
                      'Ref: ${booking.bookingRef}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Status: ${booking.status.toUpperCase()}'),
                    Text('Contact: ${booking.contactEmail} / ${booking.contactPhone}'),
                    Text('Total Amount: NPR ${booking.totalAmount.toStringAsFixed(2)}'),
                    Text('Created At: ${_fmtDate(booking.createdAt)}'),
                    if (booking.cancelReason != null && booking.cancelReason!.isNotEmpty)
                      Text('Cancel Reason: ${booking.cancelReason}'),
                    if (booking.status != 'cancelled' && booking.bookingId != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () => _cancelBooking(booking.bookingId!),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text(
                              'Cancel Booking',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text('Status: ${paymentStatus.toUpperCase()}'),
                    if (isPaymentLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: LinearProgressIndicator(),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isPaymentLoading ||
                                    isPaid ||
                                    bookingId == null
                                ? null
                                : () {
                                    _paymentWebViewOpened = false;
                                    ref
                                        .read(paymentViewModelProvider.notifier)
                                        .initiatePayment(
                                          bookingId: bookingId,
                                          returnUrl:
                                              '${ApiEndpoints.serverUrl}/payment-return',
                                        );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryRed,
                            ),
                            icon: const Icon(
                              Icons.payment,
                              color: Colors.white,
                            ),
                            label: Text(
                              isPaid ? 'Paid' : 'Pay with Khalti',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isPaymentLoading ||
                                    isPaid ||
                                    bookingId == null
                                ? null
                                : () {
                                    if (pidx == null || pidx.isEmpty) {
                                      SnackbarUtils.showError(
                                        context,
                                        'Start payment first to get pidx',
                                      );
                                      return;
                                    }

                                    ref
                                        .read(paymentViewModelProvider.notifier)
                                        .verifyPayment(
                                          pidx: pidx,
                                          bookingId: bookingId,
                                        );
                                  },
                            icon: const Icon(Icons.verified),
                            label: const Text('Verify Payment'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Passengers', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...booking.passengers.map(
              (p) => Card(
                child: ListTile(
                  title: Text(p.fullName),
                  subtitle: Text('Age ${p.age} | ${p.gender} | Seat ${p.seatNumber}'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Tickets', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (!canShowTickets)
              const Text(
                'Complete payment to access your tickets.',
                style: TextStyle(color: Colors.red),
              )
            else ...[
              if (booking.bookingId != null)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              BookingTicketsScreen(bookingId: booking.bookingId!),
                        ),
                      );
                    },
                    child: const Text('Open All Tickets'),
                  ),
                ),
              if (booking.bookingId != null) const SizedBox(height: 8),
              if (detail.tickets.isEmpty)
                const Text('No tickets found')
              else
                ...detail.tickets.map(
                  (t) => Card(
                    child: ListTile(
                      onTap: t.ticketId == null
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TicketDetailScreen(
                                        ticketId: t.ticketId,
                                        initialTicket: _toTicketEntity(t),
                                      ),
                                ),
                              );
                            },
                      title: Text('${t.passengerName} (${t.seatNumber})'),
                      subtitle: Text(
                        'Status: ${t.status} | Issued: ${_fmtDate(t.issuedAt)}',
                      ),
                      trailing: t.qrToken != null
                          ? IconButton(
                              tooltip: t.qrToken,
                              onPressed: () {
                                SnackbarUtils.showSuccess(context, t.qrToken!);
                              },
                              icon: const Icon(Icons.qr_code),
                            )
                          : null,
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back, color: primaryRed),
                label: Text('Back', style: TextStyle(color: primaryRed)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ticket_domain.TicketEntity _toTicketEntity(
    booking_domain.TicketEntity ticket,
  ) {
    return ticket_domain.TicketEntity(
      ticketId: ticket.ticketId,
      booking: ticket.bookingId ?? '',
      trip: ticket.tripId ?? '',
      bookedBy: ticket.bookedBy ?? '',
      passengerName: ticket.passengerName,
      seatNumber: ticket.seatNumber,
      qrToken: ticket.qrToken ?? '',
      status: ticket.status,
      issuedAt: ticket.issuedAt,
      expiresAt: ticket.expiresAt,
    );
  }
}

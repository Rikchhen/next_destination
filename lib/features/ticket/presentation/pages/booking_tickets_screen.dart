import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/utils/snackbar_utils.dart';
import 'package:next_destination/features/ticket/presentation/pages/ticket_detail_screen.dart';
import 'package:next_destination/features/ticket/presentation/state/ticket_state.dart';
import 'package:next_destination/features/ticket/presentation/viewmodel/ticket_view_model.dart';

class BookingTicketsScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const BookingTicketsScreen({super.key, required this.bookingId});

  @override
  ConsumerState<BookingTicketsScreen> createState() => _BookingTicketsScreenState();
}

class _BookingTicketsScreenState extends ConsumerState<BookingTicketsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(ticketViewModelProvider.notifier).getTicketsByBooking(widget.bookingId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ticketViewModelProvider);
    final isLoading = state.status == TicketStatus.loading;

    ref.listen<TicketState>(ticketViewModelProvider, (previous, next) {
      if (next.status == TicketStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Tickets')),
      body: isLoading && state.tickets.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.tickets.isEmpty
          ? const Center(child: Text('No tickets found'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: state.tickets.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final ticket = state.tickets[index];
                return Card(
                  child: ListTile(
                    onTap: ticket.ticketId == null
                        ? null
                        : () {
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
                    title: Text(
                      '${ticket.passengerName} (${ticket.seatNumber})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Status: ${ticket.status.toUpperCase()}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                );
              },
            ),
    );
  }
}

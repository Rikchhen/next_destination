import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/features/ticket/domain/usecases/get_ticket_by_id_usecase.dart';
import 'package:next_destination/features/ticket/domain/usecases/get_tickets_by_booking_usecase.dart';
import 'package:next_destination/features/ticket/domain/usecases/scan_ticket_usecase.dart';
import 'package:next_destination/features/ticket/domain/usecases/void_ticket_usecase.dart';
import 'package:next_destination/features/ticket/presentation/state/ticket_state.dart';

final ticketViewModelProvider = NotifierProvider<TicketViewModel, TicketState>(
  () => TicketViewModel(),
);

class TicketViewModel extends Notifier<TicketState> {
  late final GetTicketByIdUsecase _getTicketByIdUsecase;
  late final GetTicketsByBookingUsecase _getTicketsByBookingUsecase;
  late final ScanTicketUsecase _scanTicketUsecase;
  late final VoidTicketUsecase _voidTicketUsecase;

  @override
  TicketState build() {
    _getTicketByIdUsecase = ref.read(getTicketByIdUsecaseProvider);
    _getTicketsByBookingUsecase = ref.read(getTicketsByBookingUsecaseProvider);
    _scanTicketUsecase = ref.read(scanTicketUsecaseProvider);
    _voidTicketUsecase = ref.read(voidTicketUsecaseProvider);

    return const TicketState();
  }

  Future<void> getTicketById(String ticketId) async {
    state = state.copyWith(status: TicketStatus.loading);

    final result = await _getTicketByIdUsecase.call(ticketId);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: TicketStatus.error,
          errorMessage: failure.message,
        );
      },
      (ticket) {
        state = state.copyWith(status: TicketStatus.fetchedOne, selectedTicket: ticket);
      },
    );
  }

  Future<void> getTicketsByBooking(String bookingId) async {
    state = state.copyWith(status: TicketStatus.loading);

    final result = await _getTicketsByBookingUsecase.call(bookingId);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: TicketStatus.error,
          errorMessage: failure.message,
        );
      },
      (tickets) {
        state = state.copyWith(status: TicketStatus.fetchedBooking, tickets: tickets);
      },
    );
  }

  Future<void> scanTicket(String qrToken) async {
    state = state.copyWith(status: TicketStatus.loading);

    final result = await _scanTicketUsecase.call(qrToken);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: TicketStatus.error,
          errorMessage: failure.message,
        );
      },
      (ticket) {
        state = state.copyWith(status: TicketStatus.scanned, selectedTicket: ticket);
      },
    );
  }

  Future<void> voidTicket({required String ticketId, String? reason}) async {
    state = state.copyWith(status: TicketStatus.loading);

    final result = await _voidTicketUsecase.call(
      VoidTicketUsecaseParams(ticketId: ticketId, reason: reason),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: TicketStatus.error,
          errorMessage: failure.message,
        );
      },
      (ticket) {
        final updatedTickets = state.tickets
            .map((e) => e.ticketId == ticket.ticketId ? ticket : e)
            .toList();

        state = state.copyWith(
          status: TicketStatus.voided,
          selectedTicket: ticket,
          tickets: updatedTickets,
        );
      },
    );
  }
}

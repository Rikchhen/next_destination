import 'package:equatable/equatable.dart';
import 'package:next_destination/features/ticket/domain/entity/ticket_entity.dart';

enum TicketStatus {
  initial,
  loading,
  fetchedOne,
  fetchedBooking,
  scanned,
  voided,
  error,
}

class TicketState extends Equatable {
  final TicketStatus status;
  final TicketEntity? selectedTicket;
  final List<TicketEntity> tickets;
  final String? errorMessage;

  const TicketState({
    this.status = TicketStatus.initial,
    this.selectedTicket,
    this.tickets = const [],
    this.errorMessage,
  });

  TicketState copyWith({
    TicketStatus? status,
    TicketEntity? selectedTicket,
    List<TicketEntity>? tickets,
    String? errorMessage,
  }) {
    return TicketState(
      status: status ?? this.status,
      selectedTicket: selectedTicket ?? this.selectedTicket,
      tickets: tickets ?? this.tickets,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, selectedTicket, tickets, errorMessage];
}

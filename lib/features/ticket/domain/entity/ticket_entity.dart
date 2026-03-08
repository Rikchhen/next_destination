import 'package:equatable/equatable.dart';

class TicketEntity extends Equatable {
  final String? ticketId;
  final String booking;
  final String trip;
  final String bookedBy;
  final String passengerName;
  final String seatNumber;
  final String qrToken;
  final String status;
  final DateTime? issuedAt;
  final DateTime? usedAt;
  final DateTime? expiresAt;
  final String? voidReason;

  const TicketEntity({
    this.ticketId,
    required this.booking,
    required this.trip,
    required this.bookedBy,
    required this.passengerName,
    required this.seatNumber,
    required this.qrToken,
    required this.status,
    this.issuedAt,
    this.usedAt,
    this.expiresAt,
    this.voidReason,
  });

  @override
  List<Object?> get props => [
    ticketId,
    booking,
    trip,
    bookedBy,
    passengerName,
    seatNumber,
    qrToken,
    status,
    issuedAt,
    usedAt,
    expiresAt,
    voidReason,
  ];
}

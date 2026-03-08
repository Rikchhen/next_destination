import 'package:equatable/equatable.dart';

class TicketEntity extends Equatable {
  final String? ticketId;
  final String? bookingId;
  final String? tripId;
  final String? bookedBy;
  final String passengerName;
  final String seatNumber;
  final String status;
  final String? qrToken;
  final DateTime? issuedAt;
  final DateTime? expiresAt;

  const TicketEntity({
    this.ticketId,
    this.bookingId,
    this.tripId,
    this.bookedBy,
    required this.passengerName,
    required this.seatNumber,
    required this.status,
    this.qrToken,
    this.issuedAt,
    this.expiresAt,
  });

  @override
  List<Object?> get props => [
    ticketId,
    bookingId,
    tripId,
    bookedBy,
    passengerName,
    seatNumber,
    status,
    qrToken,
    issuedAt,
    expiresAt,
  ];
}

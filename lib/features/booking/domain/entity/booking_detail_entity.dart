import 'package:equatable/equatable.dart';
import 'package:next_destination/features/booking/domain/entity/booking_entity.dart';
import 'package:next_destination/features/booking/domain/entity/ticket_entity.dart';

class BookingDetailEntity extends Equatable {
  final BookingEntity booking;
  final List<TicketEntity> tickets;

  const BookingDetailEntity({required this.booking, required this.tickets});

  @override
  List<Object?> get props => [booking, tickets];
}

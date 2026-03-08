import 'package:next_destination/features/booking/data/model/booking_api_model.dart';
import 'package:next_destination/features/booking/data/model/ticket_api_model.dart';
import 'package:next_destination/features/booking/domain/entity/booking_detail_entity.dart';

class BookingDetailApiModel {
  final BookingApiModel booking;
  final List<TicketApiModel> tickets;

  BookingDetailApiModel({required this.booking, required this.tickets});

  factory BookingDetailApiModel.fromJson(Map<String, dynamic> json) {
    final bookingMap = json['booking'] as Map<String, dynamic>;
    final ticketsRaw = json['tickets'] as List<dynamic>? ?? [];

    return BookingDetailApiModel(
      booking: BookingApiModel.fromJson(bookingMap),
      tickets: ticketsRaw
          .map((e) => TicketApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  BookingDetailEntity toEntity() {
    return BookingDetailEntity(
      booking: booking.toEntity(),
      tickets: TicketApiModel.toEntityList(tickets),
    );
  }
}

import 'package:next_destination/features/ticket/data/model/ticket_api_model.dart';

abstract interface class ITicketRemoteDatasource {
  Future<TicketApiModel> getTicketById(String ticketId);

  Future<List<TicketApiModel>> getTicketsByBooking(String bookingId);

  Future<TicketApiModel> scanTicket(String qrToken);

  Future<TicketApiModel> voidTicket(String ticketId, {String? reason});
}

import 'package:dartz/dartz.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/features/ticket/domain/entity/ticket_entity.dart';
import 'package:next_destination/features/ticket/domain/usecases/void_ticket_usecase.dart';

abstract interface class ITicketRepository {
  Future<Either<Failure, TicketEntity>> getTicketById(String ticketId);

  Future<Either<Failure, List<TicketEntity>>> getTicketsByBooking(String bookingId);

  Future<Either<Failure, TicketEntity>> scanTicket(String qrToken);

  Future<Either<Failure, TicketEntity>> voidTicket(VoidTicketUsecaseParams params);
}

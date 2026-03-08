import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/core/usecases/app_usecase.dart';
import 'package:next_destination/features/ticket/data/repository/ticket_repository.dart';
import 'package:next_destination/features/ticket/domain/entity/ticket_entity.dart';
import 'package:next_destination/features/ticket/domain/repository/ticket_repository.dart';

final getTicketsByBookingUsecaseProvider =
    Provider<GetTicketsByBookingUsecase>((ref) {
      return GetTicketsByBookingUsecase(
        ticketRepository: ref.read(ticketRepositoryProvider),
      );
    });

class GetTicketsByBookingUsecase
    implements UsecaseWithParams<List<TicketEntity>, String> {
  final ITicketRepository _ticketRepository;

  GetTicketsByBookingUsecase({required ITicketRepository ticketRepository})
    : _ticketRepository = ticketRepository;

  @override
  Future<Either<Failure, List<TicketEntity>>> call(String params) {
    return _ticketRepository.getTicketsByBooking(params);
  }
}

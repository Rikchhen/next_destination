import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/core/usecases/app_usecase.dart';
import 'package:next_destination/features/ticket/data/repository/ticket_repository.dart';
import 'package:next_destination/features/ticket/domain/entity/ticket_entity.dart';
import 'package:next_destination/features/ticket/domain/repository/ticket_repository.dart';

final getTicketByIdUsecaseProvider = Provider<GetTicketByIdUsecase>((ref) {
  return GetTicketByIdUsecase(ticketRepository: ref.read(ticketRepositoryProvider));
});

class GetTicketByIdUsecase implements UsecaseWithParams<TicketEntity, String> {
  final ITicketRepository _ticketRepository;

  GetTicketByIdUsecase({required ITicketRepository ticketRepository})
    : _ticketRepository = ticketRepository;

  @override
  Future<Either<Failure, TicketEntity>> call(String params) {
    return _ticketRepository.getTicketById(params);
  }
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/core/usecases/app_usecase.dart';
import 'package:next_destination/features/ticket/data/repository/ticket_repository.dart';
import 'package:next_destination/features/ticket/domain/entity/ticket_entity.dart';
import 'package:next_destination/features/ticket/domain/repository/ticket_repository.dart';

class VoidTicketUsecaseParams extends Equatable {
  final String ticketId;
  final String? reason;

  const VoidTicketUsecaseParams({required this.ticketId, this.reason});

  @override
  List<Object?> get props => [ticketId, reason];
}

final voidTicketUsecaseProvider = Provider<VoidTicketUsecase>((ref) {
  return VoidTicketUsecase(ticketRepository: ref.read(ticketRepositoryProvider));
});

class VoidTicketUsecase
    implements UsecaseWithParams<TicketEntity, VoidTicketUsecaseParams> {
  final ITicketRepository _ticketRepository;

  VoidTicketUsecase({required ITicketRepository ticketRepository})
    : _ticketRepository = ticketRepository;

  @override
  Future<Either<Failure, TicketEntity>> call(VoidTicketUsecaseParams params) {
    return _ticketRepository.voidTicket(params);
  }
}

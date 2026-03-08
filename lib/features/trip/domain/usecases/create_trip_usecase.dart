import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/core/usecases/app_usecase.dart';
import 'package:next_destination/features/trip/domain/entity/trip_entity.dart';
import 'package:next_destination/features/trip/domain/repository/trip_repository.dart';
import 'package:next_destination/features/trip/data/repository/trip_repository.dart';

class CreateTripUsecaseParams extends Equatable {
  final String type;
  final String from;
  final String to;
  final DateTime departureAt;
  final DateTime? arrivalAt;
  final double price;
  final int totalSeats;
  final String status;

  const CreateTripUsecaseParams({
    required this.type,
    required this.from,
    required this.to,
    required this.departureAt,
    this.arrivalAt,
    required this.price,
    required this.totalSeats,
    required this.status,
  });

  @override
  List<Object?> get props => [
    type,
    from,
    to,
    departureAt,
    arrivalAt,
    price,
    totalSeats,
    status,
  ];
}

final createTripUsecaseProvider = Provider<CreateTripUsecase>((ref) {
  return CreateTripUsecase(tripRepository: ref.read(tripRepositoryProvider));
});

class CreateTripUsecase
    implements UsecaseWithParams<TripEntity, CreateTripUsecaseParams> {
  final ITripRepository _tripRepository;

  CreateTripUsecase({required ITripRepository tripRepository})
    : _tripRepository = tripRepository;

  @override
  Future<Either<Failure, TripEntity>> call(CreateTripUsecaseParams params) {
    return _tripRepository.createTrip(params);
  }
}

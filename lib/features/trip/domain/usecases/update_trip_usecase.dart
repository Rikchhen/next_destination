import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/core/usecases/app_usecase.dart';
import 'package:next_destination/features/trip/domain/entity/trip_entity.dart';
import 'package:next_destination/features/trip/domain/repository/trip_repository.dart';
import 'package:next_destination/features/trip/data/repository/trip_repository.dart';

class UpdateTripUsecaseParams extends Equatable {
  final String tripId;
  final String type;
  final String from;
  final String to;
  final DateTime departureAt;
  final DateTime? arrivalAt;
  final double price;
  final int totalSeats;
  final int availableSeats;
  final String status;

  const UpdateTripUsecaseParams({
    required this.tripId,
    required this.type,
    required this.from,
    required this.to,
    required this.departureAt,
    this.arrivalAt,
    required this.price,
    required this.totalSeats,
    required this.availableSeats,
    required this.status,
  });

  @override
  List<Object?> get props => [
    tripId,
    type,
    from,
    to,
    departureAt,
    arrivalAt,
    price,
    totalSeats,
    availableSeats,
    status,
  ];
}

final updateTripUsecaseProvider = Provider<UpdateTripUsecase>((ref) {
  return UpdateTripUsecase(tripRepository: ref.read(tripRepositoryProvider));
});

class UpdateTripUsecase
    implements UsecaseWithParams<TripEntity, UpdateTripUsecaseParams> {
  final ITripRepository _tripRepository;

  UpdateTripUsecase({required ITripRepository tripRepository})
    : _tripRepository = tripRepository;

  @override
  Future<Either<Failure, TripEntity>> call(UpdateTripUsecaseParams params) {
    return _tripRepository.updateTrip(params);
  }
}

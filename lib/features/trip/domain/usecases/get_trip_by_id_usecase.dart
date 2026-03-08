import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/core/usecases/app_usecase.dart';
import 'package:next_destination/features/trip/domain/entity/trip_entity.dart';
import 'package:next_destination/features/trip/domain/repository/trip_repository.dart';
import 'package:next_destination/features/trip/data/repository/trip_repository.dart';

final getTripByIdUsecaseProvider = Provider<GetTripByIdUsecase>((ref) {
  return GetTripByIdUsecase(tripRepository: ref.read(tripRepositoryProvider));
});

class GetTripByIdUsecase implements UsecaseWithParams<TripEntity, String> {
  final ITripRepository _tripRepository;

  GetTripByIdUsecase({required ITripRepository tripRepository})
    : _tripRepository = tripRepository;

  @override
  Future<Either<Failure, TripEntity>> call(String params) {
    return _tripRepository.getTripById(params);
  }
}

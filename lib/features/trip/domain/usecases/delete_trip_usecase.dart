import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/core/usecases/app_usecase.dart';
import 'package:next_destination/features/trip/domain/repository/trip_repository.dart';
import 'package:next_destination/features/trip/data/repository/trip_repository.dart';

final deleteTripUsecaseProvider = Provider<DeleteTripUsecase>((ref) {
  return DeleteTripUsecase(tripRepository: ref.read(tripRepositoryProvider));
});

class DeleteTripUsecase implements UsecaseWithParams<bool, String> {
  final ITripRepository _tripRepository;

  DeleteTripUsecase({required ITripRepository tripRepository})
    : _tripRepository = tripRepository;

  @override
  Future<Either<Failure, bool>> call(String params) {
    return _tripRepository.deleteTrip(params);
  }
}

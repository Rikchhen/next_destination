import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/core/usecases/app_usecase.dart';
import 'package:next_destination/features/trip/domain/entity/trip_entity.dart';
import 'package:next_destination/features/trip/domain/repository/trip_repository.dart';
import 'package:next_destination/features/trip/data/repository/trip_repository.dart';

class GetTripsByBusinessUsecaseParams extends Equatable {
  final int page;
  final int limit;

  const GetTripsByBusinessUsecaseParams({this.page = 1, this.limit = 10});

  @override
  List<Object?> get props => [page, limit];
}

final getTripsByBusinessUsecaseProvider = Provider<GetTripsByBusinessUsecase>((
  ref,
) {
  return GetTripsByBusinessUsecase(
    tripRepository: ref.read(tripRepositoryProvider),
  );
});

class GetTripsByBusinessUsecase
    implements UsecaseWithParams<List<TripEntity>, GetTripsByBusinessUsecaseParams> {
  final ITripRepository _tripRepository;

  GetTripsByBusinessUsecase({required ITripRepository tripRepository})
    : _tripRepository = tripRepository;

  @override
  Future<Either<Failure, List<TripEntity>>> call(
    GetTripsByBusinessUsecaseParams params,
  ) {
    return _tripRepository.getTripsByBusiness(params);
  }
}

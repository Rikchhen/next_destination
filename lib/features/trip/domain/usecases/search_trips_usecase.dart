import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/core/usecases/app_usecase.dart';
import 'package:next_destination/features/trip/domain/entity/trip_search_result_entity.dart';
import 'package:next_destination/features/trip/domain/repository/trip_repository.dart';
import 'package:next_destination/features/trip/data/repository/trip_repository.dart';

class SearchTripsUsecaseParams extends Equatable {
  final String? type;
  final String? from;
  final String? to;
  final String? status;
  final DateTime? departureFrom;
  final DateTime? departureTo;
  final int page;
  final int limit;

  const SearchTripsUsecaseParams({
    this.type,
    this.from,
    this.to,
    this.status,
    this.departureFrom,
    this.departureTo,
    this.page = 1,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [
    type,
    from,
    to,
    status,
    departureFrom,
    departureTo,
    page,
    limit,
  ];
}

final searchTripsUsecaseProvider = Provider<SearchTripsUsecase>((ref) {
  return SearchTripsUsecase(tripRepository: ref.read(tripRepositoryProvider));
});

class SearchTripsUsecase
    implements
        UsecaseWithParams<TripSearchResultEntity, SearchTripsUsecaseParams> {
  final ITripRepository _tripRepository;

  SearchTripsUsecase({required ITripRepository tripRepository})
    : _tripRepository = tripRepository;

  @override
  Future<Either<Failure, TripSearchResultEntity>> call(
    SearchTripsUsecaseParams params,
  ) {
    return _tripRepository.searchTrips(params);
  }
}

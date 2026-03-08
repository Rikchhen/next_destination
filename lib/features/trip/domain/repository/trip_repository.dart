import 'package:dartz/dartz.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/features/trip/domain/entity/trip_entity.dart';
import 'package:next_destination/features/trip/domain/entity/trip_search_result_entity.dart';
import 'package:next_destination/features/trip/domain/usecases/create_trip_usecase.dart';
import 'package:next_destination/features/trip/domain/usecases/get_trips_by_business_usecase.dart';
import 'package:next_destination/features/trip/domain/usecases/search_trips_usecase.dart';
import 'package:next_destination/features/trip/domain/usecases/update_trip_usecase.dart';

abstract interface class ITripRepository {
  Future<Either<Failure, TripEntity>> createTrip(CreateTripUsecaseParams params);

  Future<Either<Failure, TripEntity>> getTripById(String tripId);

  Future<Either<Failure, List<TripEntity>>> getTripsByBusiness(
    GetTripsByBusinessUsecaseParams params,
  );

  Future<Either<Failure, TripSearchResultEntity>> searchTrips(
    SearchTripsUsecaseParams params,
  );

  Future<Either<Failure, TripEntity>> updateTrip(UpdateTripUsecaseParams params);

  Future<Either<Failure, bool>> deleteTrip(String tripId);
}

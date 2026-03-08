import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/core/services/connectivity/network_info.dart';
import 'package:next_destination/core/services/hive/hive_service.dart';
import 'package:next_destination/core/services/storage/user_session_storage.dart';
import 'package:next_destination/features/trip/data/datasource/remote/trip_remote_datasource.dart';
import 'package:next_destination/features/trip/data/datasource/trip_datasource.dart';
import 'package:next_destination/features/trip/data/model/trip_api_model.dart';
import 'package:next_destination/features/trip/domain/entity/trip_entity.dart';
import 'package:next_destination/features/trip/domain/entity/trip_search_result_entity.dart';
import 'package:next_destination/features/trip/domain/repository/trip_repository.dart';
import 'package:next_destination/features/trip/domain/usecases/create_trip_usecase.dart';
import 'package:next_destination/features/trip/domain/usecases/get_trips_by_business_usecase.dart';
import 'package:next_destination/features/trip/domain/usecases/search_trips_usecase.dart';
import 'package:next_destination/features/trip/domain/usecases/update_trip_usecase.dart';

final tripRepositoryProvider = Provider<ITripRepository>((ref) {
  final remoteDatasource = ref.read(tripRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  final hiveService = ref.read(hiveServiceProvider);
  final userSessionService = ref.read(userSessionServiceProvider);

  return TripRepository(
    tripRemoteDatasource: remoteDatasource,
    networkInfo: networkInfo,
    hiveService: hiveService,
    userSessionService: userSessionService,
  );
});

class TripRepository implements ITripRepository {
  final ITripRemoteDatasource _tripRemoteDatasource;
  final NetworkInfo _networkInfo;
  final HiveService _hiveService;
  final UserSessionService _userSessionService;

  TripRepository({
    required ITripRemoteDatasource tripRemoteDatasource,
    required NetworkInfo networkInfo,
    required HiveService hiveService,
    required UserSessionService userSessionService,
  }) : _tripRemoteDatasource = tripRemoteDatasource,
       _networkInfo = networkInfo,
       _hiveService = hiveService,
       _userSessionService = userSessionService;

  @override
  Future<Either<Failure, TripEntity>> createTrip(
    CreateTripUsecaseParams params,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = TripApiModel(
          type: params.type,
          from: params.from,
          to: params.to,
          departureAt: params.departureAt,
          arrivalAt: params.arrivalAt,
          price: params.price,
          totalSeats: params.totalSeats,
          availableSeats: params.totalSeats,
          status: params.status,
        );

        final createdTrip = await _tripRemoteDatasource.createTrip(apiModel);
        return Right(createdTrip.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Trip creation failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'Internet Required For Trip Creation'));
    }
  }

  @override
  Future<Either<Failure, TripEntity>> getTripById(String tripId) async {
    if (await _networkInfo.isConnected) {
      try {
        final trip = await _tripRemoteDatasource.getTripById(tripId);
        return Right(trip.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to fetch trip',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'Internet Required To Fetch Trip'));
    }
  }

  @override
  Future<Either<Failure, List<TripEntity>>> getTripsByBusiness(
    GetTripsByBusinessUsecaseParams params,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final trips = await _tripRemoteDatasource.getTripsByBusiness(
          page: params.page,
          limit: params.limit,
        );
        final entities = TripApiModel.toEntityList(trips);
        await _hiveService.cacheMyTrips(
          userScope: _userScope,
          trips: entities.map(_tripToMap).toList(),
        );

        return Right(entities);
      } on DioException catch (e) {
        final cached = _getCachedMyTrips();
        if (cached.isNotEmpty) {
          return Right(cached);
        }
        return Left(
          ApiFailure(
            message:
                e.response?.data['message'] ??
                'Failed to fetch business trips',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        final cached = _getCachedMyTrips();
        if (cached.isNotEmpty) {
          return Right(cached);
        }
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      final cached = _getCachedMyTrips();
      if (cached.isNotEmpty) {
        return Right(cached);
      }
      return Left(NetworkFailure(message: 'Internet Required To Fetch Business Trips'));
    }
  }

  @override
  Future<Either<Failure, TripSearchResultEntity>> searchTrips(
    SearchTripsUsecaseParams params,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _tripRemoteDatasource.searchTrips(
          type: params.type,
          from: params.from,
          to: params.to,
          status: params.status,
          departureFrom: params.departureFrom,
          departureTo: params.departureTo,
          page: params.page,
          limit: params.limit,
        );

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Trip search failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'Internet Required For Trip Search'));
    }
  }

  @override
  Future<Either<Failure, TripEntity>> updateTrip(
    UpdateTripUsecaseParams params,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = TripApiModel(
          id: params.tripId,
          type: params.type,
          from: params.from,
          to: params.to,
          departureAt: params.departureAt,
          arrivalAt: params.arrivalAt,
          price: params.price,
          totalSeats: params.totalSeats,
          availableSeats: params.availableSeats,
          status: params.status,
        );

        final updated = await _tripRemoteDatasource.updateTrip(
          params.tripId,
          apiModel,
        );

        return Right(updated.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Trip update failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'Internet Required To Update Trip'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteTrip(String tripId) async {
    if (await _networkInfo.isConnected) {
      try {
        final deleted = await _tripRemoteDatasource.deleteTrip(tripId);
        return Right(deleted);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Trip delete failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'Internet Required To Delete Trip'));
    }
  }

  String get _userScope {
    final currentUser = _userSessionService.getCurrentUserId();
    if (currentUser != null && currentUser.isNotEmpty) {
      return currentUser;
    }
    return 'default';
  }

  List<TripEntity> _getCachedMyTrips() {
    final rawTrips = _hiveService.getCachedMyTripsForBusiness(_userScope);
    return rawTrips.map(_tripFromMap).toList();
  }

  Map<String, dynamic> _tripToMap(TripEntity trip) {
    return <String, dynamic>{
      'tripId': trip.tripId,
      'type': trip.type,
      'from': trip.from,
      'to': trip.to,
      'departureAt': trip.departureAt.toIso8601String(),
      'arrivalAt': trip.arrivalAt?.toIso8601String(),
      'price': trip.price,
      'totalSeats': trip.totalSeats,
      'availableSeats': trip.availableSeats,
      'status': trip.status,
    };
  }

  TripEntity _tripFromMap(Map<String, dynamic> json) {
    return TripEntity(
      tripId: json['tripId']?.toString(),
      type: (json['type'] ?? '').toString(),
      from: (json['from'] ?? '').toString(),
      to: (json['to'] ?? '').toString(),
      departureAt: DateTime.tryParse((json['departureAt'] ?? '').toString()) ?? DateTime.now(),
      arrivalAt: json['arrivalAt'] == null
          ? null
          : DateTime.tryParse(json['arrivalAt'].toString()),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      totalSeats: (json['totalSeats'] as num?)?.toInt() ?? 0,
      availableSeats: (json['availableSeats'] as num?)?.toInt() ?? 0,
      status: (json['status'] ?? 'active').toString(),
    );
  }
}

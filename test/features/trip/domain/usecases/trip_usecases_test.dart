import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/features/trip/domain/entity/trip_entity.dart';
import 'package:next_destination/features/trip/domain/entity/trip_search_result_entity.dart';
import 'package:next_destination/features/trip/domain/repository/trip_repository.dart';
import 'package:next_destination/features/trip/domain/usecases/get_trip_by_id_usecase.dart';
import 'package:next_destination/features/trip/domain/usecases/search_trips_usecase.dart';

class MockTripRepository extends Mock implements ITripRepository {}

void main() {
  late MockTripRepository repository;
  late SearchTripsUsecase searchTripsUsecase;
  late GetTripByIdUsecase getTripByIdUsecase;

  final tTrip = TripEntity(
    tripId: 't1',
    businessId: 'b1',
    type: 'bus',
    from: 'Kathmandu',
    to: 'Pokhara',
    departureAt: DateTime(2026, 1, 2, 8),
    arrivalAt: DateTime(2026, 1, 2, 13),
    price: 1200,
    totalSeats: 40,
    availableSeats: 18,
    status: 'active',
  );

  final tSearchResult = TripSearchResultEntity(
    items: [
      TripEntity(
        tripId: 't1',
        businessId: 'b1',
        type: 'bus',
        from: 'Kathmandu',
        to: 'Pokhara',
        departureAt: DateTime(2026, 1, 2, 8),
        arrivalAt: DateTime(2026, 1, 2, 13),
        price: 1200,
        totalSeats: 40,
        availableSeats: 18,
        status: 'active',
      ),
    ],
    total: 1,
    page: 1,
    limit: 10,
    pages: 1,
  );

  setUp(() {
    repository = MockTripRepository();
    searchTripsUsecase = SearchTripsUsecase(tripRepository: repository);
    getTripByIdUsecase = GetTripByIdUsecase(tripRepository: repository);
  });

  group('SearchTripsUsecase', () {
    test('returns search result on success', () async {
      const params = SearchTripsUsecaseParams(
        from: 'Kathmandu',
        to: 'Pokhara',
        status: 'active',
        page: 1,
        limit: 10,
      );
      when(() => repository.searchTrips(params)).thenAnswer(
        (_) async => Right(tSearchResult),
      );

      final result = await searchTripsUsecase(params);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right but got Left'),
        (data) {
          expect(data.total, 1);
          expect(data.items.first, tTrip);
        },
      );
    });

    test('returns failure when repository fails', () async {
      const params = SearchTripsUsecaseParams(
        from: 'Kathmandu',
        to: 'Pokhara',
      );
      const failure = NetworkFailure();
      when(
        () => repository.searchTrips(params),
      ).thenAnswer((_) async => const Left(failure));

      final result = await searchTripsUsecase(params);

      expect(result, const Left<Failure, TripSearchResultEntity>(failure));
    });

    test('forwards exact params to repository once', () async {
      const params = SearchTripsUsecaseParams(type: 'plane', page: 2, limit: 5);
      when(
        () => repository.searchTrips(params),
      ).thenAnswer((_) async => Right(tSearchResult));

      await searchTripsUsecase(params);

      verify(
        () => repository.searchTrips(
          const SearchTripsUsecaseParams(type: 'plane', page: 2, limit: 5),
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    });
  });

  group('GetTripByIdUsecase', () {
    test('returns trip on success', () async {
      when(() => repository.getTripById('t1')).thenAnswer((_) async => Right(tTrip));

      final result = await getTripByIdUsecase('t1');

      expect(result, Right<Failure, TripEntity>(tTrip));
    });

    test('returns failure on missing trip id', () async {
      const failure = ApiFailure(message: 'Trip not found', statusCode: 404);
      when(
        () => repository.getTripById('missing'),
      ).thenAnswer((_) async => const Left(failure));

      final result = await getTripByIdUsecase('missing');

      expect(result, const Left<Failure, TripEntity>(failure));
      verify(() => repository.getTripById('missing')).called(1);
      verifyNoMoreInteractions(repository);
    });
  });
}

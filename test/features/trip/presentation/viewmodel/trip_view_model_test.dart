import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/features/trip/domain/entity/trip_entity.dart';
import 'package:next_destination/features/trip/domain/entity/trip_search_result_entity.dart';
import 'package:next_destination/features/trip/domain/usecases/create_trip_usecase.dart';
import 'package:next_destination/features/trip/domain/usecases/delete_trip_usecase.dart';
import 'package:next_destination/features/trip/domain/usecases/get_trip_by_id_usecase.dart';
import 'package:next_destination/features/trip/domain/usecases/get_trips_by_business_usecase.dart';
import 'package:next_destination/features/trip/domain/usecases/search_trips_usecase.dart';
import 'package:next_destination/features/trip/domain/usecases/update_trip_usecase.dart';
import 'package:next_destination/features/trip/presentation/state/trip_state.dart';
import 'package:next_destination/features/trip/presentation/viewmodel/trip_view_model.dart';

class MockCreateTripUsecase extends Mock implements CreateTripUsecase {}

class MockGetTripByIdUsecase extends Mock implements GetTripByIdUsecase {}

class MockGetTripsByBusinessUsecase extends Mock implements GetTripsByBusinessUsecase {}

class MockSearchTripsUsecase extends Mock implements SearchTripsUsecase {}

class MockUpdateTripUsecase extends Mock implements UpdateTripUsecase {}

class MockDeleteTripUsecase extends Mock implements DeleteTripUsecase {}

void main() {
  late MockCreateTripUsecase mockCreateTripUsecase;
  late MockGetTripByIdUsecase mockGetTripByIdUsecase;
  late MockGetTripsByBusinessUsecase mockGetTripsByBusinessUsecase;
  late MockSearchTripsUsecase mockSearchTripsUsecase;
  late MockUpdateTripUsecase mockUpdateTripUsecase;
  late MockDeleteTripUsecase mockDeleteTripUsecase;
  late ProviderContainer container;

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
    mockCreateTripUsecase = MockCreateTripUsecase();
    mockGetTripByIdUsecase = MockGetTripByIdUsecase();
    mockGetTripsByBusinessUsecase = MockGetTripsByBusinessUsecase();
    mockSearchTripsUsecase = MockSearchTripsUsecase();
    mockUpdateTripUsecase = MockUpdateTripUsecase();
    mockDeleteTripUsecase = MockDeleteTripUsecase();

    container = ProviderContainer(
      overrides: [
        createTripUsecaseProvider.overrideWithValue(mockCreateTripUsecase),
        getTripByIdUsecaseProvider.overrideWithValue(mockGetTripByIdUsecase),
        getTripsByBusinessUsecaseProvider.overrideWithValue(
          mockGetTripsByBusinessUsecase,
        ),
        searchTripsUsecaseProvider.overrideWithValue(mockSearchTripsUsecase),
        updateTripUsecaseProvider.overrideWithValue(mockUpdateTripUsecase),
        deleteTripUsecaseProvider.overrideWithValue(mockDeleteTripUsecase),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('initial state is TripStatus.initial', () {
    final state = container.read(tripViewModelProvider);
    expect(state.status, TripStatus.initial);
    expect(state.myTrips, isEmpty);
  });

  test('searchTrips success sets searched trips and paging metadata', () async {
    const params = SearchTripsUsecaseParams(
      from: 'Kathmandu',
      to: 'Pokhara',
      status: 'active',
      page: 1,
      limit: 10,
    );
    when(
      () => mockSearchTripsUsecase(params),
    ).thenAnswer((_) async => Right(tSearchResult));

    await container.read(tripViewModelProvider.notifier).searchTrips(
          from: 'Kathmandu',
          to: 'Pokhara',
          status: 'active',
          page: 1,
          limit: 10,
        );

    final state = container.read(tripViewModelProvider);
    expect(state.status, TripStatus.searched);
    expect(state.searchedTrips.length, 1);
    expect(state.total, 1);
    expect(state.page, 1);
  });

  test('searchTrips failure sets error state', () async {
    const params = SearchTripsUsecaseParams(
      from: 'Kathmandu',
      to: 'Pokhara',
      page: 1,
      limit: 10,
    );
    const failure = NetworkFailure(message: 'No internet connection');
    when(
      () => mockSearchTripsUsecase(params),
    ).thenAnswer((_) async => const Left(failure));

    await container.read(tripViewModelProvider.notifier).searchTrips(
          from: 'Kathmandu',
          to: 'Pokhara',
          page: 1,
          limit: 10,
        );

    final state = container.read(tripViewModelProvider);
    expect(state.status, TripStatus.error);
    expect(state.errorMessage, 'No internet connection');
  });

  test('getTripById success sets fetchedById and selectedTrip', () async {
    when(() => mockGetTripByIdUsecase('t1')).thenAnswer((_) async => Right(tTrip));

    await container.read(tripViewModelProvider.notifier).getTripById('t1');

    final state = container.read(tripViewModelProvider);
    expect(state.status, TripStatus.fetchedById);
    expect(state.selectedTrip, tTrip);
  });

  test('deleteTrip success removes trip from myTrips and sets deleted status', () async {
    const getMineParams = GetTripsByBusinessUsecaseParams(page: 1, limit: 10);
    when(
      () => mockGetTripsByBusinessUsecase(getMineParams),
    ).thenAnswer((_) async => Right([tTrip]));
    when(() => mockDeleteTripUsecase('t1')).thenAnswer((_) async => const Right(true));

    await container.read(tripViewModelProvider.notifier).getMyTrips();
    await container.read(tripViewModelProvider.notifier).deleteTrip('t1');

    final state = container.read(tripViewModelProvider);
    expect(state.status, TripStatus.deleted);
    expect(state.myTrips, isEmpty);
  });
}

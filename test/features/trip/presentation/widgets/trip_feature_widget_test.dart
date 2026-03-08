import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
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
import 'package:next_destination/features/trip/presentation/viewmodel/trip_view_model.dart';

class MockCreateTripUsecase extends Mock implements CreateTripUsecase {}

class MockGetTripByIdUsecase extends Mock implements GetTripByIdUsecase {}

class MockGetTripsByBusinessUsecase extends Mock implements GetTripsByBusinessUsecase {}

class MockSearchTripsUsecase extends Mock implements SearchTripsUsecase {}

class MockUpdateTripUsecase extends Mock implements UpdateTripUsecase {}

class MockDeleteTripUsecase extends Mock implements DeleteTripUsecase {}

class TripFeatureTestScreen extends ConsumerWidget {
  const TripFeatureTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tripViewModelProvider);
    final vm = ref.read(tripViewModelProvider.notifier);

    return Scaffold(
      body: Column(
        children: [
          Text('status:${state.status.name}', key: const Key('status')),
          Text('error:${state.errorMessage ?? ''}', key: const Key('error')),
          ElevatedButton(
            key: const Key('search'),
            onPressed: () => vm.searchTrips(from: 'Kathmandu', to: 'Pokhara'),
            child: const Text('search'),
          ),
          ElevatedButton(
            key: const Key('byId'),
            onPressed: () => vm.getTripById('t1'),
            child: const Text('byId'),
          ),
          ElevatedButton(
            key: const Key('mine'),
            onPressed: () => vm.getMyTrips(),
            child: const Text('mine'),
          ),
          ElevatedButton(
            key: const Key('delete'),
            onPressed: () => vm.deleteTrip('t1'),
            child: const Text('delete'),
          ),
        ],
      ),
    );
  }
}

void main() {
  late MockCreateTripUsecase mockCreate;
  late MockGetTripByIdUsecase mockGetById;
  late MockGetTripsByBusinessUsecase mockGetMine;
  late MockSearchTripsUsecase mockSearch;
  late MockUpdateTripUsecase mockUpdate;
  late MockDeleteTripUsecase mockDelete;

  final trip = TripEntity(
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

  final searchResult = TripSearchResultEntity(
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

  Widget makeApp() {
    return ProviderScope(
      overrides: [
        createTripUsecaseProvider.overrideWithValue(mockCreate),
        getTripByIdUsecaseProvider.overrideWithValue(mockGetById),
        getTripsByBusinessUsecaseProvider.overrideWithValue(mockGetMine),
        searchTripsUsecaseProvider.overrideWithValue(mockSearch),
        updateTripUsecaseProvider.overrideWithValue(mockUpdate),
        deleteTripUsecaseProvider.overrideWithValue(mockDelete),
      ],
      child: const MaterialApp(home: TripFeatureTestScreen()),
    );
  }

  setUp(() {
    mockCreate = MockCreateTripUsecase();
    mockGetById = MockGetTripByIdUsecase();
    mockGetMine = MockGetTripsByBusinessUsecase();
    mockSearch = MockSearchTripsUsecase();
    mockUpdate = MockUpdateTripUsecase();
    mockDelete = MockDeleteTripUsecase();
  });

  testWidgets('trip widget shows initial status', (tester) async {
    await tester.pumpWidget(makeApp());
    expect(find.text('status:initial'), findsOneWidget);
  });

  testWidgets('search button shows searched on success', (tester) async {
    const params = SearchTripsUsecaseParams(
      from: 'Kathmandu',
      to: 'Pokhara',
      page: 1,
      limit: 10,
    );
    when(() => mockSearch(params)).thenAnswer((_) async => Right(searchResult));

    await tester.pumpWidget(makeApp());
    await tester.tap(find.byKey(const Key('search')));
    await tester.pumpAndSettle();

    expect(find.text('status:searched'), findsOneWidget);
  });

  testWidgets('search button shows error on failure', (tester) async {
    const params = SearchTripsUsecaseParams(
      from: 'Kathmandu',
      to: 'Pokhara',
      page: 1,
      limit: 10,
    );
    const failure = NetworkFailure(message: 'No internet connection');
    when(() => mockSearch(params)).thenAnswer((_) async => const Left(failure));

    await tester.pumpWidget(makeApp());
    await tester.tap(find.byKey(const Key('search')));
    await tester.pumpAndSettle();

    expect(find.text('status:error'), findsOneWidget);
    expect(find.text('error:No internet connection'), findsOneWidget);
  });

  testWidgets('byId button shows fetchedById on success', (tester) async {
    when(() => mockGetById('t1')).thenAnswer((_) async => Right(trip));

    await tester.pumpWidget(makeApp());
    await tester.tap(find.byKey(const Key('byId')));
    await tester.pumpAndSettle();

    expect(find.text('status:fetchedById'), findsOneWidget);
  });

  testWidgets('delete button shows deleted after loading mine', (tester) async {
    const mineParams = GetTripsByBusinessUsecaseParams(page: 1, limit: 10);
    when(() => mockGetMine(mineParams)).thenAnswer((_) async => Right([trip]));
    when(() => mockDelete('t1')).thenAnswer((_) async => const Right(true));

    await tester.pumpWidget(makeApp());
    await tester.tap(find.byKey(const Key('mine')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('delete')));
    await tester.pumpAndSettle();

    expect(find.text('status:deleted'), findsOneWidget);
  });
}

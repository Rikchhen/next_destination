import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/features/booking/domain/entity/booking_detail_entity.dart';
import 'package:next_destination/features/booking/domain/entity/booking_entity.dart';
import 'package:next_destination/features/booking/domain/entity/passenger_entity.dart';
import 'package:next_destination/features/booking/domain/entity/ticket_entity.dart';
import 'package:next_destination/features/booking/domain/usecases/cancel_booking_usecase.dart';
import 'package:next_destination/features/booking/domain/usecases/create_booking_usecase.dart';
import 'package:next_destination/features/booking/domain/usecases/get_booking_by_id_usecase.dart';
import 'package:next_destination/features/booking/domain/usecases/get_booking_by_ref_usecase.dart';
import 'package:next_destination/features/booking/domain/usecases/get_my_bookings_usecase.dart';
import 'package:next_destination/features/booking/presentation/viewmodel/booking_view_model.dart';

class MockCreateBookingUsecase extends Mock implements CreateBookingUsecase {}

class MockGetBookingByIdUsecase extends Mock implements GetBookingByIdUsecase {}

class MockGetBookingByRefUsecase extends Mock implements GetBookingByRefUsecase {}

class MockGetMyBookingsUsecase extends Mock implements GetMyBookingsUsecase {}

class MockCancelBookingUsecase extends Mock implements CancelBookingUsecase {}

class BookingFeatureTestScreen extends ConsumerWidget {
  const BookingFeatureTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingViewModelProvider);
    final vm = ref.read(bookingViewModelProvider.notifier);

    return Scaffold(
      body: Column(
        children: [
          Text('status:${state.status.name}', key: const Key('status')),
          Text('error:${state.errorMessage ?? ''}', key: const Key('error')),
          ElevatedButton(
            key: const Key('mine'),
            onPressed: () => vm.getMyBookings(),
            child: const Text('mine'),
          ),
          ElevatedButton(
            key: const Key('ref'),
            onPressed: () => vm.getBookingByRef('ND-ABC123'),
            child: const Text('ref'),
          ),
          ElevatedButton(
            key: const Key('cancel'),
            onPressed: () => vm.cancelBooking('b1', reason: 'Changed plan'),
            child: const Text('cancel'),
          ),
        ],
      ),
    );
  }
}

void main() {
  late MockCreateBookingUsecase mockCreate;
  late MockGetBookingByIdUsecase mockGetById;
  late MockGetBookingByRefUsecase mockGetByRef;
  late MockGetMyBookingsUsecase mockGetMine;
  late MockCancelBookingUsecase mockCancel;

  const passenger = PassengerEntity(
    fullName: 'Ram',
    age: 27,
    gender: 'male',
    seatNumber: 'A1',
  );
  final booking = BookingEntity(
    bookingId: 'b1',
    bookedBy: 'u1',
    trip: 't1',
    bookingRef: 'ND-ABC123',
    status: 'confirmed',
    passengers: const [passenger],
    contactEmail: 'a@b.com',
    contactPhone: '9800000000',
    totalAmount: 2500,
    createdAt: DateTime(2026, 1, 1),
  );
  final cancelled = BookingEntity(
    bookingId: 'b1',
    bookedBy: 'u1',
    trip: 't1',
    bookingRef: 'ND-ABC123',
    status: 'cancelled',
    passengers: const [passenger],
    contactEmail: 'a@b.com',
    contactPhone: '9800000000',
    totalAmount: 2500,
    cancelReason: 'Changed plan',
    createdAt: DateTime(2026, 1, 1),
  );
  final detail = BookingDetailEntity(
    booking: booking,
    tickets: const [
      TicketEntity(
        ticketId: 'tk1',
        bookingId: 'b1',
        passengerName: 'Ram',
        seatNumber: 'A1',
        status: 'issued',
      ),
    ],
  );

  Widget makeApp() {
    return ProviderScope(
      overrides: [
        createBookingUsecaseProvider.overrideWithValue(mockCreate),
        getBookingByIdUsecaseProvider.overrideWithValue(mockGetById),
        getBookingByRefUsecaseProvider.overrideWithValue(mockGetByRef),
        getMyBookingsUsecaseProvider.overrideWithValue(mockGetMine),
        cancelBookingUsecaseProvider.overrideWithValue(mockCancel),
      ],
      child: const MaterialApp(home: BookingFeatureTestScreen()),
    );
  }

  setUp(() {
    mockCreate = MockCreateBookingUsecase();
    mockGetById = MockGetBookingByIdUsecase();
    mockGetByRef = MockGetBookingByRefUsecase();
    mockGetMine = MockGetMyBookingsUsecase();
    mockCancel = MockCancelBookingUsecase();
  });

  testWidgets('booking widget shows initial status', (tester) async {
    await tester.pumpWidget(makeApp());
    expect(find.text('status:initial'), findsOneWidget);
  });

  testWidgets('mine button shows fetchedMine on success', (tester) async {
    const params = GetMyBookingsUsecaseParams(page: 1, limit: 10);
    when(() => mockGetMine(params)).thenAnswer((_) async => Right([booking]));

    await tester.pumpWidget(makeApp());
    await tester.tap(find.byKey(const Key('mine')));
    await tester.pumpAndSettle();

    expect(find.text('status:fetchedMine'), findsOneWidget);
  });

  testWidgets('mine button shows error on failure', (tester) async {
    const params = GetMyBookingsUsecaseParams(page: 1, limit: 10);
    const failure = NetworkFailure(message: 'No internet connection');
    when(() => mockGetMine(params)).thenAnswer((_) async => const Left(failure));

    await tester.pumpWidget(makeApp());
    await tester.tap(find.byKey(const Key('mine')));
    await tester.pumpAndSettle();

    expect(find.text('status:error'), findsOneWidget);
    expect(find.text('error:No internet connection'), findsOneWidget);
  });

  testWidgets('ref button shows fetchedDetail on success', (tester) async {
    when(() => mockGetByRef('ND-ABC123')).thenAnswer((_) async => Right(detail));

    await tester.pumpWidget(makeApp());
    await tester.tap(find.byKey(const Key('ref')));
    await tester.pumpAndSettle();

    expect(find.text('status:fetchedDetail'), findsOneWidget);
  });

  testWidgets('cancel button shows cancelled after preload', (tester) async {
    const params = GetMyBookingsUsecaseParams(page: 1, limit: 10);
    when(() => mockGetMine(params)).thenAnswer((_) async => Right([booking]));
    when(() => mockGetByRef('ND-ABC123')).thenAnswer((_) async => Right(detail));
    const cancelParams = CancelBookingUsecaseParams(
      bookingId: 'b1',
      reason: 'Changed plan',
    );
    when(() => mockCancel(cancelParams)).thenAnswer((_) async => Right(cancelled));

    await tester.pumpWidget(makeApp());
    await tester.tap(find.byKey(const Key('mine')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ref')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('cancel')));
    await tester.pumpAndSettle();

    expect(find.text('status:cancelled'), findsOneWidget);
  });
}

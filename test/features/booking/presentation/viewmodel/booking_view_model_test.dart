import 'package:dartz/dartz.dart';
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
import 'package:next_destination/features/booking/presentation/state/booking_state.dart';
import 'package:next_destination/features/booking/presentation/viewmodel/booking_view_model.dart';

class MockCreateBookingUsecase extends Mock implements CreateBookingUsecase {}

class MockGetBookingByIdUsecase extends Mock implements GetBookingByIdUsecase {}

class MockGetBookingByRefUsecase extends Mock implements GetBookingByRefUsecase {}

class MockGetMyBookingsUsecase extends Mock implements GetMyBookingsUsecase {}

class MockCancelBookingUsecase extends Mock implements CancelBookingUsecase {}

void main() {
  late MockCreateBookingUsecase mockCreateBookingUsecase;
  late MockGetBookingByIdUsecase mockGetBookingByIdUsecase;
  late MockGetBookingByRefUsecase mockGetBookingByRefUsecase;
  late MockGetMyBookingsUsecase mockGetMyBookingsUsecase;
  late MockCancelBookingUsecase mockCancelBookingUsecase;
  late ProviderContainer container;

  const tPassengers = [
    PassengerEntity(
      fullName: 'Ram Bahadur',
      age: 27,
      gender: 'male',
      seatNumber: 'A1',
    ),
  ];

  final tActiveBooking = BookingEntity(
    bookingId: 'b1',
    bookedBy: 'u1',
    trip: 't1',
    bookingRef: 'ND-ABC123',
    status: 'confirmed',
    passengers: tPassengers,
    contactEmail: 'booker@next.com',
    contactPhone: '9800000000',
    totalAmount: 2500,
    createdAt: DateTime(2026, 1, 1),
  );

  final tCancelledBooking = BookingEntity(
    bookingId: 'b1',
    bookedBy: 'u1',
    trip: 't1',
    bookingRef: 'ND-ABC123',
    status: 'cancelled',
    passengers: tPassengers,
    contactEmail: 'booker@next.com',
    contactPhone: '9800000000',
    totalAmount: 2500,
    cancelReason: 'Changed plan',
    createdAt: DateTime(2026, 1, 1),
  );

  final tDetail = BookingDetailEntity(
    booking: BookingEntity(
      bookingId: 'b1',
      bookedBy: 'u1',
      trip: 't1',
      bookingRef: 'ND-ABC123',
      status: 'confirmed',
      passengers: tPassengers,
      contactEmail: 'booker@next.com',
      contactPhone: '9800000000',
      totalAmount: 2500,
      createdAt: DateTime(2026, 1, 1),
    ),
    tickets: const [
      TicketEntity(
        ticketId: 'tk1',
        bookingId: 'b1',
        passengerName: 'Ram Bahadur',
        seatNumber: 'A1',
        status: 'issued',
      ),
    ],
  );

  setUp(() {
    mockCreateBookingUsecase = MockCreateBookingUsecase();
    mockGetBookingByIdUsecase = MockGetBookingByIdUsecase();
    mockGetBookingByRefUsecase = MockGetBookingByRefUsecase();
    mockGetMyBookingsUsecase = MockGetMyBookingsUsecase();
    mockCancelBookingUsecase = MockCancelBookingUsecase();

    container = ProviderContainer(
      overrides: [
        createBookingUsecaseProvider.overrideWithValue(mockCreateBookingUsecase),
        getBookingByIdUsecaseProvider.overrideWithValue(mockGetBookingByIdUsecase),
        getBookingByRefUsecaseProvider.overrideWithValue(mockGetBookingByRefUsecase),
        getMyBookingsUsecaseProvider.overrideWithValue(mockGetMyBookingsUsecase),
        cancelBookingUsecaseProvider.overrideWithValue(mockCancelBookingUsecase),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('initial state is BookingStatus.initial', () {
    final state = container.read(bookingViewModelProvider);
    expect(state.status, BookingStatus.initial);
    expect(state.myBookings, isEmpty);
  });

  test('getMyBookings success sets fetchedMine with bookings list', () async {
    const params = GetMyBookingsUsecaseParams(page: 1, limit: 10);
    when(
      () => mockGetMyBookingsUsecase(params),
    ).thenAnswer((_) async => Right([tActiveBooking]));

    await container.read(bookingViewModelProvider.notifier).getMyBookings();

    final state = container.read(bookingViewModelProvider);
    expect(state.status, BookingStatus.fetchedMine);
    expect(state.myBookings.length, 1);
    expect(state.myBookings.first, tActiveBooking);
  });

  test('getMyBookings failure sets error state', () async {
    const params = GetMyBookingsUsecaseParams(page: 1, limit: 10);
    const failure = NetworkFailure(message: 'No internet connection');
    when(
      () => mockGetMyBookingsUsecase(params),
    ).thenAnswer((_) async => const Left(failure));

    await container.read(bookingViewModelProvider.notifier).getMyBookings();

    final state = container.read(bookingViewModelProvider);
    expect(state.status, BookingStatus.error);
    expect(state.errorMessage, 'No internet connection');
  });

  test('getBookingByRef success sets fetchedDetail with detail', () async {
    when(
      () => mockGetBookingByRefUsecase('ND-ABC123'),
    ).thenAnswer((_) async => Right(tDetail));

    await container
        .read(bookingViewModelProvider.notifier)
        .getBookingByRef('ND-ABC123');

    final state = container.read(bookingViewModelProvider);
    expect(state.status, BookingStatus.fetchedDetail);
    expect(state.bookingDetail, tDetail);
  });

  test('cancelBooking success updates list and detail state', () async {
    const mineParams = GetMyBookingsUsecaseParams(page: 1, limit: 10);
    when(
      () => mockGetMyBookingsUsecase(mineParams),
    ).thenAnswer((_) async => Right([tActiveBooking]));
    when(
      () => mockGetBookingByRefUsecase('ND-ABC123'),
    ).thenAnswer((_) async => Right(tDetail));
    const cancelParams = CancelBookingUsecaseParams(
      bookingId: 'b1',
      reason: 'Changed plan',
    );
    when(
      () => mockCancelBookingUsecase(cancelParams),
    ).thenAnswer((_) async => Right(tCancelledBooking));

    await container.read(bookingViewModelProvider.notifier).getMyBookings();
    await container
        .read(bookingViewModelProvider.notifier)
        .getBookingByRef('ND-ABC123');
    await container
        .read(bookingViewModelProvider.notifier)
        .cancelBooking('b1', reason: 'Changed plan');

    final state = container.read(bookingViewModelProvider);
    expect(state.status, BookingStatus.cancelled);
    expect(state.myBookings.first.status, 'cancelled');
    expect(state.bookingDetail?.booking.status, 'cancelled');
  });
}

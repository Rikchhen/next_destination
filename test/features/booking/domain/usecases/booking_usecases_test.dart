import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/features/booking/domain/entity/booking_detail_entity.dart';
import 'package:next_destination/features/booking/domain/entity/booking_entity.dart';
import 'package:next_destination/features/booking/domain/entity/passenger_entity.dart';
import 'package:next_destination/features/booking/domain/entity/ticket_entity.dart';
import 'package:next_destination/features/booking/domain/repository/booking_repository.dart';
import 'package:next_destination/features/booking/domain/usecases/get_booking_by_ref_usecase.dart';
import 'package:next_destination/features/booking/domain/usecases/get_my_bookings_usecase.dart';

class MockBookingRepository extends Mock implements IBookingRepository {}

void main() {
  late MockBookingRepository repository;
  late GetMyBookingsUsecase getMyBookingsUsecase;
  late GetBookingByRefUsecase getBookingByRefUsecase;

  final tPassengers = const [
    PassengerEntity(
      fullName: 'Ram Bahadur',
      age: 27,
      gender: 'male',
      seatNumber: 'A1',
    ),
  ];

  final tBooking = BookingEntity(
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
    repository = MockBookingRepository();
    getMyBookingsUsecase = GetMyBookingsUsecase(bookingRepository: repository);
    getBookingByRefUsecase = GetBookingByRefUsecase(bookingRepository: repository);
  });

  group('GetMyBookingsUsecase', () {
    test('returns bookings list when repository responds with success', () async {
      const params = GetMyBookingsUsecaseParams(page: 1, limit: 10);
      when(
        () => repository.getMyBookings(params),
      ).thenAnswer((_) async => Right([tBooking]));

      final result = await getMyBookingsUsecase(params);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right but got Left'),
        (bookings) {
          expect(bookings.length, 1);
          expect(bookings.first, tBooking);
        },
      );
    });

    test('returns failure when repository returns failure', () async {
      const params = GetMyBookingsUsecaseParams(page: 2, limit: 5);
      const failure = ApiFailure(message: 'Unauthorized', statusCode: 401);
      when(
        () => repository.getMyBookings(params),
      ).thenAnswer((_) async => const Left(failure));

      final result = await getMyBookingsUsecase(params);

      expect(result, const Left<Failure, List<BookingEntity>>(failure));
    });

    test('forwards exact pagination params to repository once', () async {
      const params = GetMyBookingsUsecaseParams(page: 3, limit: 20);
      when(
        () => repository.getMyBookings(params),
      ).thenAnswer((_) async => Right([tBooking]));

      await getMyBookingsUsecase(params);

      verify(
        () => repository.getMyBookings(const GetMyBookingsUsecaseParams(page: 3, limit: 20)),
      ).called(1);
      verifyNoMoreInteractions(repository);
    });
  });

  group('GetBookingByRefUsecase', () {
    test('returns booking detail for valid booking reference', () async {
      when(
        () => repository.getBookingByRef('ND-ABC123'),
      ).thenAnswer((_) async => Right(tDetail));

      final result = await getBookingByRefUsecase('ND-ABC123');

      expect(result, Right<Failure, BookingDetailEntity>(tDetail));
    });

    test('returns failure for invalid booking reference', () async {
      const failure = ApiFailure(message: 'Booking not found', statusCode: 404);
      when(
        () => repository.getBookingByRef('ND-INVALID'),
      ).thenAnswer((_) async => const Left(failure));

      final result = await getBookingByRefUsecase('ND-INVALID');

      expect(result, const Left<Failure, BookingDetailEntity>(failure));
      verify(() => repository.getBookingByRef('ND-INVALID')).called(1);
      verifyNoMoreInteractions(repository);
    });
  });
}

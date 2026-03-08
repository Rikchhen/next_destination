import 'package:dartz/dartz.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/features/booking/domain/entity/booking_detail_entity.dart';
import 'package:next_destination/features/booking/domain/entity/booking_entity.dart';
import 'package:next_destination/features/booking/domain/entity/passenger_entity.dart';
import 'package:next_destination/features/booking/domain/usecases/cancel_booking_usecase.dart';
import 'package:next_destination/features/booking/domain/usecases/get_my_bookings_usecase.dart';

abstract interface class IBookingRepository {
  Future<Either<Failure, BookingDetailEntity>> createBooking({
    required String trip,
    required List<PassengerEntity> passengers,
    required String contactEmail,
    required String contactPhone,
  });

  Future<Either<Failure, BookingDetailEntity>> getBookingById(String bookingId);

  Future<Either<Failure, BookingDetailEntity>> getBookingByRef(String bookingRef);

  Future<Either<Failure, List<BookingEntity>>> getMyBookings(
    GetMyBookingsUsecaseParams params,
  );

  Future<Either<Failure, BookingEntity>> cancelBooking(
    CancelBookingUsecaseParams params,
  );
}

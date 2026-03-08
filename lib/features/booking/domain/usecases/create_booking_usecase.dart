import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/core/usecases/app_usecase.dart';
import 'package:next_destination/features/booking/data/repository/booking_repository.dart';
import 'package:next_destination/features/booking/domain/entity/booking_detail_entity.dart';
import 'package:next_destination/features/booking/domain/entity/passenger_entity.dart';
import 'package:next_destination/features/booking/domain/repository/booking_repository.dart';

class CreateBookingUsecaseParams extends Equatable {
  final String trip;
  final List<PassengerEntity> passengers;
  final String contactEmail;
  final String contactPhone;

  const CreateBookingUsecaseParams({
    required this.trip,
    required this.passengers,
    required this.contactEmail,
    required this.contactPhone,
  });

  @override
  List<Object?> get props => [trip, passengers, contactEmail, contactPhone];
}

final createBookingUsecaseProvider = Provider<CreateBookingUsecase>((ref) {
  return CreateBookingUsecase(bookingRepository: ref.read(bookingRepositoryProvider));
});

class CreateBookingUsecase
    implements UsecaseWithParams<BookingDetailEntity, CreateBookingUsecaseParams> {
  final IBookingRepository _bookingRepository;

  CreateBookingUsecase({required IBookingRepository bookingRepository})
    : _bookingRepository = bookingRepository;

  @override
  Future<Either<Failure, BookingDetailEntity>> call(
    CreateBookingUsecaseParams params,
  ) {
    return _bookingRepository.createBooking(
      trip: params.trip,
      passengers: params.passengers,
      contactEmail: params.contactEmail,
      contactPhone: params.contactPhone,
    );
  }
}

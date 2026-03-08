import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/core/usecases/app_usecase.dart';
import 'package:next_destination/features/booking/data/repository/booking_repository.dart';
import 'package:next_destination/features/booking/domain/entity/booking_entity.dart';
import 'package:next_destination/features/booking/domain/repository/booking_repository.dart';

class CancelBookingUsecaseParams extends Equatable {
  final String bookingId;
  final String? reason;

  const CancelBookingUsecaseParams({required this.bookingId, this.reason});

  @override
  List<Object?> get props => [bookingId, reason];
}

final cancelBookingUsecaseProvider = Provider<CancelBookingUsecase>((ref) {
  return CancelBookingUsecase(bookingRepository: ref.read(bookingRepositoryProvider));
});

class CancelBookingUsecase
    implements UsecaseWithParams<BookingEntity, CancelBookingUsecaseParams> {
  final IBookingRepository _bookingRepository;

  CancelBookingUsecase({required IBookingRepository bookingRepository})
    : _bookingRepository = bookingRepository;

  @override
  Future<Either<Failure, BookingEntity>> call(CancelBookingUsecaseParams params) {
    return _bookingRepository.cancelBooking(params);
  }
}

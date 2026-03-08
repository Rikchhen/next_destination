import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/core/usecases/app_usecase.dart';
import 'package:next_destination/features/booking/data/repository/booking_repository.dart';
import 'package:next_destination/features/booking/domain/entity/booking_entity.dart';
import 'package:next_destination/features/booking/domain/repository/booking_repository.dart';

class GetMyBookingsUsecaseParams extends Equatable {
  final int page;
  final int limit;

  const GetMyBookingsUsecaseParams({this.page = 1, this.limit = 10});

  @override
  List<Object?> get props => [page, limit];
}

final getMyBookingsUsecaseProvider = Provider<GetMyBookingsUsecase>((ref) {
  return GetMyBookingsUsecase(bookingRepository: ref.read(bookingRepositoryProvider));
});

class GetMyBookingsUsecase
    implements UsecaseWithParams<List<BookingEntity>, GetMyBookingsUsecaseParams> {
  final IBookingRepository _bookingRepository;

  GetMyBookingsUsecase({required IBookingRepository bookingRepository})
    : _bookingRepository = bookingRepository;

  @override
  Future<Either<Failure, List<BookingEntity>>> call(
    GetMyBookingsUsecaseParams params,
  ) {
    return _bookingRepository.getMyBookings(params);
  }
}

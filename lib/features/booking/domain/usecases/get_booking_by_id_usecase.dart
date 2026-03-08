import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/core/usecases/app_usecase.dart';
import 'package:next_destination/features/booking/data/repository/booking_repository.dart';
import 'package:next_destination/features/booking/domain/entity/booking_detail_entity.dart';
import 'package:next_destination/features/booking/domain/repository/booking_repository.dart';

final getBookingByIdUsecaseProvider = Provider<GetBookingByIdUsecase>((ref) {
  return GetBookingByIdUsecase(bookingRepository: ref.read(bookingRepositoryProvider));
});

class GetBookingByIdUsecase
    implements UsecaseWithParams<BookingDetailEntity, String> {
  final IBookingRepository _bookingRepository;

  GetBookingByIdUsecase({required IBookingRepository bookingRepository})
    : _bookingRepository = bookingRepository;

  @override
  Future<Either<Failure, BookingDetailEntity>> call(String params) {
    return _bookingRepository.getBookingById(params);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/features/booking/domain/entity/booking_detail_entity.dart';
import 'package:next_destination/features/booking/domain/entity/passenger_entity.dart';
import 'package:next_destination/features/booking/domain/usecases/cancel_booking_usecase.dart';
import 'package:next_destination/features/booking/domain/usecases/create_booking_usecase.dart';
import 'package:next_destination/features/booking/domain/usecases/get_booking_by_id_usecase.dart';
import 'package:next_destination/features/booking/domain/usecases/get_booking_by_ref_usecase.dart';
import 'package:next_destination/features/booking/domain/usecases/get_my_bookings_usecase.dart';
import 'package:next_destination/features/booking/presentation/state/booking_state.dart';

final bookingViewModelProvider = NotifierProvider<BookingViewModel, BookingState>(
  () => BookingViewModel(),
);

class BookingViewModel extends Notifier<BookingState> {
  late final CreateBookingUsecase _createBookingUsecase;
  late final GetBookingByIdUsecase _getBookingByIdUsecase;
  late final GetBookingByRefUsecase _getBookingByRefUsecase;
  late final GetMyBookingsUsecase _getMyBookingsUsecase;
  late final CancelBookingUsecase _cancelBookingUsecase;

  @override
  BookingState build() {
    _createBookingUsecase = ref.read(createBookingUsecaseProvider);
    _getBookingByIdUsecase = ref.read(getBookingByIdUsecaseProvider);
    _getBookingByRefUsecase = ref.read(getBookingByRefUsecaseProvider);
    _getMyBookingsUsecase = ref.read(getMyBookingsUsecaseProvider);
    _cancelBookingUsecase = ref.read(cancelBookingUsecaseProvider);

    return const BookingState();
  }

  Future<void> createBooking({
    required String trip,
    required List<PassengerBookingInput> passengers,
    required String contactEmail,
    required String contactPhone,
  }) async {
    state = state.copyWith(status: BookingStatus.loading);

    final passengerEntities = passengers
        .map(
          (p) => PassengerEntity(
            fullName: p.fullName,
            age: p.age,
            gender: p.gender,
            seatNumber: p.seatNumber,
          ),
        )
        .toList();

    final params = CreateBookingUsecaseParams(
      trip: trip,
      passengers: passengerEntities,
      contactEmail: contactEmail,
      contactPhone: contactPhone,
    );

    final result = await _createBookingUsecase.call(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: BookingStatus.error,
          errorMessage: failure.message,
        );
      },
      (detail) {
        state = state.copyWith(status: BookingStatus.created, bookingDetail: detail);
      },
    );
  }

  Future<void> getBookingById(String bookingId) async {
    state = state.copyWith(status: BookingStatus.loading);

    final result = await _getBookingByIdUsecase.call(bookingId);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: BookingStatus.error,
          errorMessage: failure.message,
        );
      },
      (detail) {
        state = state.copyWith(status: BookingStatus.fetchedDetail, bookingDetail: detail);
      },
    );
  }

  Future<void> getBookingByRef(String bookingRef) async {
    state = state.copyWith(status: BookingStatus.loading);

    final result = await _getBookingByRefUsecase.call(bookingRef);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: BookingStatus.error,
          errorMessage: failure.message,
        );
      },
      (detail) {
        state = state.copyWith(status: BookingStatus.fetchedDetail, bookingDetail: detail);
      },
    );
  }

  Future<void> getMyBookings({int page = 1, int limit = 10}) async {
    state = state.copyWith(status: BookingStatus.loading);

    final result = await _getMyBookingsUsecase.call(
      GetMyBookingsUsecaseParams(page: page, limit: limit),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: BookingStatus.error,
          errorMessage: failure.message,
        );
      },
      (bookings) {
        state = state.copyWith(status: BookingStatus.fetchedMine, myBookings: bookings);
      },
    );
  }

  Future<void> cancelBooking(String bookingId, {String? reason}) async {
    state = state.copyWith(status: BookingStatus.loading);

    final params = CancelBookingUsecaseParams(bookingId: bookingId, reason: reason);
    final result = await _cancelBookingUsecase.call(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: BookingStatus.error,
          errorMessage: failure.message,
        );
      },
      (booking) {
        final updatedList = state.myBookings
            .map((e) => e.bookingId == booking.bookingId ? booking : e)
            .toList();

        final currentDetail = state.bookingDetail;
        final updatedDetail = currentDetail != null &&
                currentDetail.booking.bookingId == booking.bookingId
            ? BookingDetailEntity(booking: booking, tickets: currentDetail.tickets)
            : currentDetail;

        state = state.copyWith(
          status: BookingStatus.cancelled,
          myBookings: updatedList,
          bookingDetail: updatedDetail,
        );
      },
    );
  }

  void removeCancelledBookingFromList(String bookingId) {
    final filtered = state.myBookings
        .where((booking) => booking.bookingId != bookingId)
        .toList();

    state = state.copyWith(status: BookingStatus.fetchedMine, myBookings: filtered);
  }

  int removeAllCancelledBookingsFromList() {
    final before = state.myBookings.length;
    final filtered = state.myBookings
        .where((booking) => booking.status != 'cancelled')
        .toList();
    final removed = before - filtered.length;

    state = state.copyWith(status: BookingStatus.fetchedMine, myBookings: filtered);
    return removed;
  }
}

class PassengerBookingInput {
  final String fullName;
  final int age;
  final String gender;
  final String seatNumber;

  const PassengerBookingInput({
    required this.fullName,
    required this.age,
    required this.gender,
    required this.seatNumber,
  });
}

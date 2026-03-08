import 'package:equatable/equatable.dart';
import 'package:next_destination/features/booking/domain/entity/booking_detail_entity.dart';
import 'package:next_destination/features/booking/domain/entity/booking_entity.dart';

enum BookingStatus {
  initial,
  loading,
  created,
  fetchedMine,
  fetchedDetail,
  cancelled,
  error,
}

class BookingState extends Equatable {
  final BookingStatus status;
  final List<BookingEntity> myBookings;
  final BookingDetailEntity? bookingDetail;
  final String? errorMessage;

  const BookingState({
    this.status = BookingStatus.initial,
    this.myBookings = const [],
    this.bookingDetail,
    this.errorMessage,
  });

  BookingState copyWith({
    BookingStatus? status,
    List<BookingEntity>? myBookings,
    BookingDetailEntity? bookingDetail,
    String? errorMessage,
  }) {
    return BookingState(
      status: status ?? this.status,
      myBookings: myBookings ?? this.myBookings,
      bookingDetail: bookingDetail ?? this.bookingDetail,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, myBookings, bookingDetail, errorMessage];
}

import 'package:next_destination/features/booking/data/model/booking_api_model.dart';
import 'package:next_destination/features/booking/data/model/booking_detail_api_model.dart';

abstract interface class IBookingRemoteDatasource {
  Future<BookingDetailApiModel> createBooking({
    required String trip,
    required List<Map<String, dynamic>> passengers,
    required String contactEmail,
    required String contactPhone,
  });

  Future<BookingDetailApiModel> getBookingById(String bookingId);

  Future<BookingDetailApiModel> getBookingByRef(String bookingRef);

  Future<List<BookingApiModel>> getMyBookings({int page = 1, int limit = 10});

  Future<BookingApiModel> cancelBooking(String bookingId, {String? reason});
}

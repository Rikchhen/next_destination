import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/api/api_client.dart';
import 'package:next_destination/core/api/api_endpoint.dart';
import 'package:next_destination/core/services/storage/token_service.dart';
import 'package:next_destination/features/booking/data/datasource/booking_datasource.dart';
import 'package:next_destination/features/booking/data/model/booking_api_model.dart';
import 'package:next_destination/features/booking/data/model/booking_detail_api_model.dart';

final bookingRemoteDatasourceProvider = Provider<IBookingRemoteDatasource>((
  ref,
) {
  return BookingRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class BookingRemoteDatasource implements IBookingRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  BookingRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  @override
  Future<BookingDetailApiModel> createBooking({
    required String trip,
    required List<Map<String, dynamic>> passengers,
    required String contactEmail,
    required String contactPhone,
  }) async {
    final token = _tokenService.getToken();

    final response = await _apiClient.post(
      ApiEndpoints.bookingCreate,
      data: {
        'trip': trip,
        'passengers': passengers,
        'contactEmail': contactEmail,
        'contactPhone': contactPhone,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return BookingDetailApiModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<BookingDetailApiModel> getBookingById(String bookingId) async {
    final token = _tokenService.getToken();

    final response = await _apiClient.get(
      ApiEndpoints.bookingById(bookingId),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return BookingDetailApiModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<BookingDetailApiModel> getBookingByRef(String bookingRef) async {
    final token = _tokenService.getToken();

    final response = await _apiClient.get(
      ApiEndpoints.bookingByRef(bookingRef),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return BookingDetailApiModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<BookingApiModel>> getMyBookings({
    int page = 1,
    int limit = 10,
  }) async {
    final token = _tokenService.getToken();

    final response = await _apiClient.get(
      ApiEndpoints.bookingMine,
      queryParameters: {'page': page, 'limit': limit},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final data = response.data['bookings'] as List<dynamic>;
    return data
        .map((e) => BookingApiModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<BookingApiModel> cancelBooking(String bookingId, {String? reason}) async {
    final token = _tokenService.getToken();

    final response = await _apiClient.patch(
      ApiEndpoints.bookingCancelById(bookingId),
      data: {
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final data = response.data['booking'] as Map<String, dynamic>;
    return BookingApiModel.fromJson(data);
  }
}

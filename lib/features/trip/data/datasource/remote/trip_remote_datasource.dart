import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/api/api_client.dart';
import 'package:next_destination/core/api/api_endpoint.dart';
import 'package:next_destination/core/services/storage/token_service.dart';
import 'package:next_destination/features/trip/data/datasource/trip_datasource.dart';
import 'package:next_destination/features/trip/data/model/trip_api_model.dart';
import 'package:next_destination/features/trip/data/model/trip_search_result_api_model.dart';

final tripRemoteDatasourceProvider = Provider<ITripRemoteDatasource>((ref) {
  return TripRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class TripRemoteDatasource implements ITripRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  TripRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  @override
  Future<TripApiModel> createTrip(TripApiModel model) async {
    final token = _tokenService.getToken();

    final response = await _apiClient.post(
      ApiEndpoints.tripCreate,
      data: model.toCreateJson(),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final data = response.data['trip'] as Map<String, dynamic>;
    return TripApiModel.fromJson(data);
  }

  @override
  Future<TripApiModel> getTripById(String tripId) async {
    final response = await _apiClient.get(ApiEndpoints.tripById(tripId));
    final data = response.data['trip'] as Map<String, dynamic>;
    return TripApiModel.fromJson(data);
  }

  @override
  Future<List<TripApiModel>> getTripsByBusiness({
    int page = 1,
    int limit = 10,
  }) async {
    final token = _tokenService.getToken();

    final response = await _apiClient.get(
      ApiEndpoints.tripBusinessMine,
      queryParameters: {'page': page, 'limit': limit},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final list = response.data['trips'] as List<dynamic>;
    return list
        .map((e) => TripApiModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<TripSearchResultApiModel> searchTrips({
    String? type,
    String? from,
    String? to,
    String? status,
    DateTime? departureFrom,
    DateTime? departureTo,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.tripSearch,
      queryParameters: {
        if (type != null && type.isNotEmpty) 'type': type,
        if (from != null && from.trim().isNotEmpty) 'from': from.trim(),
        if (to != null && to.trim().isNotEmpty) 'to': to.trim(),
        if (status != null && status.isNotEmpty) 'status': status,
        if (departureFrom != null)
          'departureFrom': departureFrom.toIso8601String(),
        if (departureTo != null) 'departureTo': departureTo.toIso8601String(),
        'page': page,
        'limit': limit,
      },
    );

    return TripSearchResultApiModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<TripApiModel> updateTrip(String tripId, TripApiModel model) async {
    final token = _tokenService.getToken();

    final response = await _apiClient.patch(
      ApiEndpoints.tripEditById(tripId),
      data: model.toEditJson(),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final data = response.data['trip'] as Map<String, dynamic>;
    return TripApiModel.fromJson(data);
  }

  @override
  Future<bool> deleteTrip(String tripId) async {
    final token = _tokenService.getToken();

    final response = await _apiClient.delete(
      ApiEndpoints.tripDeleteById(tripId),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data['success'] == true;
  }
}

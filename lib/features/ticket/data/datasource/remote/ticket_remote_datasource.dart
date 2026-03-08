import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/api/api_client.dart';
import 'package:next_destination/core/api/api_endpoint.dart';
import 'package:next_destination/core/services/storage/token_service.dart';
import 'package:next_destination/features/ticket/data/datasource/ticket_datasource.dart';
import 'package:next_destination/features/ticket/data/model/ticket_api_model.dart';

final ticketRemoteDatasourceProvider = Provider<ITicketRemoteDatasource>((ref) {
  return TicketRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class TicketRemoteDatasource implements ITicketRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  TicketRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  @override
  Future<TicketApiModel> getTicketById(String ticketId) async {
    final token = _tokenService.getToken();

    final response = await _apiClient.get(
      ApiEndpoints.ticketById(ticketId),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final data = response.data['ticket'] as Map<String, dynamic>;
    return TicketApiModel.fromJson(data);
  }

  @override
  Future<List<TicketApiModel>> getTicketsByBooking(String bookingId) async {
    final token = _tokenService.getToken();

    final response = await _apiClient.get(
      ApiEndpoints.ticketsByBooking(bookingId),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final list = response.data['tickets'] as List<dynamic>;
    return list
        .map((e) => TicketApiModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<TicketApiModel> scanTicket(String qrToken) async {
    final token = _tokenService.getToken();

    final response = await _apiClient.post(
      ApiEndpoints.ticketScan,
      data: {'qrToken': qrToken},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final data = response.data['ticket'] as Map<String, dynamic>;
    return TicketApiModel.fromJson(data);
  }

  @override
  Future<TicketApiModel> voidTicket(String ticketId, {String? reason}) async {
    final token = _tokenService.getToken();

    final response = await _apiClient.patch(
      ApiEndpoints.ticketVoidById(ticketId),
      data: {if (reason != null && reason.trim().isNotEmpty) 'reason': reason},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final data = response.data['ticket'] as Map<String, dynamic>;
    return TicketApiModel.fromJson(data);
  }
}

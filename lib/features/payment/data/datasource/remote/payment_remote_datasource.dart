import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/api/api_client.dart';
import 'package:next_destination/core/api/api_endpoint.dart';
import 'package:next_destination/core/services/storage/token_service.dart';
import 'package:next_destination/features/payment/data/datasource/payment_datasource.dart';
import 'package:next_destination/features/payment/data/model/payment_api_model.dart';
import 'package:next_destination/features/payment/data/model/payment_initiation_api_model.dart';

final paymentRemoteDatasourceProvider = Provider<IPaymentRemoteDatasource>((ref) {
  return PaymentRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class PaymentRemoteDatasource implements IPaymentRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  PaymentRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  @override
  Future<PaymentInitiationApiModel> initiateKhaltiPayment({
    required String bookingId,
    required String returnUrl,
  }) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.post(
      ApiEndpoints.paymentKhaltiInitiate,
      data: {'bookingId': bookingId, 'returnUrl': returnUrl},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return PaymentInitiationApiModel.fromJson(data);
  }

  @override
  Future<PaymentApiModel> verifyKhaltiPayment({
    required String pidx,
    required String bookingId,
  }) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.post(
      ApiEndpoints.paymentKhaltiVerify,
      data: {'pidx': pidx, 'bookingId': bookingId},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final wrapper = response.data['data'] as Map<String, dynamic>;
    final paymentMap = (wrapper['payment'] ??
            (wrapper['data'] is Map<String, dynamic>
                ? (wrapper['data'] as Map<String, dynamic>)['payment']
                : null))
        as Map<String, dynamic>?;

    return PaymentApiModel.fromJson(paymentMap ?? {});
  }

  @override
  Future<PaymentApiModel?> getPaymentByBookingId(String bookingId) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.get(
      ApiEndpoints.paymentByBooking(bookingId),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final data = response.data['data'] as Map<String, dynamic>?;
    if (data == null) return null;
    return PaymentApiModel.fromJson(data);
  }
}


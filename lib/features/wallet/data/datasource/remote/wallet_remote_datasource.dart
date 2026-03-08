import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/api/api_client.dart';
import 'package:next_destination/core/api/api_endpoint.dart';
import 'package:next_destination/core/services/storage/token_service.dart';
import 'package:next_destination/features/wallet/data/datasource/wallet_datasource.dart';
import 'package:next_destination/features/wallet/data/model/wallet_balance_api_model.dart';
import 'package:next_destination/features/wallet/data/model/wallet_transaction_page_api_model.dart';

final walletRemoteDatasourceProvider = Provider<IWalletRemoteDatasource>((ref) {
  return WalletRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class WalletRemoteDatasource implements IWalletRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  WalletRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  @override
  Future<WalletBalanceApiModel> getBusinessWalletBalance() async {
    final token = _tokenService.getToken();
    final response = await _apiClient.get(
      ApiEndpoints.businessWalletBalance,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    return WalletBalanceApiModel.fromJson(data);
  }

  @override
  Future<WalletTransactionPageApiModel> getBusinessTransactions({
    int page = 1,
    int limit = 10,
  }) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.get(
      ApiEndpoints.businessWalletTransactions,
      queryParameters: {'page': page, 'limit': limit},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return WalletTransactionPageApiModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}


import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/core/services/connectivity/network_info.dart';
import 'package:next_destination/features/wallet/data/datasource/remote/wallet_remote_datasource.dart';
import 'package:next_destination/features/wallet/data/datasource/wallet_datasource.dart';
import 'package:next_destination/features/wallet/domain/entity/wallet_balance_entity.dart';
import 'package:next_destination/features/wallet/domain/entity/wallet_transaction_page_entity.dart';
import 'package:next_destination/features/wallet/domain/repository/wallet_repository.dart';

final walletRepositoryProvider = Provider<IWalletRepository>((ref) {
  return WalletRepository(
    remoteDatasource: ref.read(walletRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class WalletRepository implements IWalletRepository {
  final IWalletRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;

  WalletRepository({
    required IWalletRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
  }) : _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, WalletBalanceEntity>> getBusinessWalletBalance() async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.getBusinessWalletBalance();
        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data['message'] ?? 'Failed to fetch wallet balance',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'Internet Required To Fetch Wallet'));
    }
  }

  @override
  Future<Either<Failure, WalletTransactionPageEntity>> getBusinessTransactions({
    int page = 1,
    int limit = 10,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.getBusinessTransactions(
          page: page,
          limit: limit,
        );
        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data['message'] ??
                'Failed to fetch wallet transactions',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(
        NetworkFailure(message: 'Internet Required To Fetch Transactions'),
      );
    }
  }
}

